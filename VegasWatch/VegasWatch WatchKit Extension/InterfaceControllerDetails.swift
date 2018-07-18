//
//  InterfaceControllerDetails.swift
//  VegasWatch
//
//  Created by Gabriel, Jan on 25.04.16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceControllerDetails: WKInterfaceController {

    @IBOutlet var creditLabel: WKInterfaceLabel!
    @IBOutlet var playLabel: WKInterfaceLabel!
    
    @IBOutlet var wonLabel: WKInterfaceLabel!
    @IBOutlet var lostLabel: WKInterfaceLabel!
    
 //   @IBOutlet var debugLabel: WKInterfaceLabel!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.playLabel.setText("Plays: \(singleDataset.sharedInstance.countPlay)")
        self.creditLabel.setText("Credits: \(singleDataset.sharedInstance.totalCredits)")
//        self.debugLabel.setText("\(singleDataset.sharedInstance.uniqueUserID)")
        
        self.wonLabel.setText("Won: \n\(singleDataset.sharedInstance.countWon)")
        self.lostLabel.setText("Lost: \n\(singleDataset.sharedInstance.countLost)")
        
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }


}
