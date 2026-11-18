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
import AppTrackingTransparency
import AdSupport

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /// A few seconds of background time to get the goodbye out, see below.
    var leavingTask: UIBackgroundTaskIdentifier = .invalid
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
    
/*    @available(iOS 14, *)
    func requestIDFA() {
        print("hii")
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        // Tracking authorization completed. Start loading ads here.
        // loadAd()
      })
        print("byee")
    }*/

    
    func applicationWillResignActive(_ application: UIApplication) {
        PlayTracker.shared.stop()
        Global.gameData.gameScene.lastUpdateTime = 42069.0
        gameCode = Global.gameData.gameID
        username = Global.playerData.playerID
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Leaving an online game is a few writes (and, for the host, a read
        // first), and iOS suspends the app within seconds of this. Ask for a
        // little longer so they get out. If they still don't, the server marks
        // the seat gone when the connection drops (Seat, in DataPusher.swift).
        if leavingTask == .invalid {
            leavingTask = application.beginBackgroundTask(withName: "Leave online game") { [weak self] in
                self?.endLeavingTask(application)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.endLeavingTask(application)
            }
        }
        Global.gameData.gameScene.lastUpdateTime = 42069.0
        Global.gameData.ResetGameData(toLobby: false)
    }
    
    private func endLeavingTask(_ application: UIApplication) {
        guard leavingTask != .invalid else { return }
        application.endBackgroundTask(leavingTask)
        leavingTask = .invalid
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    // Runs at launch and every time the game comes back to the front, after
    // FirebaseApp.configure() above.
    func applicationDidBecomeActive(_ application: UIApplication) {
        DataPusher.markSeen()
        PlayTracker.shared.start()
    }

}

