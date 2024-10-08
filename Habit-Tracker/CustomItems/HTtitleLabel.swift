//
//  HTtitleLabel.swift
//  Habit-Tracker
//
//  Created by Zohair on 02/09/2024.
//

import UIKit

class HTtitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(fontSize: CGFloat){
        super.init(frame: .zero)
        self.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        textColor = .label
        translatesAutoresizingMaskIntoConstraints = false 
    }
}
