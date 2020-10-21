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
    
     
    let motionManager = CMMotionManager()
    let player = SKSpriteNode(imageNamed: "apbo")
    
       var isPlayerAlive = true
    override func didMove(to view: SKView) {
        
    player.name = "apbo"
    player.position.x = frame.minX+75
    player.zPosition = 1
    addChild(player)

    
player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
       player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.isDynamic = false
               
        
    }
}

func movement() {
    
}

