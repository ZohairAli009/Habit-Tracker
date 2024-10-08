//
//  CustomCellOptions.swift
//  Habit-Tracker
//
//  Created by Zohair on 23/09/2024.
//

import UIKit

class CellOptionsView: UIView {

    var optionNames = ["Edit habit", "Delete habit", "Sort by name"]
    var optionSymbols = ["pencil.line", "trash", "line.3.horizontal"]
    var optionTag: Int?
    
    var optionView: OptionsView!
    var stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = frame
        setupOptionViews()
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupOptionViews(){
        
        for i in 0...2 {
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionViewTapped))
            
            optionView = OptionsView(labelText: optionNames[i], image: optionSymbols[i])
            optionView.backgroundColor = .systemMint
            optionView.tag = i + 1
            optionView.addGestureRecognizer(tapGesture)
            stackView.addArrangedSubview(optionView)
        }
    }
    
    
    @objc func optionViewTapped(gesture: UIGestureRecognizer){
        
        guard let tag = gesture.view?.tag else { return }
        
        NotificationCenter.default.post(name: NSNotification.Name("OptionTags"), object: tag)
    }
    
    private func configure(){
        addSubview(stackView)
        
        backgroundColor = .systemMint
        layer.cornerRadius = 22
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        stackView.backgroundColor = .black
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false 
        
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
            
        ])
    }

    
}
