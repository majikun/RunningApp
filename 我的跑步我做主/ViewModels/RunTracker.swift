//
//  RunTracker.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//
import Foundation
import CoreLocation

class RunTracker: NSObject, CLLocationManagerDelegate, ObservableObject {
    let locationManager = CLLocationManager()
    @Published var totalDistance: Double = 0.0
    @Published var currentStageDistance: Double = 0.0
    @Published var currentStageIndex = 0
    @Published var coordinates: [CLLocationCoordinate2D] = []  // 新增的坐标数组

    var stages: [RunStage]
    var lastLocation: CLLocation?
    var isPaused = false  // 新增的暂停状态
    var runStartTime: Date?
    var runEndTime: Date?

    init(stages: [RunStage]) {
        self.stages = stages
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last, !isPaused else { return }
        
        coordinates.append(currentLocation.coordinate)  // 记录当前位置坐标

        if let lastLocation = lastLocation {
            let distance = currentLocation.distance(from: lastLocation)
            totalDistance += distance
            currentStageDistance += distance  // 更新当前阶段的里程

            let currentStage = stages[currentStageIndex]
            if currentStageDistance >= currentStage.distance {
                completeCurrentStage()
            }
        }
        lastLocation = currentLocation
    }

    func completeCurrentStage() {
        // 检查是否越界
        guard currentStageIndex < stages.count else {
            print("Error: currentStageIndex out of bounds")
            fatalError("Crash due to stage completion error: currentStageIndex out of bounds")
        }

        stages[currentStageIndex].endTime = Date()
        currentStageIndex += 1

        if currentStageIndex < stages.count {
            startNextStage()
        } else {
            completeRun()
        }
    }

    func startNextStage() {
        currentStageDistance = 0.0
        lastLocation = nil  // 确保从 0 重新计数
        SpeechManager.shared.announceStage(stages[currentStageIndex].name, distance: stages[currentStageIndex].distance)
    }

    func completeRun() {
        runEndTime = Date()
        SpeechManager.shared.announceCompletion(totalDistance: totalDistance)
        locationManager.stopUpdatingLocation()  // 确保停止位置更新
    }
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            locationManager.stopUpdatingLocation()  // 暂停时停止位置更新
        } else {
            locationManager.startUpdatingLocation()  // 恢复时重新开始位置更新
        }
    }
}
