//
//  GameScene.swift
//  APBOv2
//
//  Created by 90306670 on 10/20/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit
import CoreMotion

enum CollisionType: UInt32 {
case player = 1
case playerWeapon = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let turnButton = SKSpriteNode(imageNamed: "button")
    let motionManager = CMMotionManager()
    let player = SKSpriteNode(imageNamed: "apbo")
    var count = 0;
    
       var isPlayerAlive = true
    override func didMove(to view: SKView) {
            physicsWorld.gravity = .zero
            physicsWorld.contactDelegate = self
            if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: 500, y: 100)
        //        particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
                
                player.name = "apbo"
                player.position = CGPoint(x: size.width/2, y: size.height/2)
                player.zPosition = 1
                addChild(player)
                
                turnButton.name = "btn"
                turnButton.size.height = 100
                turnButton.size.width = 100
                turnButton.position = CGPoint(x: self.frame.maxX*0.9,y: self.frame.midY)
                self.addChild(turnButton)

    
player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
       player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.isDynamic = false
               
        
        let moveRight = SKAction.moveBy(x: 50, y:0, duration:5.0)
 
        let endless = SKAction.repeatForever(moveRight)
        player.run(endless)
 
    }
}
 let rotate = SKAction.rotate(byAngle: -1, duration: 0.5)
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let positionInScene = touch!.location(in: self)
        let touchedNode = self.atPoint(positionInScene)

     if let name = touchedNode.name {
            if name == "btn" {

            let rotate = SKAction.rotate(byAngle: -1, duration: 0.5)
            let rotateEndless = SKAction.repeatForever(rotate)
        player.run(rotateEndless)
                count=1;
            }
       } else {
               count=0;
       }
    }
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        if count==1 {
            let rotate = SKAction.rotate(byAngle: 1, duration: 0.5)
            let rotateEndless = SKAction.repeatForever(rotate)
                player.run(rotateEndless)
        }

            
            
        }
    
    
    
func movement() {
   

}

}
