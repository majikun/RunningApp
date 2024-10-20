//
//  JSONRunPlan.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/13/24.
//

import Foundation
import CoreData

// JSON 文件中的结构
struct JSONRunStage: Codable {
    let index: Int64
    let name: String
    let distance: Double
}

struct JSONRunPlan: Codable {
    let name: String
    let stages: [JSONRunStage]
}
