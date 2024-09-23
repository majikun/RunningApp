//
//  AddRunStageView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/13/24.
//
import SwiftUI

struct AddRunStageView: View {
    @Environment(\.dismiss) private var dismiss  // Marked as private to exclude from initializer
    @State private var stageName: String = ""
    @State private var stageDistance: Double = 0.0

    var onAdd: (RunStage) -> Void  // Callback to pass the new stage back to the main view
    var nextIndex: Int  // The next available index

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("阶段名称")) {
                    TextField("名称", text: $stageName)
                }
                
                Section(header: Text("阶段距离（米）")) {
                    TextField("距离", value: $stageDistance, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("添加新阶段")
            .navigationBarItems(leading: Button("取消") {
                dismiss()
            }, trailing: Button("添加") {
                let newStage = RunStage(name: stageName, distance: stageDistance, index: nextIndex)
                onAdd(newStage)
                dismiss()
            })
        }
    }
}
