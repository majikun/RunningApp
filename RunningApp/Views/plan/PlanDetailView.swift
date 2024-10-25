import SwiftUI

struct PlanDetailView: View {
    let plan: RunPlan
    @ObservedObject var runManager = RunManager.shared
    @State private var showRunDetail = false  // 用于控制 sheet 的呈现

    var body: some View {
        VStack(alignment: .leading) {
            Text(plan.name ?? NSLocalizedString("unknown_plan", comment: "Unknown Plan"))
                .font(.largeTitle)
                .padding()

            Text(NSLocalizedString("stage_details", comment: "Stage Details"))
                .font(.headline)
                .padding(.top)

            List {
                ForEach(plan.stagesArray, id: \.objectID) { stage in
                    HStack {
                        Text(String(format: NSLocalizedString("stage_number", comment: "Stage %d: %@"), stage.index + 1, stage.name ?? NSLocalizedString("unknown_stage", comment: "Unknown Stage")))
                        Spacer()
                        Text(String(format: NSLocalizedString("stage_distance_with_value", comment: "Distance: %d meters"), Int(stage.distance)))
                    }
                }
            }

            Spacer()

            if let tracker = runManager.runTracker, runManager.isRunning, tracker.plan.id == plan.id {
                Text(NSLocalizedString("training_in_progress", comment: "Training in Progress..."))
                    .font(.title2)
                    .foregroundColor(.green)
                    .padding()
                
                Button(action: {
                    showRunDetail = true
                }) {
                    Text(NSLocalizedString("view_current_training", comment: "View Current Training"))
                        .font(.title2)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            } else if runManager.runTracker != nil && runManager.isRunning {
                Text(NSLocalizedString("another_training_in_progress", comment: "Another training is in progress"))
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding()

                Button(action: {
                    showRunDetail = true
                }) {
                    Text(NSLocalizedString("view_current_training", comment: "View Current Training"))
                        .font(.title2)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            } else {
                Button(action: {
                    print(NSLocalizedString("start_running_button_pressed", comment: "Start Running button pressed"))
                    runManager.startRun(plan: plan)
                    showRunDetail = true  // 设置状态变量，触发 sheet
                }) {
                    Text(NSLocalizedString("start_running", comment: "Start Running"))
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
        .navigationBarTitle(NSLocalizedString("plan_details", comment: "Plan Details"), displayMode: .inline)
        .sheet(isPresented: $showRunDetail) {
            RunDetailView()
        }
    }
}
