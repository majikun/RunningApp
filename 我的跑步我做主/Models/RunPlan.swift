//
//  RunStage.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//
import Foundation
import SwiftData

@Model
class RunPlan: ObservableObject, Identifiable {
    var id: UUID = UUID()
    var name: String
    var stages: [RunStage] = []

    init(name: String, stages: [RunStage]) {
        self.name = name
        self.stages = stages.sorted { $0.index < $1.index } // Sort based on the index
    }
}
