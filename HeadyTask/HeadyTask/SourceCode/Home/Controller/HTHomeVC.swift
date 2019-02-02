//
//  HTHomeVC.swift
//  HeadyTask
//
//  Created by Naveen on 30/01/19.
//  Copyright © 2019 NaveenSwarna. All rights reserved.
//

import UIKit

class HTHomeVC: UIViewController {
    
    
    var catGroupData : [HTCategoryModel] = []
    @IBOutlet weak var categoryTable: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        callAPIandSaveData()
        categoryTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    

    
    // MARK: - Call API and Save Data to Local DataBase
    
    func callAPIandSaveData() {
        
        HTHomeParser().getHomeScreenData { (fullData,status) in
            
            if status {
                HTDBAdapter.sharedInstance.saveDataToDataBase(fullData)
            }
            else{
                let alertController = UIAlertController(title: nil, message: "Please check your Internet Connection", preferredStyle:UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                { action -> Void in
                    
                    alertController.dismiss(animated: true, completion: nil)
                })
                self.present(alertController, animated: true, completion: nil)
            }
            
            self.fetchDataforThisScreen()
            
        }
    }

    func fetchDataforThisScreen() {
        self.catGroupData = HTDBAdapter.sharedInstance.fetchCategoryData(-1)
        DispatchQueue.main.async
        {
            self.categoryTable.reloadData()
        }
    }

}


extension HTHomeVC : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       return self.catGroupData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = catGroupData[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = catGroupData[indexPath.row]
        
        if model.subCategories.count > 0 {
            
            let vc = HTSubCategoriesVC(nibName: nil, bundle: nil)
            vc.cateGoryArray = model.subCategories
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            let vc = HTChildCategoriesVC(nibName: nil, bundle: nil)
            vc.cateGoryArray = model.childCategories
            self.navigationController?.pushViewController(vc, animated: true)
        }
       
    }
}
