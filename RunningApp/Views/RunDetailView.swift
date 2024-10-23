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
                        Text(tracker.planName)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(tracker.currentStageIndex + 1)/\(tracker.stages.count) 阶段")
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
                                Text("\(Int(tracker.totalDistance)) 米")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text("总距离")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(Int(tracker.currentStageDistance)) 米")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text("\(tracker.currentStageName) \(Int(tracker.currentStageObject)) 米")
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
                                    Text(runManager.isPaused ? "恢复" : "暂停")
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
                                    Text("停止")
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
                                Text("阶段进度")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 20)
                                
                                ForEach(0..<tracker.stages.count, id: \.self) { index in
                                    let stage = tracker.stages[index]
                                    let isCurrentStage = index == tracker.currentStageIndex
                                    
                                    HStack(spacing: 16) {
                                        Text("\(index + 1):")
                                            .frame(width: 30, alignment: .leading)
                                            .foregroundColor(isCurrentStage ? .blue : .primary)
                                        Text("\(stage.name ?? "未知阶段")")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(isCurrentStage ? .blue : .primary)
                                        Text("\(Int(stage.distance)) 米")
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
                    Text("没有进行中的训练")
                        .font(.title2)
                        .padding()
                }
            }
            .navigationBarTitle("进行中的训练", displayMode: .inline)
            .preferredColorScheme(.light) // 确保深色模式支持
        }
    }
}
