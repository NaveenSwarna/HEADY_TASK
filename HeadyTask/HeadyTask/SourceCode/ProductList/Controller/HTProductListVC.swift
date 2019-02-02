//
//  HTProductListVC.swift
//  HeadyTask
//
//  Created by SurendraMac on 01/02/19.
//  Copyright © 2019 NaveenSwarna. All rights reserved.
//

import UIKit

class HTProductListVC: UITableViewController {
    
    var productList : [HTProductModel] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")

    }

    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = productList[indexPath.row].name
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc  = HTProductInfoVC(nibName: nil, bundle: nil)
        vc.product = productList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)

        
    }
}
