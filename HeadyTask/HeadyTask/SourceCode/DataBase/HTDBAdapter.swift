//
//  HTDBAdapter.swift
//  HeadyTask
//
//  Created by Naveen on 31/01/19.
//  Copyright © 2019 NaveenSwarna. All rights reserved.
//

import UIKit
import SQLite3
class HTDBAdapter: NSObject {
    
        static let sharedInstance = HTDBAdapter()
    
    var db: OpaquePointer?

    
    // MARK:- Open Database
    
    func openDatabase()  {
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Heady.db")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
    }
    
    
    
    // MARK:- Save Full Data

    func saveDataToDataBase( _ categoryList : [HTCategoryModel]) {
        
        openDatabase()
        emptyAllRelatedTables()
        saveAllDataToLocalDB(categoryList)
    }
    
    // MARK:- Delete Full Data
    // USED when API given new response
    func emptyAllRelatedTables() {
        
        deleteEachTableByName("Category")
        deleteEachTableByName("Child_Category")
        deleteEachTableByName("Products")
        deleteEachTableByName("Variants")
        deleteEachTableByName("Tax")
    }
    
    func deleteEachTableByName(_ tableName : String) {
        
        var stmt: OpaquePointer?
        
        let queryString = "DELETE FROM \(tableName)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting category: \(errmsg)")
            return
        }
        sqlite3_finalize(stmt)
        
    }
    
    // MARK:- Save Categories Data
    
    func saveAllDataToLocalDB( _ categoryList : [HTCategoryModel]) {

        for eachCategory in categoryList {
            saveCategorytoDB(eachCategory)
        }
    }
    
    func saveCategorytoDB( _ category : HTCategoryModel)  {
        
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO Category (CID,NAME,PARENTCID) VALUES (?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(category.categoryId)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 2, category.name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 3, Int32(category.parentCategoryId)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting category: \(errmsg)")
            return
        }
        
        sqlite3_finalize(stmt)
        
        if category.subCategories.count > 0 {
            
            saveAllDataToLocalDB(category.subCategories)
        }
        
        saveChildCategories(category)
    }
    
    // MARK:- Save Child / Sub Categories Data

    
    func saveChildCategories( _ category : HTCategoryModel )  {
        for childCategory in category.childCategories {

        
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO Child_Category (CID,CCID,NAME) VALUES (?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(childCategory.categoryId)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding: \(errmsg)")
            return
        }
      
        
        if sqlite3_bind_int(stmt, 2, Int32(childCategory.childCategoryId)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 3, childCategory.name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting category: \(errmsg)")
            return
        }
        sqlite3_finalize(stmt)

        
        self.saveProduct(childCategory)
        }
        
    }
    
    // MARK:- Save Products Data

    
    func saveProduct( _ childCategory : HTChildCategoryModel )  {
        
        for product in childCategory.productList {

        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO Products (PID,CCID,NAME,DATE_ADDED,VIEW_COUNT,ORDER_COUNT,SHARES) VALUES (\(Int32(product.productId)),\(Int32(product.childCategoryId)),'\(product.name)','\(product.dateAdded)',\(Int32(product.viewCount)),\(Int32(product.orderCount)),\(Int32(product.shares)))"
        
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
       
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting category: \(errmsg)")
            return
        }
        sqlite3_finalize(stmt)
        saveVariants(product)
        saveTax(product)
        
        }
        
    }
    
    // MARK:- Save Variants Data

    func saveVariants(_ product : HTProductModel) {
        
        
        for variant in product.variantList {

        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO Variants (VID,PID,COLOR,SIZE,PRICE) VALUES (\(Int32(variant.varientId)),\(Int32(product.productId)),'\(variant.color)',\(Int32(variant.size)),\(Int32(variant.price)))"
        
            
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
      
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting category: \(errmsg)")
            return
        }
        sqlite3_finalize(stmt)

        }
    }
    
    // MARK:- Save Tax Data

    func saveTax(_ product : HTProductModel) {
        
        
        for tax in product.taxList {

        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO Tax (PID,NAME,VALUE) VALUES (\(Int32(tax.productId)),'\(tax.name)','\(tax.taxValue)')"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
      
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting category: \(errmsg)")
            return
        }
        
        sqlite3_finalize(stmt)
        }
    }
    
    //MARK: - RETREVIENG DATA FROM DATA BASE TO DISPLAY
    
    
    func fetchCategoryData( _ parentCatId : Int) -> [HTCategoryModel] {
        
        var categoryModels : [HTCategoryModel] = []
        let queryString = "SELECT * FROM Category where PARENTCID = ?"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return []
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(parentCatId)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding : \(errmsg)")
            return []
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            var eachCategory = HTCategoryModel()
            let id = sqlite3_column_int(stmt, 0)
            eachCategory.categoryId = Int(id)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            eachCategory.name = name
            let parentId = sqlite3_column_int(stmt, 2)
            eachCategory.parentCategoryId = Int(parentId)
            categoryModels.append(eachCategory)
        }
        sqlite3_finalize(stmt)
        
        
        for i in 0..<categoryModels.count {
            
            categoryModels[i].subCategories.append(contentsOf: fetchCategoryData(categoryModels[i].categoryId))
        }
        
        for i in 0..<categoryModels.count {
            
            categoryModels[i].childCategories.append(contentsOf: fetchChildCategoryData(categoryModels[i].categoryId))
        }
       
        
        return categoryModels
    }
    
    
    func fetchChildCategoryData( _ parentCatId : Int) -> [HTChildCategoryModel] {
        
        var categoryModels : [HTChildCategoryModel] = []
        
        let queryString = "SELECT * FROM Child_Category where CID = ?"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return []
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(parentCatId)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding : \(errmsg)")
            return []
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            var eachCategory = HTChildCategoryModel()
            
            let parentId = sqlite3_column_int(stmt, 0)
            eachCategory.categoryId = Int(parentId)
            
            let id = sqlite3_column_int(stmt, 1)
            eachCategory.childCategoryId = Int(id)
            
            let name = String(cString: sqlite3_column_text(stmt, 2))
            eachCategory.name = name
           
            categoryModels.append(eachCategory)
        }
        sqlite3_finalize(stmt)
        
       
        
        for i in 0..<categoryModels.count {
            
            categoryModels[i].productList.append(contentsOf: fetchProductList(categoryModels[i].childCategoryId))
        }
        
        return categoryModels
    }
    
    func fetchProductList( _ childCategoryId : Int ) -> [HTProductModel]  {
        
        var productModels : [HTProductModel] = []
        
        
        let queryString = "SELECT * FROM Products where CCID = ?"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return []
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(childCategoryId)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding : \(errmsg)")
            return []
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            var eachProduct = HTProductModel()

            let id = sqlite3_column_int(stmt, 0)
            eachProduct.productId = Int(id)

            let childCatId = sqlite3_column_int(stmt, 1)
            eachProduct.childCategoryId = Int(childCatId)

            let name = String(cString: sqlite3_column_text(stmt, 2))
            eachProduct.name = name
            let date = String(cString: sqlite3_column_text(stmt, 3))
            eachProduct.dateAdded = date
            
            let viewCount = sqlite3_column_int(stmt, 4)
            eachProduct.viewCount = Int(viewCount)
            
            let orderCount = sqlite3_column_int(stmt, 5)
            eachProduct.orderCount = Int(orderCount)
            
            let shares = sqlite3_column_int(stmt, 6)
            eachProduct.shares = Int(shares)
            
            productModels.append(eachProduct)
        }
        sqlite3_finalize(stmt)
        
        return productModels
    }
    
    
    func getProductInfo(_ product : HTProductModel) -> HTProductModel  {
        
        var eachProduct = HTProductModel()

        eachProduct.productId = product.productId
        eachProduct.childCategoryId = product.childCategoryId
        eachProduct.name = product.name
        eachProduct.dateAdded = product.dateAdded
        eachProduct.viewCount = product.viewCount
        eachProduct.orderCount = product.orderCount
        eachProduct.shares = product.shares
        
        
        
        let queryString = "SELECT * FROM Variants where PID = ?"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return product
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(product.productId)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding : \(errmsg)")
            return product
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            var eachVariant  = HTVariantsModel()
            
            let vid = sqlite3_column_int(stmt, 0)
            eachVariant.varientId = Int(vid)
            
            let PID = sqlite3_column_int(stmt, 1)
            eachVariant.productId = Int(PID)
            
            let color = String(cString: sqlite3_column_text(stmt, 2))
            eachVariant.color = color
           
            
            let size = sqlite3_column_int(stmt, 3)
            eachVariant.size = Int(size)
            
            let price = sqlite3_column_int(stmt, 4)
            eachVariant.price = Int(price)
            
            eachProduct.variantList.append(eachVariant)
        }
        sqlite3_finalize(stmt)
        
        eachProduct.taxList.append(contentsOf: getTaxList(product))
        eachProduct.colorList = getDistinctColorForProduct(product)
        eachProduct.sizeList = getDistinctSizeForProduct(product)

        return eachProduct
    }
    
    func getDistinctColorForProduct( _ product : HTProductModel) -> [HTVariantsModel] {
        
        let queryString = "SELECT DISTINCT COLOR FROM Variants where PID = \(Int32(product.productId))"
        
        var colorList :[HTVariantsModel] = []
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return []
        }
        
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            var eachVariant  = HTVariantsModel()
            let color = String(cString: sqlite3_column_text(stmt, 0))
            eachVariant.color = color
            
            colorList.append(eachVariant)
        }
        sqlite3_finalize(stmt)
        
        return colorList
    }
    
    
    func getColorListForProductBasedOnSize( _ product : HTProductModel ,_ size : Int ) -> [HTVariantsModel] {
        
        let queryString = "SELECT DISTINCT COLOR FROM Variants where PID = \(Int32(product.productId)) and SIZE = \(Int32(size))"
        
        var colorList :[HTVariantsModel] = []
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return []
        }
        
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            var eachVariant  = HTVariantsModel()
            let color = String(cString: sqlite3_column_text(stmt, 0))
            eachVariant.color = color
            
            colorList.append(eachVariant)
        }
        sqlite3_finalize(stmt)
        
        return colorList
    }
    
    
    func getPriceForProduct( _ product : HTProductModel ,_ size : Int , _ Color : String) -> String {
        
        let queryString = "SELECT PRICE FROM Variants where PID = \(Int32(product.productId)) and SIZE = \(Int32(size)) and COLOR = '\(Color)' limit 1"
        
        var price :String   = ""
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return ""
        }
        
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            price = String(cString: sqlite3_column_text(stmt, 0))
            
        }
        sqlite3_finalize(stmt)
        
        return price
    }
    
    
    func getDistinctSizeForProduct( _ product : HTProductModel) -> [HTVariantsModel] {
        
        let queryString = "SELECT DISTINCT SIZE FROM Variants where PID = \(Int32(product.productId))"
        
        var colorList :[HTVariantsModel] = []
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return []
        }
        
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            var eachVariant  = HTVariantsModel()
            let size = sqlite3_column_int(stmt, 0)
            eachVariant.size = Int(size)
            colorList.append(eachVariant)
        }
        sqlite3_finalize(stmt)
        return colorList
    }
    
    
    func getSizeListForProductBasedOnColor( _ product : HTProductModel , _ Color : String) -> [HTVariantsModel] {
        
        let queryString = "SELECT DISTINCT SIZE FROM Variants where PID = \(Int32(product.productId)) and COLOR = '\(Color)'"
        
        var colorList :[HTVariantsModel] = []
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return []
        }
        
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            var eachVariant  = HTVariantsModel()
            let size = sqlite3_column_int(stmt, 0)
            eachVariant.size = Int(size)
            colorList.append(eachVariant)
        }
        sqlite3_finalize(stmt)
        return colorList
    }
    
    
    func getTaxList(_ product : HTProductModel) -> [HTTaxModel]  {
        
        
        var taxList : [HTTaxModel] = []
        
        
        let queryString = "SELECT * FROM Tax where PID = ?"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return []
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(product.productId)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding : \(errmsg)")
            return []
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            var eachTax  = HTTaxModel()
            
            let pid = sqlite3_column_int(stmt, 0)
            eachTax.productId = Int(pid)
            
            let name = String(cString: sqlite3_column_text(stmt, 1))
            eachTax.name = name
            
            let value = String(cString: sqlite3_column_text(stmt, 2))
            eachTax.taxValue = Double(value) ?? 0.0
            
          
           taxList.append(eachTax)
        }
        sqlite3_finalize(stmt)
        
        return taxList
    }
    
}
