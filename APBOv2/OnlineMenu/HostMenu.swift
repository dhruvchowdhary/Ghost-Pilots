//
//  HostMenu.swift
//  APBOv2
//
//  Created by 90306670 on 2/17/21.
//  Copyright © 2021 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

class HostMenu: SKScene {
    var backButtonNode: MSButtonNode!
    var startButtonNode: MSButtonNode!
    
    var leftModeButtonNode: MSButtonNode!
    var rightModeButtonNode: MSButtonNode!
    var modeImage = SKNode(fileNamed: "ffa")
    let modeArray = ["ffa", "astroball", "infection"]
    var i = 0
    
    var leftMapButtonNode: MSButtonNode!
    var rightMapButtonNode: MSButtonNode!
    var mapImage = SKNode(fileNamed: "OnlineCubis")
    var mapArray = ["OnlineCubis", "OnlineTrisen", "OnlineHex"]
    var j = 0
    
    override func didMove(to view: SKView) {
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        self.sceneShake(shakeCount: 4, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1)
        self.run(SKAction.playSoundFileNamed("menuThumpnew", waitForCompletion: false))
        
        backButtonNode = self.childNode(withName: "back") as? MSButtonNode
        backButtonNode.selectedHandlers = {
            self.loadOnlineMenu()
        }
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIScreen.main.bounds.width < 779 {
                backButtonNode.position.x = -600
                backButtonNode.position.y =  300
            }
        }
        
        startButtonNode = self.childNode(withName: "startButton") as? MSButtonNode
        startButtonNode.selectedHandlers = {
            // create game code
            Global.gameData.CreateNewGame()
        }
        
        mapImage = self.childNode(withName: "mapImage")
        leftMapButtonNode = self.childNode(withName: "leftMap") as? MSButtonNode
        leftMapButtonNode.selectedHandlers = {
            // go left map
            if self.j==0 {
                self.j = self.mapArray.endIndex - 1
            } else {
                self.j = self.j-1
            }
            Global.gameData.map = self.mapArray[self.j]
            let mapPicChange = SKAction.setTexture(SKTexture(imageNamed: self.mapArray[self.j]))
            self.mapImage!.run(mapPicChange)
            self.leftMapButtonNode.alpha = 1
        }
        
        rightMapButtonNode = self.childNode(withName: "rightMap") as? MSButtonNode
        rightMapButtonNode.selectedHandlers = {
            // go right map
            if self.j == self.mapArray.endIndex - 1 {
                self.j = 0
            } else {
                self.j = self.j+1
            }
            Global.gameData.map = self.mapArray[self.j]
            let mapPicChange = SKAction.setTexture(SKTexture(imageNamed: self.mapArray[self.j]))
            self.mapImage!.run(mapPicChange)
            self.rightMapButtonNode.alpha = 1
        }
        
        
    }
    
    func sceneShake(shakeCount: Int, intensity: CGVector, shakeDuration: Double) {
        let sceneView = self.scene!.view! as UIView
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = shakeDuration / Double(shakeCount)
        shakeAnimation.repeatCount = Float(shakeCount)
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x - intensity.dx, y: sceneView.center.y - intensity.dy))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x + intensity.dx, y: sceneView.center.y + intensity.dy))
        sceneView.layer.add(shakeAnimation, forKey: "position")
    }
    
    func loadOnlineMenu() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Menu scene */
        guard let scene = SKScene(fileNamed:"OnlineMenu") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        if UIDevice.current.userInterfaceIdiom == .pad {
            scene.scaleMode = .aspectFit
        } else {
            scene.scaleMode = .aspectFill
        }
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func loadLobbyMenu() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Menu scene */
        guard let scene = SKScene(fileNamed:"LobbyMenu") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        if UIDevice.current.userInterfaceIdiom == .pad {
            scene.scaleMode = .aspectFit
        } else {
            scene.scaleMode = .aspectFill
        }
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}
