//
//  HeadyParser.swift
//  HeadyTask
//
//  Created by Naveen on 30/01/19.
//  Copyright © 2019 NaveenSwarna. All rights reserved.
//

import UIKit


typealias ServiceResponse = (NSDictionary , Bool) -> Void


class HeadyParser: NSObject {
    
    static let sharedInstance = HeadyParser()
    
    
    func makeHTTPGetRequest(path: String, onCompletion: @escaping ServiceResponse) {
        
        print(path)
        
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL)
        
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            if data != nil {
                do {
                    
                    let jsonResult =  try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    
                    onCompletion(jsonResult ,true)
                    
                }catch{
                    print("JSON body creation Error")
                    onCompletion(NSDictionary() ,false)
                }
            }
            else
            {
                print("JSON body creation Error")
                onCompletion(NSDictionary() ,false)
            }
        })
        task.resume()
    }
    
}
