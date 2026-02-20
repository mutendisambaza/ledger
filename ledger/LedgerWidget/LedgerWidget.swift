//
//  LedgerWidget.swift
//  LedgerWidget
//
//  Created for Ledger Phase 1
//

import WidgetKit
import SwiftUI

struct LedgerEntry: TimelineEntry {
    let date: Date
    let totalCents: Int
    let totalFormatted: String
}

struct LedgerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LedgerEntry {
        LedgerEntry(date: Date(), totalCents: 0, totalFormatted: "$0.00")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LedgerEntry) -> Void) {
        let reader = WidgetStoreReader()
        let entry = LedgerEntry(
            date: Date(),
            totalCents: reader.todayTotalCents,
            totalFormatted: reader.todayTotalFormatted
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LedgerEntry>) -> Void) {
        let reader = WidgetStoreReader()
        let entry = LedgerEntry(
            date: Date(),
            totalCents: reader.todayTotalCents,
            totalFormatted: reader.todayTotalFormatted
        )
        
        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct LedgerWidgetEntryView: View {
    var entry: LedgerEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        let reader = WidgetStoreReader()
        let isStale = reader.isStale
        switch family {
        case .accessoryRectangular:
            LedgerRectangularView(total: entry.totalFormatted, isStale: isStale)
        case .accessoryInline:
            LedgerInlineView(total: entry.totalFormatted, isStale: isStale)
        case .systemSmall:
            LedgerHomeScreenView(total: entry.totalFormatted, isStale: isStale)
        default:
            LedgerRectangularView(total: entry.totalFormatted, isStale: isStale)
        }
    }
}

struct LedgerWidget: Widget {
    let kind: String = "LedgerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LedgerTimelineProvider()) { entry in
            LedgerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Ledger")
        .description("Today's spending from Gmail receipts")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .systemSmall])
    }
}

#Preview(as: .accessoryRectangular) {
    LedgerWidget()
} timeline: {
    LedgerEntry(date: .now, totalCents: 0, totalFormatted: "$0.00")
}

#Preview(as: .accessoryInline) {
    LedgerWidget()
} timeline: {
    LedgerEntry(date: .now, totalCents: 0, totalFormatted: "$0.00")
}
