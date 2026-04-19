//
//  History.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI
import SwiftData


//Displays all products scanned by barcode, swiftdata displays the entries and sorts by latest scan
struct HistoryView: View {
    
    //fetches all ScannedProducts from SwiftData, reverse order to display latest scan first
    @Query(sort: \ScannedProduct.dateScanned, order:.reverse) private var history :[ScannedProduct]
    
    //gives user access to SwiftData database to delete scans
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView{
            Group{
                //shows place holder message if no entries are found in history
                if history.isEmpty {
                    VStack(spacing: 16){
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No History")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("Scan your products to find them here ")
                    }
                    .padding()
                }
                else {
                    List{
                        //shows a scrollable list
                        ForEach(history){
                            item in HistoryRow(item: item)
                        }
                        //swipe to delete
                        .onDelete(perform: deleteItem)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    if !history.isEmpty {
                        //for multiple items, edit mode to delete in bulk
                        EditButton()
                    }
                }
                }
                    
        }

//
    }
    //removes item from its position
    private func deleteItem(at item: IndexSet) {
        for index in item{
            modelContext.delete(history[index])
        }
    }
}

//displays scanned products in a list
struct HistoryRow: View{
    let item : ScannedProduct
    
    var body: some View{
        //product image / icon
        HStack(spacing: 12){
            
            //loads image from url stored in SwiftData
            AsyncImage(url: URL(string: item.imageURL ?? "")){
                image in image
                    .resizable()
                    .scaledToFit()
            //if url fails, displays a placeholder instead
            } placeholder: {
                Image(systemName: "photo")
                    .foregroundColor(Color.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .background(Color.gray)
            
            //keeps line compact by keeping product name on 1 line
            VStack(alignment: .leading, spacing: 5){
                Text(item.productName)
                    .font(.body)
                    .lineLimit(2)
                
                //date and time of scan
                Text(item.dateScanned.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                
                //shows flagged ingredients in red
                if !item.flaggedIngredients.isEmpty{
                    Text(item.flaggedIngredients)
                        .font(.caption)
                        .foregroundColor(.red)
                        
                
                }
                //shows which dietary filters were active at time of scan
                if !item.activeFilters.isEmpty{
                    Text("Filters: \(item.activeFilters)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        
                }
                else{
                    //displays this if no filters were active
                    Text("No filters active")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                    
            }
            Spacer()
            //suitability result colour coded based on result
            Text(item.suitabilityResult)
                .font(.caption)
                .foregroundColor(resultColour(for: item.suitabilityResult))
                .padding()
                .background(resultColour(for: item.suitabilityResult).opacity(0.3))
                .clipShape(Capsule())
            
        }
        .padding()
        
    }
    
    //returns a colour based on suitability result
    private func resultColour(for result: String) -> Color{
        switch result{
        case "Suitable":
            return .green
        case "Not Suitable":
            return .red
        default:
            return .gray
        }
    }
}
#Preview {
    HistoryView()
        .modelContainer(for: ScannedProduct.self, inMemory: true)
}
