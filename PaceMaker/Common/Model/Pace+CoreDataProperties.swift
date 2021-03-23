//
//  Pace+CoreDataProperties.swift
//  
//
//  Created by gabriel.jeong on 2021/03/23.
//
//

import Foundation
import CoreData


extension Pace {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pace> {
        return NSFetchRequest<Pace>(entityName: "Pace")
    }

    @NSManaged public var runDate: Date?
    @NSManaged public var distance: Double
    @NSManaged public var duration: Int64
    @NSManaged public var walking: Int64
    @NSManaged public var pace: String?
    @NSManaged public var id: String
    
}
