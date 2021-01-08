//
//  GameCenter.swift
//  APBOv2
//
//  Created by 90306670 on 1/7/21.
//  Copyright © 2021 Dhruv Chowdhary. All rights reserved.
//

import GameKit
import UIKit

class GameCenter {
    
    static let shared = GameCenter()
    var viewController: UIViewController?
    var isAuthenticated = false
    
    private init() {
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            if GKLocalPlayer.local.isAuthenticated {
                self.isAuthenticated = true
                print("Authenticated to Game Center")
            } else if let vc = gcAuthVC {
                self.viewController?.present(vc, animated: true)
            } else {
                print("Error connecting to Game Center")
            }
        }
    }
    
    func updateScore(value: Int) {
        let score = GKScore(leaderboardIdentifier: "com.score.ghostpilots")
        score.value = Int64(value)
        GKScore.report([score]) { (error) in
            if error != nil {
                print("Score update: \(error!)")
            }
        }
        
    }
    
}
