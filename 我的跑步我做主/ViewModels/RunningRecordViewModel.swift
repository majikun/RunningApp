//
//  RunningRecordViewModel.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/7/24.
//

import Foundation
import MapKit

struct RunningRecordViewModel: Identifiable {
    var id: UUID
    var planName: String
    var totalDistance: String
    var totalTime: String
    var startTime: String
    var endTime: String
    var coordinates: [CLLocationCoordinate2D]  // 直接使用 CLLocationCoordinate2D
    
    init(record: RunningRecord) {
        self.id = record.id
        self.planName = record.planName
        self.totalDistance = "\(record.totalDistance) meters"
        self.totalTime = String(format: "%.2f seconds", record.totalTime)
        self.startTime = DateFormatter.localizedString(from: record.startTime, dateStyle: .short, timeStyle: .short)
        self.endTime = DateFormatter.localizedString(from: record.endTime, dateStyle: .short, timeStyle: .short)
        self.coordinates = record.getCoordinates()  // 获取转换后的坐标数据
    }
}
