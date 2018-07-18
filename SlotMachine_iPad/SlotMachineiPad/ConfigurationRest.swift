//
//  Configuration.swift
//  SlotMachine_Server
//
//  Created by Born, Torsten on 17/06/16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import Foundation

class ConfigurationRest: NSObject{

    func getAppleIdByDeviceId(_ deviceId : String, appleId: @escaping (String) -> ()) {
            
            self.getAppleId(deviceId) {
                
                appleIdReturn in
                
                appleId(appleIdReturn)
                
            }
            
    }
        
    func getUsernameByAppleId(_ appleId : String, username: @escaping (String) -> ()) {
            
            self.getUsername(appleId) {
                
                usernameReturn in
                
                username(usernameReturn)
                
        }
            
    }

    func getAccessToken(_ tokenReturn: @escaping (String) -> ()) {
        
        let client_id           = "ScqA65iPtioykx52i1vIfmcE34Bz3nUT"
        let client_secret       = "j5iLQbrsEJ9qVxn1"
        let configuration_scope = "hybris.tenant=showcasevegas hybris.configuration_manage"
        
        let service     = "https://api.yaas.io/hybris/oauth2/v1/token"
        let session     = URLSession.shared
        let request     = NSMutableURLRequest(url: URL(string: service)!)
        
        let body    = "grant_type=client_credentials&client_id=" + client_id + "&client_secret=" + client_secret + "&scope=" + configuration_scope
        let data    = body.data(using: String.Encoding.utf8)
        
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
            let json:JSON = try JSON(data: data!)
            let token = json["access_token"].stringValue

            tokenReturn(token)
            }catch{
            }
            
        })
        
        task.resume()
        
    }
    
    func getAppleId(_ devideId : String, appleIdReturn: @escaping (String) -> ()) {
        
        // New token needed with special scope to access configruation
        self.getAccessToken() {
            
            tokenReturn in
            
            let tenant = "showcasevegas"
            
            let service = "https://api.yaas.io/hybris/configuration/v1/" + tenant + "/configurations/" + devideId
            let session = URLSession.shared
            let request = NSMutableURLRequest(url: URL(string: service)!)
            
            request.httpMethod = "GET"
            request.setValue("Bearer " + tokenReturn, forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                do{
                let json:JSON = try JSON(data: data!)
                
                let httpResponse = response as? HTTPURLResponse
                
                if (httpResponse!.statusCode == 200) {
                    
                    let appleId = json["value"].stringValue
                    
                    appleIdReturn(appleId)
                    
                } else {
                
                    appleIdReturn("unknown")

                }
                }catch{
                }
                
            })
            
            task.resume()
            
        }
    
    }
    
    func getUsername(_ appleId : String, usernameReturn: @escaping (String) -> ()) {
        
        // New token needed with special scope to access configruation
        self.getAccessToken() {
            
            tokenReturn in
            
            let tenant = "showcasevegas"
            
            let service = "https://api.yaas.io/hybris/configuration/v1/" + tenant + "/configurations/" + appleId
            let session = URLSession.shared
            let request = NSMutableURLRequest(url: URL(string: service)!)
            
            request.httpMethod = "GET"
            request.setValue("Bearer " + tokenReturn, forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                do{
                let json:JSON = try JSON(data: data!)
                
                let httpResponse = response as? HTTPURLResponse
                
                if (httpResponse!.statusCode == 200) {
                    
                    let username = json["value"].stringValue
                    
                    usernameReturn(username)
                    
                } else {
                    
                    usernameReturn("unknown")
                    
                }
                }catch{
                }
                
            })
            
            task.resume()
            
        }
        
    }
    
}
