//
//  RunningRecordExt.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/21/24.
//

import Foundation
import CoreData
import CoreLocation  // 如果需要使用 CLLocationCoordinate2D

import CoreLocation

extension RunningRecord {
    func getCoordinates() -> [CLLocationCoordinate2D] {
        guard let coordinateStrings = self.coordinates else { return [] }
        return coordinateStrings.compactMap { coordinateString in
            let components = coordinateString.split(separator: ",").compactMap { Double($0) }
            if components.count == 2 {
                return CLLocationCoordinate2D(latitude: components[0], longitude: components[1])
            } else {
                return nil
            }
        }
    }

    var stagesArray: [RunStageResult] {
        let set = stages as? Set<RunStageResult> ?? []
        return set.sorted { $0.index < $1.index }
    }
}


extension RunStageResult {

    // 计算属性：timeTaken
    var timeTaken: TimeInterval {
        guard let startTime = startTime, let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
}
