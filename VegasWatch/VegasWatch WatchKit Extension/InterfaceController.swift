//
//  InterfaceController.swift
//  VegasWatch WatchKit Extension
//
//  Created by Gabriel, Jan on 20.04.16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import WatchKit
import Foundation



// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


//
// Awesome Swift Resources used:
//

// Using a time: http://stackoverflow.com/questions/27990085/nstimer-how-to-delay-in-swift
// HTTP request: http://swiftdeveloperblog.com/http-get-request-example-in-swift/
// HTTP is blocked by default see http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
//
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



class InterfaceController: WKInterfaceController {

    @IBOutlet var playButton: WKInterfaceButton!
    @IBOutlet var debugLabel: WKInterfaceLabel!
    @IBOutlet var resultLabel: WKInterfaceLabel!    // Wrong/Correct Label
    
    let playCredit = 10             // players bet
    var userNameAppleID = "Chuck"   // Unique ID for cURL request
    var countPlay = 0               // counter on played games
    var countWon = 0                // countre Won games
    var countLost = 0               // counter lost games
    var totalCredits = 100           // starting credit
    
    
    @IBAction func letsPlay() {
        
        singleDataset.sharedInstance.countPlay = singleDataset.sharedInstance.countPlay + 1
        
        self.playButton.setEnabled(false)
        
        
        // Send PubSub Event per REST!
        let pubSubRest = PubSubRest()
        let seconds = 7.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        let gameresult = self.cacluateResult()
        
        self.resultLabel.setText("game is on")
        

        pubSubRest.sendEvent(gameresult, deviceID: singleDataset.sharedInstance.uniqueUserID)
        
        self.animateWithDuration(0.3, animations: {
            self.playButton.setAlpha(0.3)
        })
        

        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.resultLabel.setAlpha(1)
            self.playButton.setAlpha(1)
            print("Gameresult is: \(gameresult)")
            
            
            if( gameresult == true) {
                self.resultLabel.setText("You win!")
            } else {
                self.resultLabel.setText("You loose!")
            }
            self.playButton.setEnabled(true)
        })
        
    }
    
    @IBAction func resetButton() {
        
        singleDataset.sharedInstance.totalCredits = 100
        singleDataset.sharedInstance.countWon = 0
        singleDataset.sharedInstance.countPlay = 0
        singleDataset.sharedInstance.countLost = 0
        self.resultLabel.setAlpha(1)
        self.playButton.setAlpha(1)
        self.resultLabel.setText("let's play")
        self.playButton.setEnabled(true)
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) ->
        AnyObject? {
            print(segueIdentifier)
            if segueIdentifier == "hierarchical" {
                return ["segue": "hierarchical",
                        "data":"Passed through hierarchical navigation"]
            } else if segueIdentifier == "pagebased" {
                return ["segue": "pagebased",
                        "data": "Passed through page-based navigation"]
            } else {
                return ["segue": "nothin", "data": "nix"]
            }
    }

    func cacluateResult() -> Bool {
        
        // calculate random number - if even then win, if odd then loose
        
        var gameresult: Bool
        
        var randomNumber = Int(arc4random_uniform(6)) + 1
        
        if(randomNumber % 2 == 0) {
            gameresult = true
            singleDataset.sharedInstance.totalCredits =  singleDataset.sharedInstance.totalCredits + self.playCredit
            singleDataset.sharedInstance.countWon = singleDataset.sharedInstance.countWon + 1
        } else {
            gameresult = false
            singleDataset.sharedInstance.totalCredits =  singleDataset.sharedInstance.totalCredits - self.playCredit
            singleDataset.sharedInstance.countLost = singleDataset.sharedInstance.countLost + 1
        }
        
        return gameresult
        
    }
    
    }

