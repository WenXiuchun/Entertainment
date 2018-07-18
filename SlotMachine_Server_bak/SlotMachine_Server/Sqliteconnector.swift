//
//  sqliteconnector.swift
//  karen-message-service
//
//  Created by vegas on 25.07.16.
//  Copyright © 2016 vegas. All rights reserved.
//

import Foundation
import AppKit

@objc class Sqliteconnector : NSObject{
    
    var currentId : Int64 = 0
    var pubSubRest      = PubSubRest()
    
    func initialize() {
        
        do {
            
            let db = try Connection("/Users/vegas/Library/Messages/chat.db")
            currentId = try db.scalar("SELECT ROWID FROM message ORDER BY ROWID DESC LIMIT 1")! as! Int64
        
        } catch let error as NSError{
            
            print(error.localizedDescription)
        
        }
    
    }
    
    func getResponse() {
      
        do {
            
            let message = Message()
            var pathToPicture : String!
            let dbnew = try Connection("/Users/i323932/Library/Messages/chat.db")
            var picture = false
            let newRowid = try dbnew.scalar("SELECT ROWID FROM message ORDER BY ROWID DESC LIMIT 1")
            var is_from_me = try dbnew.scalar("SELECT is_from_me FROM message ORDER BY rowid DESC LIMIT 1")
            is_from_me = is_from_me!
            
            if(is_from_me! as! Int64==0) {
                
                if(newRowid! as! Int64 > currentId){
                 
                    let text = try dbnew.scalar("SELECT text FROM message ORDER BY rowid DESC LIMIT 1")
                    
                    if(text! as! String=="\u{FFFC}"){
                        let path = try dbnew.scalar("SELECT filename FROM attachment join message_attachment_join on message_attachment_join.attachment_id=attachment.rowid join message on message_attachment_join.message_id=message.rowid order by attachment.rowid desc")
                        pathToPicture = path! as! String
                        let pathToPictureSubstring = pathToPicture.substringFromIndex(pathToPicture.startIndex.advancedBy(1))
                        pathToPicture = "/users/i323932" + pathToPictureSubstring
                        print(pathToPicture)
                        var filesize : UInt64 = 0
                        let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(pathToPicture)
                        if let _attr = attr {
                            filesize = _attr.fileSize();
                        }
                        picture = true
                    }
                    
                    let user = try dbnew.scalar("SELECT id from handle WHERE ROWID = (SELECT handle_id FROM message ORDER BY rowid DESC LIMIT 1)")
                    currentId=newRowid! as! Int64
                    
                    if(picture==true){
                        let mainURL = "https://chatbot.us-east.cf.yaas.io/chatbot"
                        
                        let url = NSURL(string: mainURL)
                        let request = NSMutableURLRequest(URL: url!)
                        let imageUrl = NSURL(fileURLWithPath: pathToPicture)
                        
                        let image = NSImage(byReferencingURL: imageUrl)
                        var imageData = image.TIFFRepresentation! //eigentlich unwichtig
                        if let bits = image.representations.first as? NSBitmapImageRep{
                            imageData = bits.representationUsingType(.NSJPEGFileType, properties: [:])!
                        }
                        
                        request.addValue("binary/octet-stream", forHTTPHeaderField: "Content-Type")
                        request.HTTPMethod = "POST" // POST OR PUT What you want
                        
                        let body = NSMutableData()
                        
                        body.appendData(imageData)
                        
                        request.HTTPBody = body
                        let queue:NSOperationQueue = NSOperationQueue()
                        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                            let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                            
                            message.sendMessage(user as! String,text: answer) {
                                
                                returnMessage in
                                
                            }

                            
                        })
                    
                    }else{
                    
                        let sentence = text! as! String
                        
                        //special case - start gambling
                        if sentence.rangeOfString("Play - 5$") != nil {
                            
                            self.pubSubRest.sendGameStartEvent(user as! String)
                        
                        } else {
                        
                            let urlPath: String = "https://chatbot.us-east.cf.yaas.io/chatbot?sentence="+sentence.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                            let url: NSURL = NSURL(string: urlPath)!
                            let request1: NSMutableURLRequest = NSMutableURLRequest(URL: url)
                        
                            request1.HTTPMethod = "GET"
                            let queue:NSOperationQueue = NSOperationQueue()
                        
                            NSURLConnection.sendAsynchronousRequest(request1, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                                let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                                message.sendMessage(user as! String,text: answer){
                                    
                                    returnMessage in
                                    
                                }

                            
                            })
    
                       }
                    }
                }
            }
        
        } catch let error as NSError{
          
            print(error.domain)
        
        }
        
    }
    
    func getAnswers(pubSubRest : PubSubRest) {
        
        self.pubSubRest = pubSubRest
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "getResponse", userInfo: nil, repeats: true)
        CFRunLoopRun()
        
    }
    
}

