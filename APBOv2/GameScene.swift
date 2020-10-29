//
//  GameScene.swift
//  APBOv2
//
//  Created by 90306670 on 10/20/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit
import CoreMotion

let degreesToRadians = CGFloat.pi / 180
let radiansToDegrees = 180 / CGFloat.pi

enum CollisionType: UInt32 {
case player = 1
case bullet = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
     
    
    let turnButton = SKSpriteNode(imageNamed: "button")
    let shootButton = SKSpriteNode(imageNamed: "button")
    let turretSprite = SKSpriteNode(imageNamed: "turretshooter")
    let cannonSprite = SKSpriteNode(imageNamed: "turretbase")
    let player = SKSpriteNode(imageNamed: "apbo")
    
    let motionManager = CMMotionManager()
    
    
     var lastUpdateTime: CFTimeInterval = 0
    var count = 0;
    var doubleTap = 0;
    
    var isPlayerAlive = true
    
    override func didMove(to view: SKView) {
        size = view.bounds.size
        
        backgroundColor = SKColor(red: 14.0/255, green: 23.0/255, blue: 57.0/255, alpha: 1)
        
            physicsWorld.gravity = .zero
            physicsWorld.contactDelegate = self
            if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: frame.midX, y: frame.midY)
        //      particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
                
                player.name = "apbo"
                player.position.x = size.width/2
                player.position.y = size.height/2
                
                cannonSprite.position = CGPoint(x: size.width/2, y: size.height/2)
                addChild(cannonSprite)
                cannonSprite.zPosition = 1
                
                turretSprite.position = CGPoint(x: size.width/2, y: size.height/2)
                addChild(turretSprite)
                turretSprite.zPosition = 2
              
                player.zPosition = 1
                addChild(player)
                
                turnButton.name = "btn"
                turnButton.size.height = 100
                turnButton.size.width = 100
                turnButton.zPosition = 2
                turnButton.position = CGPoint(x: self.frame.maxX-110,y: self.frame.minY+70)
                self.addChild(turnButton)
                
                shootButton.name = "shoot"
                shootButton.size.height = 100
                shootButton.size.width = 100
                shootButton.zPosition = 2
                shootButton.position = CGPoint(x: self.frame.minX+110 ,y: self.frame.minY+70)
                self.addChild(shootButton)
           
    
player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
       player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.isDynamic = false
                
        
       // let moveRight = SKAction.moveBy(x: 50, y:0, duration:5.0)
 
        let endless = SKAction.repeatForever(moveRight)
        player.run(endless)
                let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
                self.player.zRotation = self.player.zRotation + CGFloat(self.direction);
                }
    }
}
 let rotate = SKAction.rotate(byAngle: -1, duration: 0.5)
    var direction = 0.0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let positionInScene = touch!.location(in: self)
        let touchedNode = self.atPoint(positionInScene)

     if let name = touchedNode.name {
            if name == "btn" {
                count=1;
                direction = 0.1
                if (doubleTap==1) {
                    self.player.zRotation = self.player.zRotation + 1.0;
                    
                } else {
                    doubleTap = 1;
                }
            }
       } else {
               count=0;
       }
        if let name = touchedNode.name {
        if name == "shoot" {
        let shot = SKSpriteNode(imageNamed: "bullet")
                       shot.name = "bullet"
                       shot.position = player.position
                       shot.zPosition = 1
                       shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
                       shot.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
                       addChild(shot)
                   
                   
                       
            let movement = SKAction.moveBy(x: 700 * cos(player.zRotation), y: 700 * sin(player.zRotation), duration: 1.26)
                   
                   
                       let sequence = SKAction.sequence([movement, .removeFromParent()])
                       shot.run(sequence)
            }
        }
    }
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        if count==1 {
            direction = 0
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                self.doubleTap = 0;
            }
        }

            
            
        }
    
    override func update(_ currentTime: TimeInterval) {
        
        
        let deltaTime = max(1.0/30, currentTime - lastUpdateTime)
          lastUpdateTime = currentTime
          
        updatePlayer(deltaTime)
          updateTurret(deltaTime)
        
    }
    
    func updatePlayer(_ dt: CFTimeInterval) {
        
        player.position = CGPoint(x:player.position.x + cos(player.zRotation) * 2.5 ,y:player.position.y + sin(player.zRotation) * 2.5)
       
        
        if player.position.y < frame.minY + 35 {
            player.position.y = frame.minY + 35
        } else if player.position.y > frame.maxY-35 {
            player.position.y = frame.maxY - 35
        }
        
        if player.position.x < frame.minX + 80 {
            player.position.x = frame.minX + 80
        } else if player.position.x > frame.maxX-80 {
            player.position.x = frame.maxX - 80

                    }
        

    }
    
    
    func updateTurret(_ dt: CFTimeInterval) {
      let deltaX = player.position.x - turretSprite.position.x
      let deltaY = player.position.y - turretSprite.position.y
      let angle = atan2(deltaY, deltaX)
      
      turretSprite.zRotation = angle - 270 * degreesToRadians
    }
    
    
func movement() {
   

}

}
