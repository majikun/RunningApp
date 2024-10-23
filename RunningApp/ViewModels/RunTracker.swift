//
//  RunTracker.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//
//
import Foundation
import CoreLocation
import ActivityKit
import CoreLocation
import CoreData
import MapKit

// 定义用于运行时保存阶段结果的结构体
struct StageResult {
    var stageName: String
    var plannedDistance: Double
    var actualDistance: Double = 0.0
    var startTime: Date?
    var endTime: Date?
    var index: Int64
}

class RunTracker: NSObject, CLLocationManagerDelegate, ObservableObject, LocationManagerDelegate {
    @Published var totalDistance: Double = 0.0
    @Published var currentStageDistance: Double = 0.0
    @Published var currentStageIndex = 0
    @Published var currentStageName = ""
    @Published var currentStageObject: Double = 0.0
    @Published var coordinates: [CLLocationCoordinate2D] = []
    @Published var isCompleted: Bool = false
    @Published var time: TimeInterval = 0.0
    @Published var pace: Double = 0.0
    @Published var plan: RunPlan
    @Published var isRunning = false
    @Published var isPaused = false

    var stages: [RunStage]
    var planName: String
    private var stageResults: [StageResult] = []  // 使用 StageResult 而非 RunStageResult
    private var lastLocation: CLLocation?
    private var isAutoPaused = false
    var runStartTime: Date?
    private var runEndTime: Date?
    private var timer: Timer?
    private var activity: Activity<RunningWidgetAttributes>? = nil

    var currentStage: RunStage? {
        if currentStageIndex < stages.count {
            return stages[currentStageIndex]
        }
        return nil
    }

    init(plan: RunPlan) {
        self.stages = plan.stagesArray
        self.planName = plan.name ?? "默认计划名称"
        self.plan = plan
        super.init()

        // 初始化 stageResults，以匹配 stages 的数量
        for (index, stage) in stages.enumerated() {
            let stageResult = StageResult(
                stageName: stage.name ?? "默认阶段名称",
                plannedDistance: stage.distance,
                index: Int64(index)
            )
            stageResults.append(stageResult)
        }

        // 设置自己为 LocationManager 的委托
        LocationManager.shared.delegate = self
        LocationManager.shared.startTracking()  // 开始位置更新
        BackgroundTaskManager.shared.startBackgroundTask()  // 开始后台任务
    }

    // 开始跑步
    func startRun() {
        isRunning = true
        runStartTime = Date()
        startNextStage()
        LocationManager.shared.startTracking()
        startTimer()
        startLiveActivity()
    }

    // 停止跑步
    func stopRun() {
        isRunning = false
        LocationManager.shared.stopTracking()
        completeRun()
        stopTimer()
    }

    func didUpdateLocation(_ location: CLLocation) {
        guard isRunning, !isPaused else { return }
        
        coordinates.append(location.coordinate)

        if let lastLocation = lastLocation {
            let distance = location.distance(from: lastLocation)
            totalDistance += distance          // 总距离，单位米
            currentStageDistance += distance   // 当前阶段距离，单位米

            // 更新当前阶段的实际距离
            stageResults[currentStageIndex].actualDistance = currentStageDistance

            updatePace()
            updateLiveActivity()

            let currentStage = stages[currentStageIndex]
            if currentStageDistance >= currentStage.distance {
                completeCurrentStage()
            }
        }
        lastLocation = location
    }

    // 完成当前阶段
    func completeCurrentStage() {
        guard currentStageIndex < stages.count else {
            print("Error: currentStageIndex out of bounds")
            return
        }
        
        // 检查 stageResults 的索引范围
        guard currentStageIndex < stageResults.count else {
            print("Error: stageResults index out of bounds")
            return
        }

        stageResults[currentStageIndex].endTime = Date()
        currentStageIndex += 1

        if currentStageIndex < stages.count {
            startNextStage()
        } else {
            completeRun()
        }
    }

    // 开始下一个阶段
    func startNextStage() {
        currentStageDistance = 0.0
        currentStageName = stages[currentStageIndex].name ?? "默认阶段名称"
        currentStageObject = stages[currentStageIndex].distance
        lastLocation = nil  // 确保从 0 重新计数

        // 记录阶段开始时间
        stageResults[currentStageIndex].startTime = Date()

        SpeechManager.shared.announceStage(currentStageName, distance: currentStageObject)
    }
    
