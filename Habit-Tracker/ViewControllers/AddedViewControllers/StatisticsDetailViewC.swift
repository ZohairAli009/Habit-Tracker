//
//  StatisticsDetailViewC.swift
//  Habit-Tracker
//
//  Created by Zohair on 30/09/2024.
//

import UIKit

class StatisticsDetailViewC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var dateLabel: UILabel!
    
    var habitsToShow: [Habits] = []
    var emptyStateKey: Bool = false
    var userSelectedDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .clear
        dateLabel.text = userSelectedDate
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return habitsToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as? statisticDetailCell
        
        if emptyStateKey {
            
            cell?.iconLabel.text = habitsToShow[indexPath.item].habitIcon
            cell?.nameLabel.text = habitsToShow[indexPath.item].habitName
            cell?.countLabel.text = "0"
            cell?.repsLabel.text = habitsToShow[indexPath.item].repsPerDay
            cell?.imageView.image = UIImage(systemName: "checkmark")
            
            return cell!
            
        }else{
            cell?.iconLabel.text = habitsToShow[indexPath.item].habitIcon
            cell?.nameLabel.text = habitsToShow[indexPath.item].habitName
            cell?.countLabel.text = habitsToShow[indexPath.item].habitCounter
            cell?.repsLabel.text = habitsToShow[indexPath.item].repsPerDay
            cell?.imageView.image = UIImage(systemName: "checkmark")
            
            let intReps = Int(habitsToShow[indexPath.item].repsPerDay!) ?? 1
            let intCounter = Int(habitsToShow[indexPath.item].habitCounter!)
            let cgFloatReps = CGFloat(intReps)
            let cgFloatCounter = CGFloat(intCounter!)
            
            cell?.progress = cgFloatCounter / cgFloatReps
            
            return cell!
        }
    }
    
    @IBAction func cancelBtnTap(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
