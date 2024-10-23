//
//  RunningRecord.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/7/24.
//

import Foundation
import SwiftData
import MapKit

@Model
class RunningRecord: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()  // 唯一标识符
    var planName: String
    var totalDistance: Double
    var totalTime: TimeInterval
    var startTime: Date
    var endTime: Date
    var coordinates: [String]  // 使用字符串保存坐标，格式如 "latitude,longitude"
    
    init(planName: String, totalDistance: Double, totalTime: TimeInterval, startTime: Date, endTime: Date, coordinates: [CLLocationCoordinate2D] = []) {
        self.planName = planName
        self.totalDistance = totalDistance
        self.totalTime = totalTime
        self.startTime = startTime
        self.endTime = endTime
        self.coordinates = coordinates.map { "\($0.latitude),\($0.longitude)" }  // 将坐标转换为字符串
    }
    
    func getCoordinates() -> [CLLocationCoordinate2D] {
        return coordinates.compactMap { coordinateString in
            let components = coordinateString.split(separator: ",").map { Double($0) ?? 0 }
            if components.count == 2 {
                let latitude = components[0]
                let longitude = components[1]
                print("Loaded coordinate: \(latitude), \(longitude)")  // 打印加载的坐标
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            } else {
                print("Error parsing coordinate: \(coordinateString)")  // 如果解析错误，打印错误信息
                return nil
            }
        }
    }

}

