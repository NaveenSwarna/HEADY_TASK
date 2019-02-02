//
//  ViewController.swift
//  HeadyTask
//
//  Created by Naveen on 30/01/19.
//  Copyright © 2019 NaveenSwarna. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        HTHomeParser().getHomeScreenData { (fullData,status) in
            
            HTDBAdapter.sharedInstance.saveDataToDataBase(fullData)
        }

    }


}

