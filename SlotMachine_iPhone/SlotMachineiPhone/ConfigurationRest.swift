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

        self.getAppleId(deviceId) {
            
            appleIdReturn in
            
            appleId(appleIdReturn)
            
        }
       
    }
    
    func getUsernameByAppleId(appleId : String, username: (String) -> ()) {
        
        self.getUsername(appleId) {
            
            usernameReturn in
            
            username(usernameReturn)
            
        }
        
    }
    
    func getAccessToken(tokenReturn: (String) -> ()) {
        
        let client_id           = "ScqA65iPtioykx52i1vIfmcE34Bz3nUT"
        let client_secret       = "j5iLQbrsEJ9qVxn1"
        let configuration_scope = "hybris.tenant=showcasevegas hybris.configuration_manage"
        
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

            tokenReturn(token)
            
        })
        
        task.resume()
        
    }
    
    func getAppleId(devideId : String, appleIdReturn: (String) -> ()) {
        
        // New token needed with special scope to access configruation
        self.getAccessToken() {
            
            tokenReturn in
            
            let tenant = "showcasevegas"
            
            let service = "https://api.yaas.io/hybris/configuration/v1/" + tenant + "/configurations/" + devideId
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
    
    func getUsername(appleId : String, usernameReturn: (String) -> ()) {
        
        // New token needed with special scope to access configruation
        self.getAccessToken() {
            
            tokenReturn in
            
            let tenant = "showcasevegas"
            
            let service = "https://api.yaas.io/hybris/configuration/v1/" + tenant + "/configurations/" + appleId
            let session = NSURLSession.sharedSession()
            let request = NSMutableURLRequest(URL: NSURL(string: service)!)
            
            request.HTTPMethod = "GET"
            request.setValue("Bearer " + tokenReturn, forHTTPHeaderField: "Authorization")
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                let json:JSON = JSON(data: data!)
                
                let httpResponse = response as? NSHTTPURLResponse
                
                if (httpResponse!.statusCode == 200) {
                    
                    let username = json["value"].stringValue
                    
                    usernameReturn(username)
                    
                } else {
                    
                    usernameReturn("unknown")
                    
                }
                
            })
            
            task.resume()
            
        }
        
    }

    
}