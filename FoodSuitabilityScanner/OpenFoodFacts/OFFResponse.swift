//
//  OFFResponse.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 01/02/2026.
//


// defines data models for handling JSON responses 


struct OFFResponse: Codable{
    let product : FoodProduct?
    
}
struct FoodProduct : Codable{
    let product_name : String?
    let ingredients_text : String?
}
enum OFFError: Error {
    case productNotFound
    case noDataAvailable
    case decodingError
}
