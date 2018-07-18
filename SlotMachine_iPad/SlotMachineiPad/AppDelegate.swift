//
//  AppDelegate.swift
//  SlotMachineiPad
//
//  Created by Gabriel, Jan on 20.07.16.
//  Copyright © 2016 SAP SE. All rights reserved.
//

import UIKit

let startGameKey = "com.sap.hybris.innolab.StartGame"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let pubSubRest      = PubSubRest()
    let faceEmotionRest = FaceEmotionRest()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Insert code here to initialize your application
        
        // Retrieve PubSub Event per REST!
        //self.pubSubRest.getEvents()
        
        // Disable dimming of the device
        UIApplication.shared.isIdleTimerDisabled = true
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        self.pubSubRest.stopEvents()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.pubSubRest.stopEvents()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //self.pubSubRest.getEvents()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.pubSubRest.stopEvents()
    }
    
    
}

