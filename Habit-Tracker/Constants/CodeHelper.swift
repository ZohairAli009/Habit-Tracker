//
//  CodeHelper.swift
//  Habit-Tracker
//
//  Created by Zohair on 03/09/2024.
//

import UIKit
import CoreData

// MARK: - Enumerations
enum cellAction{
    case increament, decreament
}

enum emptyStateAction{
    case add, remove
}

var showConffetiKey = true 
struct CodeHelper {
    
    // MARK: - UIHelper
    static func configureNavLabel(label: UILabel, view: UIView){
        
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = "All Day"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -9),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.widthAnchor.constraint(equalToConstant: 110),
            label.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    
    func showConfetti(imgName: String, View: UIView) {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: View.bounds.width / 2, y: 0) // Start from the top
        emitterLayer.emitterShape = .line
        emitterLayer.emitterSize = CGSize(width: View.bounds.width, height: 1)
        
        // Configure confetti particles
        let colors: [UIColor] = [.systemMint, .green, .yellow, .purple, .orange]
        var cells: [CAEmitterCell] = []
        
        let bottomY = View.bounds.height // This is the bottom of the view
        let baseVelocity: CGFloat = 285 // Base velocity from your setup
        let velocityRange: CGFloat = 60 // Velocity variation
        
        for color in colors {
            let cell = CAEmitterCell()
            cell.birthRate = 9
            cell.velocity = baseVelocity
            cell.velocityRange = velocityRange
            cell.emissionLongitude = .pi
            cell.spin = 2.5
            cell.spinRange = 2
            cell.scale = 0.14
            cell.scaleRange = 0.22
            cell.color = color.cgColor
            cell.contents = UIImage(named: imgName)?.cgImage  // Use a small image for confetti
            
            // Calculate the particle lifetime dynamically based on velocity and view height
            let minVelocity = baseVelocity - velocityRange
            let maxVelocity = baseVelocity + velocityRange
            
            // Calculate min and max lifetime based on how long it takes to fall to the bottom
            let minLifetime = Float(bottomY / maxVelocity)
            let maxLifetime = Float(bottomY / minVelocity)
            
            cell.lifetime = (minLifetime + maxLifetime) / 2 // Average lifetime
            cell.lifetimeRange = (maxLifetime - minLifetime) / 2 // Range for variation
            
            cells.append(cell)
        }
        
