//
//  RunningView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/10/24.
//

import Foundation
import SwiftUI
import ActivityKit
import CoreLocation

struct RunningView: View {
    @StateObject private var runTracker = RunTracker(plan: RunPlan(name: "示例计划", stages: []))

    var body: some View {
        VStack {
            Text("时间: \(Int(runTracker.time)) 秒")
            Text("公里: \(String(format: "%.2f", runTracker.totalDistance)) 公里")
            Text("配速: \(String(format: "%.2f", runTracker.pace)) 分/公里")
        }
    }
}

// Step 5: Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RunningView()
    }
}
