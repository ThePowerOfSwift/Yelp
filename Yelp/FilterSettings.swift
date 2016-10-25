//
//  FilterSettings.swift
//  Yelp
//
//  Created by Jonathan Cheng on 10/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class FilterSettings: NSObject {
    var deals: Bool = false
    var categories: [[String: String]] = [[:]]  //[["name": "Afghan", "value": "false"], ["name": "American", "value": "false"]]
    var distance: [[String: String]] = [[:]]
    var sortby: [[String: String]] = [[:]]
    
    override init() {
        super.init()
        
        // Populate filters
        categories.removeAll()
        for aCategory in categoriesArray() {
            // Add boolean (as string) for key "value"
            var newCategory = aCategory
            newCategory.updateValue("false", forKey: "value")
            categories.append(newCategory)
        }
        
        distance.removeAll()
        distance = [["name": "Auto", "value": "true", "code": "0"],
                    ["name": "0.3 miles", "value": "false", "code": "483"],
                    ["name": "1 mile", "value": "false", "code": "1610"],
                    ["name": "5 miles", "value": "false", "code": "8047"],
                    ["name": "20 miles", "value": "false", "code": "32187"]]
        
        sortby.removeAll()
        sortby = [["name": "Best Match", "value": "true", "code": ""],
                  ["name": "Distance", "value": "false", "code": ""],
                  ["name": "Highest Rated", "value": "false", "code": ""]]
    }
    
    func sort() -> YelpSortMode {
        //return the first sortby that have "true" value
        for sort in sortby {
            if sort["value"] == "true" {
                let name = sort["name"]!
                switch name {
                case "Distance":
                    return .distance
                case "Highest Rated":
                    return .highestRated
                default: return .bestMatched
                }
            }
        }
        return .bestMatched
    }
    
    override var description: String {
        return "\tDeals: \(deals)" +
        "\n\tCategories: \(categories)" +
        "\n\tDistance: \(distance)" +
        "\n\tSort by: \(sortby)"
    }
    
    func categoriesArray() -> [[String: String]] {
        return Category().categoriesArray
    }
    
    
}
