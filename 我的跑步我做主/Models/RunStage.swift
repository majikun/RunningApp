//
//  RunStage.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/13/24.
//

import Foundation
import SwiftData

@Model
class RunStage: Identifiable {
    var id = UUID()  // 确保每个阶段都有唯一标识符
    var name: String
    var distance: Double
    var index: Int  // Added to ensure the stage has a specific order

        init(name: String, distance: Double, index: Int) {
            self.name = name
            self.distance = distance
            self.index = index
        }
}
