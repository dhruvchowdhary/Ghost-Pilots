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
let maxHealth = 100
let healthBarWidth: CGFloat = 40
let healthBarHeight: CGFloat = 4
let cannonCollisionRadius: CGFloat = 70
let playerCollisionRadius: CGFloat = 10
let shotCollisionRadius: CGFloat = 20
let playAgain = SKLabelNode(text: "Tap to Play Again")

enum CollisionType: UInt32 {
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let playerHealthBar = SKSpriteNode()
    let cannonHealthBar = SKSpriteNode()
    var playerHP = maxHealth
    var cannonHP = maxHealth
    var isPlayerAlive = true
    var playerShields = 1
    var waveNumber = 0
    var levelNumber = 0
    let turnButton = SKSpriteNode(imageNamed: "button")
    let shootButton = SKSpriteNode(imageNamed: "button")
    //    let turretSprite = SKSpriteNode(imageNamed: "turretshooter")
    //    let cannonSprite = SKSpriteNode(imageNamed: "turretbase")
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    let positions = Array(stride(from: -320, through: 320, by: 80))
    let player = SKSpriteNode(imageNamed: "player")
    let shot = SKSpriteNode(imageNamed: "bullet")
    var lastUpdateTime: CFTimeInterval = 0
    var count = 0
    var doubleTap = 0;
    let thruster1 = SKEmitterNode(fileNamed: "Thrusters")
    let playAgain = SKLabelNode(text: "Tap to Play Again")
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        //size = view.bounds.size
        backgroundColor = SKColor(red: 14.0/255, green: 23.0/255, blue: 57.0/255, alpha: 1)
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: frame.midX, y: frame.midY)
        //      particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
        }
                
        player.name = "player"
        player.position.x = frame.midX-700
        player.position.y = frame.midY-80
        player.zPosition = 1
        addChild(player)

        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.isDynamic = false
        
