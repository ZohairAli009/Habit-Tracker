//
//  EmojisViewC.swift
//  Habit-Tracker
//
//  Created by Zohair on 10/09/2024.
//

import UIKit

class EmojisViewC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var emojiCollectionView: UICollectionView!
    @IBOutlet var selectedEmojiLabel: UILabel!
    
    @IBOutlet var emojiBtn1: UIButton!
    @IBOutlet var emojiBtn2: UIButton!
    @IBOutlet var emojiBtn3: UIButton!
    @IBOutlet var emojiBtn4: UIButton!
    @IBOutlet var emojiBtn5: UIButton!
    @IBOutlet var emojiBtn6: UIButton!
    
    var emojisArray = [[String]]()
    var emojiBtnsArray: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emojisArray = EmojisList.emojiCategories
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.backgroundColor = .clear
    
        selectedEmojiLabel.layer.cornerRadius = 18
        
        emojiBtnsArray = [emojiBtn1, emojiBtn2, emojiBtn3, emojiBtn4, emojiBtn5, emojiBtn6]
        
        
        for (count, btn) in emojiBtnsArray.enumerated() {
            btn.setImage(UIImage(
                systemName: EmojisList.sfSymbols[count])?.withRenderingMode(.alwaysTemplate), for: .normal
            )
            if btn == emojiBtn1 {
                btn.tintColor = .label
                continue
            }
            btn.tintColor = .lightText.withAlphaComponent(0.2)
        }
    }
    
    
    
    func resetEmojiBtnsTint(sender: UIButton){
        
        for btn in emojiBtnsArray{
            if btn == sender{ continue }
            btn.tintColor = .lightText.withAlphaComponent(0.2)
        }
    }
    
    
    @IBAction func emojisBtnTapped(_ sender: UIButton) {
        
        resetEmojiBtnsTint(sender: sender)
        
        sender.tintColor = .label
        
        switch sender.tag {
        case 11:
            emojiCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top , animated: true)
            
        case 12:
            emojiCollectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .top, animated: true)
            
        case 13:
            emojiCollectionView.scrollToItem(at: IndexPath(item: 0, section: 2), at: .top, animated: true)
            
        case 14:
            emojiCollectionView.scrollToItem(at: IndexPath(item: 0, section: 3), at: .top, animated: true)
            
        case 15:
            emojiCollectionView.scrollToItem(at: IndexPath(item: 0, section: 4), at: .top, animated: true)
            
        case 16:
            emojiCollectionView.scrollToItem(at: IndexPath(item: 0, section: 5), at: .top, animated: true)
            
        default:
            print("D")
        }
    }
    
    
    @IBAction func NavBtnsTapped(_ sender: UIButton) {
        
        switch sender.tag {
            
        case 8: 
            self.dismiss(animated: true)
            
        case 9:
           
            guard let selectedEmoji = selectedEmojiLabel.text else { return }
            
            NotificationCenter.default.post(name: NSNotification.Name("selectedEmoji"), object: selectedEmoji)
            
            self.dismiss(animated: true)
            
        default:
            print("defualt case")
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojisArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojisArray[section].count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojisCell
    
        cell!.emojiLabel.text = emojisArray[indexPath.section][indexPath.item]
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmojiHeader", for: indexPath)
            
            let label = header.viewWithTag(17) as? UILabel
            label?.text = EmojisList.categoryNames[indexPath.section]
            
            return header
        }
        
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let emojiCell = collectionView.cellForItem(at: indexPath)
        let emojiLabel = emojiCell?.viewWithTag(10) as? UILabel
        
        selectedEmojiLabel.text = emojiLabel?.text
    }
    
}
