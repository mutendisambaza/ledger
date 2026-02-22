//
//  CalendarNode.swift
//  ledger
//
//  Calendar day node with color-coded states
//

import SwiftUI

struct CalendarNode: View {
    let date: Date?
    let isToday: Bool
    let isPast: Bool
    let isFuture: Bool
    let isFailed: Bool
    let totalCents: Int
    let onTap: () -> Void

    @State private var isPressed = false

    init(
        date: Date?,
        isToday: Bool = false,
        isPast: Bool = false,
        isFuture: Bool = false,
        isFailed: Bool = false,
        totalCents: Int = 0,
        onTap: @escaping () -> Void = {}
    ) {
        self.date = date
        self.isToday = isToday
        self.isPast = isPast
        self.isFuture = isFuture
        self.isFailed = isFailed
        self.totalCents = totalCents
        self.onTap = onTap
    }

    var body: some View {
        Button(action: {
            if date != nil {
                onTap()
            }
        }) {
            ZStack {
                if let date = date {
                    // Background circle
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 44, height: 44)

                    // Today indicator (white dot in center)
                    if isToday && !isFailed {
                        Circle()
                            .fill(DesignSystem.Colors.glowingWhite)
                            .frame(width: 8, height: 8)
                            .glow(
                                color: .white,
                                radius: 4,
                                intensity: 0.8
                            )
                    }

                    // Failed day indicator (X)
                    if isFailed {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.failedRed)
                    }

                    // Day number (small, bottom-right)
                    if !isFailed {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(dayNumberColor)
                                    .padding(.trailing, 6)
                                    .padding(.bottom, 6)
                            }
                        }
                        .frame(width: 44, height: 44)
                    }
                } else {
                    // Empty cell for padding
                    Color.clear
                        .frame(width: 44, height: 44)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(date == nil)
        .accessibilityLabel(accessibilityLabelText)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if date != nil && !isPressed {
                        withAnimation(.easeIn(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }

    private var backgroundColor: Color {
        if isFailed {
            return DesignSystem.Colors.darkGrey
        } else if isToday {
            return DesignSystem.Colors.sageGreen
        } else if isPast {
            return DesignSystem.Colors.darkGrey
        } else if isFuture {
            return DesignSystem.Colors.mediumGrey.opacity(0.3)
        } else {
            return DesignSystem.Colors.mediumGrey
        }
    }

    private var dayNumberColor: Color {
        if isToday {
            return DesignSystem.Colors.black
        } else if isPast {
            return DesignSystem.Colors.glow(0.4)
        } else {
            return DesignSystem.Colors.glow(0.6)
        }
    }

    private var accessibilityLabelText: String {
        guard let date else { return "No date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let total = String(format: "$%.2f", Double(totalCents) / 100.0)
        return "\(formatter.string(from: date)), \(isFailed ? "over limit" : "within limit"), \(total) spent"
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Calendar Node States")
            .font(DesignSystem.Typography.sectionHeader)
            .foregroundColor(.white)

        HStack(spacing: 16) {
            VStack {
                CalendarNode(
                    date: Date(),
                    isToday: true,
                    isPast: false,
                    isFuture: false,
                    isFailed: false
                )
                Text("Today")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.white)
            }

            VStack {
                CalendarNode(
                    date: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
                    isToday: false,
                    isPast: true,
                    isFuture: false,
                    isFailed: false
                )
                Text("Past")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.white)
            }

            VStack {
                CalendarNode(
                    date: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                    isToday: false,
                    isPast: false,
                    isFuture: true,
                    isFailed: false
                )
                Text("Future")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.white)
            }

            VStack {
                CalendarNode(
                    date: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
                    isToday: false,
                    isPast: true,
                    isFuture: false,
                    isFailed: true
                )
                Text("Failed")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(.white)
            }
        }

        VStack {
            CalendarNode(
                date: nil,
                isToday: false,
                isPast: false,
                isFuture: false,
                isFailed: false
            )
            Text("Empty")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.white)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DesignSystem.Colors.black)
}
