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
            }
        }
        .onAppear {
            // 从持久化层获取数据并转换为展示层模型
            let fetchedRecords = PersistenceManager.shared.fetchAllRecords()
            self.records = fetchedRecords.map { RunningRecordViewModel(record: $0) }
        }
    }
}
