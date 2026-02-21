//
//  CalendarView.swift
//  ledger
//
//  Full-screen monthly calendar with spend tracking
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var ledgerStore: LedgerStore
    @StateObject private var calendarManager = CalendarDataManager()
    @StateObject private var limitManager = SpendLimitManager()

    @State private var selectedDay: Date?

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.black
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.lg) {
                // Header with month/year and navigation
                header

                // Weekday labels
                weekdayHeader

                // Calendar grid
                calendarGrid

                Spacer()

                // Selected day details
                if let selectedDay = selectedDay {
                    dayDetailsCard(for: selectedDay)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xl)
        }
        .onSwipe(right: {
            router.goBack()
        })
    }

    private var header: some View {
        HStack {
            // Previous month button
            Button(action: {
                withAnimation(Animation.glassMorphSpring) {
                    calendarManager.previousMonth()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.chromeSilver)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            // Month and year
            Text(calendarManager.formattedMonthYear())
                .font(DesignSystem.Typography.calendarHeader)
                .foregroundColor(DesignSystem.Colors.glowingWhite)
                .glow(
                    color: DesignSystem.Colors.glowingWhite,
                    radius: DesignSystem.Effects.glowRadius
                )

            Spacer()

            // Next month button
            Button(action: {
                withAnimation(Animation.glassMorphSpring) {
                    calendarManager.nextMonth()
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.chromeSilver)
                    .frame(width: 44, height: 44)
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 8) {
            ForEach(CalendarDataManager.weekdayAbbreviations(), id: \.self) { weekday in
                Text(weekday)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.chromeSilver)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xxs)
    }

    private var calendarGrid: some View {
        let grid = calendarManager.calendarGrid()
        let rows = stride(from: 0, to: grid.count, by: 7).map {
            Array(grid[$0..<min($0 + 7, grid.count)])
        }

        return VStack(spacing: 12) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: 8) {
                    ForEach(0..<rows[rowIndex].count, id: \.self) { colIndex in
                        if let date = rows[rowIndex][colIndex] {
                            CalendarNode(
                                date: date,
                                isToday: calendarManager.isToday(date),
                                isPast: calendarManager.isPast(date),
                                isFuture: calendarManager.isFuture(date),
                                isFailed: limitManager.isDayOverLimit(
                                    date: date,
                                    transactions: ledgerStore.transactions
                                ),
                                totalCents: limitManager.getTotalForDay(
                                    date: date,
                                    transactions: ledgerStore.transactions
                                ),
                                onTap: {
                                    withAnimation(Animation.glassMorphSpring) {
                                        selectedDay = date
                                    }
                                }
                            )
                            .accessibilityLabel(calendarAccessibilityLabel(for: date))
                            .frame(maxWidth: .infinity)
                        } else {
                            CalendarNode(
                                date: nil,
                                onTap: {}
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    private func dayDetailsCard(for date: Date) -> some View {
        let totalCents = limitManager.getTotalForDay(date: date, transactions: ledgerStore.transactions)
        let isOverLimit = limitManager.isDayOverLimit(date: date, transactions: ledgerStore.transactions)
        let dayTransactions = getDayTransactions(for: date)

        return SageGlassCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                // Date header
                HStack {
                    Text(formatDate(date))
                        .font(DesignSystem.Typography.cardHeader)
                        .foregroundColor(DesignSystem.Colors.glowingWhite)

                    Spacer()

                    // Close button
                    Button(action: {
                        withAnimation(Animation.glassMorphSpring) {
                            selectedDay = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.chromeSilver)
                    }
                }

                // Total amount
                HStack {
                    Text("Total:")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.glow(0.7))

                    Spacer()

                    Text(formatCents(totalCents))
                        .font(DesignSystem.Typography.amountMedium)
                        .foregroundColor(
                            isOverLimit
                                ? DesignSystem.Colors.failedRed
                                : DesignSystem.Colors.sageGreen
                        )
                }

                // Limit status
                if isOverLimit {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(DesignSystem.Colors.failedRed)
                        Text("Over limit by \(formatCents(totalCents - limitManager.dailyLimitCents))")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.failedRed)
                    }
                }

                // Transaction count
                if dayTransactions.count > 0 {
                    Divider()
                        .background(DesignSystem.Colors.chrome(0.3))

                    Text("\(dayTransactions.count) transaction\(dayTransactions.count == 1 ? "" : "s")")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.glow(0.6))
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func getDayTransactions(for date: Date) -> [Transaction] {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date

        return ledgerStore.transactions.filter {
            $0.timestamp >= dayStart && $0.timestamp < dayEnd
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    private func formatCents(_ cents: Int) -> String {
        let dollars = Double(cents) / 100.0
        return String(format: "$%.2f", dollars)
    }

    private func calendarAccessibilityLabel(for date: Date) -> String {
        let totalCents = limitManager.getTotalForDay(date: date, transactions: ledgerStore.transactions)
        let overLimit = limitManager.isDayOverLimit(date: date, transactions: ledgerStore.transactions)
        return "\(formatDate(date)), \(overLimit ? "over limit" : "within limit"), \(formatCents(totalCents)) spent"
    }
}

#Preview {
    CalendarView()
        .environmentObject(NavigationRouter())
        .environmentObject(LedgerStore.shared)
}
