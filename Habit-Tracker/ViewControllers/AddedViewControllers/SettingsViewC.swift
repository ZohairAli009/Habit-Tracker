//
//  SettingsViewC.swift
//  Habit-Tracker
//
//  Created by Zohair on 04/10/2024.
//

import UIKit

class SettingsViewC: UIViewController {
    
    
    @IBOutlet var tapableView: UIView!
    @IBOutlet var trashBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }

    
    private func setupViewController(){
        let tapGesture = UITapGestureRecognizer(target:self, action: #selector(deleteViewTapped))
        tapableView.addGestureRecognizer(tapGesture)
        
        tapableView.layer.cornerRadius = 22
        trashBtn.layer.cornerRadius = 16
        trashBtn.setImage(UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16)), for: .normal)
        trashBtn.tintColor = .secondaryLabel
    }
    
    
    @objc func deleteViewTapped(){
        let ac = UIAlertController(title: "RESET ALL DATA", message: "All habits that are you added will cleaned up and will also remove statistics data.\n\n THIS ACTION CANNOT BE UNDONE.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "CANCEL", style: .default))
        ac.addAction(UIAlertAction(title: "RESET", style: .destructive, handler: { _ in
            CodeHelper().clearCoreData()
            self.dismiss(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name("fetchHabitsAfterReset"), object: nil)
        }))
        present(ac, animated: true)
        if let backgroundView = ac.view.subviews.first?.subviews.first?.subviews.first {
            backgroundView.backgroundColor = Colors.color2
        }
    }
    
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}
