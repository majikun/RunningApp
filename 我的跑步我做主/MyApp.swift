//
//  _______App.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//
import SwiftUI
import SwiftData

@main
struct MyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RunningRecord.self,  // 确保 RunningRecord 在 schema 中
            RunStageResult.self,
            Item.self  // 你可能还会有其他的模型
        ])
        
        do {
            return try ModelContainer(for: schema)  // 初始化 ModelContainer
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    PersistenceManager.shared.container = sharedModelContainer  // 传递容器给 PersistenceManager
                    CoreDataManager.shared.initializeDefaultPlansIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)  // 将 ModelContainer 传递给整个视图层
    }
}
