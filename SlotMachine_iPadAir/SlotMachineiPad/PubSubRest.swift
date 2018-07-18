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
   var myTimer : NSTimer = NSTimer()
    
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
    
    myTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "getPubSubEvent", userInfo: nil, repeats: true)
    
    }
    
    func stopEvents(){
        myTimer.invalidate()
    }
    
    func getAccessToken() {
        
        let client_id       = "ScqA65iPtioykx52i1vIfmcE34Bz3nUT"
        let client_secret   = "j5iLQbrsEJ9qVxn1"
        
        let service     = "https://api.yaas.io/hybris/oauth2/v1/token"
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
            
            print("new access token received: " + token)
            
        })
        
        task.resume()
        
    }
    
    func getAccessTokenSync( tokenReturn: (String) -> ()) {
    
        let client_id       = "ScqA65iPtioykx52i1vIfmcE34Bz3nUT"
        let client_secret   = "j5iLQbrsEJ9qVxn1"
        
        let service     = "https://api.yaas.io/hybris/oauth2/v1/token"
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
            
            print("forced new access token: " + token)
            
            tokenReturn(token)
            
        })
        
        task.resume()
    }
    func getPubSubEvent() {
        
        let tenant      = "showcasevegas.showcasevegas"
        let topic       = "game-start"
        
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
            
            let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            print("[" + timestamp + "] Get Event HTTP Response: \(httpResponse!.statusCode)")
            print(json["events"][0]["payload"].stringValue)
            
            if (httpResponse!.statusCode == 401) {
                
                self.getAccessToken()
                return
                
            } else if (httpResponse!.statusCode < 400) {
                
                if (json != nil) {
                    
                    let payload:JSON            = JSON.parse(json["events"][0]["payload"].stringValue)
                    var appleIdrecieved:   String      = payload["appleId"].stringValue;
                    var gameResultWin: Bool     = Bool(payload["gameResultWin"]);
                    var eventToken: String = json["token"].stringValue;
                    var eventCreatedAt: Double = json["events"][0]["createdAt"].doubleValue
                    
                    let epocTime = NSTimeInterval(eventCreatedAt) / 1000
                    let creationDate = NSDate(timeIntervalSince1970:  epocTime)
                    
                    print("event (\(creationDate)) for \(appleIdrecieved) recieved, registered is \(self.appleID)")
                    
                    
                    let elapsedTime = NSDate().timeIntervalSinceDate(creationDate)
                    print("elapsedTime \(elapsedTime)")
                    
                    if(elapsedTime < 12.00){
                        
                        if(self.appleID != appleIdrecieved){
                            return
                        }
                        
                        var myDict: [String:AnyObject] = [ "gameResultWin" : gameResultWin, "appleId" : appleIdrecieved]
                        // Start the game on the device
                        NSNotificationCenter.defaultCenter().postNotificationName(startGameKey, object: myDict)
                        
                    }else{
                        print("token trashed")
                    }
                    
                    
                    // commit event, once processed
                    let service = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/commit"
                    let session = NSURLSession.sharedSession()
                    var request = NSMutableURLRequest(URL: NSURL(string: service)!)
                    
                    body    = "{ \"token\": \"\(eventToken)\" }"
                    
                    var data_commit    = body.dataUsingEncoding(NSUTF8StringEncoding)
                    
                    request.HTTPMethod = "POST"
                    request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.HTTPBody = data_commit
                    
                    let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
                    
                    
                    
                    do{
                        
                        let dataVal = try NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
                        
                        print(response)
                        do {
                            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(dataVal, options: []) as? NSDictionary {
                                print("Synchronous\(jsonResult)")
                            }
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                        
                        
                        
                    }catch let error as NSError
                    {
                        print(error.localizedDescription)
                    }
                    
                    
                    
                }
                
            } else if (httpResponse!.statusCode == 409) {
                
                var eventCreatedAt: Double = json["events"][0]["createdAt"].doubleValue
                print("Event locked")
                
            }
            
        })
        
        task.resume()
        
    }


    
    func sendGameRegisterEvent(appleID: String, username: String){
        var body        = "{ \"metadata\": { \"version\": \"1\" }, \"payload\": \"{ \\\"appleID\\\": \\\"" + appleID + "\\\", \\\"username\\\": \\\"" + username + "\\\" }\" }"
        self.appleID = appleID
        sendPubSubEvent(body, topic: "game-register")
    }
    
    func sendGameEndEvent(appleID : String, username: String, emotion : String) {
        
        var body        = "{ \"metadata\": { \"version\": \"1\" }, \"payload\": \"{ \\\"appleID\\\": \\\"" + appleID + "\\\", \\\"username\\\": \\\"" + username + "\\\", \\\"emotion\\\": \\\"" + emotion + "\\\" }\" }"
        self.appleID = ""
        sendPubSubEvent(body, topic: "game-end")
    }
    
    func sendPubSubEvent(payload: String, topic: String) {
        
        
        self.getAccessTokenSync(){
            
            tokenReturn in
            
            let tenant      = "showcasevegas.showcasevegas"
            let service     = "https://api.yaas.io/hybris/pubsub/v1/topics/" + tenant + "/" + topic + "/publish"
            let session     = NSURLSession.sharedSession()
            let request     = NSMutableURLRequest(URL: NSURL(string: service)!)
            let data        = payload.dataUsingEncoding(NSUTF8StringEncoding)
            
            request.HTTPMethod = "POST"
            request.setValue("Bearer " + self.accessToken, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = data
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                let json:JSON = JSON(data: data!)
                let httpResponse = response as? NSHTTPURLResponse
                if (httpResponse!.statusCode == 401) {
                    //self.getAccessToken()
                    
                    //self.sendPubSubEvent(payload, topic: topic)
                    return
                } else if (httpResponse!.statusCode < 400) {
                    // success !
                    print("message sent about" + topic)
                }
                
            })
            
            task.resume()
            
        }
        

        
    }
    
}