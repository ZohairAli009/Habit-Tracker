//
//  HabitCell.swift
//  Habit-Tracker
//
//  Created by Zohair on 02/09/2024.
//

import UIKit

class HabitCell: UICollectionViewCell {
    
    
    @IBOutlet var habitIconLabel: UILabel!
    @IBOutlet var habitNameLabel: UILabel!
    @IBOutlet var repsLabel: UILabel!
    @IBOutlet var habitCountLabel: UILabel!
    
    @IBOutlet var cellView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    let progressLayer = CALayer()
    
    var progress: CGFloat = 0 {
        didSet {
            updateLayer()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        setupSwipeGesture()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cellView.layer.masksToBounds = true
        cellView.clipsToBounds = true
    }
    
    private func configure(){
        
        habitIconLabel.layer.cornerRadius = 20
        habitIconLabel.layer.masksToBounds = true 
        habitIconLabel.backgroundColor = .clear.withAlphaComponent(0.15)
        
        progressLayer.anchorPoint = CGPoint(x: 0, y: 1)
        cellView.layer.insertSublayer(progressLayer, at: 0)
        progressLayer.frame.size.height = bounds.height
        progressLayer.cornerRadius = 22
        progressLayer.backgroundColor = UIColor.systemMint.cgColor
    }
    
    
    func updateLayer(){
        let newWidth = cellView.bounds.width * progress
        progressLayer.frame.size.width = newWidth
    }
    
    
    private func setupSwipeGesture() {
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        rightSwipe.direction = .right
        self.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        leftSwipe.direction = .left
        self.addGestureRecognizer(leftSwipe)
        
    }

    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let swipeData: Any = [self, gesture.direction]
        
        NotificationCenter.default.post(name: NSNotification.Name("userSwiped"), object: swipeData)
    }
    
}
