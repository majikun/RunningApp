import SwiftUI

struct MainView: View {
    @ObservedObject var runManager = RunManager.shared
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: RunPlan.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RunPlan.name, ascending: true)]
    ) private var runPlans: FetchedResults<RunPlan>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("我的跑步我做主")
                    .font(.largeTitle)
                    .padding()
                
                
                if let tracker = runManager.runTracker, runManager.isRunning {
                    NavigationLink(destination: RunDetailView(), isActive: $runManager.showRunDetail) {
                        Text("继续训练：\(tracker.plan.name!)")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // 修改后的 List 部分
                List {
                    ForEach(runPlans, id: \.objectID) { plan in
                        HStack {
                            // 计划摘要部分，不再可点击
                            NavigationLink(destination: PlanDetailView(plan: plan)) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(plan.name ?? "未知计划")
                                        .font(.headline)
                                    Text("总阶段数: \(plan.stages?.count ?? 0)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("总距离: \(Int(plan.totalDistance)) m")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            HStack(spacing: 10) {
                                if !runManager.isRunning {
                                    Button(action: {
                                        if runManager.isRunning {
                                            runManager.showRunDetail = true
                                        } else {
                                            runManager.startRun(plan: plan)
                                            runManager.showRunDetail = true
                                        }
                                    }) {
                                        Text("开始")
                                            .font(.headline)
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 5)
                                            .background(Color.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .listStyle(PlainListStyle())
                
                Spacer()
                //--------底部按钮---------
                HStack {
                    NavigationLink(destination: HistoryListView()) {
                        Text("历史")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: ManageRunPlansView()) {
                        Text("管理")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: DiagnosticsView()) {
                        Text("诊断")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .sheet(isPresented: $runManager.showPlanDetail) {
            if let selectedPlan = runManager.selectedPlan {
                PlanDetailView(plan: selectedPlan)
            }
        }
    }
}
