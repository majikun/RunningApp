//
//  RunManager.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/14/24.
//

import Foundation
import Combine
import CoreData

class RunManager: ObservableObject {
    static let shared = RunManager()

    @Published var isRunning = false
    @Published var isPaused = false
    @Published var runTracker: RunTracker? {
        didSet {
            if let tracker = runTracker {
                trackerCancellable = tracker.objectWillChange
                    .sink { [weak self] _ in
                        self?.objectWillChange.send()
                    }
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
    
    @Published var selectedPlan: RunPlan?
    @Published var showPlanDetail = false
    @Published var showRunDetail = false
    
    var currentRunningRecord: RunningRecord?  // 持有当前跑步记录的引用

    var saveTimer: Timer?
    private var trackerCancellable: AnyCancellable?
    private var trackerCompletionCancellable: AnyCancellable?
    
    private init() {}

    func startPlanDetail(plan: RunPlan) {
        selectedPlan = plan
        showPlanDetail = true
    }

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
                await self.saveRunData()
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
        runningRecord.totalTime = tracker.time  // 使用 tracker 的计时器时间
        runningRecord.endTime = Date()
        runningRecord.coordinates = tracker.coordinates.map { "\($0.latitude),\($0.longitude)" }

        // 保存上下文
        CoreDataManager.shared.saveContext()
    }

    // 创建新的跑步记录
    @MainActor private func createNewRunningRecord(plan: RunPlan) {
        let context = CoreDataManager.shared.context

        let runningRecord = RunningRecord(context: context)
        runningRecord.id = UUID()
        runningRecord.planName = plan.name ?? "未知计划"
        runningRecord.totalDistance = 0.0
        runningRecord.totalTime = 0.0
        runningRecord.startTime = Date()
        runningRecord.endTime = Date()
        runningRecord.coordinates = []

        currentRunningRecord = runningRecord

        // 保存上下文
        CoreDataManager.shared.saveContext()
    }
    
    @MainActor private func handleRunCompletion() {
        isRunning = false      
        runTracker = nil
        stopSaveTimer()
        saveRunData()
        runTracker = nil
        currentRunningRecord = nil  // 清除当前跑步记录的引用
    }
}


