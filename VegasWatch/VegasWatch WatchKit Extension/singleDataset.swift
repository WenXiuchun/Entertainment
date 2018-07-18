//
//  singleDataset.swift
//  VegasWatch
//
//  Created by Gabriel, Jan on 25.04.16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import UIKit

class singleDataset: NSObject {
    
    class var sharedInstance : singleDataset {
        struct Example {
            static let instance = singleDataset()
        }
        return Example.instance
    }

    var countPlay = 0                // counter on played games
    var countWon = 0                 // countre Won games
    var countLost = 0                // counter lost games
    var totalCredits = 100           // starting credit
    var uniqueUserID: String = "1"
    
   
    override init() {
        
        super.init()
        
        // retrieve Default Values
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let tmp: String? = userDefaults.stringForKey("uniqueUserID")
        
        if(tmp == nil){
            
            // in case there is UUID defaulted and stored, generate one and persist it.
            uniqueUserID = NSUUID().UUIDString
            self.persistData()
            print("uniqueUserID generated: \(uniqueUserID)")
            
        }else{
            
            // if there is one, cast to String
            uniqueUserID = tmp!
            print("unique id is: " + uniqueUserID)
            
        }
        
    }
    
 
    func persistData() {
        
        // persist data as Defaults
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(uniqueUserID, forKey: "uniqueUserID")
        userDefaults.synchronize()
        
    }
    
}