//
//  RunningRecord+CoreDataProperties.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/21/24.
//
//

import Foundation
import CoreData


extension RunningRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RunningRecord> {
        return NSFetchRequest<RunningRecord>(entityName: "RunningRecord")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var planName: String?
    @NSManaged public var totalDistance: Double
    @NSManaged public var totalTime: Double
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var coordinates: [String]?
    @NSManaged public var stages: NSSet?

}

// MARK: Generated accessors for stages
extension RunningRecord {

    @objc(addStagesObject:)
    @NSManaged public func addToStages(_ value: RunStageResult)

    @objc(removeStagesObject:)
    @NSManaged public func removeFromStages(_ value: RunStageResult)

    @objc(addStages:)
    @NSManaged public func addToStages(_ values: NSSet)

    @objc(removeStages:)
    @NSManaged public func removeFromStages(_ values: NSSet)

}

extension RunningRecord : Identifiable {

}
