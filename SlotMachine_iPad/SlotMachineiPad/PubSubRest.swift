//
//  PubSubRest.swift
//  VegasWatch
//
//  Created by Born, Torsten on 22/04/16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import Foundation

class PubSubRest: NSObject{
    
    var accessToken       = ""
    var appleID = ""
    let configurationRest = ConfigurationRest()
    var myTimer : Timer = Timer()
    
    func getEvents() {
        
        
        // Listening to a pubsub event
        
        // Scenario flow
        // -> Send: Player lock gambling machine to play (inform via pubsub - topic: game-register)
        // -> Recieve: Event to start the gaming (via pubsub event - topic: game-start)
        // -> Send: Gambling machine sends game result (via pubsub event - topic: game-end)
        
        //
        // {
        //    "metadata": { "version": "1" },
        //    "
        // }
        
        myTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(PubSubRest.getPubSubEvent), userInfo: nil, repeats: true)
        
    }
    
    func stopEvents(){
        myTimer.invalidate()
    }
    
    func getAccessToken() {
        
        let client_id       = "S8ANUliWs9inmNiup5ITWHejAlTzWUtO"
        let client_secret   = "U03m1U65EmOiOVIO"
        
        let service     = "https://api.yaas.io/hybris/oauth2/v1/token"
        let session     = URLSession.shared
        let request     = NSMutableURLRequest(url: URL(string: service)!)
        
        let body    = "grant_type=client_credentials&client_id=" + client_id + "&client_secret=" + client_secret
        let data    = body.data(using: String.Encoding.utf8)
        
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do{
            let json:JSON = try JSON(data: data!)
            
            let token = json["access_token"].stringValue
            
            self.accessToken = token
            
            print("new access token received: " + token)
            }catch{
                
            }
            
        })
        
        task.resume()
        
    }
    
    func getAccessTokenSync( _ tokenReturn: @escaping (String) -> ()) {
        
        let client_id       = "S8ANUliWs9inmNiup5ITWHejAlTzWUtO"
        let client_secret   = "U03m1U65EmOiOVIO"
        
        let service     = "https://api.yaas.io/hybris/oauth2/v1/token"
        let session     = URLSession.shared
        let request     = NSMutableURLRequest(url: URL(string: service)!)
        
        let body    = "grant_type=client_credentials&client_id=" + client_id + "&client_secret=" + client_secret
        let data    = body.data(using: String.Encoding.utf8)
        
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
            let json:JSON = try JSON(data: data!)
            
            let token = json["access_token"].stringValue
            
            self.accessToken = token
            
            print("forced new access token: " + token)
            
            tokenReturn(token)
            }catch{
            }
            
        })
        
        task.resume()
    }
    
    func getPubSubEvent() {
        
        let tenant      = "coil2.cice"
        let topic       = "game-start"
        
        let service     = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/read"
        let session     = URLSession.shared
        let request     = NSMutableURLRequest(url: URL(string: service)!)
        
        var body    = "{ \"numEvents\": 1, \"ttlMs\": 1000, \"autoCommit\": false }"
        
        let data    = body.data(using: String.Encoding.utf8)
        
        request.httpMethod = "POST"
        request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
            let json:JSON = try JSON(data: data!)
            
            let httpResponse = response as? HTTPURLResponse
            
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
            print("[" + timestamp + "] Get Event HTTP Response: \(httpResponse!.statusCode)")
            print(json["events"][0]["payload"].stringValue)
            
            if (httpResponse!.statusCode == 401) {
                
                self.getAccessToken()
                return
                
            } else if (httpResponse!.statusCode < 400) {
                
                if (json != nil) {
                    
                    let payload:JSON            = JSON.parse(json["events"][0]["payload"].stringValue)
                    var appleIdrecieved:   String      = payload["appleId"].stringValue;
                    var gameResultWin: Bool     = payload["gameResultWin"].boolValue;
                    var eventToken: String = json["token"].stringValue;
                    var eventCreatedAt: Double = json["events"][0]["createdAt"].doubleValue
                    
                    let epocTime = TimeInterval(eventCreatedAt) / 1000
                    let creationDate = Date(timeIntervalSince1970:  epocTime)
                    
                    print("event (\(creationDate)) for \(appleIdrecieved) recieved, registered is \(self.appleID)")
                    
                    
                    let elapsedTime = Date().timeIntervalSince(creationDate)
                    print("elapsedTime \(elapsedTime)")
                    
                    if(elapsedTime < 12.00){
                        
                        if(self.appleID != appleIdrecieved){
                            return
                        }
                        
                        var myDict: [String:Any] = [ "gameResultWin" : gameResultWin, "appleId" : appleIdrecieved]
                        // Start the game on the device
                        NotificationCenter.default.post(name: Notification.Name(rawValue: startGameKey), object: myDict)
                        
                    }else{
                        print("token trashed")
                    }
                    
                    
                    // commit event, once processed
                    let service = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/commit"
                    let session = URLSession.shared
                    var request = NSMutableURLRequest(url: URL(string: service)!)
                    
                    body    = "{ \"token\": \"\(eventToken)\" }"
                    
                    var data_commit    = body.data(using: String.Encoding.utf8)
                    
                    request.httpMethod = "POST"
                    request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = data_commit
                    
                    do{
                        let task_commit = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                            
                            let httpResponse2 = response as? HTTPURLResponse
                            do {
                            let json2:JSON = try JSON(data: data!)
                            }catch{
                            
                            }
                        })
                        task_commit.resume()
                    }
                    
                }
                
            } else if (httpResponse!.statusCode == 409) {
                
                var eventCreatedAt: Double = json["events"][0]["createdAt"].doubleValue
                print("Event locked")
                
            }
            }catch{
                
            }
            
        })
        
        task.resume()
        
    }
    
    func sendGameRegisterEvent(_ appleID: String, username: String){
        let body        = "{ \"metadata\": { \"version\": \"1\" }, \"payload\": \"{ \\\"appleID\\\": \\\"" + appleID + "\\\", \\\"username\\\": \\\"" + username + "\\\" }\" }"
        self.appleID = appleID
        sendPubSubEvent(body, topic: "game-register")
    }
    
    func sendGameEndEvent(_ appleID : String, username: String, emotion : String) {
        
        let body        = "{ \"metadata\": { \"version\": \"1\" }, \"payload\": \"{ \\\"appleID\\\": \\\"" + appleID + "\\\", \\\"username\\\": \\\"" + username + "\\\", \\\"emotion\\\": \\\"" + emotion + "\\\" }\" }"
        self.appleID = ""
        sendPubSubEvent(body, topic: "game-end")
    }
    
    func sendPubSubEvent(_ payload: String, topic: String) {
        
        
        self.getAccessTokenSync(){
            
            tokenReturn in
            
            let tenant      = "coil2.cice"
            let service     = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/publish"
            let session     = URLSession.shared
            let request     = NSMutableURLRequest(url: URL(string: service)!)
            let data        = payload.data(using: String.Encoding.utf8)
            
            request.httpMethod = "POST"
            request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                do {
                let json:JSON = try JSON(data: data!)
                let httpResponse = response as? HTTPURLResponse
                if (httpResponse!.statusCode == 401) {
                    //self.getAccessToken()
                    
                    //self.sendPubSubEvent(payload, topic: topic)
                    return
                } else if (httpResponse!.statusCode < 400) {
                    // success !
                    print("message sent about" + topic)
                }
                }catch{
                }
                
            })
            
            task.resume()
            
        }
        
        
        
    }
    
}
