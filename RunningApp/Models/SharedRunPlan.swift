//
//  SharedRunPlan.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/21/24.
//

import Foundation

struct SharedRunPlan: Codable {
    let name: String
    let stages: [SharedRunStage]
}

struct SharedRunStage: Codable {
    let index: Int
    let name: String
    let distance: Double
}
