//
//  DatePickerViewC.swift
//  Habit-Tracker
//
//  Created by Zohair on 15/09/2024.
//

import UIKit

class DatePickerViewC: UIViewController {
    
    var habitDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDatePicker()
        setupViewController()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let strDate = UserDefaults.standard.string(forKey: "SelectedDate") {
            
            let formetter = DateFormatter()
            formetter.dateFormat = "MMM d, yyyy"
            
            let date = formetter.date(from: strDate)
            
            habitDatePicker.setDate(date!, animated: true)
        }
        
    }
    
    
    func setupViewController(){
        
        view.backgroundColor = Colors.color2
        habitDatePicker.tintColor = .systemMint
        
        habitDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissView), name: NSNotification.Name("DismissDatePicker"), object: nil)
        habitDatePicker.setDate(Date(), animated: false)
    }
    
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("DismissDatePicker"), object: nil)
    }
    
    
    @objc func setCurrentDate(){
        habitDatePicker.setDate(Date(), animated: false)
        print("add oneeeee")
    }
    
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        
        let currentDate = Date()
        if sender.date > currentDate {
            NotificationCenter.default.post(name: NSNotification.Name("FutureDateTapped"), object: nil)
        }
        else if sender.date < currentDate {
            NotificationCenter.default.post(name: NSNotification.Name("PreviousDateTapped"), object: nil)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "MMM d,"
        let selectedDate = dateFormatter.string(from: sender.date)
        
        
        NotificationCenter.default.post(name: NSNotification.Name("dateChanged"), object: selectedDate)
    }
    
    @objc func dismissView(_ notification: NSNotification){
        dismiss(animated: true)
        
        let object = notification.object as? String
        
        UserDefaults.standard.setValue(object, forKey: "SelectedDate")
    }
    
    
    func setupDatePicker(){
        view.addSubview(habitDatePicker)
        
        habitDatePicker.translatesAutoresizingMaskIntoConstraints = false
        habitDatePicker.datePickerMode = .date
        habitDatePicker.preferredDatePickerStyle = .inline
        
        NSLayoutConstraint.activate([
            habitDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            habitDatePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            habitDatePicker.heightAnchor.constraint(equalToConstant: 374),
            habitDatePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
