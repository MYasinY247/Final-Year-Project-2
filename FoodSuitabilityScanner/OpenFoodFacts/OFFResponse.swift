//
//  OFFResponse.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 01/02/2026.
//


// defines data models for handling JSON responses & decodes JSON data


struct OFFResponse: Decodable{
    let product : FoodProduct?
    
}
struct FoodProduct : Decodable{
    let product_name : String?
    let ingredients_text : String?
    let labels_tags: [String]?
    let allergens_tags: [String]?
    let ingredients_analysis_tags: [String]?
    let image_url: String?
}
enum OFFError: Error {
    case productNotFound
    case noDataAvailable
    case decodingError
}
