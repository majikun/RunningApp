//
//  RunPlanDetailView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/13/24.
//

import SwiftUI
struct RunPlanDetailView: View {
    @ObservedObject var plan: RunPlan  // 确保视图能够观察到计划的变化
    @State private var showAddStageSheet = false

    var body: some View {
        VStack {
            List {
                ForEach(plan.stages.sorted(by: { $0.index < $1.index })) { stage in
                    HStack {
                        TextField("Stage Name", text: $plan.stages[plan.stages.firstIndex(of: stage)!].name)
                        TextField("Distance", value: $plan.stages[plan.stages.firstIndex(of: stage)!].distance, formatter: NumberFormatter())
                    }
                }
                .onDelete(perform: deleteStage)
            }

            Button("Add Stage") {
                showAddStageSheet.toggle()
            }
            .sheet(isPresented: $showAddStageSheet) {
                AddRunStageView(onAdd: { newStage in
                    let nextIndex = plan.stages.count
                    let indexedStage = RunStage(name: newStage.name, distance: newStage.distance, index: nextIndex)
                    plan.stages.append(indexedStage)
                }, nextIndex: plan.stages.count)
            }

            Spacer()
        }
        .navigationTitle(plan.name)
    }

    func deleteStage(at offsets: IndexSet) {
        plan.stages.remove(atOffsets: offsets)
    }
}
