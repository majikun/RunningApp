//
//  PersistenceManager.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/7/24.
//
import SwiftData
import Foundation

@MainActor
class PersistenceManager {
    static let shared = PersistenceManager()

    internal var container: ModelContainer?

    init() {
        do {
            // 初始化 ModelContainer，并包含多个模型
            self.container = try ModelContainer(for: RunPlan.self, RunStage.self, RunStageResult.self, RunningRecord.self)
        } catch {
            print("Failed to initialize ModelContainer: \(error)")
        }
    }

    // MARK: - RunPlan 的操作

    func saveRunPlan(_ plan: RunPlan) throws {
        guard let container = container else {
            throw NSError(domain: "PersistenceManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
        }
        container.mainContext.insert(plan)
        try container.mainContext.save()
    }

    func fetchAllRunPlans() -> [RunPlan] {
        guard let container = container else { return [] }
        let fetchRequest = FetchDescriptor<RunPlan>()
        do {
            return try container.mainContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch plans: \(error)")
            return []
        }
    }

    func deleteRunPlan(_ plan: RunPlan) throws {
        guard let container = container else {
            throw NSError(domain: "PersistenceManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
        }
        container.mainContext.delete(plan)
        try container.mainContext.save()
    }
    
    // 检查是否为首次启动并初始化默认计划
    func initializeDefaultPlansIfNeeded() {
        if isFirstLaunch() {
            if let defaultPlans = loadRunPlansFromFile() {
                for plan in defaultPlans {
                    do {
                        try saveRunPlan(plan)
                    } catch {
                        print("Failed to save default run plan: \(error)")
                    }
                }
            }
        }
    }

    // 检查是否首次运行
    func isFirstLaunch() -> Bool {
        let existingPlans = fetchAllRunPlans()
        return existingPlans.isEmpty
    }
    // MARK: - RunningRecord 的操作
    
    func saveRunningRecord(_ record: RunningRecord) throws {
        guard let container = container else {
            throw NSError(domain: "PersistenceManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
        }
        
        // 判断记录是否已经存在，若存在则更新
        let fetchRequest = FetchDescriptor<RunningRecord>(
            predicate: #Predicate { $0.id == record.id }  // 假设你为 RunningRecord 添加了唯一的 id
        )

        let existingRecords = try container.mainContext.fetch(fetchRequest)

        if let existingRecord = existingRecords.first {
            // 更新已有记录
            existingRecord.totalDistance = record.totalDistance
            existingRecord.totalTime = record.totalTime
            existingRecord.coordinates = record.coordinates
            existingRecord.endTime = record.endTime
        } else {
            // 如果不存在，则插入新记录
            container.mainContext.insert(record)
        }

        try container.mainContext.save()
    }

    func fetchAllRunningRecords() -> [RunningRecord] {
        guard let container = container else { return [] }
        let fetchRequest = FetchDescriptor<RunningRecord>()
        do {
            return try container.mainContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }

    func deleteRunningRecord(_ record: RunningRecord) throws {
        guard let container = container else {
            throw NSError(domain: "PersistenceManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "ModelContainer is not initialized"])
        }
        container.mainContext.delete(record)
        try container.mainContext.save()
    }
    
    
}