        emitterLayer.emitterCells = cells
        View.layer.addSublayer(emitterLayer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            emitterLayer.birthRate = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) { // Wait until all
                emitterLayer.removeFromSuperlayer()
            }
        }
    }
    
    
    // MARK: - Helper Code
    
    // this func takes current date and return dates of all week
    static func getDatesOfCurrentWeek(currentDate: Date) -> [String] {
        let calendar = Calendar.current
        
        // Find the start of the current week
        let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: currentDate)?.start
        
        // If we have the start of the week, create an array with all dates of the week
        var datesOfWeek: [Date] = []
        if let startOfWeek = startOfWeek {
            for day in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                    datesOfWeek.append(date)
                }
            }
        }
        
        var stringDates: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d,"
        
        for date in datesOfWeek {
            stringDates.append(dateFormatter.string(from: date))
        }
        
        return stringDates
    }
    
    
    // this fun return current date in string formatt
    static func currentDate() -> String {
        let currentDate = Date()
        let dateFormetter = DateFormatter()
        dateFormetter.dateStyle = .medium
        dateFormetter.timeStyle = .none
        dateFormetter.dateFormat = "MMM d,"
        
        return dateFormetter.string(from: currentDate)
    }
    
    // this func converts and return date type to string type
    static func dateToStringConvert(date: Date) -> String {
        let dateFormetter = DateFormatter()
        dateFormetter.dateStyle = .medium
        dateFormetter.timeStyle = .none
        dateFormetter.dateFormat = "MMM d,"
        
        return dateFormetter.string(from: date)
    }
    
    // this func returns next date from current date
    func getNextDate() -> String{
        let calendar = Calendar.current
        let now = Date()
        let dateFormetter = DateFormatter()
        dateFormetter.dateStyle = .medium
        dateFormetter.timeStyle = .none
        dateFormetter.dateFormat = "MMM d,"
        
        // Add 1 day from the current date
        guard let previousDate = calendar.date(byAdding: .day, value: 1, to: now) else {
            return dateFormetter.string(from: now)
        }
        
        return dateFormetter.string(from: previousDate)
    }
    
    // this func takes only month, date formatt and return date with year
    static func convertDateFormatWithCurrentYear(from dateString: String) -> String? {
        let originalFormatter = DateFormatter()
        originalFormatter.dateFormat = "MMM d,"
        
        if let date = originalFormatter.date(from: dateString) {
            var calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            
            // Extract month and day components from the parsed date
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            // Create a new date with the current year, and the parsed month and day
            var components = DateComponents()
            components.year = currentYear
            components.month = month
            components.day = day
            
            if let correctedDate = calendar.date(from: components) {
                let newFormatter = DateFormatter()
                newFormatter.dateFormat = "MMM d, yyyy"
                return newFormatter.string(from: correctedDate)
            }
        }
        
        return nil
    }
    
    
    // this func is used to increment or decrement the habit count according to user tap on
    // plus or undo button
    func actionToHabitCount(for indexPath: IndexPath, collectionView: UICollectionView, habitsArray: [Habits], Context: NSManagedObjectContext, action: cellAction, View: UIView){
        
        // get cell that is tapped by user and location of tap in cell
        let cell = collectionView.cellForItem(at: indexPath) as? HabitCell
        let tapLocation = collectionView.panGestureRecognizer.location(in: cell)
        let cellWidth = cell?.frame.width
        
        // get count of cell's habit and convert into int type
        let countLabel = cell?.viewWithTag(2) as? UILabel
        var previousIntCount = Int(countLabel!.text!)
        let reps = habitsArray[indexPath.item].repsPerDay
        
        // do + or - according to action
        switch action {
        case .increament:
            // check user must tap on right edge of cell
            if tapLocation.x > cellWidth! - 60 {
                // increament the habit count and save it to coreDat
                previousIntCount! += 1
                let newCount = "\(previousIntCount ?? 0)"
                habitsArray[indexPath.item].habitCounter = newCount
                try! Context.save()
                
                if newCount == reps {
                    habitsArray[indexPath.item].isDone = 1
                    try! Context.save()
                }
                
                let doneHabits = habitsArray.filter {$0.isDone == 1}
                if doneHabits.count == habitsArray.count{
                    if showConffetiKey {
                        showConfetti(imgName: "conffeti-1", View: View)
                        showConfetti(imgName: "conffeti-2", View: View)
                        showConffetiKey = false
                    }
                }
            }
            
        case .decreament:
            // minus the count
            if previousIntCount != 0 {
                previousIntCount! -= 1
                let newCount = "\(previousIntCount ?? 0)"
                habitsArray[indexPath.item].habitCounter = newCount
                try! Context.save()
                
                let intNewCount = Int(newCount)
                let intReps = Int(reps!)
                
                if intNewCount! < intReps! {
                    habitsArray[indexPath.item].isDone = 0
                    try! Context.save()
                    showConffetiKey = true
                }
            }
        }
    }
    
    
    func scheduleDailyNotifications(context: NSManagedObjectContext) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // Set the notification content
        let habits = try! context.fetch(Habits.fetchRequest())
        let allHabit = habits.filter {$0.date == nil}
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Habits for today: \(allHabit.count). Nothing is impossible 😎."
        content.sound = UNNotificationSound.default
        
        // Schedule notifications for each day
        let calender = Calendar.current
        let randomMinute = Int.random(in: 0...59)
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = randomMinute
        dateComponents.year = calender.component(.year, from: Date())
        dateComponents.month = calender.component(.month, from: Date())
        dateComponents.day = calender.component(.day, from: Date())
        
        // Create the trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add the request to the notification center
        center.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    func clearCoreData() {
        // Get the persistent container from AppDelegate or your Core Data stack
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // Get all the entities in Core Data
        let entities = appDelegate.persistentContainer.managedObjectModel.entities
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.name ?? "")
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let objects = try context.fetch(fetchRequest)
                for object in objects {
                    guard let objectData = object as? NSManagedObject else { continue }
                    context.delete(objectData)
                }
                try context.save()
                print("Deleted all data for entity: \(entity.name ?? "unknown entity")")
            } catch let error {
                print("Failed to clear data for entity: \(entity.name ?? "unknown entity"), error: \(error)")
            }
        }
        
    }
    
}
