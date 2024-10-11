import SwiftUI

struct ContentView: View {
    @State private var runPlans: [RunPlan] = []  // 从 SwiftData 加载
    @State private var showingAddPlanSheet = false
    @State private var showingEditPlanSheet = false
    @State private var selectedPlan: RunPlan?
    @State private var runRecords: [RunRecord] = []  // 添加一个 @State 的 runRecords 变量

    @ObservedObject var runManager = RunManager.shared

    var body: some View {
        NavigationView {
            VStack {
                Text("选择一个跑步节奏")
                    .font(.largeTitle)
                    .padding()

                // 显示所有计划
                List {
                    ForEach($runPlans, id: \.id) { $plan in
                        NavigationLink(destination: RunDetailView(plan: plan, runRecords: $runRecords)) {
                            HStack {
                                Text(plan.name)
                            }
                            .font(.title)
                        }
                    }
                    .onDelete(perform: deletePlan)  // 支持删除功能
                }
                
                if let tracker = runManager.runTracker, runManager.isRunning {
                    NavigationLink(destination: RunDetailView(plan: tracker.plan, runRecords: $runRecords)) {
                        Text("进行中的训练：\(tracker.plan.name)")
                            .font(.title)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    Button(action: {
                        print("没有进行中的训练")
                    }) {
                        Text("进行中的训练：无")
                            .font(.title)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }

                NavigationLink(destination: RunningRecordListView()) {
                    Text("训练记录")
                        .font(.title)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()

                NavigationLink(destination: RunPlanListView()) {
                    Text("管理跑步计划")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .onAppear {
                runPlans = PersistenceManager.shared.fetchAllRunPlans().sorted(by: { $0.name < $1.name })
            }

        }
    }

    // 删除计划
    @MainActor private func deletePlan(at offsets: IndexSet) {
        for index in offsets {
            let plan = runPlans[index]
            do {
                try PersistenceManager.shared.deleteRunPlan(plan)
                runPlans.remove(at: index)
            } catch {
                print("Failed to delete plan: \(error)")
            }
        }
    }
}
