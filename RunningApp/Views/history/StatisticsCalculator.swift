//
//  Calculator.swift
//  RunningApp
//
//  Created by Jake Ma on 10/25/24.
//
import SwiftUI
import CoreData

class StatisticsCalculator {
    static func totalDistance(runningRecords: FetchedResults<RunningRecord>) -> Double {
        runningRecords.reduce(0) { $0 + ($1.totalDistance) } // Convert from meters to kilometers
    }
    
    static func totalRuns(runningRecords: FetchedResults<RunningRecord>) -> Int {
        runningRecords.count
    }
    
    static func totalTime(runningRecords: FetchedResults<RunningRecord>) -> String {
        let totalSeconds = runningRecords.reduce(0) { $0 + $1.totalTime }
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

}
