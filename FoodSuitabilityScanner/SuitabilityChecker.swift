//
//  Untitled.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 15/03/2026.
//

import Foundation

enum SuitabilityResult
{
    case suitable
    case notSuitable (reasons :[String])
    case unknown
}

struct SuitabilityChecker {
    static func check(product: FoodProduct, filters: [String]) -> SuitabilityResult{
        guard !filters.isEmpty else {
            return .suitable
        }
        var failedReasons: [String] = []
        
        let ingredients = product.ingredients_text?.lowercased() ?? ""
        let labels = product.labels_tags?.map{ tag in tag.lowercased()} ?? []
        let allergens_tags = product.allergens_tags?.map{tag in tag.lowercased()} ?? []
        let analysis = product.ingredients_analysis_tags?.map { tag in tag.lowercased() } ?? []
        
        //combines labels and analysis for lifestyle check
        let lifestyleTags = labels + analysis
        
        for filter in filters {
            switch filter {
                //lifestyle
            case "Vegan":
                if !lifestyleTags.contains(where: {tag in tag.contains("vegan")}){
                    failedReasons.append("Not Confirmed Vegan")
                }
                
            case "Vegetarian":
                if !lifestyleTags.contains(where: {tag in tag.contains("vegetarian")}){
                    failedReasons.append("Not Confirmed Vegetarian")
                }
            case "Pescatarian":
                let meat = labels.contains(where: {tag in
                    tag.contains("meat") ||
                    tag.contains("pork") ||
                    tag.contains("chicken") ||
                    tag.contains("beef")
                })
                if meat == true {
                    failedReasons.append("Contains Meat")
                }
                
            //Allergens
            case "Nuts":
                if allergens_tags.contains(where: {tag in tag.contains("nut")}){
                    failedReasons.append("Contains Nuts")
                }
            case "Dairy":
                if allergens_tags.contains(where: {tag in tag.contains("milk") || tag.contains("cheese") || tag.contains("dairy")}){
                    failedReasons.append("Contains Dairy")
                }
            case "Gluten":
                if allergens_tags.contains(where: {tag in tag.contains("nut") || tag.contains("wheat")}){
                    failedReasons.append("Contains Gluten")
                }
                
            //Religion
            case "Halal":
                let haram = ["pork", "pig", "lard", "bacon", "ham", "gelatin", "alcohol", "wine", "beer"]
                let foundHaramIngredients = haram.filter {ingredient in ingredients.contains(ingredient)}
                if !foundHaramIngredients.isEmpty{
                    failedReasons.append("Not Halal, contains \(foundHaramIngredients.joined(separator: ", "))")
                }
            case "Kosher":
                let nonKosherIngredients = ["pork", "pig", "lard", "bacon", "ham", "shrimp", "prawn", "lobster", "crab", "shellfish", "gelatin"]
                let foundNonKosherIngredients = nonKosherIngredients.filter {ingredient in ingredients.contains(ingredient)}
                
                if !foundNonKosherIngredients.isEmpty{
                    failedReasons.append("Not Kosher, contains \(foundNonKosherIngredients.joined(separator: ", "))")
                }
            default:
                break
            }
        }
        
        if failedReasons.isEmpty {
            return .suitable
        }
        else{
            return .notSuitable(reasons: failedReasons)
        }
    }
}
