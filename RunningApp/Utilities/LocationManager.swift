//
//  LocationManager.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/12/24.
//
//

import CoreLocation

// 定义一个协议，用于传递位置更新信息
protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()  // 单例模式
    
    let locationManager = CLLocationManager()
    
    // 定义一个委托，用于通知位置更新
    weak var delegate: LocationManagerDelegate?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()  // 请求始终允许访问位置
        locationManager.allowsBackgroundLocationUpdates = true  // 允许后台位置更新
        locationManager.pausesLocationUpdatesAutomatically = false  // 禁止自动暂停
    }

    // 开始位置更新
    func startTracking() {
        locationManager.startUpdatingLocation()
    }

    // 停止位置更新
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegate - 处理位置更新
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        
        // 打印位置信息
        print("Location updated: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        
        // 通知委托对象位置已更新
        delegate?.didUpdateLocation(currentLocation)
    }

    // 处理错误，例如拒绝位置访问
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).code == CLError.denied.rawValue {
            print("Location access denied. Please enable location services.")
            stopTracking()  // 停止位置更新
        } else {
            print("Failed to update location: \(error.localizedDescription)")
        }
    }
}
