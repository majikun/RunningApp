//
//  RunRecordListView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//
import SwiftUI

struct RunningRecordListView: View {
    @State private var records: [RunningRecordViewModel] = []
    
    var body: some View {
        List(records) { record in
            VStack(alignment: .leading) {
                Text(record.planName)
                    .font(.headline)
                Text("Total Distance: \(record.totalDistance)")
                Text("Total Time: \(record.totalTime)")
                Text("Started: \(record.startTime)")
                Text("Ended: \(record.endTime)")
                
                // 添加“查看地图”按钮
                NavigationLink(destination: MapView(coordinates: record.coordinates)) {
                    Text("查看地图")
                        .font(.body)
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            // 从持久化层获取数据并转换为展示层模型
            let fetchedRecords = PersistenceManager.shared.fetchAllRunningRecords()
            self.records = fetchedRecords.map { RunningRecordViewModel(record: $0) }
        }
    }
}


