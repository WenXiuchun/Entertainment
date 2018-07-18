//
//  Configuration.swift
//  SlotMachine_Server
//
//  Created by Born, Torsten on 17/06/16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import Foundation

class ConfigurationRest: NSObject{
    
    func getAppleIdByDeviceId(deviceId : String, appleId: (String) -> ()) {
        
        // Mapping stored @ YaaS configuration service
        //
        // Post: https://api.yaas.io/hybris/configuration/v1/showcasevegas/configurations
        //
        // {
        //   "key": "3889B95E-E3AE-4A94-835F-A6E165257755",
        //   "value": "torsten.born@sap.com",
        //   "secured": false
        // }
        
        self.getAppleId(deviceId) {
            
            appleIdReturn in
            
            appleId(appleIdReturn)
            
        }
        
    }
    
    func getAccessToken(tokenReturn: (String) -> ()) {
        
        let client_id           = "CxHplWOy8OChOiMTiyaBCCRe9VzKZ7ap"
        let client_secret       = "yht1RLTH0JmfbJZM"
        let configuration_scope = "hybris.tenant=vegas hybris.configuration_manage"
        
        let service     = "https://api.yaas.io/hybris/oauth2/v1/token"
        let session     = NSURLSession.sharedSession()
        let request     = NSMutableURLRequest(URL: NSURL(string: service)!)
        
        var body    = "grant_type=client_credentials&client_id=" + client_id + "&client_secret=" + client_secret + "&scope=" + configuration_scope
        let data    = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json:JSON = JSON(data: data!)
            let token = json["access_token"].stringValue
            
            print("TEST "+token)
            tokenReturn(token)
            
        })
        
        task.resume()
        
    }
    
    func getAppleId(deviceId : String, appleIdReturn: (String) -> ()) {
        
        // New token needed with special scope to access configruation
        self.getAccessToken() {
            
            tokenReturn in
            
            let tenant = "vegas"
            
            let service = "https://api.yaas.io/hybris/configuration/v1/" + tenant + "/configurations/" + deviceId
            let session = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: NSURL(string: service)!)
            
            request.HTTPMethod = "GET"
            request.setValue("Bearer " + tokenReturn, forHTTPHeaderField: "Authorization")
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                let json:JSON = JSON(data: data!)
                
                let httpResponse = response as? NSHTTPURLResponse
                
                if (httpResponse!.statusCode == 200) {
                    
                    let appleId = json["value"].stringValue
                    
                    appleIdReturn(appleId)
                    
                } else {
                    
                    appleIdReturn("unknown")
                    
                }
                
            })
            
            task.resume()
            
        }
        
    }
    func getUserinformation(appleId : String, userInformation: (String) -> ()) {
        
        // New token needed with special scope to access configruation
        self.getAccessToken() {
            
            tokenReturn in
            
            let tenant = "vegas"
            
            let service = "https://api.yaas.io/hybris/configuration/v1/" + tenant + "/configurations/" + appleId
            let session = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: NSURL(string: service)!)
            
            request.HTTPMethod = "GET"
            request.setValue("Bearer " + tokenReturn, forHTTPHeaderField: "Authorization")
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                let json:JSON = JSON(data: data!)
                
                let httpResponse = response as? NSHTTPURLResponse
                
                if (httpResponse!.statusCode == 200) {
                    
                    let userInfo = json["value"].stringValue
                    
                    userInformation(userInfo)
                    
                } else {
                    
                    userInformation("not yet set")
                    
                }
                
            })
            
            task.resume()
            
        }
    }
    
    func postAppleIdforDeviceId(appleId : String, deviceId : String){
        self.getAccessToken() {
            
            tokenReturn in
            
            let tenant = "vegas"
            
            let service = "https://api.yaas.io/hybris/configuration/v1/" + tenant + "/configurations"
            let session = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: NSURL(string: service)!)
        
        
        var body    = "{\"key\": \"" + deviceId + "\",\"version\": \"1\", \"secured\": \"false\", \"value\": \"" + appleId + "\"}"
        
        print(body)
        let data    = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.HTTPMethod = "POST"
        request.setValue("Bearer " + tokenReturn, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                let json:JSON = JSON(data: data!)
                print(json)
                
            })
            
            task.resume()
        }
    }
    
    func postUsernameForAppleId(username : String, appleId : String){
        self.getAccessToken() {
            
            tokenReturn in
            
            let tenant = "vegas"
            
            let service = "https://api.yaas.io/hybris/configuration/v1/" + tenant + "/configurations"
            let session = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: NSURL(string: service)!)
            
            
            var body    = "{\"key\": \"" + appleId + "\",\"version\": \"1\", \"secured\": \"false\", \"value\": \"" + username + "\"}"
            
            print(body)
            let data    = body.dataUsingEncoding(NSUTF8StringEncoding)
            
            request.HTTPMethod = "POST"
            request.setValue("Bearer " + tokenReturn, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = data
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                let json:JSON = JSON(data: data!)
                print(json)
                
            })
            
            task.resume()
        }
    }
    
}