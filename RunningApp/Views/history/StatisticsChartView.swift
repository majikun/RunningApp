//
//  StatisticsChartView.swift
//  RunningApp
//
//  Created by Jake Ma on 10/25/24.
//
import SwiftUI
import Charts

struct StatisticsChartView: View {
    var runningRecords: FetchedResults<RunningRecord>
    @Binding var dateRange: Date
    var period: StatisticsPeriod

    var body: some View {
        // Prepare your data
        let dayData: [(day: Date, xValue: Int, totalDistance: Double)] = daysInSelectedPeriod().map { day in
            let totalDistance: Double
            switch period {
            case .weekly, .monthly, .yearly:
                totalDistance = runningRecords.filter {
                    Calendar.current.isDate($0.startTime ?? Date(), equalTo: day, toGranularity: period.granularity)
                }
                .reduce(0) { $0 + ($1.totalDistance / 1000) } // Convert to kilometers
            case .overall:
                totalDistance = runningRecords.filter {
                    if let startTime = $0.startTime {
                        return Calendar.current.isDate(startTime, equalTo: day, toGranularity: .year)
                    }
                    return false
                }
                .reduce(0) { $0 + ($1.totalDistance / 1000) }
            }

            // Compute xValue based on the period
            let xValue: Int
            let calendar = Calendar.current
            switch period {
            case .weekly:
                var weekday = calendar.component(.weekday, from: day)
                weekday = (weekday + 5) % 7 + 1 // Adjust to make Monday = 1
                xValue = weekday
            case .monthly:
                xValue = calendar.component(.day, from: day)
            case .yearly:
                xValue = calendar.component(.month, from: day)
            case .overall:
                xValue = calendar.component(.year, from: day)
            }

            return (day: day, xValue: xValue, totalDistance: totalDistance)
        }

        VStack {
            Text(String(format: NSLocalizedString("chart_for_period_format", comment: "Chart title for selected period"), period.localizedTitle(locale: Locale.current)))
                .font(.headline)
                .padding(.bottom, 8)

            Chart {
                ForEach(dayData, id: \.day) { data in
                    if isSelectedBar(day: data.day) {
                        // Bar with annotation for selected bar
                        BarMark(
                            x: .value("X", data.xValue),
                            y: .value("Distance (km)", data.totalDistance)
                        )
                        .foregroundStyle(.blue)
                        .annotation(position: .top) {
                            Text(String(format: "%.2f km", data.totalDistance))
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    } else {
                        // Bar without annotation for other bars
                        BarMark(
                            x: .value("X", data.xValue),
                            y: .value("Distance (km)", data.totalDistance)
                        )
                        .foregroundStyle(.gray)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: xAxisValues()) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            switch period {
                            case .weekly, .monthly, .yearly:
                                Text("\(intValue)")
                            case .overall:
                                Text("\(intValue)")
                            }
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    let location = value.location
                                    let origin = geometry[proxy.plotAreaFrame].origin
                                    let size = geometry[proxy.plotAreaFrame].size
                                    let frame = CGRect(origin: origin, size: size)

                                    // Ensure the tap is within the plot area
                                    guard frame.contains(location) else { return }

                                    // Calculate the x-position relative to the chart's plot area
                                    let xPosition = location.x - frame.minX

                                    // Convert the x-position to the corresponding x-axis value
                                    if let xValue = proxy.value(atX: xPosition, as: Int.self) {
                                        // Map xValue to date based on the current period
                                        if let tappedDate = dateForXValue(xValue: xValue) {
                                            dateRange = tappedDate
                                        }
                                    }
                                }
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private func xAxisValues() -> [Int] {
        switch period {
        case .weekly:
            return Array(1..<8) // 1 to 7
        case .monthly:
            // 显示间隔的天数，例如每隔 5 天
            let calendar = Calendar.current
            let range = calendar.range(of: .day, in: .month, for: dateRange) ?? 1..<32
            // 获取当月的最大天数
            let maxDay = range.upperBound - 1
            // 生成间隔的天数数组
            let intervalDays = stride(from: 1, through: maxDay, by: 5).map { $0 }
            return intervalDays
        case .yearly:
            return Array(1..<13) // 1 to 12
        case .overall:
            return yearsInData()
        }
    }

    private func dateForXValue(xValue: Int) -> Date? {
        let calendar = Calendar.current
        switch period {
        case .weekly:
            guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: dateRange)?.start else {
                return nil
            }
            return calendar.date(byAdding: .day, value: xValue - 1, to: startOfWeek)
        case .monthly:
            guard let startOfMonth = calendar.dateInterval(of: .month, for: dateRange)?.start else {
                return nil
            }
            return calendar.date(byAdding: .day, value: xValue - 1, to: startOfMonth)
        case .yearly:
            guard let startOfYear = calendar.dateInterval(of: .year, for: dateRange)?.start else {
                return nil
            }
            return calendar.date(byAdding: .month, value: xValue - 1, to: startOfYear)
        case .overall:
            var components = calendar.dateComponents([.year], from: dateRange)
            components.year = xValue
            return calendar.date(from: components)
        }
    }

    private func daysInSelectedPeriod() -> [Date] {
        let calendar = Calendar.current
        switch period {
        case .weekly:
            guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: dateRange)?.start else {
                return []
            }
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        case .monthly:
            guard let range = calendar.range(of: .day, in: .month, for: dateRange) else {
                return []
            }
            let startOfMonth = calendar.dateInterval(of: .month, for: dateRange)?.start ?? dateRange
            return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth) }
        case .yearly:
            guard let range = calendar.range(of: .month, in: .year, for: dateRange) else {
                return []
            }
            let startOfYear = calendar.dateInterval(of: .year, for: dateRange)?.start ?? dateRange
            return range.compactMap { calendar.date(byAdding: .month, value: $0 - 1, to: startOfYear) }
        case .overall:
            let years = yearsInData()
            let dates = years.compactMap { year -> Date? in
                let components = DateComponents(year: year)
                return calendar.date(from: components)
            }
            return dates.sorted()
        }
    }

    private func isSelectedBar(day: Date) -> Bool {
        let calendar = Calendar.current
        switch period {
        case .weekly:
            return calendar.isDate(day, inSameDayAs: dateRange)
        case .monthly:
            return calendar.isDate(day, inSameDayAs: dateRange)
        case .yearly:
            return calendar.isDate(day, equalTo: dateRange, toGranularity: .month)
        case .overall:
            return calendar.isDate(day, equalTo: dateRange, toGranularity: .year)
        }
    }

    private func yearsInData() -> [Int] {
        let yearsSet = Set(runningRecords.compactMap { record -> Int? in
            if let date = record.startTime {
                return Calendar.current.component(.year, from: date)
            }
            return nil
        })
        let years = Array(yearsSet).sorted()
        return years
    }
}

extension StatisticsPeriod {
    var granularity: Calendar.Component {
        switch self {
        case .weekly:
            return .day
        case .monthly:
            return .day
        case .yearly:
            return .month
        case .overall:
            return .year
        }
    }
}
