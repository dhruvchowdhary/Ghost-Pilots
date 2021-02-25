//
//  LobbyMenu.swift
//  APBOv2
//
//  Created by 90306670 on 2/24/21.
//  Copyright © 2021 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

class LobbyMenu: SKScene {
    var backButtonNode: MSButtonNode!
    var codeLabel = SKLabelNode(text: "00000")
    var user1 = SKLabelNode(text: "user1")
    var user1colorButtonNode: MSButtonNode!
    
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
            // if host give host to someone else || if no one destroy lobby/code || if not host just leave
            self.loadOnlineMenu()
        }
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIScreen.main.bounds.width < 779 {
                backButtonNode.position.x = -600
                backButtonNode.position.y =  300
            }
        }
        
        

        codeLabel.position = CGPoint(x: frame.midX, y: frame.midY - 340)
        codeLabel.text = String(Global.gameData.gameID)
        setupLabel(label: codeLabel)
        
       // user1.text =
        user1.position = CGPoint(x: frame.midX - 300, y: frame.midY)
        user1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        setupLabel(label: user1)
        
        user1colorButtonNode = self.childNode(withName: "redPlayer") as? MSButtonNode
        user1colorButtonNode.position = CGPoint(x: user1.position.x - 230, y: user1.position.y + 50)
        user1colorButtonNode.selectedHandlers = {
            // go down a list checking if color is in use by another player and if not change it to that
            self.user1colorButtonNode.texture = SKTexture(imageNamed: "apboBlue")
            // change player's image in firebase
            
            self.user1colorButtonNode.alpha = 1
        }
        
        Global.multiplayerHandler.listenForGuestChanges()
    }
    
    
    func setPlayerList(playerList: [String]) {
        
    }
    
    func setupLabel(label: SKLabelNode) {
        label.zPosition = 2
        label.fontColor = UIColor.white
        label.fontSize = 120
        label.fontName = "AvenirNext-Bold"
        addChild(label)
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
}


