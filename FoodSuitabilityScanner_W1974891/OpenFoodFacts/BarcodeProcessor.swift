//
//  BarcodeProcessor.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 01/02/2026.
//

import Foundation

struct BarcodeProcessor {
    
    static func getBarcode(barcode: String, completion: @escaping (Result<FoodProduct,OFFError>) -> Void){ // a generic
        
        let urlString = "https://world.openfoodfacts.net/api/v2/product/\(barcode).json"
        guard let url = URL(string: urlString) else {
            completion(.failure(.noDataAvailable))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(.failure(.noDataAvailable))
                return
            }
            guard let data = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            DispatchQueue.main.async(){
                do{
                    let decoded = try JSONDecoder().decode(OFFResponse.self, from: data)
                    if let product = decoded.product{
                        print("Decoded Product: \(product)")
                                                print("Product name: \(product.product_name ?? "No name available")")  
                                                
                        completion(.success(product))
                    }
                    else{
                        completion(.failure(.productNotFound))
                    }
                }catch{
                    completion(.failure(.decodingError))
                    
                }
            }
            
        }.resume()
        
        
        
        
    }

    
            
        

    
}
