//
//  RunPlan+CoreDataProperties.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/20/24.
//
//

import Foundation
import CoreData


extension RunPlan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RunPlan> {
        return NSFetchRequest<RunPlan>(entityName: "RunPlan")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var stages: NSSet?

}

// MARK: Generated accessors for stages
extension RunPlan {

    @objc(addStagesObject:)
    @NSManaged public func addToStages(_ value: RunStage)

    @objc(removeStagesObject:)
    @NSManaged public func removeFromStages(_ value: RunStage)

    @objc(addStages:)
    @NSManaged public func addToStages(_ values: NSSet)

    @objc(removeStages:)
    @NSManaged public func removeFromStages(_ values: NSSet)

}

extension RunPlan : Identifiable {

}
