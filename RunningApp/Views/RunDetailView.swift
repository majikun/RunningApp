import SwiftUI
import MapKit

struct RunDetailView: View {
    @ObservedObject var runManager = RunManager.shared
    @State private var scrollProxy: ScrollViewProxy? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                if let tracker = runManager.runTracker {
                    // 计划名称和目标的动态变化
                    HStack {
                        Text(NSLocalizedString(tracker.planName, comment: ""))
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text(String(format: NSLocalizedString("stage_progress", comment: "%d/%d Stages"), tracker.currentStageIndex + 1, tracker.stages.count))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // 卡片样式的总距离和控制按钮部分
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(format: NSLocalizedString("total_distance_label", comment: "Total Distance: %d meters"), Int(tracker.totalDistance)))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text(NSLocalizedString("total_distance", comment: ""))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(format: NSLocalizedString("current_stage_distance_label", comment: "Current Stage Distance: %d meters"), Int(tracker.currentStageDistance)))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text(String(format: NSLocalizedString("current_stage", comment: "%@ %d meters"), tracker.currentStageName, Int(tracker.currentStageObject)))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        
                        // 控制按钮
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    runManager.pauseRun()
                                }
                            }) {
                                HStack {
                                    Image(systemName: runManager.isPaused ? "play.fill" : "pause.fill")
                                    Text(NSLocalizedString(runManager.isPaused ? "resume" : "pause", comment: ""))
                                        .fontWeight(.bold)
                                }
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .scaleEffect(runManager.isPaused ? 1.0 : 1.1)
                            }
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    runManager.stopRun()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "stop.fill")
                                    Text(NSLocalizedString("stop", comment: ""))
                                        .fontWeight(.bold)
                                }
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .scaleEffect(1.0)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // 滚动视图中的阶段进度
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(NSLocalizedString("stage_progress_title", comment: "Stage Progress"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 20)
                                
                                ForEach(0..<tracker.stages.count, id: \.self) { index in
                                    let stage = tracker.stages[index]
                                    let isCurrentStage = index == tracker.currentStageIndex
                                    
                                    HStack(spacing: 16) {
                                        Text(String(format: NSLocalizedString("stage_index", comment: "Stage %d"), index + 1))
                                            .frame(width: 30, alignment: .leading)
                                            .foregroundColor(isCurrentStage ? .blue : .primary)
                                        Text(stage.name ?? NSLocalizedString("unknown_stage", comment: ""))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(isCurrentStage ? .blue : .primary)
                                        Text(String(format: NSLocalizedString("stage_distance_with_value", comment: "%d meters"), Int(stage.distance)))
                                            .frame(width: 80, alignment: .trailing)
                                            .foregroundColor(isCurrentStage ? .blue : .primary)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 20)
                                    .background(isCurrentStage ? Color.blue.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                                    .id(index)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                        .scrollIndicators(.visible)
                        .onAppear {
                            scrollProxy = proxy
                        }
                        .onChange(of: tracker.currentStageIndex) { index in
                            withAnimation {
                                scrollProxy?.scrollTo(index, anchor: .center)
                            }
                        }
                    }
                } else {
                    Text(NSLocalizedString("no_active_training", comment: "No Active Training"))
                        .font(.title2)
                        .padding()
                }
            }
            .navigationBarTitle(NSLocalizedString("active_training", comment: "Active Training"), displayMode: .inline)
            .preferredColorScheme(.light) // 确保深色模式支持
        }
    }
}
