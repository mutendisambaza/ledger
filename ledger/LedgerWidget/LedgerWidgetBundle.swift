//
//  LedgerWidgetBundle.swift
//  LedgerWidget
//
//  Created for Ledger Phase 1
//

import WidgetKit
import SwiftUI

@main
struct LedgerWidgetBundle: WidgetBundle {
    var body: some Widget {
        LedgerWidget()
        BudgetUsageWidget()
    }
}
