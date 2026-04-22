//
//  SettingsView.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI
import SwiftData


struct SettingsView: View {
    @EnvironmentObject var diet : DietaryPreferencesModel  //shared model across app
    @Environment(\.modelContext) private var modelContext //access to SwiftData
    @Query private var history :[ScannedProduct] //fetch records from SwiftData
    
    @AppStorage("fontSize") private var fontSize: String = "Medium" //default font size when user first launches app
    @State private var clearDietAlert = false
    @State private var clearHistoryAlert = false
    
    

    var body: some View {
        NavigationView{
            List{
                //font size applies to whole app
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
                //destructive in red to follow Apple design
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
                                Text("Clear History")
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
                    Button("Clear", role: .destructive){clearHistory()} //deletes all ScannedProduct records
                    Button("Cancel", role: .cancel){}
                    
                } message: {
                    Text("This will remove all scan history entries.")
                }

                Section{
                    Label{
                        VStack(alignment: .leading)
                        {
                            //notice reminding users the app is a tool
                            Text("Important Notice")
                            Text("This app is a tool to assist decision making only and should not be treated as a definitive source of verification. Always check product labels and ask for clarification if you have dietary, allergen, or religious requirements.")
                                .font(.caption)
                        }
                    }
                icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    //loops over records and removing each one
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
