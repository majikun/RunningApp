//
//  RunningRecordDetailView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/21/24.
//

import SwiftUI
import MapKit

struct RunningRecordDetailView: View {
    @ObservedObject var record: RunningRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("计划名称：\(record.planName ?? "未知计划")")
                    .font(.headline)
                Text("总距离：\(Int(record.totalDistance)) 米")
                Text("总时间：\(Int(record.totalTime)) 秒")
                Text("开始时间：\(formattedDate(record.startTime))")
                Text("结束时间：\(formattedDate(record.endTime))")
                
                // 地图视图
                MapView(coordinates: record.getCoordinates())
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding()

                // 阶段结果列表
                Text("阶段结果：")
                    .font(.headline)
                    .padding(.top)
                ForEach(record.stagesArray, id: \.objectID) { stage in
                    VStack(alignment: .leading) {
                        Text("阶段名称：\(stage.stageName ?? "未知阶段")")
                        Text("计划距离：\(Int(stage.plannedDistance)) 米")
                        Text("实际距离：\(Int(stage.actualDistance)) 米")
                        Text("时间花费：\(Int(stage.timeTaken)) 秒")
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding()
        }
        .navigationTitle("跑步详情")
    }
}
