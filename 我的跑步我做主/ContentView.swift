import SwiftUI

struct ContentView: View {
    @State private var runPlans: [RunPlan] = []  // 从 SwiftData 加载
    @State private var showingAddPlanSheet = false
    @State private var showingEditPlanSheet = false
    @State private var selectedPlan: RunPlan?
    @State private var runRecords: [RunRecord] = []  // 添加一个 @State 的 runRecords 变量


    var body: some View {
        NavigationView {
            VStack {
                Text("选择一个跑步节奏")
                    .font(.largeTitle)
                    .padding()

                // 显示所有计划
                List {
                    ForEach(runPlans, id: \.name) { plan in
                        NavigationLink(destination: RunDetailView(plan: plan, runRecords: $runRecords)) {
                            Text("\(plan.name)")
                                .font(.title)
                        }
                    }
                    .onDelete(perform: deletePlan)  // 支持删除功能
                }
                
                // 修改为不传递 runRecords 参数
                NavigationLink(destination: RunningRecordListView()) {
                    Text("训练记录")
                        .font(.title)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // 添加新计划按钮
                Button(action: {
                    showingAddPlanSheet = true
                }) {
                    Text("添加新跑步计划")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showingAddPlanSheet, content: {
                    AddRunPlanView { newPlan in
                        runPlans.append(newPlan)
                        do {
                            try PersistenceManager.shared.saveRunPlan(newPlan)
                        } catch {
                            print("Failed to save plan: \(error)")
                        }
                    }
                })
                
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
                runPlans = PersistenceManager.shared.fetchAllRunPlans()
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
