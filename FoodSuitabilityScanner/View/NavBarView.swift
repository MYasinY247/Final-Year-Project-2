//
//  NavBar.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI
import SwiftData

struct NavBarView: View {
    var body: some View {
        TabView{
            //scan view tab
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "barcode")
                }
            //dietary requirements tab
            DietaryRequirementsView()
                .tabItem {
                    Label("Diet", systemImage: "fork.knife")
                }
            //history view tab
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
            //settings tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
#Preview {
    NavBarView()
        .environmentObject(DietaryPreferencesModel())
        .modelContainer(for: ScannedProduct.self, inMemory: true)
}
