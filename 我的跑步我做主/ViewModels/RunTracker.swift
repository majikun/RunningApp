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

class RunTracker: NSObject, CLLocationManagerDelegate, ObservableObject, LocationManagerDelegate {
    @Published var totalDistance: Double = 0.0
    @Published var currentStageDistance: Double = 0.0
    @Published var currentStageIndex = 0
    @Published var coordinates: [CLLocationCoordinate2D] = []
    @Published var isCompleted: Bool = false
    @Published var time: TimeInterval = 0.0
    @Published var pace: Double = 0.0
    @Published var plan: RunPlan
    @Published var isRunning = false

    var stages: [RunStage]
    var planName: String
    var stageResults: [RunStageResult] = []  // 保存实际运行阶段的结果
    var lastLocation: CLLocation?
    var isPaused = false
    var runStartTime: Date?
    var runEndTime: Date?
    private var timer: Timer?
    private var activity: Activity<RunningAttributes>? = nil

    var currentStage: RunStage? {
        if currentStageIndex < stages.count {
            return stages[currentStageIndex]
        }
        return nil
    }

    init(plan: RunPlan) {
        self.stages = plan.stages.sorted(by: { $0.index < $1.index })
        self.planName = plan.name  // 使用 planName
        self.plan = plan
        super.init()

        // 初始化 stageResults，以匹配 stages 的数量
        for stage in stages {
            let stageResult = RunStageResult(stageName: stage.name, plannedDistance: stage.distance, startTime: nil, endTime: nil)
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
        Task {
            await endLiveActivity()
        }
    }

    // LocationManagerDelegate - 处理位置更新
    func didUpdateLocation(_ location: CLLocation) {
        guard isRunning, !isPaused else { return }  // 确保只有跑步开始后才更新位置
        
        coordinates.append(location.coordinate)  // 记录当前位置坐标

        if let lastLocation = lastLocation {
            let distance = location.distance(from: lastLocation)
            totalDistance += distance / 1000  // Convert to km
            currentStageDistance += distance  // 更新当前阶段的里程

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
        lastLocation = nil  // 确保从 0 重新计数
        stageResults[currentStageIndex].startTime = Date()  // 记录阶段开始时间
        SpeechManager.shared.announceStage(stages[currentStageIndex].name, distance: stages[currentStageIndex].distance)
    }

    // 完成整个跑步
    func completeRun() {
        runEndTime = Date()
        isCompleted = true  // 新增：通知外部训练完成
        SpeechManager.shared.announceCompletion(totalDistance: totalDistance)
        
        // 停止位置更新和后台任务
        LocationManager.shared.stopTracking()
        BackgroundTaskManager.shared.endBackgroundTask()  // 确保停止后台任务
    }

    // 暂停/恢复跑步
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            LocationManager.shared.stopTracking()  // 暂停位置更新
        } else {
            LocationManager.shared.startTracking()  // 恢复位置更新
        }
    }

    // Timer Methods
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isRunning, let runStartTime = self.runStartTime else { return }
            self.time = Date().timeIntervalSince(runStartTime)
            self.updatePace()
            self.updateLiveActivity()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // 更新配速
    private func updatePace() {
        if totalDistance > 0 {
            pace = time / totalDistance
        }
    }

    // Live Activity Methods
    private func startLiveActivity() {
        let attributes = RunningAttributes(sessionName: planName)
        let initialContentState = RunningAttributes.ContentState(distance: totalDistance, time: time, pace: pace)
        do {
            activity = try Activity<RunningAttributes>.request(attributes: attributes, contentState: initialContentState, pushType: nil)
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }

    private func updateLiveActivity() {
        guard let activity = activity else { return }
        let updatedContentState = RunningAttributes.ContentState(distance: totalDistance, time: time, pace: pace)
        Task {
            await activity.update(using: updatedContentState)
        }
    }

    private func endLiveActivity() async {
        await activity?.end(dismissalPolicy: .immediate)
        activity = nil
    }
}
