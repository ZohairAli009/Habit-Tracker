//
//  addHabitViewC.swift
//  Habit-Tracker
//
//  Created by Zohair on 01/09/2024.
//

import UIKit

class addHabitViewC: UIViewController {
    
    // MARK: - @IBOutlet Variables

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var customHabitView: UIView!
    @IBOutlet var mainView: UIView!
    
    // MARK: - Overriden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureViewCon()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Added Functions 
    
    func configureViewCon(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissHandler), name: NSNotification.Name("putViewAgain"), object: nil)
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
        
        tabBarController?.tabBar.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(customHabitViewTapped))
        customHabitView.addGestureRecognizer(tapGesture)
    }
    
    
    @objc func dismissHandler(){
        mainView.isHidden = false
    }
    

    @objc func customHabitViewTapped(){
        let editHabitVC = storyboard?.instantiateViewController(withIdentifier: "EditScreen") as? EditScreenViewC
        
        editHabitVC?.modalPresentationStyle = .overFullScreen
        editHabitVC?.modalTransitionStyle = .coverVertical
        
        present(editHabitVC! , animated: true)
    }
    
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        
        tabBarController?.selectedIndex = 0
    }
    
}


// MARK: - Extentions

extension addHabitViewC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularHabits.popularHabitNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popHabitCell", for: indexPath) as? popularHabitsCell
        
        collectionView.backgroundColor = .clear
        cell?.layer.cornerRadius = 20
        
        cell?.habitIcon.text = popularHabits.popularHabitIcons[indexPath.item]
        cell?.habitNameLabel.text = popularHabits.popularHabitNames[indexPath.item]
        cell?.habitDescription.text = popularHabits.popularHabitDescr[indexPath.item]
        cell?.colorView.backgroundColor = popularHabits.popularHabitViewColors[indexPath.item].withAlphaComponent(0.19)
        
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as? popularHabitsCell
        let name = cell?.habitNameLabel.text
        let icon = cell?.habitIcon.text
        let reps = popularHabits.popularHabitRepsPerDay[indexPath.item]
        let repsText = popularHabits.popularHabitRepsText[indexPath.item]
        
        let VC = storyboard?.instantiateViewController(withIdentifier: "EditScreen") as? EditScreenViewC
        VC?.popularHabitName = name
        VC?.popularHabitIcon = icon
        VC?.popularHabitReps = reps
        VC?.popularHabitRepsText = repsText
        
        mainView.isHidden = true
        VC?.modalPresentationStyle = .overFullScreen
        present(VC! , animated: true)
        
    }
    
}
