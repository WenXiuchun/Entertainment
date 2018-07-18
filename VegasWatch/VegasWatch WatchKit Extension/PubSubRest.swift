
//
//  PubSubRest.swift
//  VegasWatch
//
//  Created by Born, Torsten on 22/04/16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import Foundation

class PubSubRest {
    
    
    var gameresult: Bool = false
    var deviceID: String = ""
    
    
    init() {
        // perform some initialization here
    }
    
    private func getAccessToken() {
        
        let client_id       = "CxHplWOy8OChOiMTiyaBCCRe9VzKZ7ap"
        let client_secret   = "yht1RLTH0JmfbJZM"
        
        let service     = "https://api.yaas.io/hybris/oauth2/v1/token"
        let session     = NSURLSession.sharedSession()
        let request     = NSMutableURLRequest(URL: NSURL(string: service)!)
        
        var body    = "grant_type=client_credentials&client_id=" + client_id + "&client_secret=" + client_secret
        let data    = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        var token2: String = ""
        
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data
        
        
        print("retrieving token")
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            let json:JSON = JSON(data: data!)
            let token = json["access_token"].stringValue
            print("calling pubsub")
            self.pubSubEvent(token)
            
        })
        
        task.resume()
        
    }
    
    private func pubSubEvent(token: String) {

        let deviceId        = self.deviceID
        let tenant      = "vegas.demo"
        let topic       = "gaming-start"
        
        let service     = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/publish"
        let session     = NSURLSession.sharedSession()
        let request     = NSMutableURLRequest(URL: NSURL(string: service)!)
 
        print(self.deviceID)
        var userDefaults = NSUserDefaults(suiteName: "group.com.sap.cec.innospace.vegas")
        if userDefaults?.objectForKey("appleID") != nil {
            print(userDefaults?.stringForKey("appleID"))
        }
        
        var body    = "{ \"metadata\": { \"version\": \"1\" }, \"payload\": \"{ \\\"deviceID\\\": \\\"" + deviceId + "\\\", \\\"gameResultWin\\\": \\\"" + String(gameresult) + "\\\" }\"}"
        
        print(body)
        let data    = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.HTTPMethod = "POST"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            let json:JSON = JSON(data: data!)
            print("pubSubEvent")
            print(json)
            
        })
        
        task.resume()
        
    }
    
    func sendEvent(gameresult: Bool, deviceID: String) {
        self.gameresult = gameresult
        self.deviceID = deviceID

        self.getAccessToken()
        

    }
    
}