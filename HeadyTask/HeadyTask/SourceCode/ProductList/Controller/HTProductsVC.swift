//
//  HTProductsVC.swift
//  HeadyTask
//
//  Created by Naveen on 02/02/19.
//  Copyright © 2019 NaveenSwarna. All rights reserved.
//

import UIKit


class HTProductsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource {
   

    @IBOutlet var toolBar: UIToolbar!
    var productList : [HTProductModel] = []
    @IBOutlet var pickerView: UIPickerView!
    
    @IBOutlet var tableView: UITableView!
//    let toolBar = UIToolbar()
    
    let sortArray : [String] = ["Views Low to High","Views High to Low","Shares Low To High","Shares High To Low","Most Ordered Low to High","Most Ordered High to Low"]
    
    var selectedSortType : String = ""
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(HTProductsVC.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(HTProductsVC.cancelClick))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        toolBar.isHidden = true
        pickerView.isHidden = true
        
        let button : UIBarButtonItem = UIBarButtonItem(title: "Sort", style: UIBarButtonItem.Style.plain, target: self, action: #selector(HTProductsVC.showPicker))
        
        self.navigationItem.rightBarButtonItem = button

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - Table view data source
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = productList[indexPath.row].name
        
        return cell
    }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc  = HTProductInfoVC(nibName: nil, bundle: nil)
        vc.product = productList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    //MARK :- TOOLBAR DELEGATES
    
    @objc func doneClick()
    {
        self.pickerView.isHidden = true
        self.toolBar.isHidden = true
        
        switch selectedSortType {
        case "Views Low to High":
            productList = productList.sorted(by: { $0.viewCount < $1.viewCount })
        case "Views High to Low":
            productList = productList.sorted(by: { $0.viewCount > $1.viewCount })
        case "Shares Low To High":
            productList = productList.sorted(by: { $0.shares < $1.shares })
        case "Shares High To Low":
            productList = productList.sorted(by: { $0.shares > $1.shares })
        case "Most Ordered Low to High":
            productList = productList.sorted(by: { $0.orderCount < $1.orderCount })
        case "Most Ordered High to Low":
            productList = productList.sorted(by: { $0.orderCount > $1.orderCount })
        default:
            productList = productList.sorted(by: { $0.viewCount < $1.viewCount })

        }
        
        self.tableView.reloadData()
        
    }
    
    @objc func cancelClick()
    {
        self.pickerView.isHidden = true
        self.toolBar.isHidden = true
    }
    
   @objc func showPicker()
   {
        self.pickerView.isHidden = false
        self.toolBar.isHidden = false
   }
  
    
    //MARK:- PICKER VIEW DELEGATES
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return sortArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return sortArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
       selectedSortType = sortArray[row]
    }
}
