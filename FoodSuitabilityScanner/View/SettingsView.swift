//
//  Settings.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI
import SwiftData


struct SettingsView: View {
    @EnvironmentObject var diet : DietaryPreferencesModel
    @Environment(\.modelContext) private var modelContext
    @Query private var history :[ScannedProduct]
    
    @AppStorage("fontSize") private var fontSize: String = "Medium"
    @State private var clearDietAlert = false
    @State private var clearHistoryAlert = false
    
    

    var body: some View {
        NavigationView{
            List{
                //font size
                Section{
                    HStack{
                        Label{
                            VStack(alignment: .leading){
                                Text("Font Size")
                                Text("Change the font size of the app")
                                    .font(.caption)
                                    
                            }
                        } icon: {
                            Image(systemName: "pencil")
                        }
                        Spacer()
                        //single select font size
                        Picker("Font Size", selection: $fontSize){
                            Text("Small").tag("Small")
                            Text("Medium").tag("Medium")
                            Text("Large").tag("Large")
                            }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                            
                        }
                    .padding()
                    }
                
                //clear diet
                Section{
                    Button(action: {clearDietAlert = true })
                    {
                        Label {
                            VStack(alignment: .leading, spacing: 5){
                                Text("Clear Dietary Requirement Selection")
                                    .foregroundColor(.red)
                                Text("Turns off all dietary requirement selections")
                                    .font(.caption)
                                
                            }
                            
                        } icon: {
                            Image(systemName: "pencil")
                                .foregroundStyle(Color.red)
                        }
                        
                    }
                    .padding()
                }
                .alert("Clear Dietary Requirements", isPresented: $clearDietAlert){
                    Button("Clear", role: .destructive){diet.resetAll()}
                    Button("Cancel", role: .cancel){}
                }
                    message: {
                            Text("This will turn off all dietary requirement selections.")
                        }
                    
                //clear scan history
                Section{
                    Button(action: {clearHistoryAlert = true}){
                        Label{
                            VStack(alignment: .leading ){
                                Text("Clear Scan History")
                                    .foregroundStyle(Color.red)
                                Text("Removes all entries from the History")
                                    .font(.caption)
                                
                            }
                            
                        }
                        icon: {
                                Image(systemName: "pencil")
                                .foregroundStyle(Color.red)
                            }
                    }
                    .padding()
                
                }
                .alert("Clear Scan History", isPresented: $clearHistoryAlert){
                    Button("Clear", role: .destructive){clearHistory()}
                    Button("Cancel", role: .cancel){}
                    
                } message: {
                    Text("This will remove all scan history entries.")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func clearHistory(){
        for item in history{
            modelContext.delete(item)
        }
    }
}
#Preview {
    SettingsView()
        .environmentObject(DietaryPreferencesModel())
        .modelContainer(for: ScannedProduct.self, inMemory: true)
}
