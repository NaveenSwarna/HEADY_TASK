//
//  AppDelegate.swift
//  HeadyTask
//
//  Created by Naveen on 30/01/19.
//  Copyright © 2019 NaveenSwarna. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        checkDB()
        setRoot()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    //MARK:- Custom Methods
    
    func checkDB() {
        
        let bundlePath = Bundle.main.path(forResource: "Heady", ofType: ".db")
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("Heady.db") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                print(filePath)
            } else {
                print("FILE NOT AVAILABLE")
                print(filePath)
                
                
                do{
                    try fileManager.copyItem(atPath: bundlePath!, toPath: filePath)
                }catch{
                    print("\n")
                    print(error)
                    
                }
            }
        }
        
        
    }
    
    func setRoot()  {
        
        let vc = HTHomeVC(nibName: nil, bundle: nil)
        let appDelegate = UIApplication.shared.delegate
        let nav = UINavigationController(rootViewController: vc)
        appDelegate?.window??.rootViewController = nav
    }
    
}

