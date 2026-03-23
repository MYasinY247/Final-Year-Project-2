//
//  FoodSuitabilityScannerApp.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 26/01/2026.
//

import SwiftUI
import SwiftData

@main
struct FoodSuitabilityScannerApp: App {
    @StateObject private var diet = DietaryPreferencesModel()
    @AppStorage("fontSize") private var fontSize:String = "Medium"
    
    var size : ContentSizeCategory{
        switch fontSize{
        case "Small": return .small
        case "Large": return .large
            
        default: return .medium
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavBarView()
                .environmentObject(diet)
                .environment(\.sizeCategory, size)
        }
        .modelContainer(for: ScannedProduct.self)
        
    }
}
