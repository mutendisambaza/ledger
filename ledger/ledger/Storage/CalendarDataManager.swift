//
//  CalendarDataManager.swift
//  ledger
//
//  Manages calendar-specific data and month navigation
//

import Foundation
import Combine

class CalendarDataManager: ObservableObject {
    @Published var currentMonth: Date
    @Published var selectedDate: Date?

    private let calendar = Calendar.current

    init(currentMonth: Date = Date()) {
        self.currentMonth = calendar.startOfDay(for: currentMonth)
    }

    /// Get the first day of the current month
    var monthStart: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) ?? currentMonth
    }

    /// Get the last day of the current month
    var monthEnd: Date {
        calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) ?? currentMonth
    }

    /// Get all days in the current month
    func daysInMonth() -> [Date] {
        var days: [Date] = []
        var currentDate = monthStart

        while currentDate <= monthEnd {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            if currentDate <= monthStart { break } // Safety check
        }

        return days
    }

    /// Get calendar grid (including padding days from previous/next month)
    func calendarGrid() -> [Date?] {
        var grid: [Date?] = []
        let days = daysInMonth()

        guard let firstDay = days.first else { return grid }

        // Get weekday of first day (0 = Sunday, 6 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1

        // Add nil padding for days before month starts
        for _ in 0..<firstWeekday {
            grid.append(nil)
        }

        // Add all days in month
        grid.append(contentsOf: days)

        // Add nil padding to complete the last week
        while grid.count % 7 != 0 {
            grid.append(nil)
        }

        return grid
    }

    /// Navigate to previous month
    func previousMonth() {
        if let previous = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = previous
        }
    }

    /// Navigate to next month
    func nextMonth() {
        if let next = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = next
        }
    }

    /// Format month and year for display (e.g., "January 2026")
    func formattedMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    /// Check if date is today
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    /// Check if date is in the past
    func isPast(_ date: Date) -> Bool {
        date < calendar.startOfDay(for: Date())
    }

    /// Check if date is in the future
    func isFuture(_ date: Date) -> Bool {
        date > calendar.startOfDay(for: Date())
    }

    /// Get weekday abbreviation (S, M, T, W, T, F, S)
    static func weekdayAbbreviations() -> [String] {
        return ["S", "M", "T", "W", "T", "F", "S"]
    }
}
