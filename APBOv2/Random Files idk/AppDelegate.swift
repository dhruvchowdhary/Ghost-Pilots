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
    var gameCode: Int = 0
    var username: String = ""

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
        Global.gameData.gameScene.lastUpdateTime = 42069.0
        gameCode = Global.gameData.gameID
        username = Global.playerData.playerID
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Global.gameData.gameScene.lastUpdateTime = 42069.0
        Global.gameData.ResetGameData(toLobby: false)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

}

