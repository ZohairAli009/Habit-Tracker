//
//  HabitGoalViewC.swift
//  Habit-Tracker
//
//  Created by Zohair on 07/09/2024.
//

import UIKit

class HabitGoalViewC: UIViewController {
    
    @IBOutlet var doneBtn: UIButton!
    @IBOutlet var repsTextField: UITextField!
    @IBOutlet var repsLabelTextField: UITextField!
    
    var onTheseDays: [String] = []
    var dayBtnTags: [Int] = []
    var allTextFields: [UITextField] = []
    
    var repsPerDay: String = ""
    var repsLabel: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        allTextFields = [repsTextField, repsLabelTextField]
        dayBtnTags = [1,2,3,4,5,6,7]
        setupTextFields()
    }
    
    func setupTextFields(){
        
        for textField in allTextFields {
            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))

            textField.leftView = paddingView
            textField.leftViewMode = .always
        }

        repsTextField.keyboardType = .numberPad
        repsLabelTextField.keyboardType = .default
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func textFieldDidChange(){
        doneBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
        doneBtn.tintColor = .label
    }
    
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        
        var days: [String] = []
        for index in dayBtnTags {
            days.append(HabitTimes.daysList[index - 1])
        }
        
        var dataList: Any = []
        dataList = [repsPerDay, repsLabel, days]
        
        if repsLabel.isEmpty && repsPerDay.isEmpty{
            dataList = ["1", "times", days]
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("HabitGoal"), object: dataList)
        
        self.dismiss(animated: true)
    }
    
    
    @IBAction func daysBtnTap(_ sender: UIButton) {
        doneBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
        doneBtn.tintColor = .label
        
        if dayBtnTags.contains(sender.tag) {
            sender.backgroundColor = .clear
            let text = sender.titleLabel?.text
            sender.setTitle(text, for: .normal)
            sender.setTitleColor(.label.withAlphaComponent(0.2), for: .normal)
            dayBtnTags.removeAll { $0 == sender.tag }
            
        } else {
            
            sender.backgroundColor = .init(red: 44/255, green: 72/255, blue: 106/255, alpha: 1)
            dayBtnTags.append(sender.tag)
            let text = sender.titleLabel?.text
            sender.setTitle(text, for: .normal)
            sender.setTitleColor(.label , for: .normal)
        }
    }
}


extension HabitGoalViewC: UITextFieldDelegate {
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 8 {
            repsPerDay = textField.text!
        }
        else if textField.tag == 9 {
            repsLabel = textField.text!
        }
    }
}
