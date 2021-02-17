//
//  OnlineMenu.swift
//  APBOv2
//
//  Created by 90306670 on 11/24/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

class OnlineMenu: SKScene {

    // test
/* UI Connections */
var buttonPlay: MSButtonNode!
var backButtonNode: MSButtonNode!
    

let notDoneLabel = SKLabelNode(text: "The online version of this game is currently under development!")

    override func didMove(to view: SKView) {
        /* Setup your scene here */
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: frame.midX, y: frame.midY)
        //      particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
        }
        self.sceneShake(shakeCount: 4, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1)
        self.run(SKAction.playSoundFileNamed("menuThumpnew", waitForCompletion: false))
        notDoneLabel.position = CGPoint(x: frame.midX, y: frame.midY - 345)
        notDoneLabel.fontColor = UIColor.white
        notDoneLabel.fontSize = 42
        notDoneLabel.fontName = "AvenirNext-Bold"
        addChild(notDoneLabel)
        
        /* Set UI connections */
        backButtonNode = self.childNode(withName: "back") as? MSButtonNode
        backButtonNode.selectedHandlers = {
            self.loadMainMenu()
        }
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIScreen.main.bounds.width < 779 {
                backButtonNode.position.x = -600
                backButtonNode.position.y =  300
            }
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
    
    func loadMainMenu() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Menu scene */
        guard let scene = GameScene(fileNamed:"MainMenu") else {
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
