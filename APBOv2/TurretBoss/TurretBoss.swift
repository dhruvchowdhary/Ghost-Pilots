import SpriteKit
import CoreMotion

class TurretBossScene: SKScene, SKPhysicsContactDelegate {
    var buttonPlay: MSButtonNode!
    var backButtonNode: MSButtonNode!
    var pauseButtonNode: MSButtonNode!
    let playerHealthBar = SKSpriteNode()
    let cannonHealthBar = SKSpriteNode()
    var playerHP = maxHealth
    var cannonHP = maxHealth
    var isPlayerAlive = true
    var varisPaused = 1
    var playerShields = 1
    var waveNumber = 0
    var levelNumber = 0
    let turnButton = SKSpriteNode(imageNamed: "button")
    let shootButton = SKSpriteNode(imageNamed: "button")
    let turretSprite = SKSpriteNode(imageNamed: "turretshooter")
    let cannonSprite = SKSpriteNode(imageNamed: "turretbase")
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
    let rotate = SKAction.rotate(byAngle: -1, duration: 0.5)
    var direction = 0.0
    let dimPanel = SKSpriteNode(color: UIColor.black, size: CGSize(width: 2000, height: 1000) )
    
    var lastFireTime: Double = 0
    
    
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
        
        
        addChild(cannonHealthBar)
        
        
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
        
        
        cannonSprite.position = CGPoint(x: frame.midX, y: frame.midY)
        cannonSprite.zPosition = 1
          addChild(cannonSprite)
                
        
        self.dimPanel.zPosition = 50
         self.dimPanel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
         self.addChild(self.dimPanel)
         self.dimPanel.alpha = 0
        
        turretSprite.physicsBody = SKPhysicsBody(texture: turretSprite.texture!, size: turretSprite.texture!.size())

        turretSprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(turretSprite)
        turretSprite.zPosition = 3
     
        turretSprite.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        turretSprite.physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        turretSprite.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
 

        
        backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
        backButtonNode.alpha = 0
        backButtonNode.selectedHandlers = {
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView? else {
                print("Could not get Skview")
                return
            }

            /* 2) Load Menu scene */
            guard let scene = SoloMenu(fileNamed:"SoloMenu") else {
                print("Could not make GameScene, check the name is spelled correctly")
                return
            }

            /* 3) Ensure correct aspect mode */
            scene.scaleMode = .aspectFit

            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = true
            skView.showsFPS = true

            /* 4) Start game scene */
            skView.presentScene(scene)
        }
        
