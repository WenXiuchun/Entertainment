//
//  Message.swift
//  SlotMachine_Server
//
//  Created by Born, Torsten on 17/06/16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import Foundation

class Message: NSObject{
    
    func sendMessage(appleId : String, text : String, returnMessage: (String) -> ()) {
        
        if (appleId != "unknown") {

                let script = "tell application \"Messages\"\n" +
                    "set theService to first service whose service type is iMessage\n" +
                    "send \"" + text + "\" to buddy \"" + appleId + "\" of theService\n" +
                "end tell"
            
                // NSAppleScript is really not thread safe
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
               
                    if let scriptObject = NSAppleScript(source: script) {
                        
                        var errorDict: NSDictionary? = nil
                        let execute = scriptObject.executeAndReturnError(&errorDict)
                        
                        if errorDict != nil {
                            
                            print("Error while sending messages to: " + appleId + " Log: " + String(errorDict))
                        
                        }
                        
                    } else {
                    
                        print("Error while sending messages to: " + appleId)
                        
                    }

                }
                    
                let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
            
                print("[" + timestamp + "] Message (" + text + ") send to: " + appleId)
            
                returnMessage("")
            
        }
            
    }
        
}
