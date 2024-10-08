//
//  HTButton.swift
//  Habit-Tracker
//
//  Created by Zohair on 01/09/2024.
//

import UIKit

class HTButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(background: UIColor, frame: CGRect, SFSymbol: String, symbolSize: CGFloat){
        super.init(frame: .zero)
        
        let config = UIImage.SymbolConfiguration(pointSize: symbolSize, weight: .bold)
        
        self.backgroundColor = background.withAlphaComponent(0.2)
        self.frame = frame
        self.setImage(UIImage(systemName: SFSymbol, withConfiguration: config) , for: .normal)
        configure()
    }
    
    private func configure(){
        
        layer.cornerRadius = 12
        tintColor = .label
    }
}
