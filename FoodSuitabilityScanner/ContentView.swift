//
//  ContentView.swift
//  FoodSuitabilityScanner
// yeo it worked, so commit then push
//  Created by Muhammad Yasin Yahya on 26/01/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavBarView()
    }
}

#Preview {
    ContentView()
        .environmentObject(DietaryPreferencesModel())
}
