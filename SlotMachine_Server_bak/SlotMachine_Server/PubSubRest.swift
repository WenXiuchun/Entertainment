//
//  PubSubRest.swift
//  SlotMachine_Server
//
//  Created by Born, Torsten on 17/06/16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import Foundation

@objc class PubSubRest: NSObject {

    var accessToken: String = "" {
        
        didSet {
        
            // Inform us as soon as the server started / inital access token is recevied
            if oldValue == "" {
 
                //send message via imessage
                var messageService  = Message()
                
                messageService.sendMessage("aviva.wen@sap.com", text: "Karen (server) started and access token received!") {
                    returnMessage in
                }
                
                /*messageService.sendMessage("+4915157118107", text: "Karen (server) started and access token received!") {
                    returnMessage in
                }
                
                messageService.sendMessage("michael.oemler@sap.com", text: "Karen (server) started and access token received!") {
                    returnMessage in
                }*/
                
            }
                
        }
        
    }
    
    func getEvents() {

        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "getPubSubEventRegister", userInfo: nil, repeats: true)
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "getPubSubEventGameResult", userInfo: nil, repeats: true)
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "getPubSubEventSendMessage", userInfo: nil, repeats: true)
        CFRunLoopRun()

        // <--- <Scenario flow> --->

        // Player lock gambling machine to play (informed via pubsub - topic: game-register)
        // -> Response: Good Luck (via imessage)

        // Player sends money to start the game (via imessage)
        // -> Response: Event to start the gaming (via pubsub event - topic: game-start)

        // Gambling machine sends game result (via pubsub event - topic: game-end)
        // -> Response: emotion (via imessage)

        // <--- </Scenario flow> --->
        
        // Extension: Further scenarios can send message via imessage (via pubsub event - topic: message)
        // Extension: Create interaction log record (via pubsub event - topic: ilog-register, ilog-engagement, ilog-gameresult)
    }

    func getAccessToken() {

        let client_id       = "S8ANUliWs9inmNiup5ITWHejAlTzWUtO"
        let client_secret   = "U03m1U65EmOiOVIO"
        let service         = "https://api.yaas.io/hybris/oauth2/v1/token"

        let session     = NSURLSession.sharedSession()
        let request     = NSMutableURLRequest(URL: NSURL(string: service)!)

        var body    = "grant_type=client_credentials&client_id=" + client_id + "&client_secret=" + client_secret
        let data    = body.dataUsingEncoding(NSUTF8StringEncoding)

        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data

        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in

        let json:JSON = JSON(data: data!)

            let token = json["access_token"].stringValue

            self.accessToken = token

            let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            print("[" + timestamp + "] New access token received: " + token)

        })

        task.resume()

    }

    func commitEvent(eventToken : String, tenant : String, topic : String, resonseCode: (String) -> ()) {
        
        let service = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/commit"
        let session = NSURLSession.sharedSession()
        var request = NSMutableURLRequest(URL: NSURL(string: service)!)
     
        var body        = "{ \"token\": \"\(eventToken)\" }"
        var data_commit = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.HTTPMethod = "POST"
        request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data_commit
  
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
            let httpResponse   = response as? NSHTTPURLResponse
            let json:JSON      = JSON(data: data!)
            let timestamp      = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            
            resonseCode( String(httpResponse?.statusCode) )
                
        })
           
        task.resume()
        
    }
    
    func getPubSubEventRegister() {
    
        let tenant      = "coil2.cice"
        let topic       = "game-register"
    
        let service     = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/read"
        let session     = NSURLSession.sharedSession()
        let request     = NSMutableURLRequest(URL: NSURL(string: service)!)
    
        var body    = "{ \"numEvents\": 1, \"ttlMs\": 1000, \"autoCommit\": false }"
    
        let data    = body.dataUsingEncoding(NSUTF8StringEncoding)
    
        request.HTTPMethod = "POST"
        request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data
    
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
    
            let json:JSON = JSON(data: data!)
    
            let httpResponse = response as? NSHTTPURLResponse
    
            if (httpResponse!.statusCode == 401) {
    
                self.getAccessToken()
                return
    
            } else if (httpResponse!.statusCode < 400) {
    
                if (json != nil) {
    
                    let payload:JSON        = JSON.parse(json["events"][0]["payload"].stringValue)
                    var appleID:    String  = payload["appleID"].stringValue;
                    var username:   String  = payload["username"].stringValue;
                    var createdAt:  Double  = json["events"][0]["createdAt"].doubleValue;
                    var eventToken: String  = json["token"].stringValue;
                    
                    let epocTime        = NSTimeInterval(createdAt) / 1000
                    let creationDate    = NSDate(timeIntervalSince1970:  epocTime)
                    let elapsedTime     = NSDate().timeIntervalSinceDate(creationDate)
                    
                    let timestamp       = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
                    
                    // Process only events that are not older than 12 sec
                    if(elapsedTime < 12.00) {

                        print("[" + timestamp + "] Event recieved (created: " + String(createdAt) + ") User (" + username + ") registerd at slot machine - will now be processed")
                        
                        var message = "Good Luck " + username + " !"
                        
                        //send message via imessage
                        var messageService  = Message()
                        messageService.sendMessage(appleID, text: message) {
                            
                            returnMessage in
                        
                        }
                        
                        //send event to create interaction log record
                        self.sendInteractionLogEvent(appleID, topic: "ilog-register", emotion: "", gameResult: "")
    
                    } else {
                        
                        print("[" + timestamp + "] Event recieved (created: " + String(createdAt) + ") User (" + username + ") registerd at slot machine - older than 12 sec, will now be trashed!")

                    }
                    
                    //Commit event
                    self.commitEvent(eventToken, tenant : tenant, topic : topic) {
                     
                        resonseCode in
                        
                        print("[" + timestamp + "] Event " + topic + " is now commited - Response Code: " + resonseCode + "")

                    }
    
               }

            }
                
        })
            
        task.resume()
    }

    func getPubSubEventGameResult() {
    
        let tenant      = "coil2.cice"
        let topic       = "game-end"
    
        let service     = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/read"
        let session     = NSURLSession.sharedSession()
        let request     = NSMutableURLRequest(URL: NSURL(string: service)!)
    
        var body    = "{ \"numEvents\": 1, \"ttlMs\": 1000, \"autoCommit\": false }"
    
        let data    = body.dataUsingEncoding(NSUTF8StringEncoding)
    
        request.HTTPMethod = "POST"
        request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data
    
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
    
            let json:JSON = JSON(data: data!)
            let httpResponse = response as? NSHTTPURLResponse
    
            if (httpResponse!.statusCode == 401) {
    
                self.getAccessToken()
                return

            } else if (httpResponse!.statusCode < 400) {
   
                if (json != nil) {

                    let payload:JSON = JSON.parse(json["events"][0]["payload"].stringValue)
                    var appleID:    String = payload["appleID"].stringValue;
                    var username:   String = payload["username"].stringValue;
                    var emotion:    String = payload["emotion"].stringValue;
                    var createdAt:  Double  = json["events"][0]["createdAt"].doubleValue;
                    var eventToken: String  = json["token"].stringValue;
                        
                    let epocTime        = NSTimeInterval(createdAt) / 1000
                    let creationDate    = NSDate(timeIntervalSince1970:  epocTime)
                    let elapsedTime     = NSDate().timeIntervalSinceDate(creationDate)
                        
                    let timestamp       = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
                        
                    // Process only events that are not older than 12 sec
                    if(elapsedTime < 12.00) {

                        print("[" + timestamp + "] Event recieved (created: " + String(createdAt) + ") Emotion of player " + username + " is: " + emotion + "")
                            
                        var message = username + ", your emotion is: " + emotion + ". Time for some engagement ?"
                            
                        //send message via imessage
                        var messageService  = Message()
                        messageService.sendMessage(appleID, text: message) {
                                
                            returnMessage in
                                
                        }
                            
                        //send event to create interaction log record
                        self.sendInteractionLogEvent(appleID, topic: "ilog-engagement", emotion: emotion, gameResult: "")
                            
                    } else {
                            
                        print("[" + timestamp + "] Event recieved (created: " + String(createdAt) + ") Emotion of player " + username + " is: " + emotion + " - older than 12 sec, will now be trashed!")
                            
                    }
                        
                    //Commit event
                    self.commitEvent(eventToken, tenant : tenant, topic : topic) {
                            
                        resonseCode in
                            
                        print("[" + timestamp + "] Event " + topic + " is now commited - Response Code: " + resonseCode + "")
                        
                    }

                }
    
            }
            
        })
        
        task.resume()
    }
    
    func getPubSubEventSendMessage() {
        
        let tenant      = "coil2.cice"
        let topic       = "sendmessage"
        
        let service     = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/read"
        let session     = NSURLSession.sharedSession()
        let request     = NSMutableURLRequest(URL: NSURL(string: service)!)
        
        var body    = "{ \"numEvents\": 1, \"ttlMs\": 1000, \"autoCommit\": false }"
        
        let data    = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.HTTPMethod = "POST"
        request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                let json:JSON = JSON(data: data!)
                
                let httpResponse = response as? NSHTTPURLResponse
                
                if (httpResponse!.statusCode == 401) {
                    
                    self.getAccessToken()
                    return
                    
                } else if (httpResponse!.statusCode < 400) {
                    
                    if (json != nil) {
                        
                        let payload:JSON = JSON.parse(json["events"][0]["payload"].stringValue)
                        var appleID:    String = payload["appleID"].stringValue;
                        var message:    String = payload["message"].stringValue;
                        var createdAt:  Double  = json["events"][0]["createdAt"].doubleValue;
                        var eventToken: String  = json["token"].stringValue;
                        
                        let epocTime        = NSTimeInterval(createdAt) / 1000
                        let creationDate    = NSDate(timeIntervalSince1970:  epocTime)
                        let elapsedTime     = NSDate().timeIntervalSinceDate(creationDate)
                        
                        let timestamp       = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
                        
                        // Process only events that are not older than 12 sec
                        if(elapsedTime < 12.00) {
                        
                            print("[" + timestamp + "] Event recieved (created: " + String(createdAt) + ") Send message to user with the apple id: " + appleID + "")
                        
                            //send message via imessage
                            var messageService  = Message()
                            messageService.sendMessage(appleID, text: message) {
                                
                                returnMessage in
                                
                            }
              
                        
                        } else {
                            
                            print("[" + timestamp + "] Event recieved (created: " + String(createdAt) + ") Send message to user with the apple id: " + appleID + " - older than 12 sec, will now be trashed!")
                            
                        }
                            
                        //Commit event
                        self.commitEvent(eventToken, tenant : tenant, topic : topic) {
                            
                            resonseCode in
                            
                            print("[" + timestamp + "] Event " + topic + " is now commited - Response Code: " + resonseCode + "")
                            
                            
                        }
                        
                    }
                    
                } 
        })
            
        task.resume()
    }
    
    func sendInteractionLogEvent(appleId : String, topic : String, emotion : String, gameResult : String) {
        
        let tenant      = "coil2.cice"
        let topic       = topic
        
        let service     = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/publish"
        let session     = NSURLSession.sharedSession()
        let request     = NSMutableURLRequest(URL: NSURL(string: service)!)
        
        var body        = "{ \"metadata\": { \"version\": \"1\" }, \"payload\": \"{ \\\"appleID\\\": \\\"" + appleId + "\\\", \\\"emotion\\\": \\\"" + emotion + "\\\", \\\"gameresult\\\": \\\"" + gameResult + "\\\" }\"}"
        let data        = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.HTTPMethod = "POST"
        request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                let json:JSON = JSON(data: data!)
                
                let httpResponse = response as? NSHTTPURLResponse
                
                if (httpResponse!.statusCode == 401) {
                    
                    // no access token, let´s do it again - should never happen due to the pull loop (getEvents()) - but you never know / endless loop (!?)
                    self.getAccessToken()
                    self.sendGameStartEvent(appleId)
                    
                } else {
                    
                    let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
                    print("[" + timestamp + "] Event send (Interaction Log: " + topic + " !) for " + appleId)
                    
                }
                
        })
            
        task.resume()
        
    }
    
    func sendGameStartEvent(appleId : String) {
        
        let tenant      = "coil2.cice"
        let topic       = "game-start"
        
        let service     = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/publish"
        let session     = NSURLSession.sharedSession()
        let request     = NSMutableURLRequest(URL: NSURL(string: service)!)
        
        var gameresult  = self.cacluateGameResult()
        
        var body        = "{ \"metadata\": { \"version\": \"1\" }, \"payload\": \"{ \\\"appleId\\\": \\\"" + appleId + "\\\", \\\"gameResultWin\\\": \\\"" + String(gameresult) + "\\\" }\"}"
        let data        = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        request.HTTPMethod = "POST"
        request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = data
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                let json:JSON = JSON(data: data!)
                
                let httpResponse = response as? NSHTTPURLResponse
                
                if (httpResponse!.statusCode == 401) {
                    
                    // no access token, let´s do it again - should never happen due to the pull loop (getEvents()) - but you never know / endless loop (!?)
                    self.getAccessToken()
                    self.sendGameStartEvent(appleId)
                    
                } else {
                    
                    let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
                    print("[" + timestamp + "] Event send (Start Gambling !) for " + appleId)
                    
                    //send event to create interaction log record
                    self.sendInteractionLogEvent(appleId, topic: "ilog-gameresult", emotion: "", gameResult: String(gameresult))
                    
                }
                
        })
            
        task.resume()

    }
    
    private func cacluateGameResult() -> Bool {
        
        var randomNumber = Int(arc4random_uniform(6)) + 1
        
        if(randomNumber % 2 == 0) {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
}
    
    