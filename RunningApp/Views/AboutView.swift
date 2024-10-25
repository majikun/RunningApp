//
//  AboutView.swift
//  RunningApp
//
//  Created by Jake Ma on 10/24/24.
//
import SwiftUI
import CoreLocation
import ActivityKit
import os
import MachO

struct AboutView: View { // New AboutView struct
    @State private var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @State private var backgroundRefreshStatus: UIBackgroundRefreshStatus = .denied
    @State private var isTrackingAllowed: Bool = false
    @State private var memoryUsage: UInt64 = 0
    @State private var cpuUsage: Double = 0.0
    @State private var errorLogs: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("about_this_app", comment: ""))
                .font(.largeTitle)
                .padding()
            
            Text(NSLocalizedString("about_description", comment: ""))
                .font(.body)
                .padding()
                .multilineTextAlignment(.center)
            
            Link(NSLocalizedString("github_repository", comment: ""), destination: URL(string: "https://github.com/majikun/RunningApp")!)
                .font(.headline)
                .padding()
                .foregroundColor(.blue)
            
            Spacer()
        }
        .padding()
        
        
        VStack(spacing: 20) {
            Text("Diagnostics")
                .font(.largeTitle)
                .padding()

            // Location Permission Status
            HStack {
                Text("Location Permission: ")
                Spacer()
                Text(statusText(for: locationPermissionStatus))
                Button("Open Settings") {
                    openAppSettings()
                }.opacity(locationPermissionStatus == .authorizedAlways || locationPermissionStatus == .authorizedWhenInUse ? 0 : 1)
            }

            // Background Refresh Status
            HStack {
                Text("Background Refresh: ")
                Spacer()
                Text(backgroundRefreshStatus == .available ? "Enabled" : "Disabled")
                Button("Open Settings") {
                    openAppSettings()
                }.opacity(backgroundRefreshStatus == .available ? 0 : 1)
            }

            // Live Activity Tracking Status
            HStack {
                Text("Live Activity Permission: ")
                Spacer()
                Text(isTrackingAllowed ? "Allowed" : "Not Allowed")
                Button("Open Settings") {
                    openAppSettings()
                }.opacity(isTrackingAllowed ? 0 : 1)
            }

            // CPU Usage
            HStack {
                Text("CPU Usage: ")
                Spacer()
                Text(String(format: "%.2f%%", cpuUsage))
            }

            // Memory Usage
            HStack {
                Text("Memory Usage: ")
                Spacer()
                Text("\(memoryUsage / 1024 / 1024) MB")
            }
            Spacer()
        }
        .padding()
        .onAppear {
            checkPermissions()
            monitorAppResourceUsage()
        }
    }
    
    
    func statusText(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Always Allowed"
        case .authorizedWhenInUse: return "When In Use"
        @unknown default: return "Unknown"
        }
    }

    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    func checkPermissions() {
        let manager = CLLocationManager()
        locationPermissionStatus = manager.authorizationStatus
        backgroundRefreshStatus = UIApplication.shared.backgroundRefreshStatus
        isTrackingAllowed = ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func monitorAppResourceUsage() {
        DispatchQueue.global(qos: .background).async {
            while true {
                self.memoryUsage = self.reportMemory()
                self.cpuUsage = self.reportCPU()
                Thread.sleep(forTimeInterval: 1.0)
            }
        }
    }

    func reportMemory() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard kerr == KERN_SUCCESS else {
            return 0
        }

        return info.resident_size
    }

    func reportCPU() -> Double {
        var threadList: thread_act_array_t?
        var threadCount = mach_msg_type_number_t()
        let kerr = task_threads(mach_task_self_, &threadList, &threadCount)
        guard kerr == KERN_SUCCESS else {
            return -1
        }

        var totalUsageOfCPU: Double = 0.0
        if let threadList = threadList {
            for i in 0..<Int(threadCount) {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let thInfo = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: Int(threadInfoCount)) {
                        thread_info(threadList[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                    }
                }
                guard thInfo == KERN_SUCCESS else { return -1 }
                if threadInfo.flags & TH_FLAGS_IDLE == 0 {
                    totalUsageOfCPU += Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0
                }
            }
        }

        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threadList), vm_size_t(threadCount * UInt32(MemoryLayout<thread_t>.size)))

        return totalUsageOfCPU
    }
}
