//
//  RunningWidgetAttributes.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/11/24.
//

import Foundation
import ActivityKit
import WidgetKit

struct RunningWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 定义可变的活动状态数据
        var totalTime: TimeInterval       // 总时长（秒）
        var totalDistance: Double         // 总距离（米）
        var currentStageIndex: Int        // 当前阶段索引
        var currentStageDistance: Double  // 当前阶段距离（米）
    }

    // 定义静态的活动属性
    var sessionName: String              // 训练名称
}
