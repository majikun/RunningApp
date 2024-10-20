//
//  RunPlanStageArray.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/19/24.
//

import Foundation
import CoreData

extension RunPlan {
    var stagesArray: [RunStage] {
        let fetchRequest: NSFetchRequest<RunStage> = RunStage.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "plan == %@", self)
        
        do {
            return try CoreDataManager.shared.context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch stages: \(error)")
            return []
        }
    }
}
