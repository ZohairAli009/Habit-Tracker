//
//  OptionsView.swift
//  Habit-Tracker
//
//  Created by Zohair on 23/09/2024.
//

import UIKit

class OptionsView: UIView {
    
    let label = UILabel()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(labelText: String, image: String){
        super.init(frame: .zero)
        label.text = labelText
        imageView.image = UIImage(systemName: image)
        imageView.tintColor = .white
        configure()
    }
    
    
    private func configure(){
        addSubview(label)
        addSubview(imageView)
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 7),
            label.heightAnchor.constraint(equalToConstant: 25),
            label.widthAnchor.constraint(equalToConstant: 110),
            
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            imageView.heightAnchor.constraint(equalToConstant: 25),
            imageView.widthAnchor.constraint(equalToConstant: 25)
        ])
    }
    
}
