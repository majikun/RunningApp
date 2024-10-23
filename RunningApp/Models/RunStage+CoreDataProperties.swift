//
//  RunStage+CoreDataProperties.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/20/24.
//
//

import Foundation
import CoreData


extension RunStage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RunStage> {
        return NSFetchRequest<RunStage>(entityName: "RunStage")
    }

    @NSManaged public var distance: Double
    @NSManaged public var id: UUID?
    @NSManaged public var index: Int64
    @NSManaged public var name: String?
    @NSManaged public var plan: RunPlan?

}

extension RunStage : Identifiable {

}
