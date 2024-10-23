//
//  BackgroundTaskManager.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/12/24.
//

import Foundation
import UIKit

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()  // 单例模式
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            // 当后台任务时间到时，系统将调用此 block
            self.endBackgroundTask()
        }

        // 执行后台任务逻辑，如位置跟踪或数据同步
        print("Background task started.")
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
            print("Background task ended.")
        }
    }
}
