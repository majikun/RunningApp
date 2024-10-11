//
//  LiveActivityView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/10/24.
//

import Foundation
import SwiftUI
import ActivityKit


// Step 4: Create SwiftUI View to Display Running Data on Lock Screen
struct RunningLiveActivityView: View {
    let distance: Double
    let time: TimeInterval
    let pace: Double

    var body: some View {
        VStack {
            Text("时间: \(Int(time)) 秒")
            Text("公里: \(String(format: "%.2f", distance)) 公里")
            Text("配速: \(String(format: "%.2f", pace)) 分/公里")
        }
        .padding()
    }
}
 
// Step 5: Preview
struct RunningLiveActivityView_Previews: PreviewProvider {
    static var previews: some View {
        RunningLiveActivityView(distance: 1.23, time: 123, pace: 5.0)
    }
}
