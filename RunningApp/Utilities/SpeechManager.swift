//
//  SpeechManager.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//
import Foundation
import AVFoundation

class SpeechManager {
    static let shared = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {
        // 监听中断通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    // 配置音频会话
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    func announce(_ message: String) {
        configureAudioSession()  // 配置音频会话
        
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.languageCode == "zh" ? "zh-CN" : "en-US")
        synthesizer.speak(utterance)
    }

    // 语音提示阶段
    func announceStage(_ stage: String, distance: Double) {
        configureAudioSession()  // 配置音频会话
        
        let message = String(format: NSLocalizedString("announce_stage", comment: "Start %@ %d meters"), stage, Int(distance))
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.languageCode == "zh" ? "zh-CN" : "en-US")
        synthesizer.speak(utterance)
    }
    
    // 语音提示训练完成
    func announceCompletion(totalDistance: Double) {
        configureAudioSession()  // 配置音频会话
        
        let message = String(format: NSLocalizedString("announce_completion", comment: "Congratulations on completing your training, covering a total of %d meters"), Int(totalDistance))
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.languageCode == "zh" ? "zh-CN" : "en-US")
        synthesizer.speak(utterance)
    }
    
    // 处理中断事件
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // 中断开始，可以选择暂停当前的语音提示
            print("Audio session interrupted")
        case .ended:
            // 中断结束，恢复音频会话并继续播放语音提示
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // 可以继续播放
                    configureAudioSession()
                }
            }
        default:
            break
        }
    }
}
