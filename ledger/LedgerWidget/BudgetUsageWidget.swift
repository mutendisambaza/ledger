import SwiftUI
import WidgetKit

struct BudgetUsageEntry: TimelineEntry {
    let date: Date
    let usedCents: Int
    let limitCents: Int
    let percent: Int
    let ratio: Double
}

struct BudgetUsageProvider: TimelineProvider {
    func placeholder(in context: Context) -> BudgetUsageEntry {
        BudgetUsageEntry(date: Date(), usedCents: 3250, limitCents: 5000, percent: 65, ratio: 0.65)
    }

    func getSnapshot(in context: Context, completion: @escaping (BudgetUsageEntry) -> Void) {
        let reader = WidgetStoreReader()
        completion(
            BudgetUsageEntry(
                date: Date(),
                usedCents: reader.todayTotalCents,
                limitCents: reader.dailyLimitCents,
                percent: reader.budgetUsagePercent,
                ratio: reader.budgetUsageRatio
            )
        )
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetUsageEntry>) -> Void) {
        let reader = WidgetStoreReader()
        let entry = BudgetUsageEntry(
            date: Date(),
            usedCents: reader.todayTotalCents,
            limitCents: reader.dailyLimitCents,
            percent: reader.budgetUsagePercent,
            ratio: reader.budgetUsageRatio
        )

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct BudgetUsageWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: BudgetUsageEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: entry.ratio)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(entry.percent)%")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .widgetLabel("Daily budget")

        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 4) {
                Text("Budget")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(entry.percent)% used")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                ProgressView(value: entry.ratio)
                    .tint(entry.ratio > 1 ? .red : .green)
            }

        case .systemSmall:
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Budget")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(entry.percent)%")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                ProgressView(value: entry.ratio)
                    .tint(entry.ratio > 1 ? .red : .green)
                Text("Used \(currency(entry.usedCents)) / \(currency(entry.limitCents))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

        default:
            VStack(alignment: .leading, spacing: 4) {
                Text("Budget")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(entry.percent)% used")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                ProgressView(value: entry.ratio)
                    .tint(entry.ratio > 1 ? .red : .green)
            }
        }
    }

    private func currency(_ cents: Int) -> String {
        let dollars = Double(cents) / 100.0
        return String(format: "$%.2f", dollars)
    }
}

struct BudgetUsageWidget: Widget {
    let kind: String = "BudgetUsageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BudgetUsageProvider()) { entry in
            BudgetUsageWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Budget Usage")
        .description("Shows percentage of your daily budget used.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .systemSmall])
    }
}
