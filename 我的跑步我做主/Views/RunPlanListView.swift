//
//  RunPlanListView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/13/24.
//

import SwiftUI

struct RunPlanListView: View {
    @State private var runPlans: [RunPlan] = []
    @State private var showAddPlanSheet = false
    @State private var selectedPlan: RunPlan?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(runPlans, id: \.self) { plan in
                    NavigationLink(destination: RunPlanDetailView(plan: plan)) {
                        Text(plan.name)
                    }
                }
                .onDelete(perform: deleteRunPlan)
            }
            .navigationBarTitle("Running Plans")
            .navigationBarItems(trailing: Button(action: {
                showAddPlanSheet.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showAddPlanSheet) {
                AddRunPlanView { newPlan in
                    runPlans.append(newPlan)
                    // Save new plan to persistence
                    do {
                                try PersistenceManager.shared.saveRunPlan(newPlan)
                            } catch {
                                print("Failed to save the plan: \(error)")
                            }
                }
            }
        }
        .onAppear {
            runPlans = PersistenceManager.shared.fetchAllRunPlans().sorted(by: { $0.name < $1.name })
        }
    }
    
    func deleteRunPlan(at offsets: IndexSet) {
        offsets.forEach { index in
            let plan = runPlans[index]
           
            Task {
                do {
                    try await PersistenceManager.shared.deleteRunPlan(plan)
                } catch {
                    print("Failed to delete the plan: \(error)")
                }
            }
        }
        runPlans.remove(atOffsets: offsets)
    }
}
