//
//  ScannedProduct.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 19/03/2026.
//

import Foundation
import SwiftData

@Model
class ScannedProduct{
    var productName:String
    var dateScanned:Date
    var suitabilityResult:String
    var flaggedIngredients: String
    var imageURL: String
    
    init(productName: String, dateScanned: Date, suitabilityResult: String, flaggedIngredients: String, imageURL: String) {
        self.productName = productName
        self.dateScanned = dateScanned
        self.suitabilityResult = suitabilityResult
        self.flaggedIngredients = flaggedIngredients
        self.imageURL = imageURL
    }
    
}
