//
//  DietaryRequirements.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI

struct DietaryOptions: Identifiable {
    var id = UUID()
    var name: String
    var description: String
}



struct DietaryRequirementsView: View {
    // lifestyle, single selection
    @State private var selectedLifestyle: String? = nil
    
    //allergies, multi selection
    @State private var isNutsOn = false
    @State private var isGlutenOn = false
    @State private var isDairyOn = false
    
    //religions, multi selection
    @State private var isHalalOn = false
    @State private var isKosherOn = false
    
    //Dietary Option Defintions
    let LifestyleOptions: [DietaryOptions] = [
        DietaryOptions(name: "Vegan", description: "No animal products, including meat, poultry, fish, eggs, dairy, or honey."),
        DietaryOptions(name: "Vegetarian", description: "No meat, poultry, fish, eggs, dairy, or honey."),
        DietaryOptions(name: "Pescatarian", description: "No meat but includes fish and seafoods")]
    
    let AllergyOptions: [DietaryOptions] = [
        DietaryOptions(name: "Nuts", description: "Contains nuts, seeds, or tree nuts."),
        DietaryOptions(name: "Gluten", description: "Contains wheat, barley, rye, or spelt."),
        DietaryOptions(name: "Dairy", description: "Contains milk, cheese, yogurt, or cream.")]
    
    let ReligionOptions: [DietaryOptions] = [
        DietaryOptions(name: "Halal", description: "Follows Islamic dietary laws, which prohibit the consumption of pork and other meats considered haram (forbidden in Islam)."),
        DietaryOptions(name: "Kosher", description: "Follows Jewish dietary laws, which prohibit the consumption of pork and shellfish considered chametz (leavened bread or dairy products).")]
    
    //options put together for the info button
    var allOptions: [DietaryOptions] {LifestyleOptions + AllergyOptions + ReligionOptions}
    
    var body: some View {
        NavigationView{
            ZStack{
                List{
                    Section(header: Text("Lifestyle")
                        .font(.title))
                    {
                        ForEach(LifestyleOptions) { option in
                            DietaryToggle(
                                name : option.name,
                                isOn : selectedLifestyle == option.name,
                                toggleOn:{
                                    if selectedLifestyle == option.name{
                                        selectedLifestyle = nil
                                    }
                                    else{
                                        selectedLifestyle = option.name
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}
struct DietaryToggle: View {
    let name : String
    let isOn : Bool
    let toggleOn: () -> Void
    
    var body: some View{
        HStack{
            Text(name)
                .font(.body)
            Spacer()
            
            Toggle("", isOn: Binding(get: {isOn}, set: {_ in toggleOn()}))
                .labelsHidden()
                .hidden()
            
        }
        .padding()
    }
}


#Preview {
    DietaryRequirementsView()
}
