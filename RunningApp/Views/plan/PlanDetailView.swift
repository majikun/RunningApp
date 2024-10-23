import SwiftUI

struct PlanDetailView: View {
    let plan: RunPlan
    @ObservedObject var runManager = RunManager.shared
    @State private var showRunDetail = false  // 用于控制 sheet 的呈现

    var body: some View {
        VStack(alignment: .leading) {
            Text(plan.name ?? "未知计划")
                .font(.largeTitle)
                .padding()

            Text("阶段详情")
                .font(.headline)
                .padding(.top)

            List {
                ForEach(plan.stagesArray, id: \.objectID) { stage in
                    HStack {
                        Text("阶段 \(stage.index + 1): \(stage.name ?? "未知阶段")")
                        Spacer()
                        Text("距离: \(Int(stage.distance)) 米")
                    }
                }
            }

            Spacer()

            if let tracker = runManager.runTracker, runManager.isRunning, tracker.plan.id == plan.id {
                Text("正在进行中...")
                    .font(.title2)
                    .foregroundColor(.green)
                    .padding()
                
                Button(action: {
                    showRunDetail = true
                }) {
                    Text("查看进行中的训练")
                        .font(.title2)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            } else if runManager.runTracker != nil && runManager.isRunning {
                Text("已有进行中的训练")
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding()

                Button(action: {
                    showRunDetail = true
                }) {
                    Text("查看进行中的训练")
                        .font(.title2)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                Button(action: {
                    print("点击开始跑步按钮")
                    runManager.startRun(plan: plan)
                    showRunDetail = true  // 设置状态变量，触发 sheet
                }) {
                    Text("开始跑步")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationBarTitle("计划详情", displayMode: .inline)
        .sheet(isPresented: $showRunDetail) {
            RunDetailView()
        }
    }
}
