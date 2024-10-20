//
//  CoreDataManager.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/18/24.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let context: NSManagedObjectContext

    private init() {
        // 初始化 Core Data 堆栈
        let container = NSPersistentContainer(name: "RunPlanModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        self.context = container.viewContext
    }

    // MARK: - RunPlan Initialization

    func initializeDefaultPlansIfNeeded() {
        // Check if there are existing RunPlans in the database
        let fetchRequest: NSFetchRequest<RunPlan> = RunPlan.fetchRequest()
        fetchRequest.fetchLimit = 1 // Only need to check if at least one exists
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                // No existing plans, load default ones from file
                loadRunPlansFromFile()
            }
        } catch {
            print("Failed to check existing run plans: \(error)")
        }
    }

    private func loadRunPlansFromFile() {
        guard let url = Bundle.main.url(forResource: "runplans", withExtension: "json") else {
            print("runplans.json not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonRunPlans = try decoder.decode([JSONRunPlan].self, from: data)

            // Convert JSON to CoreData models and set relationships
            for jsonPlan in jsonRunPlans {
                guard let entity = NSEntityDescription.entity(forEntityName: "RunStage", in: context) else {
                    print("Failed to create RunStage entity description")
                    return
                }
                
                let stages = jsonPlan.stages.map { stage in
                    let runStage = RunStage(entity: entity, insertInto: context)
                    runStage.id = UUID()
                    runStage.name = stage.name
                    runStage.distance = stage.distance
                    runStage.index = stage.index
                    return runStage
                }
                
                let planEntity = NSEntityDescription.entity(forEntityName: "RunPlan", in: context)
                guard let planEntityDescription = planEntity else {
                    print("Failed to create RunPlan entity description")
                    return
                }
                
                let plan = RunPlan(entity: planEntityDescription, insertInto: context)
                plan.id = UUID()
                plan.name = jsonPlan.name
                plan.stages = NSSet(array: stages)
            }

            // Save all created RunPlans and RunStages to Core Data
            try saveContext()

        } catch {
            print("Failed to parse JSON or save to Core Data: \(error)")
        }
    }

    // MARK: - RunPlan CRUD Operations

    func createRunPlan(name: String, stages: [RunStage]) throws -> RunPlan {
        let runPlan = RunPlan(context: context)
        runPlan.id = UUID()
        runPlan.name = name
        runPlan.stages = NSSet(array: stages)
        try saveContext()
        return runPlan
    }

    func fetchAllRunPlans(sorted: Bool = false) -> [RunPlan] {
        let fetchRequest: NSFetchRequest<RunPlan> = RunPlan.fetchRequest()
        do {
            let runPlans = try context.fetch(fetchRequest)
            if sorted {
                return runPlans.sorted(by: { $0.name ?? "" < $1.name ?? "" })
            }
            return runPlans
        } catch {
            print("Failed to fetch run plans: \(error)")
            return []
        }
    }

    func deleteRunPlan(_ plan: RunPlan) throws {
        context.delete(plan)
        try saveContext()
    }

    // MARK: - Helper Methods

    func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw error
            }
        }
    }
}
