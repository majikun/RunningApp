//
//  RunRecordDetailView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//

import SwiftUI
import MapKit

struct RunRecordDetailView: View {
    var runRecord: RunRecord  // 包含位置信息
    
    var body: some View {
        VStack {
            Text("跑步轨迹")
                .font(.largeTitle)
                .padding()

            MapView(coordinates: runRecord.coordinates)
                .frame(height: 300)
                .cornerRadius(10)
            
            
            // 其他记录详情展示，比如总里程、总时长等
            Text("总里程: \(runRecord.totalDistance) 米")
            Text("总时长: \(runRecord.totalDuration) 秒")
        }
        .padding()
    }
}
