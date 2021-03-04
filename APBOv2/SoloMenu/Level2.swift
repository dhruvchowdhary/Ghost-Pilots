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
            
        path.addLine(to: CGPoint(x: -600, y: 0))
        
        path.addLine(to: CGPoint(x: -600, y: 200))
        
                path.addLine(to: CGPoint(x: -1200, y: 720))
        
                path.addLine(to: CGPoint(x: -1800, y: 200))
        
        path.addLine(to: CGPoint(x: -1200, y: 200))
            
        path.addLine(to: CGPoint(x: -1200, y: 360))

         //   path.close()
        
        
        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.position.x = 1200
        shapeNode.position.y = -360
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
    
    override func resetscene() {
        
        restartButtonNode = self.childNode(withName: "restartButton") as? MSButtonNode
        restartButtonNode.alpha = 0
        restartButtonNode.selectedHandlers = {
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView? else {
                print("Could not get Skview")
                return
            }
            
            /* 2) Load Menu scene */
            guard let scene = GameScene(fileNamed:"Level2") else {
                print("Could not make GameScene, check the name is spelled correctly")
                return
            }
            
            /* 3) Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = false
            skView.showsFPS = false
            
            /* 4) Start game scene */
            skView.presentScene(scene)
        }
        
        playAgainButtonNode = self.childNode(withName: "playAgainButton") as? MSButtonNode
        playAgainButtonNode.alpha = 0
        playAgainButtonNode.selectedHandlers = {
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView? else {
                print("Could not get Skview")
                return
            }
            
            /* 2) Load Menu scene */
            guard let scene = GameScene(fileNamed:"Level2") else {
                print("Could not make GameScene, check the name is spelled correctly")
                return
            }
            
            /* 3) Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = false
            skView.showsFPS = false
            
            /* 4) Start game scene */
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            skView.presentScene(scene, transition: reveal)
        }
    }
    
    override func createWave() {
        guard !isGameOver else { return }
        
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[4]
       // waveNumber += 1
        waveCounter += 1
  //     var rng = SystemRandomNumberGenerator()
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0...maximumEnemyType-1)

        let speedChange = (3-enemyType)*100 + speedAdd
      //      , using: &rng)
        
        let enemyOffsetX: CGFloat = 100
        let enemyStartX = 1000
        if currentWave.enemies.isEmpty {
            for(index, position) in positions.shuffled().enumerated() {
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffsetX * CGFloat(index * 3), moveStright: 1, speeds: speedChange)
            //    print(speedChange)
                // 4th wave ^
                addChild(enemy)
                enemy.name = "\(enemyType)"
                
                
                
                let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: CGFloat(speedChange))
                let sequence = SKAction.sequence([movement, .removeFromParent()])
                enemy.run(sequence)
            //    enemy.name = "enemy"
               // enemyShipNode = self.childNode(withName: "enemy") as? MSButtonNode
                
            }
        } else {
            for enemy in currentWave.enemies {
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffset: enemyOffsetX * enemy.xOffset, moveStright: 1, speeds: speedChange)
                
                node.name = "\(enemyType)"
             ///   print("enemyType:" + "\(enemyType)")
              //  print("waveCounter:" + "\(waveCounter)")
               // print("speed:" + "\(speedChange)")
                // waves 1-3 ^
                addChild(node)
                
                let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: CGFloat(speedChange))
                let sequence = SKAction.sequence([movement, .removeFromParent()])
                node.run(sequence)
   
            }
        }
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
