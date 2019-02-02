//
//  HTProductInfoVC.swift
//  HeadyTask
//
//  Created by SurendraMac on 01/02/19.
//  Copyright © 2019 NaveenSwarna. All rights reserved.
//

import UIKit

class HTProductInfoVC: UIViewController {

    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var lbl_ViewCount: UILabel!
    
    @IBOutlet weak var lbl_Price: UILabel!
    @IBOutlet weak var order_Count: UILabel!
    @IBOutlet weak var lbl_Shares: UILabel!
    @IBOutlet weak var sizeCollView: UICollectionView!
    
    @IBOutlet weak var variantCollView: UICollectionView!
    @IBOutlet weak var taxCollView: UICollectionView!
    
    var product  = HTProductModel()
    
    var colorSelected : String = ""
    var sizeSelected : String = ""

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        product = HTDBAdapter.sharedInstance.getProductInfo(product)
        
        lbl_Name.text = product.name
        
        if product.viewCount > 0 {
            lbl_ViewCount.text = "\(product.viewCount) Views"
        }
       
        if product.orderCount > 0 {

        order_Count.text = "\(product.orderCount) Orders placed"
        }
            if product.shares > 0 {

                lbl_Shares.text = "\(product.shares) people shared this item"
        }
        

        variantCollView.register(UINib(nibName: "HTVariantCell", bundle: nil), forCellWithReuseIdentifier: "HTVariantCell")
        taxCollView.register(UINib(nibName: "HTVariantCell", bundle: nil), forCellWithReuseIdentifier: "HTVariantCell")
        sizeCollView.register(UINib(nibName: "HTVariantCell", bundle: nil), forCellWithReuseIdentifier: "HTVariantCell")

        updatePriceBasedOnVariant()
    }
}


extension HTProductInfoVC : UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == variantCollView
        {
            return product.colorList.count
        }
        else if collectionView == sizeCollView
        {
            return product.sizeList.count
        }
        return product.taxList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell : HTVariantCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HTVariantCell", for: indexPath) as! HTVariantCell
        
        if collectionView == variantCollView
        {
            cell.textLbl.text = product.colorList[indexPath.row].color
       
            if cell.textLbl.text == colorSelected {
                
                cell.textLbl.backgroundColor = .green
            }
            else
            {
                cell.textLbl.backgroundColor = .white
            }
        }
        else if collectionView == sizeCollView {
            
            cell.textLbl.text = "\(product.sizeList[indexPath.row].size)"
            
            if cell.textLbl.text == "-1" {
                
                cell.textLbl.text = "NA"
            }
            
            if cell.textLbl.text == sizeSelected {
                
                cell.textLbl.backgroundColor = .green
            }
            else
            {
                cell.textLbl.backgroundColor = .white
            }
        }
        else
        {
            cell.textLbl.text = product.taxList[indexPath.row].name + " \(product.taxList[indexPath.row].taxValue)% "
        }
        
       
            
        updatePriceBasedOnVariant()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == variantCollView
        {
            colorSelected = product.colorList[indexPath.row].color
            product.sizeList = HTDBAdapter.sharedInstance.getSizeListForProductBasedOnColor(product, colorSelected)
            
            
            variantCollView.reloadData()
            sizeCollView.reloadData()
            
        }
        else if collectionView == sizeCollView
        {
            sizeSelected = "\(product.sizeList[indexPath.row].size)"
            
//            product.colorList = HTDBAdapter.sharedInstance.getColorListForProductBasedOnSize(product, Int(sizeSelected) ?? 0)

            collectionView.reloadData()
            
        }
        updatePriceBasedOnVariant()
    }
    
    func updatePriceBasedOnVariant()
    {
        if sizeSelected == "" {
            
            if product.sizeList.count > 0 {
                sizeSelected = "\(product.sizeList[0].size)"
            }
            else{
                return
            }
        }
        
        if colorSelected == "" {
            
            if product.colorList.count > 0 {

                colorSelected = product.colorList[0].color
            }
            else{
                return
            }
        }
        
        if Int(sizeSelected) != -1 {
        
        let value = HTDBAdapter.sharedInstance.getPriceForProduct(product, Int(sizeSelected) ?? 0, colorSelected)
        
        if value != ""
        {
            self.lbl_Price.text = "Price : \(value)"
        }
       else
        {
           self.lbl_Price.text = ""
            
             /*let alertController = UIAlertController(title: nil, message: "This item is not available for selected size and selected color. \n NOTE :  WE CAN HANDLE HERE FOR MULTIPLE COMBINATIONS LIKE SHOW HIDING AVAILABLE SIZES AND COLORS ", preferredStyle:UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
            { action -> Void in
                
                alertController.dismiss(animated: true, completion: nil)
            })
            self.present(alertController, animated: true, completion: nil)
           */
        }
        }else
        {
            if let row = product.variantList.index(where: {$0.color == colorSelected}) {
                self.lbl_Price.text = "Price : \(product.variantList[row].price)"
            }
        }
    }
}
