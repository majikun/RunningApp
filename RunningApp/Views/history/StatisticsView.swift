import SwiftUI
import CoreData
import Charts

struct StatisticsView: View {
    @State private var selectedPeriod: StatisticsPeriod = .weekly
    @State private var selectedDateRange: Date = Date()
    @Environment(\.locale) var locale
    @FetchRequest(
        entity: RunningRecord.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RunningRecord.startTime, ascending: true)]
    ) var runningRecords: FetchedResults<RunningRecord>
    
    var body: some View {
        VStack {
            // Period Selection at the Top
            Picker("", selection: $selectedPeriod) {
                ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                    Text(period.localizedTitle(locale: locale)).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.top)
            
            Spacer()
                .frame(height: 16)
            
            // Switch between different period views
            switch selectedPeriod {
            case .weekly:
                WeeklyStatisticsView(selectedDateRange: $selectedDateRange, runningRecords: runningRecords)
            case .monthly:
                MonthlyStatisticsView(selectedDateRange: $selectedDateRange, runningRecords: runningRecords)
            case .yearly:
                YearlyStatisticsView(selectedDateRange: $selectedDateRange, runningRecords: runningRecords)
            case .overall:
                OverallStatisticsView(runningRecords: runningRecords)
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle(NSLocalizedString("statistics_title", comment: "Statistics view title"))
    }
}

struct WeeklyStatisticsView: View {
    @Binding var selectedDateRange: Date
    var runningRecords: FetchedResults<RunningRecord>
    
    var body: some View {
        VStack {
            // Week Selector
            HStack {
                Button(action: {
                    selectedDateRange = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDateRange) ?? selectedDateRange
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Text(weekRangeText(for: selectedDateRange))
                    .font(.headline)
                    .padding(.horizontal)
                
                Button(action: {
                    selectedDateRange = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDateRange) ?? selectedDateRange
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Chart
            StatisticsChartView(runningRecords: runningRecords, dateRange: $selectedDateRange, period: .weekly)
                .padding(.horizontal)
                .frame(height: 250)
            
            // Summary Data
            SummaryDataView(runningRecords: runningRecords)
                .padding(.top)
        }
    }
    
    private func weekRangeText(for date: Date) -> String {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.dateInterval(of: .weekOfMonth, for: date)?.start else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        let startText = formatter.string(from: startOfWeek)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
        let endText = formatter.string(from: endOfWeek)
        return String(format: NSLocalizedString("week_range_format", comment: "Week range text"), startText, endText)
    }
}

struct MonthlyStatisticsView: View {
    @Binding var selectedDateRange: Date
    var runningRecords: FetchedResults<RunningRecord>
    
    var body: some View {
        VStack {
            // Month Selector
            HStack {
                Button(action: {
                    selectedDateRange = Calendar.current.date(byAdding: .month, value: -1, to: selectedDateRange) ?? selectedDateRange
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Text(monthText(for: selectedDateRange))
                    .font(.headline)
                    .padding(.horizontal)
                
                Button(action: {
                    selectedDateRange = Calendar.current.date(byAdding: .month, value: 1, to: selectedDateRange) ?? selectedDateRange
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Chart
            StatisticsChartView(runningRecords: runningRecords, dateRange: $selectedDateRange, period: .monthly)
                .padding(.horizontal)
                .frame(height: 250)
            
            // Summary Data
            SummaryDataView(runningRecords: runningRecords)
                .padding(.top)
        }
    }
    
    private func monthText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        return formatter.string(from: date)
    }
}

struct YearlyStatisticsView: View {
    @Binding var selectedDateRange: Date
    var runningRecords: FetchedResults<RunningRecord>
    
    var body: some View {
        VStack {
            // Year Selector
            HStack {
                Button(action: {
                    selectedDateRange = Calendar.current.date(byAdding: .year, value: -1, to: selectedDateRange) ?? selectedDateRange
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Text(yearText(for: selectedDateRange))
                    .font(.headline)
                    .padding(.horizontal)
                
                Button(action: {
                    selectedDateRange = Calendar.current.date(byAdding: .year, value: 1, to: selectedDateRange) ?? selectedDateRange
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // Chart
            StatisticsChartView(runningRecords: runningRecords, dateRange: $selectedDateRange, period: .yearly)
                .padding(.horizontal)
                .frame(height: 250)
            
            // Summary Data
            SummaryDataView(runningRecords: runningRecords)
                .padding(.top)
        }
    }
    
    private func yearText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

struct OverallStatisticsView: View {
    var runningRecords: FetchedResults<RunningRecord>
    
    var body: some View {
        VStack {
            // Chart
            StatisticsChartView(runningRecords: runningRecords, dateRange: .constant(Date()), period: .overall)
                .padding(.horizontal)
                .frame(height: 250)
            
            // Summary Data
            SummaryDataView(runningRecords: runningRecords)
                .padding(.top)
        }
    }
}

struct SummaryDataView: View {
    var runningRecords: FetchedResults<RunningRecord>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(format: NSLocalizedString("total_distance_format", comment: "Total distance covered"), StatisticsCalculator.totalDistance(runningRecords: runningRecords)))
                .fontWeight(.bold)
            Text(String(format: NSLocalizedString("total_runs_format", comment: "Total number of runs"), StatisticsCalculator.totalRuns(runningRecords: runningRecords)))
                .fontWeight(.bold)
            Text(String(format: NSLocalizedString("total_time_format", comment: "Total time spent running"), StatisticsCalculator.totalTime(runningRecords: runningRecords)))
                .fontWeight(.bold)
        }
        .padding(.horizontal)
    }
}

// Extension to conditionally apply a view modifier
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


enum StatisticsPeriod: String, CaseIterable {
    case weekly, monthly, yearly, overall
    
    func localizedTitle(locale: Locale) -> String {
        switch self {
        case .weekly:
            return NSLocalizedString("weekly_period", comment: "Weekly period")
        case .monthly:
            return NSLocalizedString("monthly_period", comment: "Monthly period")
        case .yearly:
            return NSLocalizedString("yearly_period", comment: "Yearly period")
        case .overall:
            return NSLocalizedString("overall_period", comment: "Overall period")
        }
    }
}
