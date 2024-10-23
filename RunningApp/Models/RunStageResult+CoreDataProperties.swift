//
//  RunStageResult+CoreDataProperties.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/21/24.
//
//

import Foundation
import CoreData


extension RunStageResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RunStageResult> {
        return NSFetchRequest<RunStageResult>(entityName: "RunStageResult")
    }

    @NSManaged public var stageName: String?
    @NSManaged public var plannedDistance: Double
    @NSManaged public var actualDistance: Double
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var index: Int64
    @NSManaged public var record: RunningRecord?

}

extension RunStageResult : Identifiable {

}
