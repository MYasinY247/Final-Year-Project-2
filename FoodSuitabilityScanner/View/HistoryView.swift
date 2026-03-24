//
//  History.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 27/01/2026.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \ScannedProduct.dateScanned, order:.reverse) private var history :[ScannedProduct]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group{
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
                    ForEach(history){
                        item in HistoryRow(item: item)
                    }
                    .onDelete(perform: deleteItem)
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar{
            if !history.isEmpty {
                EditButton()
            }
        }
    }
    private func deleteItem(at offsets: IndexSet) {
        for index in offsets{
            modelContext.delete(history[index])
            
            
        }
    }
}

struct HistoryRow: View{
    let item : ScannedProduct
    
    var body: some View{
        //product image / icon
        HStack(spacing: 12){
            AsyncImage(url: URL(string: item.imageURL)){
                image in image
                    .resizable()
                    .scaledToFit()
  
            } placeholder: {
                Image(systemName: "photo")
                    .foregroundColor(Color.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .background(Color.gray)
            
            VStack(alignment: .leading, spacing: 5){
                Text(item.productName)
                    .font(.body)
                    .lineLimit(1)
                
                Text(item.dateScanned.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                
                if !item.flaggedIngredients.isEmpty{
                    Text(item.flaggedIngredients)
                        .font(.caption)
                        .foregroundColor(.red)
                        .lineLimit(2)
                
                }
                if !item.activeFilters.isEmpty{
                    Text("Filters: \(item.activeFilters)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                    
            }
            Spacer()
            //suitability result
            Text(item.suitabilityResult)
                .font(.caption)
                .foregroundColor(resultColour(for: item.suitabilityResult))
                .padding()
                .background(resultColour(for: item.suitabilityResult).opacity(0.3))
                .clipShape(Capsule())
            
        }
        .padding()
        
    }
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
