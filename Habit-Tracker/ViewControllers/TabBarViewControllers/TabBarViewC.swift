//
//  TabBarViewC.swift
//  Habit-Tracker
//
//  Created by Zohair on 01/09/2024.
//

import UIKit

class TabBarViewC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let customHeight: CGFloat = 100

        var tabBarFrame = tabBar.frame
        tabBarFrame.size.height = customHeight
        tabBarFrame.origin.y = view.frame.height - customHeight
        tabBar.frame = tabBarFrame
        
        tabBar.invalidateIntrinsicContentSize()
    }
    
    
    func setUpTabBar(){
        UITabBar.appearance().tintColor = .white
        self.tabBar.layer.cornerRadius = 50
        self.tabBar.backgroundColor = Colors.color1.withAlphaComponent(0.5)
        
    }
    
}
