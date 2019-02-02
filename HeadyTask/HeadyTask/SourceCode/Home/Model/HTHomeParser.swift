//
//  HTHomeParser.swift
//  HeadyTask
//
//  Created by Naveen on 30/01/19.
//  Copyright © 2019 NaveenSwarna. All rights reserved.
//

import Foundation
import UIKit

struct HTHomeParser {
    
    
    typealias JsonResponse = ([HTCategoryModel] , Bool) -> Void
    
    
    func getHomeScreenData(_ onCompletion: @escaping JsonResponse) {
        
        if !UIDevice.isConnectedToNetwork {
            
            onCompletion([],false)
            
        }
        
        HeadyParser.sharedInstance.makeHTTPGetRequest(path: GET_URL) { (response , status)  in
            
            
            if status
            {
                if response["categories"] is NSArray {
                    
                    let categories : NSArray = response["categories"] as! NSArray
                    
                     if response["rankings"] is NSArray
                     {
                        let rankings : NSArray = response["rankings"] as! NSArray
                        
                        onCompletion(self.parseAndReturnFullList(categories, rankings),true)
                     }
                     else
                     {
                        onCompletion([],false)
                    }
                }
                else
                {
                    onCompletion([],false)
                }
            }
            else
            {
                onCompletion([],false)
            }
            
        }
    }
    
    
    //MARK:- Parsing response
    
    func parseAndReturnFullList(_ categories : NSArray , _ rankings : NSArray) -> [HTCategoryModel] {
        
        
        var categoriesArr = [HTCategoryModel]()
        
        for eachCat in categories {
            
            if eachCat is NSDictionary {
                
                let eachCatDict : NSDictionary =  eachCat as! NSDictionary
                
                if eachCatDict["child_categories"] is [Int] {
                    
                    let eachCatChildArray : [Int] =  eachCatDict["child_categories"] as! [Int]
                    
                    if eachCatChildArray.count > 0 { // This will be master category
                        
                        var categoryModel = HTCategoryModel()
                        
                        if eachCatDict["id"] is Int {
                            categoryModel.categoryId = eachCatDict["id"] as! Int
                        }
                        if eachCatDict["name"] is String {
                            categoryModel.name = eachCatDict["name"] as! String
                        }

                        for eachSubCats in eachCatChildArray {
                            
                            for eachMaincatList in categories {
                                
                                let eachMainCatDict : NSDictionary = eachMaincatList as! NSDictionary
                                
                                
                                if eachMainCatDict["id"] is Int {
                                    
                                    if eachSubCats == eachMainCatDict["id"] as! Int {
                                        
                                        if eachMainCatDict["child_categories"] is [Int] {
                                            
                                            let each_CatChildArray : [Int] =  eachMainCatDict["child_categories"] as! [Int]
                                        
                                            if each_CatChildArray.count > 0 {
                                               
                                              categoryModel.subCategories.append(subCategoriesParsing(categoryModel.categoryId,eachMainCatDict, each_CatChildArray, categories, rankings))
                                                
                                            }
                                            else
                                            {
                                                categoryModel.childCategories.append(childCategoryParsing(categoryModel.categoryId, eachMainCatDict, rankings))
//                                                groupedCategories.append(eachSubCats) // for handling ungrouped categories
                                            }
                                        }
                                        
                                    }
                                }
                                
                            }
                        }
                        categoriesArr.append(categoryModel)
                    }
                }
            }
        }
        
        
        for each in categoriesArr {
            for subeach in each.childCategories {
                if let index = categoriesArr.index(where: { $0.categoryId == subeach.categoryId }) {
                    categoriesArr.remove(at: index)
                }
            }
            
            for subeach in each.subCategories {
                if let index = categoriesArr.index(where: { $0.categoryId == subeach.categoryId }) {
                    categoriesArr.remove(at: index)
                }
            }
        }


        return categoriesArr
    }
    
    
    func subCategoriesParsing(_ subCategoryID : Int ,_ eachCatDict : NSDictionary , _ eachCatChildArray : [Int] , _ categories : NSArray ,_ rankings : NSArray  ) -> HTCategoryModel {
        
        var categoryModel = HTCategoryModel()
        
        categoryModel.parentCategoryId = subCategoryID
        if eachCatDict["id"] is Int {
            categoryModel.categoryId = eachCatDict["id"] as! Int
        }
        if eachCatDict["name"] is String {
            categoryModel.name = eachCatDict["name"] as! String
        }
        
        for eachSubCats in eachCatChildArray {
            
            for eachMaincatList in categories {
                
                let eachMainCatDict : NSDictionary = eachMaincatList as! NSDictionary
                
                
                if eachMainCatDict["id"] is Int {
                    
                    if eachSubCats == eachMainCatDict["id"] as! Int {
                        
                        if eachMainCatDict["child_categories"] is [Int] {
                            
                            let each_CatChildArray : [Int] =  eachMainCatDict["child_categories"] as! [Int]
                            
                            if each_CatChildArray.count > 0 {
                                
                                categoryModel.subCategories.append( subCategoriesParsing(categoryModel.categoryId, eachMainCatDict, each_CatChildArray, categories, rankings))
                            }
                            else
                            {
                                categoryModel.childCategories.append(childCategoryParsing(categoryModel.categoryId, eachMainCatDict, rankings))
                                
                            }
                        }
                        
                    }
                }
                
            }
        }
         return categoryModel
    }
    
    
    
