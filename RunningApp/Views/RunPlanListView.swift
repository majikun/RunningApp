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
                        Text(plan.name!)
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
                AddRunPlanView { newPlanName, newStages in
                    do {
                        let newPlan = try CoreDataManager.shared.createRunPlan(name: newPlanName, stages: newStages)
                        runPlans.append(newPlan)
                        print("Successfully saved new plan: \(newPlanName)")
                    } catch {
                        print("Failed to save the plan: \(error)")
                    }
                }
            }
        }
        .onAppear {
            runPlans = CoreDataManager.shared.fetchAllRunPlans(sorted: true)
        }
    }
    
    func deleteRunPlan(at offsets: IndexSet) {
        offsets.forEach { index in
            let plan = runPlans[index]
            do {
                try CoreDataManager.shared.deleteRunPlan(plan)
            } catch {
                print("Failed to delete the plan: \(error)")
            }
        }
        runPlans.remove(atOffsets: offsets)
    }

}
