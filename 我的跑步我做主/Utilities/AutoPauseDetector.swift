//
//  AutoPauseDetector.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/11/24.
//

import CoreLocation
import CoreMotion

class AutoPauseDetector {
    private var stillnessThreshold: Double = 0.5 // Speed in m/s to determine if user is still
    private var stillnessDuration: TimeInterval = 10 // Duration in seconds to determine stillness
    private var pauseTimer: Timer?
    private var isPaused = false
    private let motionManager = CMMotionManager()

    weak var delegate: AutoPauseDelegate?

    init() {
        startMotionUpdates()
    }

    func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
                guard let data = data, error == nil else { return }
                let acceleration = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
                if acceleration < 0.02 {
                    // Acceleration is very low, user might be still
                }
            }
        }
    }

    func updateSpeed(currentSpeed: CLLocationSpeed) {
        if currentSpeed < stillnessThreshold {
            startPauseTimer()
        } else {
            cancelPauseTimer()
            if isPaused {
                resumeRunning()
            }
        }
    }

    private func startPauseTimer() {
        if pauseTimer == nil {
            pauseTimer = Timer.scheduledTimer(timeInterval: stillnessDuration, target: self, selector: #selector(triggerAutoPause), userInfo: nil, repeats: false)
        }
    }

    private func cancelPauseTimer() {
        pauseTimer?.invalidate()
        pauseTimer = nil
    }

    @objc private func triggerAutoPause() {
        isPaused = true
        delegate?.didAutoPause()
    }

    private func resumeRunning() {
        isPaused = false
        delegate?.didResumeRunning()
    }
}

protocol AutoPauseDelegate: AnyObject {
    func didAutoPause()
    func didResumeRunning()
}
