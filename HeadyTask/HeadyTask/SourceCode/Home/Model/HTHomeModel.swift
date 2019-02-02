//
//  HTHomeModel.swift
//  HeadyTask
//
//  Created by Naveen on 30/01/19.
//  Copyright © 2019 NaveenSwarna. All rights reserved.
//

import Foundation

 struct HTCategoryModel {
    var categoryId : Int = -1
    var parentCategoryId : Int = -1

    var name : String = ""
    var childCategories : [HTChildCategoryModel] = []
    var subCategories : [HTCategoryModel] = []


}


struct HTChildCategoryModel {
    var categoryId : Int = -1
    var childCategoryId : Int = -1
    var name : String = ""
    var productList : [HTProductModel] = []


}

struct HTProductModel {
    var productId : Int = -1
    var childCategoryId : Int = -1
    var name : String = ""
    var dateAdded : String = ""
    var viewCount : Int = -1
    var orderCount : Int = -1
    var shares : Int = -1
    var variantList : [HTVariantsModel] = []
    var taxList : [HTTaxModel] = []
    var colorList : [HTVariantsModel] = []
    var sizeList : [HTVariantsModel] = []

}
struct HTVariantsModel {
    var varientId : Int = -1
    var productId : Int = -1
    var color : String = ""
    var size : Int = -1
    var price : Int = -1
}

struct HTTaxModel {
    var productId : Int = -1
    var name : String = ""
    var taxValue : Double = 0.0
}
