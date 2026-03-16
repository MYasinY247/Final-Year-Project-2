//
//  FoodSuitabilityScannerApp.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 26/01/2026.
//

import SwiftUI

@main
struct FoodSuitabilityScannerApp: App {
    @StateObject private var diet = DietaryPreferencesModel()
    var body: some Scene {
        WindowGroup {
            NavBarView()
                .environmentObject(diet)
        }
    }
}
