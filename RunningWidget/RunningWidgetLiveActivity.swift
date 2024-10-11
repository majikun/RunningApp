//
//  RunningWidgetLiveActivity.swift
//  RunningWidget
//
//  Created by Jake Ma on 10/11/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RunningWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RunningWidgetAttributes.self) { context in
            LockScreenLiveActivityView(context: context)

        } dynamicIsland: { context in
            DynamicIsland {
                // 展开状态下的视图
                DynamicIslandExpandedRegion(.center) {
                    VStack {
                        Text("总时长: \(formatTime(context.state.totalTime))")
                        Text("总距离: \(Int(context.state.totalDistance)) 米")
                    }
                }
            } compactLeading: {
                Text("\(formatTime(context.state.totalTime))")
            } compactTrailing: {
                Text("\(Int(context.state.totalDistance)) 米")
            } minimal: {
                Text("跑")
            }
        }
    }
    
    // 格式化时间为 分:秒
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
