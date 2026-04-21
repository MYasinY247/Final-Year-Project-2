//
//  BarcodeProcessor.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 01/02/2026.
//

import Foundation

//handles the fetching product data from OFF
struct BarcodeProcessor {
    
    static func getBarcode(barcode: String, completion: @escaping (Result<FoodProduct,OFFError>) -> Void){ // a generic
        
        //builds api and inserts barcode
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json"
        
        //validate url, fails if product can't be found
        guard let url = URL(string: urlString) else {
            completion(.failure(.noDataAvailable))
            return
        }
        //begins network request to OFF on background thread, runs in background to not affect UI, no network = fail
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(.failure(.noDataAvailable))
                return
            }
            //if no data comes back = fail
            guard let data = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            //switch back to main thread before updating UI again
            DispatchQueue.main.async(){
                do{
                    //decode JSON response to fit OFFResponse model
                    let decoded = try JSONDecoder().decode(OFFResponse.self, from: data)
                    
                    //if product exists = success
                    if let product = decoded.product{
                        completion(.success(product))
                    }
                    
                    //if product doesn't exist, fail
                    else{
                        completion(.failure(.productNotFound))
                    }
                }catch{
                    completion(.failure(.decodingError))
                    
                }
            }
            
        }.resume() // needed to begin the network request
        
        
        
        
    }

    
            
        

    
}