    func completeRun() {
        runEndTime = Date()
        isCompleted = true  // 触发 @Published 属性的变化
        SpeechManager.shared.announceCompletion(totalDistance: totalDistance)
        // 停止位置更新和后台任务
        LocationManager.shared.stopTracking()
        BackgroundTaskManager.shared.endBackgroundTask()
        
        Task {
            endLiveActivity()
        }

        // 保存跑步记录到 Core Data
        saveRunningRecord()
    }
    
    // 手动暂停/恢复跑步
    func togglePause() {
        if isPaused {
            isPaused = false
            isAutoPaused = false
            resumeRun()
        } else {
            isPaused = true
            isAutoPaused = false
            pauseRun()
        }
    }

    // 自动暂停/恢复跑步
    func didAutoPause() {
        if !isPaused {
            isPaused = true
            isAutoPaused = true
            pauseRun()
        }
    }

    func didResumeRunning() {
        if isPaused && isAutoPaused {
            isPaused = false
            isAutoPaused = false
            resumeRun()
        }
    }

    private func pauseRun() {
        LocationManager.shared.stopTracking()
        updateLiveActivity()  // 更新 Live Activity
        SpeechManager.shared.announce("运动已暂停")
    }

    private func resumeRun() {
        LocationManager.shared.startTracking()
        updateLiveActivity()  // 更新 Live Activity
        SpeechManager.shared.announce("运动已恢复")
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isRunning && !self.isPaused {
                self.time += 1.0  // 仅在未暂停时累加时间
                self.updatePace()
            }
            self.updateLiveActivity()  // 始终更新 Live Activity
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // 更新配速
    private func updatePace() {
        if totalDistance > 0 {
            pace = time / (totalDistance / 1000.0)   // 配速以 **秒/公里** 为单位
        }
    }
    
    // 开始 Live Activity
    private func startLiveActivity() {
        let attributes = RunningWidgetAttributes(sessionName: planName)
        let initialContentState = RunningWidgetAttributes.ContentState(
            totalTime: 0,
            totalDistance: 0,
            currentStageIndex: currentStageIndex,
            currentStageName: currentStageName,
            currentStageObject: currentStageObject,
            currentStageDistance: 0,
            isPaused: isPaused
        )
        do {
            activity = try Activity.request(
                attributes: attributes,
                contentState: initialContentState,
                pushType: nil  // 如果不需要远程推送更新，可以设置为 nil
            )
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }

    private func updateLiveActivity() {
        guard let activity = activity else { return }
        let updatedContentState = RunningWidgetAttributes.ContentState(
            totalTime: time,
            totalDistance: totalDistance,
            currentStageIndex: currentStageIndex,
            currentStageName: currentStageName,
            currentStageObject: currentStageObject,
            currentStageDistance: currentStageDistance,
            isPaused: isPaused  // 传递暂停状态
        )
        Task {
            await activity.update(using: updatedContentState)
        }
    }

    // 结束 Live Activity
    private func endLiveActivity() {
        Task {
            await activity?.end(dismissalPolicy: .immediate)
            activity = nil
        }
    }

    // 保存跑步记录到 Core Data
    private func saveRunningRecord() {
        let context = CoreDataManager.shared.context

        // 创建 RunningRecord 实例
        let runningRecord = RunManager.shared.currentRunningRecord ?? RunningRecord(context: context)
       // runningRecord.id = UUID()
        runningRecord.planName = planName
        runningRecord.totalDistance = totalDistance
        runningRecord.totalTime = time
        runningRecord.startTime = runStartTime
        runningRecord.endTime = runEndTime
        runningRecord.coordinates = coordinates.map { "\($0.latitude),\($0.longitude)" } 

        // 将 stageResults 转换为 RunStageResult，并添加到 runningRecord
        for stageResultData in stageResults {
            let stageResult = RunStageResult(context: context)
            stageResult.stageName = stageResultData.stageName
            stageResult.plannedDistance = stageResultData.plannedDistance
            stageResult.actualDistance = stageResultData.actualDistance
            stageResult.startTime = stageResultData.startTime
            stageResult.endTime = stageResultData.endTime
            stageResult.index = stageResultData.index
            stageResult.record = runningRecord  // 设置关系

            runningRecord.addToStages(stageResult)
        }

        // 保存上下文
        do {
            try context.save()
            print("RunningRecord saved successfully.")
        } catch {
            print("Failed to save RunningRecord: \(error)")
        }
    }
}

