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
    static let pork = ["pork", "pig", "lard", "bacon", "ham"]
    static let meat = ["meat", "chicken", "beef"]
    static let fish = ["fish", "salmon", "tuna", "shrimp", "prawn", "lobster", "crab", "shellfish"]
    static let dairy = ["milk", "cheese", "butter", "cream", "whey", "casein"]
    static let otherAnimal = ["egg", "honey", "gelatin"]
    static let nut = ["hazelnut", "almond", "cashew","chestnut", "walnut", "pine nut","pecan", "pistachio", "peanut", "macadamia", "brazil nut", "may contain nuts"]
    static let gluten = ["gluten", "wheat", "barley", "rye","spelt", "durum", "semolina", "farro", "kamut"]
    
    static let nonVeganIngredients: [String] = pork + meat + fish + dairy + otherAnimal
    static let nonVegetarianIngredients: [String] = pork + meat + fish
    static let nonPescatarianIngredients: [String] = pork + meat + ["gelatin"]
    static let haramIngredients: [String] = pork + ["alcohol", "wine", "beer", "gelatin"]
    static let nonKosherIngredients: [String] = pork + [ "shrimp", "prawn", "lobster", "crab", "shellfish", "gelatin"] 
    
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
                let isVegan = lifestyleTags.contains(where: {tag in tag.contains("vegan")})
                if isVegan == false {
                    let found = nonVeganIngredients.filter({ingredient in ingredients.contains(ingredient)})
                    if !found.isEmpty {
                        failedReasons.append("Not vegan, contains: \(found.joined(separator: ", "))")
                    }
                    else{
                        failedReasons.append("Not confirmed vegan")
                    
                    }
    
                }
                
            case "Vegetarian":
                let isVegetarian = lifestyleTags.contains(where: {tag in tag.contains("vegetarian")})
                    if isVegetarian == false {
                        let found = nonVegetarianIngredients.filter({ingredient in ingredients.contains(ingredient)})
                        if !found.isEmpty {
                            failedReasons.append("Not vegetarian, contains: \(found.joined(separator: ", "))")
                        }
                        else{
                            failedReasons.append("Not confirmed vegetarian")
                            
                        }
                    }
                    
                
            case "Pescatarian":
                
                let found = nonPescatarianIngredients.filter({ingredient in ingredients.contains(ingredient)})
                if !found.isEmpty {
                        failedReasons.append("Not pescatarian, contains: \(found.joined(separator: ", "))")}
                
            //Allergens
            case "Nuts":
                let found = nut.filter{ingredient in allergens_tags.contains(where: {tag in tag.contains(ingredient)})}
                if !found.isEmpty{
                    failedReasons.append("Contains Nuts")
                }

                
                
            case "Dairy":
                let found = dairy.filter{ingredient in allergens_tags.contains(where: {tag in tag.contains(ingredient)})}
                if !found.isEmpty{
                    failedReasons.append("Contains Dairy")
                }
                
            case "Gluten":
                let found = gluten.filter{ingredient in allergens_tags.contains(where: {tag in tag.contains(ingredient)})}
                if !found.isEmpty{
                    failedReasons.append("Contains Gluten")
                }
                
            //Religion
            case "Halal":
                
                let foundHaramIngredients = haramIngredients.filter {ingredient in ingredients.contains(ingredient)}
                if !foundHaramIngredients.isEmpty{
                    failedReasons.append("Not Halal, contains \(foundHaramIngredients.joined(separator: ", "))")
                }
                
            case "Kosher":
                let foundNonKosherIngredients = nonKosherIngredients.filter {ingredient in ingredients.contains(ingredient)}
                
                if !foundNonKosherIngredients.isEmpty{
                    failedReasons.append("Not Kosher, contains \(foundNonKosherIngredients.joined(separator: ", "))")
                }
            default:
                break
            }
        }
        
        if failedReasons.isEmpty {
            if lifestyleTags.isEmpty && allergens_tags.isEmpty && ingredients.isEmpty{
                return .unknown
            }
            return .suitable
        }
        else{
            return .notSuitable(reasons: failedReasons)
        }
    }
    
    static func checkRawIngredients(text: String, filters: [String]) -> SuitabilityResult{
        
        guard !filters.isEmpty else {
            return .suitable
        }
        
        let text = text.lowercased()
        var failedReasons : [String] = []
        
        for filter in filters {
            switch filter {
            case "Vegan":
                let found = nonVeganIngredients.filter{ingredient in text.contains(ingredient)}
                if !found.isEmpty {
                    failedReasons.append("Contains \(found.joined(separator: ", "))")
                }
            case "Vegetarian":
                let found = nonVegetarianIngredients.filter{ingredient in text.contains(ingredient)}
                if !found.isEmpty {
                    failedReasons.append("Contains \(found.joined(separator: ", "))")
                }
            case "Pescatarian":
                let found = nonPescatarianIngredients.filter{ingredient in text.contains(ingredient)}
                if !found.isEmpty {
                    failedReasons.append("Contains \(found.joined(separator: ", "))")
                }
            case "Nuts":
                let found = nut.filter{ingredient in text.contains(ingredient)}
                if !found.isEmpty {
                    failedReasons.append("Contains \(found.joined(separator: ", "))")
                
                }
            case "Dairy":
                let found = dairy.filter{ingredient in text.contains(ingredient)}
                if !found.isEmpty {
                    failedReasons.append("Contains \(found.joined(separator: ", "))")
                }
            case "Gluten":
                let found = gluten.filter{ingredient in text.contains(ingredient)}
                if !found.isEmpty {
                    failedReasons.append("Contains \(found.joined(separator: ", "))")
                }
            case "Halal":
                let found = haramIngredients.filter{ingredient in text.contains(ingredient)}
                if !found.isEmpty {
                    failedReasons.append("Contains \(found.joined(separator: ", "))")
                }
            case "Kosher":
                let found = nonKosherIngredients.filter{ingredient in text.contains(ingredient)}
                if !found.isEmpty {
                    failedReasons.append("Contains \(found.joined(separator: ", "))")
                }
                
            default:
                break
                
                
            }
        }
        if failedReasons.isEmpty{
            if text.isEmpty{return .unknown}
            else{
                return .suitable
            }
        
        }
        return .notSuitable(reasons: failedReasons)
        
    }
}
