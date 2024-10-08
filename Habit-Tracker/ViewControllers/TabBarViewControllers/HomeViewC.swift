//
//  ViewController.swift
//  Habit-Tracker
//
//  Created by Zohair on 01/09/2024.
//

import UIKit
import CoreData

class HomeViewC: UIViewController {
    
    // MARK: - Variables and Constants
    
    var habitsInCollectionView: [Habits] = []
    var allHabits: [Habits] = []
    var allTodayHabits: [Habits] = []
    var allPreviousHabits: [Habits] = []
    
    var dataByDateKey: Bool = false
    var isFutureDateTapped: Bool = false
    var userTappedUndoBtn: Bool = false
    var isSaveCountAgain: Bool = true
    
    var navTimingLabel = UILabel()
    var rainBowIcon: UIButton!
    var undoBtn: UIButton?
    var iconViews: [UIButton] = []
    
    var editView: CellOptionsView!
    var editCellOverlayView: UIView!
    var editCellSnapShot: UIView!
    var userSelectedCell: IndexPath?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - @IBOutlet Variables
    
    @IBOutlet var timingLabel: UILabel!
    @IBOutlet var iconsStackView: UIStackView!
    @IBOutlet var habitsCollectionView: UICollectionView!

    @IBOutlet var emptySateLabel: UILabel!
    @IBOutlet var emptyTimeHabits: UILabel!
    
    
    // MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupIconsInView()
        setupViewController()
        addObserversToViewC()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // when viewWillApeear the selected icon is rainBow
        timingLabel.text = "AllDay"
        navTimingLabel.text = "ALL DAY"
        for icon in iconViews{
            if icon == rainBowIcon{continue}
            icon.tintColor = .secondaryLabel.withAlphaComponent(0.2)
        }
        
