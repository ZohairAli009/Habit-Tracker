//
//  EditScreenViewC.swift
//  Habit-Tracker
//
//  Created by Zohair on 03/09/2024.
//

import UIKit
import CoreData
import Charts

class EditScreenViewC: UIViewController {

    @IBOutlet var timesBtn1: UIButton!
    @IBOutlet var timesBtn2: UIButton!
    @IBOutlet var timesBtn3: UIButton!
    @IBOutlet var timesBtn4: UIButton!
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    
    @IBOutlet var tapableIconView: UIView!
    
    @IBOutlet var selectTimeScrollView: UIScrollView!
    @IBOutlet var habitNameTextFeild: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var repsLabel: UILabel!
    @IBOutlet var daysLabel: UILabel!
    @IBOutlet var repsTextLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    var timeBtnsList: [UIButton] = []
    
    var editingMode: Bool?
    var habitToEdit: Habits!
    
    var userSlectedTime: String = "ALL DAY"
    var userSlectedName: String = ""
    var repsPerDay: String = ""
    
    
    var popularHabitName: String?
    var popularHabitIcon: String?
    var popularHabitReps: String?
    var popularHabitRepsText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewCont()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let EmojiLabel = tapableIconView.viewWithTag(1) as? UILabel
        
        if editingMode == true {
            habitNameTextFeild.text = habitToEdit.habitName
            EmojiLabel?.text = habitToEdit.habitIcon
            repsLabel.text = habitToEdit.repsPerDay
        }
        
        if popularHabitName != nil {
            popularHabitTapped()
        }
    }
    
    
    func setupViewCont(){
        
        // NotificationCenter Observers
        NotificationCenter.default.addObserver(self, selector: #selector(RepsLabelText), name: NSNotification.Name("HabitGoal"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setEmojiOnIcon), name: NSNotification.Name("selectedEmoji"), object: nil)
        
        // navigation Btns
        cancelButton.layer.cornerRadius = 20
        doneButton.layer.cornerRadius = 20
        
        
        // scroll views
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        scrollView.bounces = false
        selectTimeScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 500)
        
        // text Field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height:   habitNameTextFeild.frame.height))
        habitNameTextFeild.leftView = paddingView
        habitNameTextFeild.leftViewMode = .always
        habitNameTextFeild.layer.cornerRadius = 20
        habitNameTextFeild.delegate = self
        
        timeBtnsList = [timesBtn1, timesBtn2, timesBtn3, timesBtn4]
        
        for btn in timeBtnsList {
            btn.layer.cornerRadius = 17
            btn.layer.borderWidth = 2
            btn.layer.borderColor = UIColor.label.cgColor
        }
        timesBtn1.backgroundColor = .systemMint.withAlphaComponent(0.7)
        
        // add gestures
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(TapableViewTapped))
        tapableIconView.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tapGesture2)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("HabitGoal"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("selectedEmoji"), object: nil)
    }
    
    @objc func dismissKeyBoard(){
        self.view.endEditing(true)
    }
    
    
    @objc func setEmojiOnIcon(_ notification: NSNotification){
        
        guard let emoji = notification.object as? String else { return }
        
        let EmojiLabel = tapableIconView.viewWithTag(1) as? UILabel
        EmojiLabel?.layer.cornerRadius = 8
        EmojiLabel?.text = emoji
        
        
    }
    
    
    @objc func RepsLabelText(_ notification: NSNotification){
        guard let object = notification.object as? Array<Any> else { return }
        
        let repsPerDay = object[0] as? String
        let repsText = object[1] as? String
        let days = object[2] as! [String]
        var selectedDays = ""
        
        for day in days {
            selectedDays += " \(day),"
        }
        
        repsLabel.text = repsPerDay
        repsTextLabel.text = ((repsText?.isEmpty) == true) ? "times" : repsText
        daysLabel.text = selectedDays
    }
    
    
    @objc func TapableViewTapped(){
        let emojiVC = storyboard?.instantiateViewController(withIdentifier: "EmojiVC") as? EmojisViewC
        
        let customDetents = UISheetPresentationController.Detent.custom { _ in
            return self.view.bounds.height * 0.62
        }
        
        if let sheet = emojiVC?.sheetPresentationController {
            sheet.detents = [customDetents]
            sheet.prefersGrabberVisible = true
        }
        
        emojiVC?.modalPresentationStyle = .pageSheet
        present(emojiVC!, animated: true)
    }
    
    
    func resetBtnStyle(){
        for btn in timeBtnsList {
            btn.backgroundColor = Colors.color1
        }
    }
    
    
    @IBAction func timeBtnTapped(_ sender: UIButton) {
        resetBtnStyle()
        sender.backgroundColor = .systemMint.withAlphaComponent(0.7)
        userSlectedTime = (sender.titleLabel?.text)!
    }
    
    
    @IBAction func cancelBtnTap(_ sender: Any) {
        
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name("putViewAgain"), object: nil)
    }
    
    
    @IBAction func doneBtnTap(_ sender: UIButton) {
        
        let EmojiLabel = tapableIconView.viewWithTag(1) as? UILabel
        
        if editingMode == true {
            
            var HabitsToEdit: [Habits] = []
            let editHabits = try! context.fetch(Habits.fetchRequest())
            
            HabitsToEdit = editHabits.filter {$0.uuid == habitToEdit.uuid}
            
            for habit in HabitsToEdit {
                habit.habitName = habitNameTextFeild.text
                habit.habitIcon = EmojiLabel?.text
                habit.repsPerDay = repsLabel.text
            }
            
            try! context.save()
            
            
        }else{
            let uniqueId = UUID().uuidString
            let habit = Habits(context: context)
            habit.habitName = userSlectedName
            habit.habitIcon = EmojiLabel?.text
            habit.habitTime = userSlectedTime
            habit.repsPerDay = repsLabel.text
            habit.habitCounter = "0"
            habit.isDone = 0
            habit.uuid = uniqueId
            
            try! context.save()
        }
 
        self.dismiss(animated: true)
        
        NotificationCenter.default.post(name: NSNotification.Name("putViewAgain"), object: nil)
    }
    
    
    @IBAction func setHabitGoal(_ sender: UIButton) {
        let goalVC = storyboard?.instantiateViewController(withIdentifier: "HabitGoal") as? HabitGoalViewC
        
        present(goalVC!, animated: true)
    }
    
    
    func popularHabitTapped(){
        let EmojiLabel = tapableIconView.viewWithTag(1) as? UILabel
        
        // set visually to editScreenVC
        habitNameTextFeild.text = popularHabitName
        EmojiLabel?.text = popularHabitIcon
        repsLabel.text = popularHabitReps
        repsTextLabel.text = popularHabitRepsText
        
        // set for save in coreData
        userSlectedName = popularHabitName!
        repsPerDay = popularHabitReps!
    }
    
    
    
}


extension EditScreenViewC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        userSlectedName = text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
