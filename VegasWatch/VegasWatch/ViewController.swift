//
//  ViewController.swift
//  VegasWatch
//
//  Created by Gabriel, Jan on 20.04.16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: Properties
    let deviceId        = UIDevice.currentDevice().identifierForVendor!.UUIDString
    let tenant      = "vegas.demo"
    let topic       = "gaming-start"
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var idText: UITextField!
    let configurationRest = ConfigurationRest()
    var appleIdString: String! = "WAIT"
    var usernameString: String! = "Wait for AppleID"
    var appleId: String!
    var username: String!
    var userDefaults = NSUserDefaults(suiteName: "group.com.sap.cec.innospace.vegas")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get device id
        //look online if all paramters (username and appleID are set)
        //if yes make them able to update it
        //if no make input
        
        userDefaults?.setObject(deviceId, forKey: "deviceId")
        print("deviceId is:"+deviceId)
        initialize()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Actions
    
    @IBAction func update(sender: AnyObject) {
        if(self.appleId=="unknown"){
            self.appleId = idText.text!
            userDefaults?.setObject(idText.text, forKey: "appleID")
            configurationRest.postAppleIdforDeviceId(self.appleId, deviceId: self.deviceId)
            //self.idLabel.text="Your AppleID: "+appleId
            //self.usernameLabel.text="Enter username"
        }else if(self.username==nil){
            self.username=usernameText.text!
            userDefaults?.setObject(usernameText.text, forKey: "username")
            configurationRest.postUsernameForAppleId(self.username, appleId: self.appleId)
            self.usernameLabel.text="Welcome "+username
        }
        userDefaults!.synchronize()
        initialize()
        
    }
    
    func initialize(){
        
        if userDefaults?.objectForKey("appleID") != nil {
            idText.text = userDefaults?.stringForKey("appleID")
        }
        if userDefaults?.objectForKey("username") != nil {
            usernameText.text = userDefaults?.stringForKey("username")
        }
        
        configurationRest.getAppleIdByDeviceId(deviceId){
            appleId in
            print(appleId)
            if(appleId=="unknown"){
                self.appleIdString="No AppleID found, please enter one"
                print(self.deviceId)
                self.appleId=appleId
            }else{
                self.appleIdString="Your AppleID: "+appleId
                self.configurationRest.getUserinformation(appleId){
                    userInformation in
                    print(userInformation)
                    if(userInformation=="not yet set"){
                        self.usernameString="No username found for the AppleID"
                        print(self.usernameString)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.usernameLabel.text=self.usernameString
                            print(self.usernameString)
                        })
                    }else{
                        self.usernameString="Welcome "+userInformation
                        dispatch_async(dispatch_get_main_queue(), {
                            self.usernameLabel.text=self.usernameString
                            print(self.usernameString)
                        })
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.usernameLabel.text=self.usernameString
                print(self.usernameString)
                self.idLabel.text=self.appleIdString
            })
        }
        
    }
    
}
