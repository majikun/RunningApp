//
//  RunStage.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//
import Foundation
import SwiftData

@Model
class RunPlan {
    var name: String
    var stages: [RunStage]  // 非持久化的结构体数组
    
    init(name: String, stages: [RunStage]) {
        self.name = name
        self.stages = stages
    }
}

// 这个结构体不是模型，不会被持久化，只是作为属性
struct RunStage {
    var name: String
    var distance: Double
}

