//
//  RunningApp.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//
import SwiftUI
import CoreLocation
import UserNotifications
import AVFoundation

@main
struct RunningApp: App {
    let persistenceController = CoreDataManager.shared
    
    init() {
        ValueTransformer.setValueTransformer(StringArrayTransformer(), forName: NSValueTransformerName("StringArrayTransformer"))
        CoreDataManager.shared.initializeDefaultPlansIfNeeded()
        
        // 在初始化时检查权限
        checkPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
    
    // 权限检查方法
    func checkPermissions() {
        checkLocationAuthorization()
        checkBackgroundRefreshAuthorization()
        checkNotificationAuthorization()
        checkScreenLockAuthorization()
    }
    
    func checkLocationAuthorization() {
        let locationManager = CLLocationManager()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            print(NSLocalizedString("Location_Authorized", comment: "位置服务已授权"))
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showAlert(title: NSLocalizedString("Location_Disabled_Title", comment: "位置服务未启用"),
                      message: NSLocalizedString("Location_Disabled_Message", comment: "请前往设置以启用位置权限"))
        @unknown default:
            break
        }
    }
    
    func checkBackgroundRefreshAuthorization() {
        if UIApplication.shared.backgroundRefreshStatus == .available {
            print(NSLocalizedString("Background_Refresh_Enabled", comment: "后台刷新已启用"))
        } else if UIApplication.shared.backgroundRefreshStatus == .denied {
            showAlert(title: NSLocalizedString("Background_Refresh_Disabled_Title", comment: "后台刷新未启用"),
                      message: NSLocalizedString("Background_Refresh_Disabled_Message", comment: "请前往设置以启用后台应用刷新"))
        } else if UIApplication.shared.backgroundRefreshStatus == .restricted {
            print(NSLocalizedString("Background_Refresh_Restricted", comment: "后台刷新受限制"))
        }
    }
    
    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                print(NSLocalizedString("Notifications_Authorized", comment: "通知已授权"))
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if granted {
                        print(NSLocalizedString("Notifications_Authorization_Success", comment: "通知授权成功"))
                    } else {
                        print(NSLocalizedString("Notifications_Authorization_Failure", comment: "通知授权失败"))
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    showAlert(title: NSLocalizedString("Notifications_Disabled_Title", comment: "通知未启用"),
                              message: NSLocalizedString("Notifications_Disabled_Message", comment: "请前往设置以启用通知权限"))
                }
            @unknown default:
                break
            }
        }
    }
    
    func checkScreenLockAuthorization() {
        // 检查屏幕锁定权限
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .restricted || authStatus == .denied {
            showAlert(title: NSLocalizedString("Screen_Lock_Disabled_Title", comment: "屏幕锁定未启用"),
                      message: NSLocalizedString("Screen_Lock_Disabled_Message", comment: "请前往设置以启用屏幕锁定权限"))
        }
    }
    
    // 显示弹出提示框
    func showAlert(title: String, message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "设置"), style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "取消"), style: .cancel, handler: nil))
        
        rootViewController.present(alert, animated: true, completion: nil)
    }
}
