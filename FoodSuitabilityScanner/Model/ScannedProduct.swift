//
//  ScannedProduct.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 19/03/2026.
//

import Foundation
import SwiftData

@Model// swift data will save instances of class to device local storage

//data model to store a barcode scanned product to history
class ScannedProduct{
    var productName:String
    var dateScanned:Date
    var suitabilityResult:String
    var flaggedIngredients: String
    var imageURL: String
    var activeFilters: String
    
    init(productName: String, dateScanned: Date, suitabilityResult: String, flaggedIngredients: String, imageURL: String, activeFilters: String) {
        self.productName = productName
        self.dateScanned = dateScanned
        self.suitabilityResult = suitabilityResult //suitable / unsuitable /unknown
        self.flaggedIngredients = flaggedIngredients
        self.imageURL = imageURL
        self.activeFilters = activeFilters //selected dietary requirements used at time of scan
    }
    
}
