//
//  NavBar.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI

struct NavBarView: View {
    var body: some View {
        TabView{
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "barcode")
                }
            DietaryRequirementsView()
                .tabItem {
                    Label("Diet", systemImage: "fork.knife")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
#Preview {
    NavBarView()
}
