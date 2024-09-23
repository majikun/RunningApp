//
//  JSONRunPlan.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/13/24.
//

import Foundation
// JSON 文件中的结构
struct JSONRunStage: Codable {
    let index: Int
    let name: String
    let distance: Double
}

struct JSONRunPlan: Codable {
    let name: String
    let stages: [JSONRunStage]
}

// 通过 JSON 文件加载数据
func loadRunPlansFromFile() -> [RunPlan]? {
    guard let url = Bundle.main.url(forResource: "runplans", withExtension: "json") else {
        print("runplans.json not found")
        return nil
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let jsonRunPlans = try decoder.decode([JSONRunPlan].self, from: data)

        // 将 JSON 解析后的数据转换为 SwiftData 模型，并为每个 RunStage 分配索引
        let runPlans = jsonRunPlans.map { jsonPlan in
            RunPlan(
                name: jsonPlan.name,
                stages: jsonPlan.stages.enumerated().map { (index, stage) in
                    RunStage(name: stage.name, distance: stage.distance, index: stage.index)  // 添加 index
                }
            )
        }
        return runPlans
    } catch {
        print("Failed to parse JSON: \(error)")
        return nil
    }
}
