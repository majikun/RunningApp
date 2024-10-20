import SwiftUI
import WidgetKit

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<RunningWidgetAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(context.attributes.sessionName)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            if context.state.isPaused {
                Text("已暂停")
                    .font(.title)
                    .foregroundColor(.red)
            } else {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatTime(context.state.totalTime))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.yellow)
                            Text("总时长")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(context.state.totalDistance)) 米")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.green)
                            Text("总距离")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(context.state.currentStageDistance)) 米")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        HStack {
                            Image(systemName: "ruler.fill")
                                .foregroundColor(.purple)
                            Text(context.state.currentStageName + "\(Int(context.state.currentStageObject)) 米")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                }
            }
        }
        .padding()
        .padding(.horizontal)
    }

    // 格式化时间为 分:秒
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
