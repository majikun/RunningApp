//
//  RunningAttributes.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/10/24.
//
import SwiftUI
import ActivityKit
import CoreLocation

struct RunningAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var distance: Double
        var time: TimeInterval
        var pace: Double
    }

    var sessionName: String
}
