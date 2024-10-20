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
                ForEach(plan.stagesArray) { stage in
                    HStack {
                        TextField("Stage Name", text: Binding(
                            get: { stage.name! },
                            set: { stage.name = $0 }
                        ))
                        TextField("Distance", value: Binding(
                            get: { stage.distance },
                            set: { stage.distance = $0 }
                        ), formatter: NumberFormatter())
                    }
                }
                .onDelete(perform: deleteStage)
            }

            Button("Add Stage") {
                showAddStageSheet.toggle()
            }
            .sheet(isPresented: $showAddStageSheet) {
                AddRunStageView(onAdd: { newStage in
                    let nextIndex = plan.stagesArray.count
                    let indexedStage = RunStage(context: CoreDataManager.shared.context)
                    indexedStage.id = UUID()
                    indexedStage.name = newStage.name
                    indexedStage.distance = newStage.distance
                    indexedStage.index = Int64(nextIndex)
                    indexedStage.plan = plan

                    plan.mutableSetValue(forKey: "stages").add(indexedStage)

                    do {
                        try CoreDataManager.shared.context.save()
                    } catch {
                        print("Failed to save new stage: \(error)")
                    }
                }, nextIndex: plan.stagesArray.count)

            }

            Spacer()
        }
        .navigationTitle(plan.name!)
    }

    func deleteStage(at offsets: IndexSet) {
        for index in offsets {
            let stage = plan.stagesArray[index]
            CoreDataManager.shared.context.delete(stage)
        }

        do {
            try CoreDataManager.shared.context.save()
        } catch {
            print("Failed to delete stage: \(error)")
        }
    }
}

