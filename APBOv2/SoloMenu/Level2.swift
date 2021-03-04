//
//  Level2.swift
//  APBOv2
//
//  Created by 64005832 on 3/4/21.
//  Copyright © 2021 Dhruv Chowdhary. All rights reserved.
//

import Foundation
import SpriteKit

class Level2: Level1 {
    
    override func createPath() {
           path = UIBezierPath()
            
            UIColor.white.setStroke()
            path.lineWidth = 5

            path.move(to: .zero)
            path.stroke()
            
        
                path.addLine(to: CGPoint(x: -1800, y: 0))

         //   path.close()
        
        
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.position.x = 1200
        shapeNode.position.y = 360
        shapeNode.strokeColor = UIColor(red: 0/255, green: 222/255, blue: 0/255, alpha:0.8)
        shapeNode.zPosition = 2
        shapeNode.lineWidth = 3
        shapeNode.alpha = 0.7
        addChild(shapeNode)
        /*
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: CGFloat(speeds))
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        run(sequence)
        
        */
        
        
       // return path
    }
    override func loadBluePilot() {
        bluepilot.name = "bluepilot"
        let changePilot = SKAction.setTexture(SKTexture(imageNamed: "greenpilot"))
        self.bluepilot.run(changePilot)
        bluepilot.position.x = frame.midX
        bluepilot.position.y = frame.midY
        bluepilot.zPosition = 5
        addChild(bluepilot)
        
        bluepilot.physicsBody = SKPhysicsBody(texture: bluepilot.texture!, size: bluepilot.texture!.size())
        bluepilot.physicsBody?.categoryBitMask = CollisionType.pilot.rawValue
        bluepilot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue | CollisionType.player.rawValue
        bluepilot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue | CollisionType.player.rawValue
        
        bluepilot.physicsBody?.isDynamic = false
    }
}
