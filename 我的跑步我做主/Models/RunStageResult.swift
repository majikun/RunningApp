//
//  RunStageResult.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/13/24.
//

import Foundation
import SwiftData

@Model
class RunStageResult {
    var stageName: String    // 阶段名称
    var plannedDistance: Double   // 计划的距离
    var actualDistance: Double    // 实际跑步的距离
    var startTime: Date?     // 开始时间
    var endTime: Date?       // 结束时间
    var timeTaken: TimeInterval { // 计算该阶段所花的时间
        guard let startTime = startTime, let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }

    init(stageName: String, plannedDistance: Double, actualDistance: Double = 0.0, startTime: Date? = nil, endTime: Date? = nil) {
        self.stageName = stageName
        self.plannedDistance = plannedDistance
        self.actualDistance = actualDistance
        self.startTime = startTime
        self.endTime = endTime
    }
}
