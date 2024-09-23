//
//  RunRecord.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//

import Foundation
import MapKit

struct RunRecord: Identifiable, Codable {
    let id: UUID  // 唯一标识符
    let date: Date  // 训练时间
    let totalDistance: Double  // 总里程（米）
    let totalDuration: TimeInterval  // 总时长（秒）
    let coordinates: [CLLocationCoordinate2D]  // 坐标数组
    let planName: String  // 新增字段，存储 plan 的名称


    // 自定义编码方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(totalDistance, forKey: .totalDistance)
        try container.encode(totalDuration, forKey: .totalDuration)
        try container.encode(planName, forKey: .planName)
        
        // 将 CLLocationCoordinate2D 转换为经纬度的数组
        let latitudeLongitudeArray = coordinates.map { ["lat": $0.latitude, "lon": $0.longitude] }
        try container.encode(latitudeLongitudeArray, forKey: .coordinates)
    }

    // 自定义解码方法
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()  // 如果没有 id，生成新的 UUID
        date = try container.decode(Date.self, forKey: .date)
        totalDistance = try container.decode(Double.self, forKey: .totalDistance)
        totalDuration = try container.decode(TimeInterval.self, forKey: .totalDuration)        
        planName = try container.decode(String.self, forKey: .planName)
        
        // 将解码后的经纬度数组还原为 CLLocationCoordinate2D 数组
        let latitudeLongitudeArray = try container.decode([[String: Double]].self, forKey: .coordinates)
        coordinates = latitudeLongitudeArray.map { CLLocationCoordinate2D(latitude: $0["lat"]!, longitude: $0["lon"]!) }
 
    }

    // 手动指定编码和解码时的键名
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case totalDistance
        case totalDuration
        case planName
        case coordinates
    }

    // 初始化器
    init(id: UUID = UUID(), date: Date, totalDistance: Double, totalDuration: TimeInterval, planName: String, coordinates: [CLLocationCoordinate2D]) {
        self.id = id
        self.date = date
        self.totalDistance = totalDistance
        self.totalDuration = totalDuration
        self.planName = planName
        self.coordinates = coordinates
    }
}
