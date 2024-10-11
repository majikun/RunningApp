//
//  LockScreenLiveActivityView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/11/24.
//


import SwiftUI
import WidgetKit

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<RunningWidgetAttributes>

    var body: some View {
        VStack(alignment: .leading) {
            Text(context.attributes.sessionName)
                .font(.headline)
            HStack {
                VStack(alignment: .leading) {
                    Text("总时长")
                    Text(formatTime(context.state.totalTime))
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("总距离")
                    Text("\(Int(context.state.totalDistance)) 米")
                }
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("当前阶段")
                    Text("第 \(context.state.currentStageIndex + 1) 阶段")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("阶段距离")
                    Text("\(Int(context.state.currentStageDistance)) 米")
                }
            }
        }
        .padding()
    }

    // 格式化时间为 分:秒
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
