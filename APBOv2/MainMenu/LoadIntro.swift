//
//  MainMenu.swift
//  APBOv2
//
//  Created by 90306670 on 11/18/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

class LoadIntro: SKScene {
    let intropilot = SKSpriteNode(imageNamed: "intropilot")
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        Global.gameData.skView = self.view!
        
        intropilot.position = CGPoint(x: frame.midX, y: frame.midY)
        
        
        intropilot.size =  CGSize(width: 250.6667, height: 247.3333)
        let fadeOut = SKAction.fadeOut(withDuration: 2)
        intropilot.run(fadeOut)
        
        let wait1 = SKAction.wait(forDuration:2)
        let action1 = SKAction.run {
            loadMainMenu()
        }
        self.run(SKAction.sequence([wait1,action1]))
    
        func loadMainMenu() {
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let store = UserDefaults.standard
            store.setValue(nil, forKey: "Score")
            if let scene = SKScene(fileNamed: "MainMenu") {
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
}
}
