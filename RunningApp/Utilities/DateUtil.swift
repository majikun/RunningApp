//
//  DateUtil.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/21/24.
//

import Foundation

// 辅助方法：格式化日期
func formattedDate(_ date: Date?) -> String {
    guard let date = date else { return "未知日期" }
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

// 格式化时间为 分:秒
func formatTime(_ timeInterval: TimeInterval) -> String {
    let totalSeconds = Int(timeInterval)
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
}
