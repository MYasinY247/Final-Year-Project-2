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
    @EnvironmentObject private var diet: DietaryPreferencesModel
    
    
    @State private var showInfo = false
    
    //Dietary Option Defintions
    let lifestyleOptions: [DietaryOptions] = [
        DietaryOptions(name: "Vegan", description: "No animal products, including meat, poultry, fish, eggs, dairy, or honey."),
        DietaryOptions(name: "Vegetarian", description: "No meat, poultry, fish, eggs, dairy, or honey."),
        DietaryOptions(name: "Pescatarian", description: "No meat but includes fish and seafoods")]
    
    let allergyOptions: [DietaryOptions] = [
        DietaryOptions(name: "Nuts", description: "Contains nuts, seeds, or tree nuts."),
        DietaryOptions(name: "Gluten", description: "Contains wheat, barley, rye, or spelt."),
        DietaryOptions(name: "Dairy", description: "Contains milk, cheese, yogurt, or cream.")]
    
    let religionOptions: [DietaryOptions] = [
        DietaryOptions(name: "Halal", description: "Follows Islamic dietary laws, which prohibit the consumption of pork and other meats considered haram (forbidden in Islam)."),
        DietaryOptions(name: "Kosher", description: "Follows Jewish dietary laws, which prohibit the consumption of pork and shellfish considered chametz (leavened bread or dairy products).")]
    
    //options put together for the info button
    var allOptions: [DietaryOptions] {lifestyleOptions + allergyOptions + religionOptions}
    
    var body: some View {
        NavigationView{
            ZStack{
                List{
                    //lifestyle
                    Section(header: Text("Lifestyle")
                        .font(.headline))
                    {
                        ForEach(lifestyleOptions) { option in
                            DietaryToggle(
                                name : option.name,
                                isOn : diet.selectedLifestyle == option.name,
                                toggleOn:{
                                    diet.toggleLifestyle(option.name)
                                }
                            )
                        }
                    }
                    
                    //allergies
                    Section(header: Text("Allergies")
                        .font(.headline))
                    {
                        DietaryToggle(name: "Nuts", isOn: diet.isNutsOn, toggleOn: {diet.isNutsOn.toggle();diet.save()})
                        DietaryToggle(name: "Gluten", isOn: diet.isGlutenOn, toggleOn: {diet.isGlutenOn.toggle();diet.save()})
                        DietaryToggle(name: "Dairy", isOn: diet.isDairyOn, toggleOn: {diet.isDairyOn.toggle();diet.save()})
                        
                    }
                    
                    //religion
                    Section(header: Text("Religion")
                        .font(.headline))
                    {
                        DietaryToggle(name: "Halal", isOn: diet.isHalalOn, toggleOn: {diet.isHalalOn.toggle();diet.save()})
                        DietaryToggle(name: "Kosher", isOn: diet.isKosherOn, toggleOn: {diet.isKosherOn.toggle();diet.save()})
                    }
                    
                }
                if showInfo{
                    ShowInfoPopUp(
                        info: allOptions,
                        onTap: {
                            showInfo = false
                        }
                    )
                }
            }
            .navigationTitle("Edit Your Diet")
            .navigationBarTitleDisplayMode(.large)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {showInfo = true}){
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
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
                
            
        }
        .padding()
    }
}

struct ShowInfoPopUp: View {
    let info : [DietaryOptions]
    let onTap: () -> Void

    var body: some View{
        ZStack{
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onTap()
                }
            
            VStack(alignment: .leading){
                HStack{
                    Text("Dietary Requirements")
                        .font(.title2)
                    Spacer()
                    
                    Button(action: onTap){
                        Image(systemName: "xmark")
                            .font(.system(size:14, weight: .bold))
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .padding()
                
                ScrollView{
                    VStack(alignment: .leading, spacing:10){
                        ForEach(info) { item in
                            VStack(alignment: .leading, spacing: 4)
                            {
                                Text(item.name)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Text(item.description)
                                    .font(.body)
                            }
                            if item.id != self.info.last!.id{
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxHeight: 360)
                
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground)))
            .padding()
        }
        
        
    
        
            
        
        
    }
}


#Preview {
    DietaryRequirementsView()
        .environmentObject(DietaryPreferencesModel())
}
