//
//  HistoryListView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/21/24.
//

import SwiftUI
import CoreData

struct HistoryListView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: RunningRecord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RunningRecord.startTime, ascending: false)]
    ) private var runningRecords: FetchedResults<RunningRecord>

    var body: some View {
        List {
            ForEach(runningRecords, id: \.objectID) { record in
                NavigationLink(destination: RunningRecordDetailView(record: record)) {
                    VStack(alignment: .leading) {
                        Text("计划：\(record.planName ?? "未知计划")")
                        Text("日期：\(formattedDate(record.startTime))")
                        Text("距离：\(Int(record.totalDistance)) 米")
                        Text("用时：\(Int(record.totalTime)) 秒")
                    }
                }
            }
            .onDelete(perform: deleteRecords)
        }
        .navigationTitle("历史记录")
    }

    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            let record = runningRecords[index]
            context.delete(record)
        }
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
