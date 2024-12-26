//
//  StatisticsViewC.swift
//  Habit-Tracker
//
//  Created by Zohair on 01/09/2024.
//

import UIKit

class StatisticsViewC: UIViewController {
    
    // MARK: - @IBOutlet Variables
    
    @IBOutlet var YAxisStackView: UIStackView!
    @IBOutlet var XAxisStackView: UIStackView!
    @IBOutlet var barsStackView: UIStackView!
    @IBOutlet var weeksLabel: UILabel!
    @IBOutlet var datesLabel: UILabel!
    
    
    // MARK: - Variables and constants
    
    var previousWeekTapped: Bool = true
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var XStackViewTitles = [String]()
    var datesOfCurrentWeek = [String]()
    var allWeekHabitsCount = [String]()
    var weekConstant = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displayLabelsText()
        updateStatistics()
        tabBarController?.tabBar.isHidden = false
        weeksLabel.text = "THIS WEEK"
    }
    
    
    // MARK: - Added Functions
    
    func setupViewController(){
        XStackViewTitles = ["S", "M", "T", "W", "T", "F", "S",]
        
        setupXStackView()
       
        datesOfCurrentWeek = getDateOfAllWeek(week: 0)
    }
    
    func removePreviousViewsFromYStackView(){
        
        for view in YAxisStackView.arrangedSubviews {
            YAxisStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    func removePreviousViewsFromBarStackView(){
        for view in barsStackView.arrangedSubviews {
            barsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    func updateStatistics(){
        var habitCount = 0
        let habits = try! context.fetch(Habits.fetchRequest())
        let uniqueHabits = habits.filter {$0.date == nil}
        if uniqueHabits.count == 0 {
            habitCount = 1
        }else{
            habitCount = uniqueHabits.count
        }
        
        removePreviousViewsFromYStackView()
        setupYStackView(Count: uniqueHabits.count)
        
        let countList = getDoneHabitsCountList()
        removePreviousViewsFromBarStackView()
        setupBarsStackView(list: countList, habitCount: habitCount) 
    }
    
    func setupYStackView(Count: Int){
        
        YAxisStackView.axis = .vertical
        YAxisStackView.distribution = .equalCentering
        YAxisStackView.backgroundColor = .clear
        
        
        for counts in 0...Count {
            let countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            countLabel.text = "\(counts)"
            countLabel.textAlignment = .center
            countLabel.textColor = .secondaryLabel
            countLabel.font = UIFont.systemFont(ofSize: 10)
            
            YAxisStackView.insertArrangedSubview(countLabel, at: 0)
        }
    }
    
    func setupXStackView(){
        XAxisStackView.axis = .horizontal
        XAxisStackView.distribution = .fillEqually
        XAxisStackView.spacing = 6
        XAxisStackView.backgroundColor = .clear
        
        for dayCount in 0...6 {
            let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            btn.setTitle(XStackViewTitles[dayCount], for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btn.layer.cornerRadius = 15
            btn.backgroundColor = .systemMint
            btn.tag = dayCount
            btn.addTarget(self, action: #selector(habitDetailBtnTapped), for: .touchUpInside)
            
            XAxisStackView.addArrangedSubview(btn)
        }
    }
    
    func setupBarsStackView(list countList: [Int], habitCount: Int ){
        
        barsStackView.axis = .horizontal
        barsStackView.distribution = .fillEqually
        barsStackView.spacing = 1.3
        
        let red: CGFloat = 40 / 255
        let green: CGFloat = 77 / 255
        let blue: CGFloat = 111 / 255
        
        for viewCount in 0...6 {
            
            let barView = UIView(frame: CGRect(x: 2, y: 0, width: 30, height: 250))
            barView.backgroundColor = .init(red: red, green: green, blue: blue, alpha: 0.5)
            barsStackView.isLayoutMarginsRelativeArrangement = true
            barsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 1.3, bottom: 0, right: 1.3)
            barsStackView.addArrangedSubview(barView)
            
            let layer = CALayer()
            layer.frame = CGRect(x: 0, y: barView.bounds.height, width: 16, height: 10)
            layer.backgroundColor = UIColor.systemMint.cgColor
            layer.cornerRadius = 8
        
            if countList[viewCount] == 0 {
                layer.frame.size.height = 15
            }else{
                let barHeight = CGFloat(250 / habitCount * countList[viewCount])
                animateBar(barLayer: layer, finalHeight: barHeight)
                layer.frame.size.height = barHeight
            }
            
            layer.anchorPoint = CGPoint(x: 0.2, y: 1.0)
            layer.position = CGPoint(x: 14, y: barView.bounds.height)
            barView.layer.addSublayer(layer)
        }
    }
    
    
    func animateBar(barLayer: CALayer, finalHeight: CGFloat) {
        // Create the animation for height
        let animation = CABasicAnimation(keyPath: "bounds.size.height")
        animation.fromValue = 0
        animation.toValue = finalHeight
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Apply animation to the layer
        barLayer.add(animation, forKey: "heightAnimation")
    }
    
    
    
    func getDoneHabitsCountList() -> [Int] {
        let habits = try! context.fetch(Habits.fetchRequest())
        var counts: [Int] = [0,0,0,0,0,0,0]
    
        print(datesOfCurrentWeek)
        
        for habit in habits {
            
            if habit.date == nil{
                if previousWeekTapped {
                    if habit.isDone == 1{
                        let dateIndex = datesOfCurrentWeek.firstIndex {$0 == CodeHelper.currentDate()}
                        if counts[dateIndex!] >= 0{
                            let previous = counts[dateIndex!]
                            counts.remove(at: dateIndex!)
                            counts.insert(previous + 1, at: dateIndex!)
                            print(counts)
                        }else{
                            break
                        }
                    }
                }
            }else{
                
                if previousWeekTapped == false {
                    var filterd: [Habits] = []
                    for date in datesOfCurrentWeek{
                        filterd.append(contentsOf: habits.filter {$0.date == date})
                    }
                    if filterd.isEmpty{
                        return [0,0,0,0,0,0,0]
                    }
                }
                
                if datesOfCurrentWeek.contains(habit.date!){
                    if habit.isDone == 1{
                        let dateIndex = datesOfCurrentWeek.firstIndex {$0 == habit.date}
                        
                        if counts[dateIndex!] >= 0{
                            let previous = counts[dateIndex!]
                            counts.remove(at: dateIndex!)
                            counts.insert(previous + 1, at: dateIndex!)
                        }
                    }
                }
            }
        }
        
        return counts
    }
    
    
    func displayLabelsText(){
        weeksLabel.text = "\(weekConstant) WEEKS AGO".replacingOccurrences(of: "-", with: "")
        let firstDateOfWeek = datesOfCurrentWeek.first
        let lastDateOfWeek = datesOfCurrentWeek.last
        let dates = "\(firstDateOfWeek ?? "") - \(lastDateOfWeek ?? "")"
        datesLabel.text = dates.replacingOccurrences(of: ",", with: "").uppercased()
    }
    
    
    func getDateOfAllWeek(week: Int) -> [String]{
        let calender = Calendar.current
        
        if let date = calender.date(byAdding: .weekOfMonth, value: week, to: Date()){
            let datesList = CodeHelper.getDatesOfCurrentWeek(currentDate: date)
            return datesList
        }
        
        return [""]
    }
    
    // MARK: - @objc Functions
    
    @objc func habitDetailBtnTapped(sender: UIButton){
        
        var filterByDateHabits: [Habits] = []
        let userTappedDate = datesOfCurrentWeek[sender.tag]
        let habits = try! context.fetch(Habits.fetchRequest())
        let todayHabits = habits.filter {$0.date == nil}
        
        if userTappedDate == CodeHelper.currentDate(){
            filterByDateHabits = todayHabits
        }else{
            filterByDateHabits = habits.filter {$0.date == userTappedDate}
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "staticDetailVC") as? StatisticsDetailViewC
        
        if filterByDateHabits.isEmpty{
            filterByDateHabits = todayHabits
            vc?.emptyStateKey = true
        }
        
        vc?.habitsToShow = filterByDateHabits
        vc?.userSelectedDate = CodeHelper.convertDateFormatWithCurrentYear(from: userTappedDate)!
        
        present(vc!, animated: true)
    }
    
    
    @IBAction func changeWeekBtnTapped(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            
            weekConstant -= 1
            datesOfCurrentWeek = getDateOfAllWeek(week: weekConstant)
            previousWeekTapped = false
            displayLabelsText()
            updateStatistics()
            
        case 2:
            
            if weekConstant == 0{}
            else{
                weekConstant += 1
                datesOfCurrentWeek = getDateOfAllWeek(week: weekConstant)
                displayLabelsText()
                updateStatistics()
                if weekConstant == 0{
                    previousWeekTapped = true
                    updateStatistics()
                    weeksLabel.text = "THIS WEEK"
                }
            }

        default:
            print("Default")
        }
        
    }
    
}
