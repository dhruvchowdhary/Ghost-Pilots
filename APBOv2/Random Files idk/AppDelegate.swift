//
//  AppDelegate.swift
//  APBOv2
//
//  Created by 90306670 on 10/20/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      FirebaseApp.configure()
        
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "kGADSimulatorID" ];
        //860feedcf26341aa53616c341cec30db
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
      return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        Global.gameData.isBackground = true;
        print("e")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Global.gameData.isBackground = true;
        print("e")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Global.gameData.isBackground = false
        print("f")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Global.gameData.isBackground = false
        print("f")
    }

}

