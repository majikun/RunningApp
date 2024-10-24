import SwiftUI
import MapKit

struct RunningRecordDetailView: View {
    @ObservedObject var record: RunningRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(String(format: NSLocalizedString("plan_name_with_value", comment: "Plan Name: %@"), record.planName ?? NSLocalizedString("unknown_plan", comment: "")))
                    .font(.headline)
                Text(String(format: NSLocalizedString("total_distance", comment: "Total Distance: %d meters"), Int(record.totalDistance)))
                Text(String(format: NSLocalizedString("total_time", comment: "Total Time: %d seconds"), Int(record.totalTime)))
                Text(String(format: NSLocalizedString("start_time", comment: "Start Time: %@"), formattedDate(record.startTime)))
                Text(String(format: NSLocalizedString("end_time", comment: "End Time: %@"), formattedDate(record.endTime)))
                
                // 地图视图
                MapView(coordinates: record.getCoordinates())
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding()

                // 阶段结果列表
                Text(NSLocalizedString("stage_results", comment: "Stage Results"))
                    .font(.headline)
                    .padding(.top)
                ForEach(record.stagesArray, id: \ .objectID) { stage in
                    VStack(alignment: .leading) {
                        Text(String(format: NSLocalizedString("stage_name_with_value", comment: "Stage Name: %@"), stage.stageName ?? NSLocalizedString("unknown_stage", comment: "")))
                        Text(String(format: NSLocalizedString("planned_distance", comment: "Planned Distance: %d meters"), Int(stage.plannedDistance)))
                        Text(String(format: NSLocalizedString("actual_distance", comment: "Actual Distance: %d meters"), Int(stage.actualDistance)))
                        Text(String(format: NSLocalizedString("time_taken", comment: "Time Taken: %d seconds"), Int(stage.timeTaken)))
                    }
                    .padding(.vertical, 5)
                }
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("running_details", comment: "Running Details"))
    }
}
