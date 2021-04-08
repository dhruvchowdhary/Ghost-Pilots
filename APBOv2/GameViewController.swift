//
//  GameViewController.swift
//  APBOv2
//
//  Created by 90306670 on 10/20/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit
import GoogleMobileAds

var shouldReloadScene = false
var popUpWindow: PopUpWindow!

public class GameViewController: UIViewController, GKGameCenterControllerDelegate, GADFullScreenContentDelegate {
    public var fullScreenContentDelegate: GADFullScreenContentDelegate?
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("1")
        GADRewardedAdBeta.load(withAdUnitID: Global.adHandler.rewardedID!, request: GADRequest(), completionHandler: {
            ad, error in
            Global.adHandler.rewarded = ad
        })
    }

    
//    var rewardedAd: GADRewardedAd?
//    /// Tells the delegate that the user earned a reward.
//    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
//      print("Reward received with currency: \(reward.type), amount \(reward.amount).")
//    }
//    /// Tells the delegate that the rewarded ad was presented.
//    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
//      print("Rewarded ad presented.")
//    }
//    /// Tells the delegate that the rewarded ad was dismissed.
//    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
//      print("Rewarded ad dismissed.")
// //       rewardedAd = createAndLoadRewardedAd()
//    }
//    /// Tells the delegate that the rewarded ad failed to present.
//    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
//      print("Rewarded ad failed to present.")
//    }
//
    
    public override func viewDidLoad() {
        Global.gameViewController = self
//        super.viewDidLoad()
//        rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544~1458002511")
//        rewardedAd?.load(GADRequest()) { error in
//          if let error = error {
//            print("Loading failed: \(error)")
//          } else {
//            print("Loading Succeeded")
//          }
//        }
        
        GameCenter.shared.viewController = self
        NotificationCenter.default.addObserver(self, selector: #selector(showLeaderboard), name: NSNotification.Name(rawValue: "showLeaderboard"), object: nil)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let store = UserDefaults.standard
            store.setValue(nil, forKey: "Score")
            if let scene = SKScene(fileNamed: "LoadIntro") {
                // Set the scale mode to scale to fit the window
                if UIDevice.current.userInterfaceIdiom == .pad {
                    scene.scaleMode = .aspectFit
                } else {
                    scene.scaleMode = .aspectFill
                }
                
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
//    func createAndLoadRewardedAd() -> GADRewardedAd? {
//      rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-3940256099942544~1033173712")
//      rewardedAd?.load(GADRequest()) { error in
//        if let error = error {
//          print("Loading failed: \(error)")
//        } else {
//          print("Loading Succeeded")
//        }
//      }
//      return rewardedAd
//    }
//    func playAd() {
//        if rewardedAd?.isReady == true {
//           rewardedAd?.present(fromRootViewController: self, delegate:self)
//        } else {
//            print("ad is not ready?")
//        }
//    }
    
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func showLeaderboard(){
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = "com.score.ghostpilots"
        self.showDetailViewController(gcViewController, sender: self)
        self.navigationController?.pushViewController(gcViewController, animated: true)
        self.present(gcViewController, animated: true, completion: nil)
    }
    
    public func doPopUp(popUpText: String) {
        popUpWindow = PopUpWindow(title: "", text: popUpText, buttontext: "")
        self.present(popUpWindow, animated: true, completion: nil)
    }
    
    public func showAlertButtonTapped() {

            // create the alert
        let alert = UIAlertController(title: "My Title", message: "This is my message.", preferredStyle: .alert)
     //   let alert2 =

            // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
}
