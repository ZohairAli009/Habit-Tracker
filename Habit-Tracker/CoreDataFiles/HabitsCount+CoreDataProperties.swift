//
//  HabitsCount+CoreDataProperties.swift
//  Habit-Tracker
//
//  Created by Zohair on 27/09/2024.
//
//

import Foundation
import CoreData


extension HabitsCount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitsCount> {
        return NSFetchRequest<HabitsCount>(entityName: "HabitsCount")
    }

    @NSManaged public var date: String?
    @NSManaged public var count: Int64

}

extension HabitsCount : Identifiable {

}