        fetchHabit()
        tabBarController?.tabBar.isHidden = false
    }
    
    
    // MARK: - init() and deinit() Notification Observers
    
    func addObserversToViewC(){
        NotificationCenter.default.addObserver(self, selector: #selector(selectedDateTapped), name:  NSNotification.Name("dateChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeFirstResponder), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResign), name: UIApplication.willResignActiveNotification, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(FutureDateTapped), name: NSNotification.Name("FutureDateTapped"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSelectedOption), name: NSNotification.Name("OptionTags"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userEditedTheHabit), name: NSNotification.Name("putViewAgain"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(previousDateTapped), name: NSNotification.Name("PreviousDateTapped"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSwipedCell), name: NSNotification.Name("userSwiped"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchHabit), name: NSNotification.Name("fetchHabitsAfterReset"), object: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("dateChanged"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("FutureDateTapped"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("fetchHabitsAfterReset"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("PreviousDateTapped"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("OptionTags"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("userSwiped"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("putViewAgain"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSCalendarDayChanged, object: nil)
    }
    
    
    // MARK: - Added Functions
    
    func setupViewController(){
        CodeHelper.configureNavLabel(label: navTimingLabel, view: view)
        habitsCollectionView.backgroundColor = .clear
        title = "Today"
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        habitsCollectionView.addGestureRecognizer(longPress)
        UserDefaults.standard.removeObject(forKey: "SelectedDate")
    }
    
    
    
    func EmptySateActions(habitList: [Habits]){
        if habitList.isEmpty{
            emptySateLabel.text = "NO HABITS \nClick + button and add one to achieve that habit 🥳."
            
            DispatchQueue.main.async {
                // hide views when no habits in collectionView
                self.emptySateLabel.isHidden = false
                self.timingLabel.isHidden = true
                self.iconsStackView.isHidden = true
                self.navTimingLabel.isHidden = true
                self.emptySateLabel.backgroundColor = .clear
            }
        }else{
            // appear again when user add habit
            DispatchQueue.main.async {
                self.emptySateLabel.isHidden = true
                self.timingLabel.isHidden = false
                self.rainBowIcon.tintColor = .label
                self.iconsStackView.isHidden = false
                self.navTimingLabel.isHidden = false
            }
        }
    }
    
    
    func showEmptySateLabelForTimeHabits(list: [Habits], time: String){
        if list.isEmpty {
            emptyTimeHabits.isHidden = false
            emptyTimeHabits.text = "No \(time) habits..."
        }else{
            emptyTimeHabits.isHidden = true
        }
    }
    
    
    func beginHabitInCollView(for arrayNum: Int){
        if arrayNum == 0 {
            habitsInCollectionView = allTodayHabits.filter {$0.habitTime == "ALL DAY"}
        }
        else if arrayNum == 1 {
            habitsInCollectionView = allPreviousHabits.filter {$0.habitTime == "ALL DAY"}
        }
        else {
            return
        }
        
        reloadCollectionView()
    }
    
    
    func deleteHabit(for indexPath: IndexPath){
        
        let Habit = habitsInCollectionView[indexPath.item]
        var habitsToDelete: [Habits] = []
        
        let habits = try! context.fetch(Habits.fetchRequest())
        
        habitsToDelete = habits.filter {$0.uuid == Habit.uuid}
        
        for habit in habitsToDelete {
            context.delete(habit)
        }
        
        try! context.save()
        fetchHabit()
        
    }
    
    func reloadCollectionView(){
        DispatchQueue.main.async {
            self.habitsCollectionView.reloadData()
        }
    }
    
    
    func changeIconColor(sender: UIButton){
        if sender.isTouchInside {
            sender.tintColor = .label
        }
        for icon in iconViews{
            if icon == sender{ continue }
            icon.tintColor = .secondaryLabel.withAlphaComponent(0.25)
        }
    }
    
    func setupIconsInView(){
        
        let frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        rainBowIcon = HTButton(background: UIColor(), frame: frame, SFSymbol: "rainbow", symbolSize: 24)
        let icon2 = HTButton(background: UIColor(), frame: frame, SFSymbol: "sun.horizon", symbolSize: 24)
        let icon3 = HTButton(background: UIColor(), frame: frame, SFSymbol: "sun.max", symbolSize: 24)
        let icon4 = HTButton(background: UIColor(), frame: frame, SFSymbol: "moon", symbolSize: 24)
        iconViews = [rainBowIcon, icon2, icon3, icon4]
        
        iconsStackView.axis = .horizontal
        iconsStackView.distribution = .fillEqually
        iconsStackView.alignment = .fill
        iconsStackView.spacing = 0
        
        for (icon) in iconViews{
            iconsStackView.addArrangedSubview(icon)
            icon.tintColor = .secondaryLabel.withAlphaComponent(0.5)
        }
        
        rainBowIcon.addTarget(self, action: #selector(icon1Tapped), for: .touchUpInside)
        icon2.addTarget(self, action: #selector(icon2Tapped), for: .touchUpInside)
        icon3.addTarget(self, action: #selector(icon3Tapped), for: .touchUpInside)
        icon4.addTarget(self, action: #selector(icon4Tapped), for: .touchUpInside)
    }
    
    
    func setupNavigation(){
        
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let leftFixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        leftFixedSpace.width = 25
        
        let rightFixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightFixedSpace.width = 25
        
        let Btn1 = HTButton(background: .gray.withAlphaComponent(0.1), frame: frame, SFSymbol: "gear", symbolSize: 20)
        let Btn2 = HTButton(background: .gray.withAlphaComponent(0.1), frame: frame, SFSymbol: "calendar", symbolSize: 20)
        Btn1.addTarget(self, action: #selector(settingsBtnTapped), for: .touchUpInside)
        Btn2.addTarget(self, action: #selector(calenderBtnTapped), for: .touchUpInside)
        
        let settingBtn = UIBarButtonItem(customView: Btn1)
        let calenderBtn = UIBarButtonItem(customView: Btn2)
        
        navigationItem.rightBarButtonItems = [rightFixedSpace, calenderBtn]
        navigationItem.leftBarButtonItems = [leftFixedSpace, settingBtn]
        
    }
    
    func saveCountOfAllTodayHabit(){
        
        guard !allTodayHabits.isEmpty else {
            print("AllTodayHabits list is empty!!")
            return
        }
        
        if isSaveCountAgain {
            var countList = [[String]]()
            countList.append([])
            countList.append([])
            
            for habit in allTodayHabits {
                countList[0].append(habit.habitCounter!)
                countList[1].append("\(habit.isDone)")
            }
            
            UserDefaults.standard.set(countList, forKey: "CountList")
            
            print("all today habit count list ", countList)
            
            isSaveCountAgain = false
        }
    }
    
    func resetCountOfAllTodayHabit(){
        guard !allTodayHabits.isEmpty else {
            print("AllTodayHabits list is empty!!")
            return
        }
        
        for habit in allTodayHabits {
            habit.habitCounter = "0"
            habit.isDone = 0
        }
        
        try! context.save()
        
        reloadCollectionView()
    }

    
    func saveNewDateHabitsInCoreData(forDate date: String){
        for habit in allTodayHabits {
            
            let saveHabit = Habits(context: context)
            
            saveHabit.habitCounter = habit.habitCounter
            saveHabit.date = date
            saveHabit.habitName = habit.habitName
            saveHabit.habitIcon = habit.habitIcon
            saveHabit.repsPerDay = habit.repsPerDay
            saveHabit.habitTime = habit.habitTime
            saveHabit.uuid = habit.uuid
            saveHabit.isDone = habit.isDone
            
            try! context.save()
        }
    }
    
    // MARK: - @Objc Functions
    
    @objc func appBecomeFirstResponder(){
        if let storedDate = UserDefaults.standard.object(forKey: "storedDate") as? Date {
            let currentDate = Date()
            let calendar = Calendar.current
            let previousDay = calendar.component(.day, from: storedDate)
            let currentDay = calendar.component(.day, from: currentDate)
            
            if currentDay > previousDay {
                let previousDate = CodeHelper.dateToStringConvert(date: storedDate)
                saveNewDateHabitsInCoreData(forDate: previousDate)
                resetCountOfAllTodayHabit()
                
                CodeHelper().scheduleDailyNotifications(context: context)
            }
        }
    }
    @objc func appWillResign(){
        UserDefaults.standard.set(Date(), forKey: "storedDate")
    }
    
    
    @objc func selectedDateTapped(_ notification: NSNotification){
        
        guard let date = notification.object as? String else { return }
        
        if date == CodeHelper.currentDate() {
            dataByDateKey = false
            isFutureDateTapped = false
            beginHabitInCollView(for: 0)
            title = "Today"
            if let counts = UserDefaults.standard.array(forKey: "CountList") as? [[String]] {
                for (index, habit) in allTodayHabits.enumerated() {
                    habit.habitCounter = counts[0][index]
                    habit.isDone = Int64(counts[1][index])!
                }
                try! context.save()
                reloadCollectionView()
                
                isSaveCountAgain = true
                UserDefaults.standard.removeObject(forKey: "CountList")
            }
            
        } else {
            
            let habits = try! context.fetch(Habits.fetchRequest())
            allPreviousHabits = habits.filter {$0.date == date}
            title = date.replacingOccurrences(of: ",", with: "")
            print("previous habiits", allPreviousHabits )
            
            if !allPreviousHabits.isEmpty{
                
                // when previous habit saved and code not goes to else block
                // then check if user add new habit it also appears and save in previous list
                for habit in allTodayHabits{
                    let contains = allPreviousHabits.contains {$0.uuid == habit.uuid}
                    if contains {
                        continue
                    }else{
                        let newHabit = Habits(context: context)
                        newHabit.date = date
                        newHabit.habitCounter = "0"
                        newHabit.isDone = 0
                        newHabit.habitTime = habit.habitTime
                        newHabit.habitName = habit.habitName
                        newHabit.repsPerDay = habit.repsPerDay
                        newHabit.habitIcon = habit.habitIcon
                        newHabit.uuid = habit.uuid
                        allPreviousHabits.append(newHabit)
                    }
                }
                try! context.save()
                
                allPreviousHabits.removeAll()
                let habitByNewDate = try! context.fetch(Habits.fetchRequest())
                allPreviousHabits = habitByNewDate.filter {$0.date == date}
                beginHabitInCollView(for: 1)
                dataByDateKey = true
            
            } else {
                
                saveCountOfAllTodayHabit()
                resetCountOfAllTodayHabit()
                saveNewDateHabitsInCoreData(forDate: date)
                
                let habitByNewDate = try! context.fetch(Habits.fetchRequest())
                allPreviousHabits = habitByNewDate.filter {$0.date == date}
                beginHabitInCollView(for: 1)
                dataByDateKey = true
            }
        }
    
        let selectedDate = CodeHelper.convertDateFormatWithCurrentYear(from: date)
        NotificationCenter.default.post(name: NSNotification.Name("DismissDatePicker"), object: selectedDate)
    }
    
    
    @objc func FutureDateTapped() {
        isFutureDateTapped = true
    }
    
    @objc func previousDateTapped(){
        isFutureDateTapped = false
    }
    
    @objc func userEditedTheHabit() {
        if editView != nil {
            dismissEditView()
            reloadCollectionView()
        }
    }
    
    @objc func undoBtnTapped(_ sender: UIButton){
        
        // perform minus action on cell
        CodeHelper().actionToHabitCount(
            for: IndexPath(row: sender.tag, section: 0),
            collectionView: habitsCollectionView,
            habitsArray: habitsInCollectionView,
            Context: context,
            action: .decreament,
            View: view
        )
        reloadCollectionView()
        
        // when user taps the button the button itself disappears and cell in its orignal position.
        if let undoBtn = undoBtn{
            undoBtn.removeFromSuperview()
            self.undoBtn = nil
            undoBtn.alpha = 0
        }
        guard let cell = habitsCollectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) else { return }
        UIView.animate(withDuration: 0.1, animations: {
            cell.transform = .identity
        })
    }
    
    @objc func userSwipedCell(_ notification: NSNotification){
        
        guard let object = notification.object as? [Any] else { return }
        // get the cell that user swiped with swipe direction
        guard let cell = object[0] as? UICollectionViewCell else { return }
        let direction = object[1] as? UISwipeGestureRecognizer.Direction
        let indexPath = habitsCollectionView.indexPath(for: cell)
        
        let xPosition = cell.frame.origin.x
        let yPosition = cell.frame.origin.y
        let image = UIImage(systemName: "clock.arrow.circlepath", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24))
        
        if undoBtn == nil {
            undoBtn = UIButton(frame: CGRect(x: xPosition, y: yPosition + 14, width: 60, height: 60))
            undoBtn!.backgroundColor = cell.backgroundColor
            undoBtn!.setImage(image, for: .normal)
            undoBtn!.tintColor = .systemMint
            undoBtn!.layer.cornerRadius = 12
            undoBtn!.alpha = 0
            undoBtn!.tag = indexPath!.row
            undoBtn!.addTarget(self, action: #selector(undoBtnTapped), for: .touchUpInside)
            habitsCollectionView.addSubview(undoBtn!)
        }
        
        // add button when user swipe to right
        if let undoBtn = undoBtn {
            if direction == .right{
                UIView.animate(withDuration: 0.3, animations: {
                    cell.transform = CGAffineTransform(translationX: 80, y: 0)
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    undoBtn.alpha = 1
                }
            }
            
            // remoove button when user swipe to left
            else if direction == .left{
                UIView.animate(withDuration: 0.3, animations: {
                    cell.transform = .identity
                    undoBtn.removeFromSuperview()
                    self.undoBtn = nil
                    undoBtn.alpha = 0
                })
            }
        }
    }
    
    
    @objc func fetchHabit() {
        let HabitList: [Habits] = try! context.fetch(Habits.fetchRequest())
        allHabits = HabitList
        if dataByDateKey == false {
            allTodayHabits = allHabits.filter {$0.date == nil}
            beginHabitInCollView(for: 0)
        }else{
            icon1Tapped(UIButton())
        }
        EmptySateActions(habitList: allTodayHabits)
    }
   
    @objc func settingsBtnTapped(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsViewC
        
        vc?.modalPresentationStyle = .overFullScreen
        vc?.modalTransitionStyle = .crossDissolve
        present(vc!, animated: true)
    }
    
    
    @objc func calenderBtnTapped(){
        
        let vc = DatePickerViewC()
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
    
    
    
    @objc func icon1Tapped(_ sender: UIButton){
        changeIconColor(sender: sender)
        timingLabel.text = HabitTimes.allDay
        navTimingLabel.text = HabitTimes.allDay.uppercased()
        
        if dataByDateKey {
            habitsInCollectionView = allPreviousHabits.filter {$0.habitTime == "ALL DAY"}
        } else {
            habitsInCollectionView = allTodayHabits.filter {$0.habitTime == "ALL DAY"}
        }
        showEmptySateLabelForTimeHabits(list: habitsInCollectionView, time: "allDay")
        
        reloadCollectionView()
    }
    
    @objc func icon2Tapped(_ sender: UIButton){
        changeIconColor(sender: sender)
        timingLabel.text = HabitTimes.morning
        navTimingLabel.text = HabitTimes.morning.uppercased()
        
        if dataByDateKey {
            habitsInCollectionView = allPreviousHabits.filter {$0.habitTime == "MORNING"}
        } else {
            habitsInCollectionView = allTodayHabits.filter {$0.habitTime == "MORNING"}
        }
        showEmptySateLabelForTimeHabits(list: habitsInCollectionView, time: "morning")
        
        reloadCollectionView()
    }
    
    @objc func icon3Tapped(_ sender: UIButton){
        changeIconColor(sender: sender)
        timingLabel.text = HabitTimes.afterNoon
        navTimingLabel.text = HabitTimes.afterNoon.uppercased()
        
        if dataByDateKey {
            habitsInCollectionView = allPreviousHabits.filter {$0.habitTime == "AFTERNOON"}
        } else {
            habitsInCollectionView = allTodayHabits.filter {$0.habitTime == "AFTERNOON"}
        }
        showEmptySateLabelForTimeHabits(list: habitsInCollectionView, time: "afternoon")
        
        reloadCollectionView()
    }
    
    @objc func icon4Tapped(_ sender: UIButton){
        changeIconColor(sender: sender)
        timingLabel.text = HabitTimes.evening
        navTimingLabel.text = HabitTimes.evening.uppercased()
        
        if dataByDateKey {
            habitsInCollectionView = allPreviousHabits.filter {$0.habitTime == "EVENING"}
        } else {
            habitsInCollectionView = allTodayHabits.filter {$0.habitTime == "EVENING"}
        }
        showEmptySateLabelForTimeHabits(list: habitsInCollectionView, time: "evening")
        
        reloadCollectionView()
    }
    
    
    @objc func userSelectedOption(notification: NSNotification){
        guard let option = notification.object as? Int else { return }
        guard let index = userSelectedCell else { return }
        
        switch option {
        case 1:
            let VC = storyboard?.instantiateViewController(withIdentifier: "EditScreen") as? EditScreenViewC
            
            VC?.editingMode = true
            VC?.habitToEdit = habitsInCollectionView[index.item]
            VC?.modalPresentationStyle = .overFullScreen
            present(VC!, animated: true)
            userSelectedCell = nil
            
        case 2:
            let ac = UIAlertController(title: "DELETE HABIT", message: "Are you sure you want to delete this habit?\n\nTHIS ACTION CANNOT BE UNDONE. ", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Cancel", style: .default))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteHabit(for: index)
                self.userSelectedCell = nil
                self.dismissEditView()
            }))
            
            present(ac, animated: true)
            
            if let backgroundView = ac.view.subviews.first?.subviews.first?.subviews.first {
                backgroundView.backgroundColor = Colors.color2
            }
            
        case 3:
            habitsInCollectionView.sort {
                $0.habitName!.lowercased() < $1.habitName!.lowercased()
            }
            reloadCollectionView()
            userSelectedCell = nil
            dismissEditView()
        default:
            print("no")
        }
    }
    
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            let point = gesture.location(in: habitsCollectionView)
            // Get the indexPath of the cell that was long-pressed
            if let indexPath = habitsCollectionView.indexPathForItem(at: point) {
                if let cell = habitsCollectionView.cellForItem(at: indexPath) {
                    showCellOptionsView(cell: cell)
                }
            
                if userSelectedCell == nil {
                    userSelectedCell = indexPath
                }
            }
        }
    }
    
    @objc func showCellOptionsView(cell: UICollectionViewCell){
        
        editCellOverlayView = UIView(frame: view.bounds)
        editCellOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        editCellOverlayView.isUserInteractionEnabled = true
        editCellOverlayView.alpha = 0
        view.addSubview(editCellOverlayView)
        
        editCellSnapShot = cell.snapshotView(afterScreenUpdates: true)!
        editCellSnapShot.frame.origin.y = ((cell.frame.origin.y) + 253)
        editCellSnapShot.frame.origin.x = 25
        view.addSubview(editCellSnapShot)
        
        editView = CellOptionsView(frame: CGRect(x: 50, y: 0, width: 305, height: 160))
        view.addSubview(editView)
        editView.frame.origin.y = editCellSnapShot.frame.origin.y + 92
        editView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.editCellOverlayView.alpha = 1
            self.editView.alpha = 1
        }, completion: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissEditView))
        tapGesture.name = "tapGesture"
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func dismissEditView(){
        
        if let tapGesture = view.gestureRecognizers?.first(where: {$0.name == "tapGesture"}){
            view.removeGestureRecognizer(tapGesture)
        }
        
        editView.removeFromSuperview()
        editView = nil 
        
        editCellOverlayView.removeFromSuperview()
        editCellOverlayView = nil
        
        if let snapShot = editCellSnapShot {
            snapShot.removeFromSuperview()
            editCellSnapShot = nil 
        }
    }
    
    func setCheckMarkImageOnHabitCell(isHabitDone: Int, imageview: UIImageView){
        
        if isHabitDone == 1{
            imageview.tintColor = .white
            imageview.image = UIImage(systemName: "checkmark")!
        }
        else{
            imageview.tintColor = .secondaryLabel
            imageview.image = UIImage(systemName: "plus")!
        }
    }


}


// MARK: - Extentions

extension HomeViewC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return habitsInCollectionView.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitCell", for: indexPath) as? HabitCell
        
        cell?.habitIconLabel.text = habitsInCollectionView [indexPath.item].habitIcon
        cell?.habitNameLabel.text = habitsInCollectionView [indexPath.item].habitName
        cell?.repsLabel.text = habitsInCollectionView [indexPath.item].repsPerDay
        cell?.habitCountLabel.text = habitsInCollectionView [indexPath.item].habitCounter
        cell?.layer.cornerRadius = 22
        
        let checkView = cell?.imageView
        let isdone = habitsInCollectionView[indexPath.item].isDone
        setCheckMarkImageOnHabitCell(isHabitDone: Int(isdone), imageview: checkView!)
        
        let intReps = Int(habitsInCollectionView[indexPath.item].repsPerDay!) ?? 1
        let intCounter = Int(habitsInCollectionView[indexPath.item].habitCounter!)
        let cgFloatReps = CGFloat(intReps)
        let cgFloatCounter = CGFloat(intCounter!)
        
        cell?.progress = cgFloatCounter / cgFloatReps
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !isFutureDateTapped {
            CodeHelper().actionToHabitCount(for: indexPath, collectionView: collectionView, habitsArray: habitsInCollectionView, Context: context, action: .increament, View: view)
            
            if habitsInCollectionView.count > 2 {
                DispatchQueue.main.async {
                    collectionView.performBatchUpdates({
                        collectionView.reloadItems(at: [indexPath])
                    }, completion: nil)
                }
            }else{
                reloadCollectionView()
            }
            
        }
    }
    
}