/*        cannonSprite.position = CGPoint(x: size.width/2, y: size.height/2)
        cannonSprite.zPosition = 1
          addChild(cannonSprite)
                
        turretSprite.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(turretSprite)
        turretSprite.zPosition = 3
 */
        turnButton.name = "btn"
        turnButton.size.height = 175
        turnButton.size.width = 175
        turnButton.zPosition = 2
        turnButton.position = CGPoint(x: self.frame.midX+750,y: self.frame.midY-300)
        self.addChild(turnButton)
                
        shootButton.name = "shoot"
        shootButton.size.height = 175
        shootButton.size.width = 175
        shootButton.zPosition = 2
        shootButton.position = CGPoint(x: self.frame.midX-750 ,y: self.frame.midY-300)
        self.addChild(shootButton)
           
     //   thruster1?.position = player.position
       // thruster1?.zPosition = 1
        
        thruster1?.position = CGPoint(x: -30, y: 0)
        thruster1?.targetNode = self.scene

        player.addChild(thruster1!)
       // addChild(thruster1!)

   /*
        addChild(cannonHealthBar)
               cannonHealthBar.position = CGPoint(
                 x: cannonSprite.position.x,
                 y: cannonSprite.position.y - cannonSprite.size.height/2 - 10
               )
               
               updateHealthBar(cannonHealthBar, withHealthPoints: cannonHP)
       */
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
        self.player.zRotation = self.player.zRotation + CGFloat(self.direction);
                
    }
}
    let rotate = SKAction.rotate(byAngle: -1, duration: 0.5)
    var direction = 0.0
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isPlayerAlive) {
           if let newScene = SKScene(fileNamed: "GameScene") {
            newScene.scaleMode = .aspectFill
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(newScene, transition: reveal)
            }
        }
        guard isPlayerAlive else { return }

        let touch = touches.first
        let positionInScene = touch!.location(in: self)
        let touchedNode = self.atPoint(positionInScene)

        if let name = touchedNode.name {
            if name == "btn" {
                let fadeAlpha = SKAction.fadeAlpha(to: 0.8 , duration: 0.1)
                turnButton.run(fadeAlpha)
                count = 1
                direction = 0.1
                if (doubleTap==1) {
                    self.player.zRotation = self.player.zRotation + 1.0;
                    let movement = SKAction.moveBy(x: 55 * cos(player.zRotation), y: 55 * sin(player.zRotation), duration: 0.2)
                               player.run(movement)
                    doubleTap = 0
                }
                else {
                    doubleTap = 1
                }
            }
            else {
                count = 0
            }
       }
        if let name = touchedNode.name {
            if name == "shoot" {
                let fadeAlpha = SKAction.fadeAlpha(to: 0.8 , duration: 0.1)
                    shootButton.run(fadeAlpha)
        
                let shot = SKSpriteNode(imageNamed: "bullet")
                shot.name = "playerWeapon"
                shot.position = player.position
                shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
                shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
                shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
                shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
                addChild(shot)
                let movement = SKAction.moveBy(x: 1024 * cos(player.zRotation), y: 1024 * sin(player.zRotation), duration: 1.8432)
                let sequence = SKAction.sequence([movement, .removeFromParent()])
                    shot.run(sequence)
            }
        }
    }
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        if count==1 {
            direction = 0
            count = 0
            if doubleTap == 1 {
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                self.doubleTap = 0
                }
            }
        }
        let fadeAlpha = SKAction.fadeAlpha(to: 1.0 , duration: 0.1)
        turnButton.run(fadeAlpha)
        shootButton.run(fadeAlpha)
        }
    
    override func update(_ currentTime: TimeInterval) {
        player.position = CGPoint(x:player.position.x + cos(player.zRotation) * 2.5 ,y:player.position.y + sin(player.zRotation) * 2.5)
           
            if player.position.y < frame.minY + 35 {
                player.position.y = frame.minY + 35
            } else if player.position.y > frame.maxY - 35 {
                player.position.y = frame.maxY - 35
            }
            
            if player.position.x < frame.minX + 35  {
                player.position.x = frame.minX + 35
            } else if player.position.x > frame.maxX - 35 {
                player.position.x = frame.maxX - 35
            }
                
                for child in children {
                    if child.frame.maxX < 0 {
                        if !frame.intersects(child.frame) {
                            child.removeFromParent()
                        }
                    }
                }
                
                let activeEnemies = children.compactMap { $0 as? EnemyNode }
                if activeEnemies.isEmpty {
                    createWave()
                }
                
                for enemy in activeEnemies {
                    guard frame.intersects(enemy.frame) else { continue }
                    
                    if enemy.lastFireTime + 1 < currentTime {
                        enemy.lastFireTime = currentTime
                        
                        if Int.random(in: 0...2) == 0 || Int.random(in: 0...2) == 1 {
                            enemy.fire()
                        }
                    }
                }
        
     /*
        let deltaTime = max(1.0/30, currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        
        updatePlayer(deltaTime)
        updateTurret(deltaTime)
        checkShipCannonCollision()
        checkShotCannonCollision()
     */
    
   /*
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
      */
        
      //  thruster1?.position = CGPoint(x:player.position.x + 25 , y:player.position.y - 25 )
    
      //  thruster1?.zRotation = player.zRotation
        //hi2
    
    }
    
    func createWave() {
        guard isPlayerAlive else { return }
        
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[waveNumber]
        waveNumber += 1
        
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0..<maximumEnemyType)
        
        let enemyOffsetX: CGFloat = 100
        let enemyStartX = 800
        
        if currentWave.enemies.isEmpty {
            for(index, position) in positions.shuffled().enumerated() {
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffsetX * CGFloat(index * 3), moveStright: true)
                addChild(enemy)
            }
        } else {
            for enemy in currentWave.enemies {
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffset: enemyOffsetX * enemy.xOffset, moveStright: enemy.moveStraight)
                addChild(node)
            }
        }
    }
   
 /*   func updateTurret(_ dt: CFTimeInterval) {
      let deltaX = player.position.x - turretSprite.position.x
      let deltaY = player.position.y - turretSprite.position.y
      let angle = atan2(deltaY, deltaX)
      
      turretSprite.zRotation = angle - 270 * degreesToRadians
    }
    
    func updateHealthBar(_ node: SKSpriteNode, withHealthPoints hp: Int) {
      let barSize = CGSize(width: healthBarWidth, height: healthBarHeight);
      
      let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
      let borderColor = UIColor(red: 35.0/255, green: 28.0/255, blue: 40.0/255, alpha:1)
      
      // create drawing context
      UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
      guard let context = UIGraphicsGetCurrentContext() else { return }
      
      // draw the outline for the health bar
      borderColor.setStroke()
      let borderRect = CGRect(origin: CGPoint.zero, size: barSize)
      context.stroke(borderRect, width: 1)
      
      // draw the health bar with a colored rectangle
      fillColor.setFill()
      let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(maxHealth)
      let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
      context.fill(barRect)
      
      // extract image
      guard let spriteImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
      UIGraphicsEndImageContext()
      
      // set sprite texture and size
      node.texture = SKTexture(image: spriteImage)
      node.size = barSize
    }
    
    func checkShipCannonCollision() {
       let deltaX = player.position.x - turretSprite.position.x
       let deltaY = player.position.y - turretSprite.position.y
       
       let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
       guard distance <= cannonCollisionRadius + playerCollisionRadius else { return }
      
       
       let offsetDistance = cannonCollisionRadius + playerCollisionRadius - distance
       let offsetX = deltaX / distance * offsetDistance
       let offsetY = deltaY / distance * offsetDistance
       player.position = CGPoint(
         x: player.position.x + offsetX,
         y: player.position.y + offsetY
       )
       
  

       updateHealthBar(cannonHealthBar, withHealthPoints: cannonHP)
  
     }
    func checkShotCannonCollision() {
         let deltaX = shot.position.x - turretSprite.position.x
         let deltaY = shot.position.y - turretSprite.position.y
         
         let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
         guard distance <= cannonCollisionRadius + shotCollisionRadius else { return }
        
         
         let offsetDistance = cannonCollisionRadius + shotCollisionRadius - distance
         let offsetX = deltaX / distance * offsetDistance
         let offsetY = deltaY / distance * offsetDistance
         shot.position = CGPoint(
           x: shot.position.x + offsetX,
           y: shot.position.y + offsetY
         )
   
         cannonHP = max(0, cannonHP - 20)

         updateHealthBar(cannonHealthBar, withHealthPoints: cannonHP)
        
          shot.removeFromParent()
    
       }
  */
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if secondNode.name == "player" {
            guard isPlayerAlive else { return }
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                addChild(explosion)
            }
            
            playerShields -= 1
            if playerShields == 0 {
                gameOver()
                secondNode.removeFromParent()
            }
            
            firstNode.removeFromParent()
        } else if let enemy = firstNode as? EnemyNode {
            enemy.shields -= 1
            
            if enemy.shields == 0 {
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = enemy.position
                    addChild(explosion)
                }
                enemy.removeFromParent()
            }
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = enemy.position
                addChild(explosion)
            }
            secondNode.removeFromParent()
        } else {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
    }
    
    func gameOver() {
        isPlayerAlive = false
        playAgain.position = CGPoint(x: frame.midX, y: frame.midY - 140)
        playAgain.fontColor = UIColor.white
        playAgain.fontSize = 60
        addChild(playAgain)
        
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
            addChild(gameOver)
    }

}
