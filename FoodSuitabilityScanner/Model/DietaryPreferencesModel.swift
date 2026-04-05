//
//  DietaryPreferencesModel.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 15/03/2026.
//

import SwiftUI
import Combine

//observableobject automatically updates view when a value changes
class DietaryPreferencesModel:ObservableObject {
    
    //lifestyle single select
    @Published var selectedLifestyle: String = ""
    
    //allergies multi select
    @Published var isNutsOn: Bool = false
    @Published var isGlutenOn: Bool = false
    @Published var isDairyOn: Bool = false
    
    //religion multi select
    @Published var isHalalOn: Bool = false
    @Published var isKosherOn: Bool = false
    
    //init will load save preferences automatically, user selection persists b/w app sessions
    init(){
        let defaults = UserDefaults.standard
        selectedLifestyle = defaults.string(forKey: "selectedLifestyle") ?? ""
        isNutsOn = defaults.bool(forKey: "isNutsOn")
        isGlutenOn = defaults.bool(forKey: "isGlutenOn")
        isDairyOn = defaults.bool(forKey: "isDairyOn")
        isHalalOn = defaults.bool(forKey: "isHalalOn")
        isKosherOn = defaults.bool(forKey: "isKosherOn")
    }
    
    //saving preferences
    func save(){
        let defaults = UserDefaults.standard
        defaults.set(selectedLifestyle, forKey: "selectedLifestyle")
        defaults.set(isNutsOn, forKey: "isNutsOn")
        defaults.set(isGlutenOn, forKey: "isGlutenOn")
        defaults.set(isDairyOn, forKey: "isDairyOn")
        defaults.set(isHalalOn, forKey: "isHalalOn")
        defaults.set(isKosherOn, forKey: "isKosherOn")
    }
    
    // underscore means that i dont need parameter label diet: "vegan" and just write "vegan"
    func toggleLifestyle(_ diet:String){
        if selectedLifestyle == diet{
            selectedLifestyle = ""
        }else{
            selectedLifestyle = diet
        }
        save()
        
    }
    
    //computed properties dont store in memory calcs value dynamically when needed
    var activeLifestyle: String? {
        return selectedLifestyle.isEmpty ? nil : selectedLifestyle
    }
    
    //returns a list of currently active preferences
    var activeFilters: [String]{
        var filters: [String] = []
        if let lifestyle = activeLifestyle {filters.append(lifestyle)}
        if isNutsOn { filters.append("Nuts") }
        if isGlutenOn { filters.append("Gluten") }
        if isDairyOn { filters.append("Dairy") }
        if isHalalOn { filters.append("Halal") }
        if isKosherOn { filters.append("Kosher") }
        return filters
    }
    
    //resets all the user selected preferences
    func resetAll(){
        selectedLifestyle = ""
        isNutsOn = false
        isGlutenOn = false
        isDairyOn = false
        isHalalOn = false
        isKosherOn = false
        save()
    }
}
