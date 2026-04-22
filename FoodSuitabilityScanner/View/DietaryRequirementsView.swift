//
//  DietaryRequirementsView.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI


//holds name and desc of each product, identifiable lets it be used in the ForEach loop
struct DietaryOptions: Identifiable {
    var id = UUID()
    var name: String
    var description: String
}


//lets user set their dietary preferences, reads and writes to DietaryPreferencesModel via @EnvironmentObject to ensure changes made across app

struct DietaryRequirementsView: View {
    @EnvironmentObject private var diet: DietaryPreferencesModel //shared model across app
    
    //controls info popup
    @State private var showInfo = false
    
    //Dietary Option Defintions, used in toggle rows and info popup
    let lifestyleOptions: [DietaryOptions] = [
        DietaryOptions(name: "Vegan", description: "No animal products, including meat, poultry, fish, eggs, dairy, or honey."),
        DietaryOptions(name: "Vegetarian", description: "No meat, poultry or fish."),
        DietaryOptions(name: "Pescatarian", description: "No meat but includes fish and seafoods.")]
    
    let allergyOptions: [DietaryOptions] = [
        DietaryOptions(name: "Nuts", description: "Contains nuts, seeds, or tree nuts."),
        DietaryOptions(name: "Gluten", description: "Contains wheat, barley, rye, spelt, durum, semolina, farro, kamut."),
        DietaryOptions(name: "Dairy", description: "Contains milk, cheese, butter, casein, whey, yoghurt, cream.")]
    
    let religionOptions: [DietaryOptions] = [
        DietaryOptions(name: "Halal", description: "Follows Islamic dietary laws, which prohibit the consumption of pork products and alcohol."),
        DietaryOptions(name: "Kosher", description: "Follows Jewish dietary laws, which prohibit the consumption of pork and shellfish.")]
    
    //options put together for the info button
    var allOptions: [DietaryOptions] {lifestyleOptions + allergyOptions + religionOptions}
    
    var body: some View {
        NavigationView{
            ZStack{
                List{
                    //lifestyle single selection, handled by toggleLifestyle from DietaryPreferencesModel
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
                    
                    //allergies, multi select
                    Section(header: Text("Allergies")
                        .font(.headline))
                    {
                        DietaryToggle(name: "Nuts", isOn: diet.isNutsOn, toggleOn: {diet.isNutsOn.toggle();diet.save()})
                        DietaryToggle(name: "Gluten", isOn: diet.isGlutenOn, toggleOn: {diet.isGlutenOn.toggle();diet.save()})
                        DietaryToggle(name: "Dairy", isOn: diet.isDairyOn, toggleOn: {diet.isDairyOn.toggle();diet.save()})
                        
                    }
                    
                    //religion, multi select
                    Section(header: Text("Religion")
                        .font(.headline))
                    {
                        DietaryToggle(name: "Halal", isOn: diet.isHalalOn, toggleOn: {diet.isHalalOn.toggle();diet.save()})
                        DietaryToggle(name: "Kosher", isOn: diet.isKosherOn, toggleOn: {diet.isKosherOn.toggle();diet.save()})
                    }
                    
                }
                //info about each diet pop up 
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
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {showInfo = true}){
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                    }
                }
            }
            
        }
    }
}
// reusable component used for the 3 groups of diets, and shows if toggle switch is on or off
struct DietaryToggle: View {
    let name : String
    let isOn : Bool
    let toggleOn: () -> Void
    
    var body: some View{
        HStack{
            Text(name)
                .font(.body)
            Spacer()
            
            //toggle displays the current state it is in and calls toggleOn when tapped
            Toggle("", isOn: Binding(get: {isOn}, set: {_ in toggleOn()}))
                .labelsHidden()
                
            
        }
        .padding()
    }
}

// shows a scrollable list of the explanation of each dietary requirement
struct ShowInfoPopUp: View {
    let info : [DietaryOptions]
    let onTap: () -> Void

    var body: some View{
        ZStack{
            
            //dimmed background
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
                
                //scrollable list of all the options
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
                            
                            //a divider placed after each item but not the last one
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
