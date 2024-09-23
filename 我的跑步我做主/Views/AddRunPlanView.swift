//
//  AddRunPlanView.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/13/24.
//
import SwiftUI

struct AddRunPlanView: View {
    @State private var name: String = ""
    @State private var stages: [RunStage] = []
    
    var onAdd: (RunPlan) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Plan Name", text: $name)
                
                Button("Add Plan") {
                    let newPlan = RunPlan(name: name, stages: stages)
                    onAdd(newPlan)
                }
            }
            .navigationTitle("Add New Plan")
        }
    }
}
