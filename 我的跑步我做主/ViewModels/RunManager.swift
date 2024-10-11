//
//  RunManager.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/14/24.
//

import Foundation
import Combine

class RunManager: ObservableObject {
    static let shared = RunManager()

    @Published var isRunning = false
    @Published var isPaused = false
    @Published var runTracker: RunTracker? {
        didSet {
            // 当 runTracker 被赋值时，订阅其 objectWillChange 和 isCompleted
            if let tracker = runTracker {
                trackerCancellable = tracker.objectWillChange
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
                
                // 订阅 runTracker 的 isCompleted 属性
                trackerCompletionCancellable = tracker.$isCompleted
                    .sink { [weak self] isCompleted in
                        if isCompleted {
                            DispatchQueue.main.async {
                                self?.handleRunCompletion()
                            }
                        }
                    }
            } else {
                trackerCancellable = nil
                trackerCompletionCancellable = nil
            }
        }
    }
    
    var currentRunningRecord: RunningRecord?  // 持有当前跑步记录的引用

    var saveTimer: Timer?
    private var trackerCancellable: AnyCancellable?
    private var trackerCompletionCancellable: AnyCancellable?
    
    private init() {}

    @MainActor func startRun(plan: RunPlan) {
        if runTracker == nil {
            runTracker = RunTracker(plan: plan)
            createNewRunningRecord(plan: plan)  // 创建新的跑步记录
        }
        isRunning = true
        isPaused = false
        runTracker?.startRun()
        startSaveTimer()  // 开始定时保存
    }

    @MainActor func stopRun() {
        isRunning = false
        runTracker?.stopRun()
        runTracker = nil
        stopSaveTimer()
        saveRunData()
    }

    func pauseRun() {
        isPaused.toggle()
        runTracker?.togglePause()
    }
    
    private func startSaveTimer() {
        saveTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            Task {
                await self.saveRunData()  // 使用 await 来调用异步方法
            }
        }
    }

    private func stopSaveTimer() {
        saveTimer?.invalidate()
        saveTimer = nil
    }

    @MainActor private func saveRunData() {
        guard let tracker = runTracker, let runningRecord = currentRunningRecord else { return }

        runningRecord.totalDistance = tracker.totalDistance
        runningRecord.totalTime = Date().timeIntervalSince(tracker.runStartTime ?? Date())
        runningRecord.endTime = Date()
        runningRecord.coordinates = tracker.coordinates.map { "\($0.latitude),\($0.longitude)" }


        do {
            try PersistenceManager.shared.saveRunningRecord(runningRecord)
            print("Updated running data to SwiftData")
        } catch {
            print("Failed to update running data: \(error)")
        }
    }

    // 创建新的跑步记录
    @MainActor private func createNewRunningRecord(plan: RunPlan) {
        let runningRecord = RunningRecord(
            planName: plan.name,
            totalDistance: 0.0,
            totalTime: 0.0,
            startTime: Date(),
            endTime: Date(),
            coordinates: []
        )
        currentRunningRecord = runningRecord
        do {
            try PersistenceManager.shared.saveRunningRecord(runningRecord)
            print("Saved new running record to SwiftData")
        } catch {
            print("Failed to save running data: \(error)")
        }
    }
    
    @MainActor private func handleRunCompletion() {
        isRunning = false
        runTracker?.stopRun()
        runTracker = nil
        stopSaveTimer()
        saveRunData()
    }
}
