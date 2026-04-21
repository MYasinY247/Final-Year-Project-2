//
//  Untitled.swift
//  FoodSuitabilityScanner
//
//  Created by Muhammad Yasin Yahya on 15/03/2026.
//

import Foundation

// 3 possible outcomes after scanning
enum SuitabilityResult
{
    case suitable
    case notSuitable (reasons :[String]) //contains the reasons why the food is not suitable
    case unknown
}

//static so they can be called and shared throughout the app without needing to instantiate suitability checker multiple times
struct SuitabilityChecker {
    static let pork = ["pork", "pig", "lard", "bacon"]
    static let meat = ["meat", "chicken", "beef"]
    static let fish = ["fish", "salmon", "tuna", "shrimp", "prawn", "lobster", "crab", "shellfish"]
    static let dairy = ["milk", "cheese", "butter", "cream", "whey", "casein", "yoghurt", "yogurt"]
    static let otherAnimal = ["egg", "honey", "gelatine"]
    static let nut = ["hazelnut", "almond", "cashew","chestnut", "walnut", "pine nut","pecan", "pistachio", "peanut", "macadamia", "brazil nut", "may contain nuts"]
    static let gluten = ["gluten", "wheat", "barley", "rye","spelt", "durum", "semolina", "farro", "kamut"]
    
    //combining arrays for each dietary requirement
    static let nonVeganIngredients: [String] = pork + meat + fish + dairy + otherAnimal
    static let nonVegetarianIngredients: [String] = pork + meat + fish
    static let nonPescatarianIngredients: [String] = pork + meat + ["gelatine"]
    static let haramIngredients: [String] = pork + ["alcohol", "wine", "beer", "gelatine"]
    static let nonKosherIngredients: [String] = pork + [ "shrimp", "prawn", "lobster", "crab", "shellfish", "gelatine"]
    
    
    //barcode check, checks product fetched from OFF and compared against selected diet
    static func check(product: FoodProduct, filters: [String]) -> SuitabilityResult{
        
        //no filters set = suitable by default
        guard !filters.isEmpty else {
            return .suitable
        }
        var failedReasons: [String] = []
        
        //extracts product info and set to lowercase
        let ingredients = product.ingredients_text?.lowercased() ?? ""
        let labels = product.labels_tags?.map{ tag in tag.lowercased()} ?? []
        let allergens_tags = product.allergens_tags?.map{tag in tag.lowercased()} ?? []
        let analysis = product.ingredients_analysis_tags?.map { tag in tag.lowercased() } ?? []
         
        

        //combines labels and analysis for lifestyle check
        let lifestyleTags = labels + analysis
        
        for filter in filters {
            switch filter {
                //lifestyle
                //first checks for official vegan / vegetarien tag from OFF before looking at ingredients
            case "Vegan":
                let isVegan = lifestyleTags.contains(where: {tag in tag.contains("en:vegan")})
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
                let isVegetarian = lifestyleTags.contains(where: {tag in tag.contains("en:vegetarian")})
                    if isVegetarian == false {
                        let found = nonVegetarianIngredients.filter({ingredient in ingredients.contains(ingredient)})
                        if !found.isEmpty {
                            failedReasons.append("Not vegetarian, contains: \(found.joined(separator: ", "))")
                        }
                        else{
                            failedReasons.append("Not confirmed vegetarian")
                            
                        }
                    }
                    
                //OFF has no pescatarian tag
            case "Pescatarian":
                
                let found = nonPescatarianIngredients.filter({ingredient in ingredients.contains(ingredient)})
                if !found.isEmpty {
                        failedReasons.append("Not confirmed pescatarian, contains: \(found.joined(separator: ", "))")}
                
            //Allergens, uses structured allergen_tags from OFF which is more reliable in returning a relevent response
            //the ingredients are checked against the allergen tags
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
                
            //Religion, scans for ingredients as not all products have Halal / Kosher certficiation
            case "Halal":
                
                let foundHaramIngredients = haramIngredients.filter {ingredient in ingredients.contains(ingredient)}
                if !foundHaramIngredients.isEmpty{
                    failedReasons.append("Not Halal, contains: \(foundHaramIngredients.joined(separator: ", "))")
                }
                
            case "Kosher":
                let foundNonKosherIngredients = nonKosherIngredients.filter {ingredient in ingredients.contains(ingredient)}
                
                if !foundNonKosherIngredients.isEmpty{
                    failedReasons.append("Not Kosher, contains: \(foundNonKosherIngredients.joined(separator: ", "))")
                }
            default:
                break
            }
        }
        
        //if the product contained no data from OFF then returns unknown
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
    
    
    //Uses OCR to check ingredients via scanned text and compares against selected active filters
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
        //if there were no unsuitable ingredients, return suitable
        if failedReasons.isEmpty{
            if text.isEmpty{return .unknown}
            else{
                return .suitable
            }
        
        }
        return .notSuitable(reasons: failedReasons)
        
    }
}
