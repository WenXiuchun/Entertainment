//
//  InterfaceControllerAbout.swift
//  VegasWatch
//
//  Created by Gabriel, Jan on 29.04.16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceControllerAbout: WKInterfaceController {

    @IBOutlet var debugLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.debugLabel.setText("\(singleDataset.sharedInstance.uniqueUserID)")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
