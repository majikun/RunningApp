//
//  AutoPauseDetector.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 10/11/24.
//

import CoreMotion

class AutoPauseDetector {
    private var stillnessDuration: TimeInterval = 10 // Seconds
    private var pauseTimer: Timer?
    private let motionActivityManager = CMMotionActivityManager()
    private var currentSpeed: CLLocationSpeed = 0.0
    private var isStationary = false

    weak var delegate: AutoPauseDelegate?

    init() {
        startMotionActivityUpdates()
    }

    func startMotionActivityUpdates() {
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main) { [weak self] (activity) in
                guard let self = self, let activity = activity else { return }
                self.isStationary = activity.stationary
                self.evaluateMotionState()
            }
        }
    }

    func updateSpeed(currentSpeed: CLLocationSpeed) {
        self.currentSpeed = currentSpeed
        evaluateMotionState()
    }

    private func evaluateMotionState() {
        if isStationary && currentSpeed < 0.5 {
            startPauseTimer()
        } else {
            cancelPauseTimer()
            if isPaused {
                resumeRunning()
            }
        }
    }

    private var isPaused = false

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
        if !isPaused {
            isPaused = true
            delegate?.didAutoPause()
        }
    }

    private func resumeRunning() {
        if isPaused {
            isPaused = false
            delegate?.didResumeRunning()
        }
    }
}


protocol AutoPauseDelegate: AnyObject {
    func didAutoPause()
    func didResumeRunning()
}

