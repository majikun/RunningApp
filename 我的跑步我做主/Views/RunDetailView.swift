import SwiftUI

struct RunDetailView: View {
    let plan: RunPlan

    @ObservedObject var runManager = RunManager.shared
    @Binding var runRecords: [RunRecord]

    var body: some View {
        VStack {
            if let tracker = runManager.runTracker {
                Text(tracker.planName)
                    .font(.largeTitle)
                    .padding()
                
                Text("总距离: \(Int(tracker.totalDistance)) 米")
                    .font(.title2)
                    .padding()

                if let currentStage = runManager.runTracker?.currentStage {
                    Text("\(currentStage.name): \(Int(currentStage.distance)) 米")
                        .font(.title2)
                        .padding()
                }
                
                Text("当前阶段距离: \(Int(tracker.currentStageDistance)) 米")
                    .font(.title3)
                    .padding()
            } else {
                Text(plan.name)
                    .font(.largeTitle)
                    .padding()
                Text("准备开始训练...")
                    .font(.title2)
                    .padding()
            }

            if !runManager.isRunning {
                Button(action: {
                    runManager.startRun(plan: plan)
                }) {
                    Text("开始跑步")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else if runManager.isRunning {
                HStack {
                    Button(action: {
                        runManager.pauseRun()
                    }) {
                        Text(runManager.isPaused ? "恢复" : "暂停")
                            .font(.title)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        stopRun()
                    }) {
                        Text("停止")
                            .font(.title)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            ScrollView {
                VStack(alignment: .leading) {
                    Text("跑步节奏详情")
                        .font(.headline)
                        .padding(.top, 20)
                    ForEach(plan.stages.sorted(by: { $0.index < $1.index }), id: \.id) { stage in
                        HStack {
                            Text("阶段 \(stage.index + 1)")
                                .font(.subheadline)
                            Spacer()
                            Text(stage.name)
                                .font(.body)
                            Spacer()
                            Text("距离: \(Int(stage.distance)) 米")
                                .font(.body)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if runManager.isRunning, let tracker = runManager.runTracker {
                // 恢复当前正在进行的训练，并继续展示距离
                print("当前的训练正在进行，计划名：\(tracker.planName)，总距离：\(tracker.totalDistance) 米")
                // 你可以在这里触发任何额外的逻辑，例如重新请求 GPS 更新等
            } else {
                print("没有正在进行的训练")
            }
        }
    }

    func stopRun() {
        guard let tracker = runManager.runTracker else { return }

        // 保存跑步记录的逻辑
        let runRecord = RunRecord(
            date: Date(),
            totalDistance: tracker.totalDistance,
            totalDuration: Date().timeIntervalSince(tracker.runStartTime ?? Date()),
            planName: plan.name,
            coordinates: tracker.coordinates
        )
        runRecords.append(runRecord)

        let persistenceRecord = RunningRecord(
            planName: plan.name,
            totalDistance: tracker.totalDistance,
            totalTime: Date().timeIntervalSince(tracker.runStartTime ?? Date()),
            startTime: tracker.runStartTime ?? Date(),
            endTime: Date(),
            coordinates: tracker.coordinates
        )

        do {
            try PersistenceManager.shared.saveRunningRecord(persistenceRecord)
        } catch {
            print("Failed to save record: \(error)")
        }

        // 最后再停止跑步
        runManager.stopRun()
    }
}
