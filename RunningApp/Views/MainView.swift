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
                Text(LocalizedStringKey("my_running_my_choice"))
                    .font(.largeTitle)
                    .padding()
                
                if let tracker = runManager.runTracker, runManager.isRunning {
                    NavigationLink(destination: RunDetailView(), isActive: $runManager.showRunDetail) {
                        Text(String(format: NSLocalizedString("continue_training", comment: ""), tracker.plan.name ?? ""))
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                List {
                    ForEach(runPlans, id: \RunPlan.objectID) { plan in
                        HStack {
                            NavigationLink(destination: PlanDetailView(plan: plan)) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(plan.name ?? NSLocalizedString("unknown_plan", comment: ""))
                                        .font(.headline)
                                    Text(String(format: NSLocalizedString("total_stages", comment: "Total number of stages in the plan: %d"), plan.stages?.count ?? 0))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(String(format: NSLocalizedString("total_distance_label", comment: "Total distance of the plan: %d meters"), Int(plan.totalDistance)))
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
                                        Text(LocalizedStringKey("start"))
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
                HStack(spacing: 15) { // Adjusted spacing to prevent line breaks
                    NavigationLink(destination: HistoryListView()) {
                        Image(systemName: "clock.fill")
                            .font(.largeTitle)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: StatisticsView()) {
                        Image(systemName: "table.fill")
                            .font(.largeTitle)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: ManageRunPlansView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.largeTitle)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: AboutView()) { // New About button
                        Image(systemName: "info.circle.fill")
                            .font(.largeTitle)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $runManager.showPlanDetail) {
            if let selectedPlan = runManager.selectedPlan {
                PlanDetailView(plan: selectedPlan)
            }
        }
    }
}