    func childCategoryParsing( _ categoryId : Int ,_ childDict : NSDictionary , _ rankings : NSArray) -> HTChildCategoryModel {
        
        var childCategory = HTChildCategoryModel()
        
        childCategory.categoryId = categoryId

        if childDict["id"] is Int {
            childCategory.childCategoryId = childDict["id"] as! Int
        }
        if childDict["name"] is String {
            childCategory.name = childDict["name"] as! String
        }
        
        
        if childDict["products"] is NSArray {
            
            let arr : NSArray = childDict["products"] as! NSArray
            
            for eachproduct in arr {
                
                if eachproduct is NSDictionary
                {
                    childCategory.productList.append(productParsing(childCategory.childCategoryId, eachproduct as! NSDictionary, rankings))
                }
            }
        }

        return childCategory
        
    }
    
    func productParsing( _ childCategoryId : Int ,_ product : NSDictionary , _ rankings : NSArray) -> HTProductModel {
        
        var produc = HTProductModel()
        
        produc.childCategoryId = childCategoryId
        
        if product["id"] is Int {
            produc.productId = product["id"] as! Int
        }
        if product["name"] is String {
            produc.name = product["name"] as! String
        }
        if product["date_added"] is String {
            produc.dateAdded = product["date_added"] as! String
        }
        
        
        
        
        for eachRanking in rankings {
            
            let eachRankType : NSDictionary = eachRanking as! NSDictionary
            
            if eachRankType["products"] is NSArray {
                
                let productArr : NSArray = eachRankType["products"] as! NSArray
                
                for eachFinalRank in productArr {
                    
                    let eachFinalRankDict : NSDictionary = eachFinalRank as! NSDictionary
                    
                    if eachFinalRankDict["id"] is Int {
                        
                        if produc.productId == eachFinalRankDict["id"] as! Int  {

                    if eachFinalRankDict["view_count"] is Int {
                        produc.viewCount = eachFinalRankDict["view_count"] as! Int
                    }
                    
                    if eachFinalRankDict["order_count"] is Int {
                        produc.orderCount = eachFinalRankDict["order_count"] as! Int
                    }
                    
                    if eachFinalRankDict["shares"] is Int {
                        produc.shares = eachFinalRankDict["shares"] as! Int
                    }
                    }
                    }
                }
            }
            
            
        }
        
        
        
        if product["variants"] is NSArray {

            let arr : NSArray = product["variants"] as! NSArray
            
            for eachvariant in arr {
                
                if eachvariant is NSDictionary
                {
                    produc.variantList.append(parseVariantParsing(produc.productId, eachvariant as! NSDictionary))
                }
            }
        }
        
        
        if product["tax"] is NSDictionary {
            produc.taxList.append(parseTaxParsing(produc.productId, product["tax"] as! NSDictionary))
            
        }
        
        
        
       
        return produc
        
    }
    
    
    
    func parseVariantParsing( _ productId : Int ,_ variantDict : NSDictionary) -> HTVariantsModel {
        
        var variant = HTVariantsModel()
        
        variant.productId = productId
        
        if variantDict["id"] is Int {
            variant.productId = variantDict["id"] as! Int
        }
        if variantDict["color"] is String {
            variant.color = variantDict["color"] as! String
        }
        if variantDict["size"] is Int {
            variant.size = variantDict["size"] as! Int
        }
        
        if variantDict["price"] is Int {
            variant.price = variantDict["price"] as! Int
        }
       
        return variant
        
    }
    
    
    
    func parseTaxParsing( _ productId : Int ,_ taxDict : NSDictionary) -> HTTaxModel {
        
        var tax = HTTaxModel()
        
        tax.productId = productId
        
      
        if taxDict["name"] is String {
            tax.name = taxDict["name"] as! String
        }
        if taxDict["value"] is Double {
            tax.taxValue = taxDict["value"] as! Double
        }
        
      
        return tax
        
    }
    
    
    
    
    
}
