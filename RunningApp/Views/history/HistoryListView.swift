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
                        Text(String(format: NSLocalizedString("plan", comment: "Plan: %@"), record.planName ?? NSLocalizedString("unknown_plan", comment: "")))
                        Text(String(format: NSLocalizedString("date", comment: "Date: %@"), formattedDate(record.startTime)))
                        Text(String(format: NSLocalizedString("distance", comment: "Distance: %d meters"), Int(record.totalDistance)))
                        Text(String(format: NSLocalizedString("duration", comment: "Duration: %d seconds"), Int(record.totalTime)))
                    }
                }
            }
            .onDelete(perform: deleteRecords)
        }
        .navigationTitle(NSLocalizedString("history_records", comment: "History Records"))
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
