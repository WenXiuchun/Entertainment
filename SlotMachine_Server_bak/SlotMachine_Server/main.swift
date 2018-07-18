//
//  main.swift
//  karen-message-service
//
//  Created by vegas on 25.07.16.
//  Copyright © 2016 vegas. All rights reserved.
//

import Foundation

    let sqliteconnector = Sqliteconnector()
    let pubSubRest      = PubSubRest()

    sqliteconnector.initialize()

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        sqliteconnector.getAnswers(pubSubRest);
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        pubSubRest.getEvents()
    
    }

    while true {
      
        sleep(10000)
        
    }



