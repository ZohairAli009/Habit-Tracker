//
//  statisticDetailCell.swift
//  Habit-Tracker
//
//  Created by Zohair on 01/10/2024.
//

import UIKit

class statisticDetailCell: UICollectionViewCell {
    
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var iconLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var cellView: UIView!
    @IBOutlet var repsLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var countLayer = CALayer()
    var progress: CGFloat = 0 {
        didSet{
            updateLayer()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cellView.layer.masksToBounds = true
        cellView.clipsToBounds = true
    }
    
    private func configure(){
        
        iconLabel.layer.cornerRadius = 20
        iconLabel.layer.masksToBounds = true
        iconLabel.backgroundColor = .clear.withAlphaComponent(0.15)
        
        countLayer.anchorPoint = CGPoint(x: 0, y: 1)
        cellView.layer.insertSublayer(countLayer, at: 0)
        countLayer.frame.size.height = bounds.height
        countLayer.cornerRadius = 22
        countLayer.backgroundColor = UIColor.systemMint.cgColor
        
        imageView.tintColor = .white
        self.layer.cornerRadius = 22
    }
    
    
    private func updateLayer(){
        let newWidth = cellView.bounds.width * progress
        countLayer.frame.size.width = newWidth
    }
    
}
