//
//  EnemyNode.swift
//  APBOv2
//
//  Created by 90306670 on 11/4/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit


class EnemyNode: SKSpriteNode {
   // var chosenPath: Int
   // var chosenPath: Int
    var path = UIBezierPath()
    var type: EnemyType
    var moveStright: Int
    var speeds: Int
    var lastFireTime: Double = 0
    var shields: Int
    var scoreinc: Int

    let EnemyThruster = SKEmitterNode(fileNamed: "EnemyThruster")
    
    init(type: EnemyType, startPosition: CGPoint, xOffset: CGFloat, moveStright: Int, speeds: Int) {
        self.type = type
        shields = type.shields
        scoreinc = type.scoreinc*100
        self.moveStright = moveStright
        self.speeds = speeds
       // chosenPath = moveStright.chosenPath
        // hi
        let texture = SKTexture(imageNamed: type.name)
        super.init(texture: texture, color: .white, size: texture.size())
        
        physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        name = "enemy"
        position = CGPoint(x: startPosition.x + xOffset, y: startPosition.y)
        zPosition = 5
      
        if type.name == "enemy3" {
                  EnemyThruster?.position = CGPoint(x: 0, y: -55)
            EnemyThruster?.particleScale = 0.3
              }
        else if type.name == "enemy2" {
             EnemyThruster?.position = CGPoint(x: 0, y: -40)
        }
              else {
                  EnemyThruster?.position = CGPoint(x: 0, y: -35)
              }
        
               EnemyThruster?.targetNode = self.scene
               addChild(EnemyThruster!)
        
        
    //    self.createPath()
     
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("LOL NO")
    }
    /*
    func configureMovement(_ moveStright: Int, speeds: Int) {
      //chosenPath = moveStright
        
       

        /*
        else {
            path.addCurve(to: CGPoint(x: -3500, y: 0), controlPoint1: CGPoint(x: 0, y: -position.y*4), controlPoint2: CGPoint(x: -1000, y: -position.y))
 */
 //       }
   
    }

    */

    
    
    
    
    func fire(numPoints: Int) {
        let weaponType = "\(type.name)Weapon"
        
        let weapon = SKSpriteNode(imageNamed: weaponType)
        weapon.name = "enemyWeapon"
        weapon.position = position
        weapon.zRotation = zRotation
        weapon.zPosition = 4
        parent?.addChild(weapon)
        
        weapon.physicsBody = SKPhysicsBody(rectangleOf: weapon.size)
        weapon.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
        weapon.physicsBody?.collisionBitMask = CollisionType.player.rawValue
        weapon.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        weapon.physicsBody?.mass = 0.001
        
        let speed: CGFloat = 0.7
        let adjustedRotation = zRotation + (CGFloat.pi / 2)
        
        let dx = (speed + CGFloat(numPoints)/14285.7) * cos(adjustedRotation)
        let dy = (speed + CGFloat(numPoints)/14285.7) * sin(adjustedRotation)
      //  print("dx:" + "\(dx)")
        //print("dy:" + "\(dy)")
        weapon.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
      
        /*
        let wait = SKAction.wait(forDuration:1)
        let action = SKAction.run {

              weapon.removeFromParent()
                }
            
                self.run(SKAction.sequence([wait,action]))
        */
        
     
    }
 
}