        pauseButtonNode = self.childNode(withName: "pause") as? MSButtonNode
        pauseButtonNode.selectedHandlers = {
            if self.isPlayerAlive {
                if self.varisPaused == 0 {
                    self.varisPaused = 1
                    self.scene?.view?.isPaused = false
                    self.children.map{($0 as SKNode).isPaused = false}
                    self.backButtonNode.alpha = 0
                    self.dimPanel.alpha = 0

            //        self.dimPanel.removeFromParent()
                }
                else {
                    self.backButtonNode.alpha = 1
                    self.dimPanel.alpha = 0.3

                    self.varisPaused = 0
                    
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                        if self.backButtonNode.alpha == 1
                        {
                            self.scene?.view?.isPaused = true
                            self.children.map{($0 as SKNode).isPaused = true}
                        }
                    }
                }
            }
        }

        
        buttonPlay = self.childNode(withName: "turnButton") as? MSButtonNode
        if varisPaused == 1 {
            buttonPlay.selectedHandler = {
            
                let fadeAlpha = SKAction.fadeAlpha(to: 0.8 , duration: 0.1)
                let squishBig = SKAction.scale(to: 2.05, duration: 0.1)
                self.turnButton.run(fadeAlpha)
                self.turnButton.run(squishBig)
            
                self.count = 1
                self.direction = -0.1
            
                if (self.doubleTap == 1) {
                    self.player.zRotation = self.player.zRotation - 1.0;
                    let movement = SKAction.moveBy(x: 55 * cos(self.player.zRotation), y: 55 * sin(self.player.zRotation), duration: 0.2)
                    self.player.run(movement)
                    self.doubleTap = 0
                }
                else {
                    self.doubleTap = 1
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                        self.doubleTap = 0
                    }
                }
            }
            buttonPlay.selectedHandlers = {
                self.direction = 0
            }
        }
        
        buttonPlay = self.childNode(withName: "shootButton") as? MSButtonNode
        buttonPlay.selectedHandler = {
            let fadeAlpha = SKAction.fadeAlpha(to: 0.8 , duration: 0.1)
            let squishBig = SKAction.scale(to: 2.05, duration: 0.1)
            self.shootButton.run(fadeAlpha)
            self.shootButton.run(squishBig)
            
                if self.isPlayerAlive {
                    let shot = SKSpriteNode(imageNamed: "bullet")
                    shot.name = "playerWeapon"
                    shot.position = CGPoint(x: self.player.position.x + cos(self.player.zRotation)*40, y: self.player.position.y + sin(self.player.zRotation)*40)
                    //self.player.position
                    shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
                    shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
                    shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
                    shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
                    self.addChild(shot)
                    let movement = SKAction.moveBy(x: 1500 * cos(self.player.zRotation), y: 1500 * sin(self.player.zRotation), duration: 2.6)
                    let sequence = SKAction.sequence([movement, .removeFromParent()])
                    shot.run(sequence)
                
                    self.sceneShake(shakeCount: 1, intensity: CGVector(dx: 1.3*cos(self.player.zRotation), dy: 1.3*sin(self.player.zRotation)), shakeDuration: 0.05)
            }
        }
        
        thruster1?.position = CGPoint(x: -30, y: 0)
        thruster1?.targetNode = self.scene
        player.addChild(thruster1!)
      
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


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isPlayerAlive) {
           if let newScene = TurretBossScene(fileNamed: "TurretBoss") {
            newScene.scaleMode = .aspectFit
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(newScene, transition: reveal)
            }
        }
        guard isPlayerAlive else { return }
    }
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let fadeAlpha = SKAction.fadeAlpha(to: 1.0 , duration: 0.1)
        let squishNormal = SKAction.scale(to: 1.0, duration: 0.05)
        turnButton.run(fadeAlpha)
        turnButton.run(squishNormal)
        shootButton.run(fadeAlpha)
        shootButton.run(squishNormal)
        }
    
    override func update(_ currentTime: TimeInterval) {
        
        let deltaTime = max(1.0/30, currentTime - lastUpdateTime)
              lastUpdateTime = currentTime
              

              updateTurret(deltaTime)
        
        player.position = CGPoint(x:player.position.x + cos(player.zRotation) * 3.6 ,y:player.position.y + sin(player.zRotation) * 3.6)
           
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
                
        if lastFireTime + 1 < currentTime {
                              lastFireTime = currentTime
                              
                              if Int.random(in: 0...2) == 0 || Int.random(in: 0...2) == 1 {
                                  shootTurret()
                                    }
        }
  
                for child in children {
                    if child.frame.maxX < 0 {
                        if !frame.intersects(child.frame) {
                            child.removeFromParent()
                        }
                    }
                }
                
                let activeEnemies = children.compactMap { $0 as? TurretNode }
                if activeEnemies.isEmpty {
                  //  createWave()
                }
    }
    
       func updateTurret(_ dt: CFTimeInterval) {
         let deltaX = player.position.x - turretSprite.position.x
         let deltaY = player.position.y - turretSprite.position.y
         let angle = atan2(deltaY, deltaX)
    
        
                              
         turretSprite.zRotation = angle - 270 * degreesToRadians
           }
    
    func shootTurret() {
        let shot = SKSpriteNode(imageNamed: "enemy2Weapon")
                      shot.name = "TurretWeapon"
        shot.zRotation = turretSprite.zRotation
        shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
        shot.physicsBody?.categoryBitMask = CollisionType.enemyWeapon.rawValue
        shot.physicsBody?.collisionBitMask = CollisionType.player.rawValue
        shot.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        shot.physicsBody?.mass = 0.001
        
        
        shot.position = turretSprite.position
  
   //     addChild(shot)
        let movement = SKAction.moveBy(x: 1024 * cos(turretSprite.zRotation-90 * degreesToRadians), y: 1024 * sin(turretSprite.zRotation-90 * degreesToRadians), duration: 1.8432)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        shot.run(sequence)
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
        } else if let enemy = firstNode as? TurretNode {
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
    
    func gameOver() {
        isPlayerAlive = false
        self.sceneShake(shakeCount: 2, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1)
        
        playAgain.position = CGPoint(x: frame.midX, y: frame.midY - 200)
        playAgain.zPosition = 100
        playAgain.fontColor = UIColor.white
        playAgain.fontName = "AvenirNext-Bold"
        playAgain.fontSize = 60
        addChild(playAgain)
        self.pauseButtonNode.alpha = 0
        
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: frame.midY, y: frame.midY + 100)
        gameOver.zPosition = 100
        gameOver.size = CGSize(width: 900, height: 243)
            addChild(gameOver)
    }

}
