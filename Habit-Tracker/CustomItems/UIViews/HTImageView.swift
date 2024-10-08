//
//  HTImageView.swift
//  Habit-Tracker
//
//  Created by Zohair on 02/09/2024.
//

import UIKit

class HTImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure(){
        layer.cornerRadius = 15
        backgroundColor = .clear.withAlphaComponent(0.15)
        translatesAutoresizingMaskIntoConstraints = false 
    }
}
