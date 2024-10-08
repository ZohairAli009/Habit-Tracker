//
//  Habits+CoreDataProperties.swift
//  Habit-Tracker
//
//  Created by Zohair on 28/09/2024.
//
//

import Foundation
import CoreData


extension Habits {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habits> {
        return NSFetchRequest<Habits>(entityName: "Habits")
    }

    @NSManaged public var date: String?
    @NSManaged public var habitCounter: String?
    @NSManaged public var habitIcon: String?
    @NSManaged public var habitName: String?
    @NSManaged public var habitTime: String?
    @NSManaged public var repsPerDay: String?
    @NSManaged public var uuid: String?
    @NSManaged public var isDone: Int64

}

extension Habits : Identifiable {

}
