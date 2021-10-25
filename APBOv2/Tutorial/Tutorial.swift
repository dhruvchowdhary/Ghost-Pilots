//
//  Tutorial.swift
//  APBOv2
//
//  Created by 90306670 on 12/18/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit
import CoreMotion

class Tutorial: SKScene, SKPhysicsContactDelegate {
    let cameraNode =  SKCameraNode()
    var backButtonNode: MSButtonNode!
    var pauseButtonNode: MSButtonNode!
    var turnButtonNode: MSButtonNode!
    var shootButtonNode: MSButtonNode!
    var restartButtonNode: MSButtonNode!
    var playAgainButtonNode: MSButtonNode!

    let turnLabel = SKLabelNode(text: "Press the turn button to rotate your ship!")
    let dashLabel = SKLabelNode(text: "Double-tap the turn button to dash!")
    let shootLabel = SKLabelNode(text: "Press the fire button to shoot some bullets!")
    let exitLabel = SKLabelNode(text: "Exit Tutorial")
    
    var isPlayerAlive = true
    var isGameOver = false
    var varisPaused = 1
    var playerShields = 1
    var waveNumber = 0
    var levelNumber = 0
    
    
    let turnArrow = SKSpriteNode(imageNamed: "back")
    let shootArrow = SKSpriteNode(imageNamed: "back")
    
    let turnButton = SKSpriteNode(imageNamed: "button")
    let shootButton = SKSpriteNode(imageNamed: "button")
    let turretSprite = SKSpriteNode(imageNamed: "turretshooter")
    let cannonSprite = SKSpriteNode(imageNamed: "turretbase")
//    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
//    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    let positions = Array(stride(from: -320, through: 320, by: 80))
    let player = SKSpriteNode(imageNamed: "player")
    let pilot = SKSpriteNode(imageNamed: "pilot")
    var pilotForward = false
    var pilotDirection = CGFloat(0.000)
    let pilotThrust1 = SKEmitterNode(fileNamed: "PilotThrust")
    let spark1 = SKEmitterNode(fileNamed: "Spark")
    let shot = SKSpriteNode(imageNamed: "bullet")
    var lastUpdateTime: CFTimeInterval = 0
    var count = 0
    var doubleTap = 0;
    let thruster1 = SKEmitterNode(fileNamed: "Thrusters")
    let rotate = SKAction.rotate(byAngle: -1, duration: 0.5)
    var rotation = CGFloat(0)
    var direction = 0.0
    let dimPanel = SKSpriteNode(color: UIColor.black, size: CGSize(width: 20000, height: 10000) )
    
    var lastFireTime: Double = 0
    
    var numAmmo = 3
    var regenAmmo = false
    
    let scaleAction = SKAction.scale(to: 2.2, duration: 0.4)
    
    let bullet1 = SKSpriteNode(imageNamed: "bullet")
    let bullet2 = SKSpriteNode(imageNamed: "bullet")
    let bullet3 = SKSpriteNode(imageNamed: "bullet")
    let particles = SKEmitterNode(fileNamed: "Starfield")
    
    let shape = SKShapeNode()
    
   
    
    override func didMove(to view: SKView) {
        
        shape.path = UIBezierPath(roundedRect: CGRect(x: -800 + 45 , y: -800 + 160, width: 1792 - 285, height: 1600 - 320), cornerRadius: 40).cgPath
        shape.position = CGPoint(x: frame.midX, y: frame.midY)
        shape.fillColor = .clear
        shape.strokeColor = UIColor.white
        shape.lineWidth = 10
        shape.name = "border"
        shape.physicsBody = SKPhysicsBody(edgeChainFrom: shape.path!)
        addChild(shape)
           
        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position.x = frame.width / 2
        cameraNode.position.y = frame.height / 2
        
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        //size = view.bounds.size
        backgroundColor = SKColor(red: 14.0/255, green: 23.0/255, blue: 57.0/255, alpha: 1)

       
        
        dashLabel.zPosition = 101
        dashLabel.alpha = 0
        dashLabel.fontColor = UIColor.white
        dashLabel.fontSize = 60
        dashLabel.fontName = "AvenirNext-Bold"
        addChild(dashLabel)
        
        exitLabel.zPosition = 101
        exitLabel.alpha = 1
        exitLabel.fontColor = UIColor.white
        exitLabel.fontSize = 60
        exitLabel.fontName = "AvenirNext-Bold"
        addChild(exitLabel)
        
        
        turnLabel.zPosition = 101
        turnLabel.alpha = 1
        turnLabel.fontColor = UIColor.white
        turnLabel.fontSize = 60
        turnLabel.fontName = "AvenirNext-Bold"
        addChild(turnLabel)
       
       
        turnArrow.name = "turnArrow"
              
        turnArrow.alpha = 1
        turnArrow.zPosition = 101
        turnArrow.zRotation = 2.3562
        
        addChild(turnArrow)
        
       
        shootLabel.zPosition = 100
        shootLabel.alpha = 0
        shootLabel.fontColor = UIColor.white
        shootLabel.fontSize = 60
        shootLabel.fontName = "AvenirNext-Bold"
        addChild(shootLabel)
        
         shootArrow.name = "shootArrow"
        shootArrow.alpha = 0
        shootArrow.zRotation = 0.7854
     
        shootArrow.zPosition = 101
        addChild(shootArrow)
        
        
        
        player.name = "player"
        player.position.x = frame.midX-700
        player.position.y = frame.midY-80
        player.zPosition = 200
        
        addChild(player)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
         
            self.dashLabel.alpha = 1
            self.turnLabel.alpha = 0
            
            let timer2 = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
                
                
                self.turnArrow.alpha = 0
                self.turnLabel.alpha = 0
                self.dashLabel.alpha = 0
                self.shootLabel.alpha = 1
                //  self.turnButtonNode.zPosition = 0
                //self.shootButtonNode.zPosition = 100
                self.shootArrow.alpha = 1
                
                let timer3 = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
                               self.shootLabel.alpha = 0
            //         self.turnButtonNode.zPosition = 100
                //     self.shootButtonNode.zPosition = 100
                    self.shootArrow.alpha = 0
                    self.turnArrow.alpha = 0
        //        self.dimPanel.removeFromParent()
                    self.dashLabel.alpha = 0

                      }
           
            }
        }
        
        thruster1?.position = CGPoint(x: -30, y: 0)
        thruster1?.targetNode = self.scene
        player.addChild(thruster1!)
        
        
        particles!.position = CGPoint(x: frame.midX, y: frame.midY)
        particles!.targetNode = self.scene
        addChild(particles!)

        
        bullet1.zPosition = 200
        bullet2.zPosition = 200
        bullet3.zPosition = 200
        addChild(bullet1)
        addChild(bullet2)
        addChild(bullet3)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
        player.physicsBody?.isDynamic = false
        
        pilot.size = CGSize(width: 40, height: 40)
        pilot.physicsBody = SKPhysicsBody(texture: pilot.texture!, size: pilot.size)
        pilot.physicsBody?.categoryBitMask = CollisionType.pilot.rawValue
        pilot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
        pilot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
        pilot.physicsBody?.isDynamic = false
        
        if (Global.gameData.selectedSkin.rawValue != "DEFAULTDECAL") {
            let skin = SKSpriteNode(imageNamed: Global.gameData.selectedSkin.rawValue)
            skin.zPosition = 10
            player.addChild(skin)
        }
        if (Global.gameData.selectedTrail.rawValue != "trailDefault") {
            let trail = SKEmitterNode(fileNamed: Global.gameData.selectedTrail.rawValue)
            trail?.targetNode = self.scene
            player.addChild(trail!)
            thruster1?.removeFromParent()
        }
        
        self.dimPanel.zPosition = 50
        self.dimPanel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(self.dimPanel)
        self.dimPanel.alpha = 0
        
        
        backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
        backButtonNode.zPosition = 100
        backButtonNode.alpha = 1
        backButtonNode.selectedHandlers = {
            self.exitLabel.alpha = 0.7
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView? else {
                print("Could not get Skview")
                return
            }
            
            /* 2) Load Menu scene */
            guard let scene = MainMenu(fileNamed:"MainMenu") else {
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
        
        turnButtonNode = self.childNode(withName: "turnButton") as? MSButtonNode
        turnButtonNode.selectedHandler = {
             self.turnButtonNode.setScale(1.1)
            if self.varisPaused==1 && self.isPlayerAlive {
                self.turnButtonNode.alpha = 0.6
                self.count = 1
                
                if (self.doubleTap == 1) {
                    self.player.zRotation = self.player.zRotation - 3.141592/2 + self.rotation + 0.24
                    let movement = SKAction.moveBy(x: 60 * cos(self.player.zRotation), y: 60 * sin(self.player.zRotation), duration: 0.15)
                    self.player.run(movement)
                    self.thruster1?.particleColorSequence = nil
                    self.thruster1?.particleColorBlendFactor = 1.0
                    self.thruster1?.particleColor = UIColor(red: 240.0/255, green: 50.0/255, blue: 53.0/255, alpha:1)
                    
                    self.run(SKAction.playSoundFileNamed("swishnew", waitForCompletion: false))
                    
                    self.rotation = 0
                    self.doubleTap = 0
                    self.direction = -0.08
                }
                else {
                    self.direction = -0.08
                    self.doubleTap = 1
                    //  self.thruster1?.particleColor = UIColor(red: 67/255, green: 181/255, blue: 169/255, alpha:1)
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                        self.doubleTap = 0
                    }
                }
            } else if !self.isPlayerAlive {
                self.direction = -0.08
            }
        }
        turnButtonNode.selectedHandlers = {
            self.turnButtonNode.setScale(1)
            if !self.isGameOver {
            self.turnButtonNode.alpha = 0.4
            let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
                self.thruster1?.particleColor = UIColor(red: 67/255, green: 181/255, blue: 169/255, alpha:1)
            }
            if self.varisPaused == 1 {
                self.direction = 0
            }
            } else {
                self.turnButtonNode.alpha = 0
            }
        }
        
        shootButtonNode = self.childNode(withName: "shootButton") as? MSButtonNode
        
        
        
        shootButtonNode.selectedHandler = {
            self.shootButtonNode.alpha = 0.6
            self.shootButtonNode.setScale(1.1)
            if self.varisPaused==1 && self.isPlayerAlive {
                if self.isPlayerAlive {
                    if self.numAmmo > 0 {
                        self.run(SKAction.playSoundFileNamed("Laser1new", waitForCompletion: false))
                        
                        /*
                         if let ShootingExplosion = SKEmitterNode(fileNamed: "ShootingExplosion") {
                         ShootingExplosion.position.x = self.player.position.x + 60 * cos(self.player.zRotation)
                         ShootingExplosion.position.y = self.player.position.y + 60 * sin(self.player.zRotation)
                         
                         
                         ShootingExplosion.emissionAngle = self.player.zRotation
                         
                         self.addChild(ShootingExplosion)
                         }
                         */
                        if self.numAmmo == 3 {
                            self.bullet1.removeFromParent()
                        }
                        else if self.numAmmo == 2 {
                            self.bullet2.removeFromParent()
                        }
                        else if self.numAmmo == 1 {
                            self.bullet3.removeFromParent()
                        }
                        
                        let shot = SKSpriteNode(imageNamed: "bullet")
                        shot.name = "playerWeapon"
                        shot.position = CGPoint(x: self.player.position.x + cos(self.player.zRotation)*40, y: self.player.position.y + sin(self.player.zRotation)*40)
                        
                        shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
                        shot.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
                        shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                        shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                        self.addChild(shot)
                        
                        let movement = SKAction.moveBy(x: 1500 * cos(self.player.zRotation), y: 1500 * sin(self.player.zRotation), duration: 2.6)
                        let sequence = SKAction.sequence([movement, .removeFromParent()])
                        shot.run(sequence)
                        
                        self.numAmmo = self.numAmmo - 1
                        
                        let recoil = SKAction.moveBy(x: -8 * cos(self.player.zRotation), y: -8 * sin(self.player.zRotation), duration: 0.01)
                        self.player.run(recoil)
                        
                        
                        Global.sceneShake(shakeCount: 1, intensity: CGVector(dx: 1.2*cos(self.player.zRotation), dy: 1.2*sin(self.player.zRotation)), shakeDuration: 0.04, sceneview: self.scene!)
                    }
                }
            } else {
                self.pilotForward = true
                self.pilotThrust1?.particleAlpha = 1
            }
        }
        shootButtonNode.selectedHandlers = {
            self.shootButtonNode.setScale(1)
            if !self.isGameOver {
                self.pilotDirection = self.pilot.zRotation
                self.shootButtonNode.alpha = 0.4
                self.pilotForward = false
                self.pilotThrust1?.particleAlpha = 0
            } else {
                self.shootButtonNode.alpha = 0
            }
        }
        
        
        let turnTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
            self.player.zRotation = self.player.zRotation + 1.2*CGFloat(self.direction)
            self.pilot.zRotation = self.pilot.zRotation + 1.2 * CGFloat(self.direction)
            if self.doubleTap == 1 {
                self.rotation = self.rotation - 1.2 * CGFloat(self.direction)
            } else {
                self.rotation = 0
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let fadeAlpha = SKAction.fadeAlpha(to: 1.0 , duration: 0.1)
        let squishNormal = SKAction.scale(to: 1.0, duration: 0.05)
        turnButton.run(fadeAlpha)
        turnButton.run(squishNormal)
        shootButton.run(fadeAlpha)
        shootButton.run(squishNormal)
    }

    func followCamera() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            turnArrow.position.x = cameraNode.position.x + 550
            turnArrow.position.y = cameraNode.position.y - 110
            
            shootArrow.position.x = cameraNode.position.x - 550
            shootArrow.position.y = cameraNode.position.y - 110

            dashLabel.position.x = cameraNode.position.x
            dashLabel.position.y = cameraNode.position.y + 150
            turnLabel.position.x = cameraNode.position.x
            turnLabel.position.y = cameraNode.position.y + 150
            shootLabel.position.x = cameraNode.position.x
            shootLabel.position.y = cameraNode.position.y + 150
            
            turnButtonNode.position.x = cameraNode.position.x + 640
            turnButtonNode.position.y = cameraNode.position.y - 410
            turnButtonNode.setScale(1.25)
            
            shootButtonNode.position.x = cameraNode.position.x - 640
            shootButtonNode.position.y =  cameraNode.position.y - 410
            shootButtonNode.setScale(1.25)
            
     /*       pauseButtonNode.position.x = cameraNode.position.x + 640
            pauseButtonNode.position.y =  cameraNode.position.y + 430
            pauseButtonNode.setScale(1.25)
 */
            
            backButtonNode.position.x = cameraNode.position.x - 640
            backButtonNode.position.y =  cameraNode.position.y + 430
            backButtonNode.setScale(1.25)
            
            exitLabel.position.x = backButtonNode.position.x + 260
            exitLabel.position.y = backButtonNode.position.y - 20
            
       /*     restartButtonNode.position.x = cameraNode.position.x + 480
            restartButtonNode.position.y =  cameraNode.position.y + 430
            restartButtonNode.setScale(1.25)
            
            playAgainButtonNode.position.x = cameraNode.position.x
            playAgainButtonNode.position.y = cameraNode.position.y - 224
            playAgainButtonNode.setScale(1.25)
            
            */
            
        } else {
            if UIScreen.main.bounds.width > 779 {
                turnArrow.position.x = cameraNode.position.x + 550
                turnArrow.position.y = cameraNode.position.y - 110
                
                shootArrow.position.x = cameraNode.position.x - 550
                shootArrow.position.y = cameraNode.position.y - 110
                
                dashLabel.position.x = cameraNode.position.x
                dashLabel.position.y = cameraNode.position.y + 150
                turnLabel.position.x = cameraNode.position.x
                turnLabel.position.y = cameraNode.position.y + 150
                shootLabel.position.x = cameraNode.position.x
                shootLabel.position.y = cameraNode.position.y + 150
                
                turnButtonNode.position.x = cameraNode.position.x + 660
                turnButtonNode.position.y = cameraNode.position.y - 250
                
                shootButtonNode.position.x = cameraNode.position.x - 660
                shootButtonNode.position.y =  cameraNode.position.y - 250

                backButtonNode.position.x = cameraNode.position.x - 660
                backButtonNode.position.y =  cameraNode.position.y + 290
                
                exitLabel.position.x = backButtonNode.position.x + 260
                exitLabel.position.y = backButtonNode.position.y - 20

            } else if UIScreen.main.bounds.width > 567 {
                turnArrow.position.x = cameraNode.position.x + 550
                turnArrow.position.y = cameraNode.position.y - 110
                
                shootArrow.position.x = cameraNode.position.x - 550
                shootArrow.position.y = cameraNode.position.y - 110
                
                dashLabel.position.x = cameraNode.position.x
                dashLabel.position.y = cameraNode.position.y + 150
                turnLabel.position.x = cameraNode.position.x
                turnLabel.position.y = cameraNode.position.y + 150
                shootLabel.position.x = cameraNode.position.x
                shootLabel.position.y = cameraNode.position.y + 150
                
                turnButtonNode.position.x = cameraNode.position.x + 660
                turnButtonNode.position.y = cameraNode.position.y - 320
                
                shootButtonNode.position.x = cameraNode.position.x - 660
                shootButtonNode.position.y =  cameraNode.position.y - 320
                
                backButtonNode.position.x = cameraNode.position.x - 660
                backButtonNode.position.y =  cameraNode.position.y + 350
                
                exitLabel.position.x = backButtonNode.position.x + 260
                exitLabel.position.y = backButtonNode.position.y - 20
                print(exitLabel.frame.height)
            } else {
                turnArrow.position.x = cameraNode.position.x + 550
                turnArrow.position.y = cameraNode.position.y - 110
                
                shootArrow.position.x = cameraNode.position.x - 550
                shootArrow.position.y = cameraNode.position.y - 110

                dashLabel.position.x = cameraNode.position.x
                dashLabel.position.y = cameraNode.position.y + 150
                turnLabel.position.x = cameraNode.position.x
                turnLabel.position.y = cameraNode.position.y + 150
                shootLabel.position.x = cameraNode.position.x
                shootLabel.position.y = cameraNode.position.y + 150
                
                turnButtonNode.position.x = cameraNode.position.x + 660
                turnButtonNode.position.y = cameraNode.position.y - 320
                
                shootButtonNode.position.x = cameraNode.position.x - 660
                shootButtonNode.position.y =  cameraNode.position.y - 320
                
                backButtonNode.position.x = cameraNode.position.x - 660
                backButtonNode.position.y =  cameraNode.position.y + 350
                
                exitLabel.position.x = backButtonNode.position.x + 260
                exitLabel.position.y = backButtonNode.position.y - 20
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let deltaTime = max(1.0/30, currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        
        
        if isPlayerAlive {
            
            
            cameraNode.position.x = player.position.x
            cameraNode.position.y = player.position.y
            followCamera()
            
            player.position = CGPoint(x:player.position.x + cos(player.zRotation) * 3.7 ,y:player.position.y + sin(player.zRotation) * 3.7)
            pilotDirection = player.zRotation - 3.141592/2

            bullet1.position = player.position
            bullet2.position = player.position
            bullet3.position = player.position
            
            let revolve1 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime )), y: -CGFloat(50 * sin(2 * currentTime)), duration: 0.000001)
            let revolve2 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime + 2.0944)), y: -CGFloat(50 * sin(2 * currentTime + 2.0944)), duration: 0.000001)
            let revolve3 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime + 4.18879)), y: -CGFloat(50 * sin(2 * currentTime + 4.18879)), duration: 0.000001)
            
            bullet1.run(revolve1)
            bullet2.run(revolve2)
            bullet3.run(revolve3)
            
            
            if player.position.y < frame.minY + 190 {
                player.position.y = frame.minY + 190
            } else if player.position.y > frame.maxY - 190 {
                player.position.y = frame.maxY - 190
            }
            
            if player.position.x < frame.minX + 80  {
                player.position.x = frame.minX + 80
            } else if player.position.x > frame.maxX - 80 {
                player.position.x = frame.maxX - 80
            }
            
            
            
            if self.numAmmo < 3 {
                if !self.regenAmmo {
                    self.regenAmmo = true
                    let ammoTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (timer) in
                        self.numAmmo = self.numAmmo + 1
                        
                        if self.numAmmo == 1 {
                            self.addChild(self.bullet3)
                        }
                        else if self.numAmmo == 2 {
                            self.addChild(self.bullet2)
                        }
                        else if self.numAmmo == 3 {
                            self.addChild(self.bullet1)
                        }
                        self.regenAmmo = false
                    }
                }
            }
        } else {
            if !isGameOver {
                cameraNode.position.x = pilot.position.x
                cameraNode.position.y = pilot.position.y
                followCamera()
            }
            
            bullet1.removeFromParent()
            bullet2.removeFromParent()
            bullet3.removeFromParent()
            
            if self.pilotForward {
                pilot.position = CGPoint(x:pilot.position.x + cos(pilot.zRotation+3.141592/2) * 2 ,y:pilot.position.y + sin(pilot.zRotation+3.141592/2) * 2)
            } else {
                pilot.position = CGPoint(x:pilot.position.x + cos(pilotDirection + 3.141592/2) * 0.9 ,y:pilot.position.y + sin(pilotDirection + 3.141592/2) * 0.9)
            }
            
            if pilot.position.y < frame.minY + 185 {
                pilot.position.y = frame.minY + 185
            } else if pilot.position.y > frame.maxY - 185 {
                pilot.position.y = frame.maxY - 185
            }
            if pilot.position.x < frame.minX + 75  {
                pilot.position.x = frame.minX + 75
            } else if pilot.position.x > frame.maxX - 75 {
                pilot.position.x = frame.maxX - 75
            }
        }
        /*
        for child in children {
            if child.frame.maxX < 0 {
                if !frame.intersects(child.frame) {
                    child.removeFromParent()
                }
            }
        }
 */
        if isGameOver {
            direction = -0.1
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        
        if firstNode.name == "player" && secondNode.name == "turretSprite" {
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = player.position
                addChild(explosion)
            }
            if !isGameOver {
                gameOverScreen()
            }
        }
        
        if firstNode.name == "pilot" && secondNode.name == "turretSprite" {
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = pilot.position
                addChild(explosion)
            }
            if !isGameOver {
                gameOverScreen()
            }
        }
        if secondNode.name == "player" {
            self.run(SKAction.playSoundFileNamed("explosionnew", waitForCompletion: false))
            Global.sceneShake(shakeCount: 2, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1, sceneview: self.scene!)
            if let explosion = SKEmitterNode(fileNamed: "ShipExplosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            pilot.name = "pilot"
            pilot.size = CGSize(width: 40, height: 40)
            pilot.zRotation = player.zRotation - 3.141592/2
            pilot.position = player.position
            pilot.zPosition = 5
            addChild(pilot)
            //            gameOver()
            
            pilotThrust1?.position = CGPoint(x: 0, y: -20)
            pilotThrust1?.targetNode = self.scene
            pilotThrust1?.particleAlpha = 0
            pilot.addChild(pilotThrust1!)
            
            firstNode.removeFromParent()
            secondNode.removeFromParent()
            
            let wait = SKAction.wait(forDuration:7)
            let action = SKAction.run {
                if !self.isGameOver {
                self.spark1?.position = CGPoint(x: 0, y: 0)
                self.spark1?.targetNode = self.scene
                self.spark1?.particleAlpha = 1
                self.pilot.addChild(self.spark1!)
                self.spark1?.particleAlpha = 1
                self.spark1?.particleLifetime = 1
                    self.run(SKAction.playSoundFileNamed("revivenew", waitForCompletion: false))
                }
                
                let wait1 = SKAction.wait(forDuration:1.5)
                let action1 = SKAction.run {
                    if !self.isGameOver {
                        self.spark1?.removeFromParent()
                        self.pilotThrust1?.particleAlpha = 0
                        //   self.spark1?.particleLifetime = 0
                        self.player.position = self.pilot.position
                        self.isPlayerAlive = true
                        self.addChild(self.player)
                        self.pilotThrust1?.removeFromParent()
                        self.pilot.removeFromParent()
                        
                        self.playerShields += 1
                        self.numAmmo = 3
                        self.bullet1.position = self.player.position
                        self.bullet2.position = self.player.position
                        self.bullet3.position = self.player.position
                        self.addChild(self.bullet1)
                        self.addChild(self.bullet2)
                        self.addChild(self.bullet3)
                    }
                }
                self.run(SKAction.sequence([wait1,action1]))
            }
            run(SKAction.sequence([wait,action]))
            
            self.spark1?.particleAlpha = 0
            
            /*
             
             let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in //5 sec delay
             
             let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
             if !self.isGameOver {
             self.spark1?.particleAlpha = 0
             self.player.position = self.pilot.position
             self.isPlayerAlive = true
             self.addChild(self.player)
             self.pilot.removeFromParent()
             
             self.playerShields += 1
             self.numAmmo = 3
             self.addChild(self.bullet1)
             self.addChild(self.bullet2)
             self.addChild(self.bullet3)
             }
             }
             }
             */
            
            playerShields -= 1
            
            if playerShields == 0 {
                isPlayerAlive = false
                self.player.removeFromParent()
            }
            
            //firstNode.removeFromParent()
            
        } else if secondNode.name == "pilot" {
            self.run(SKAction.playSoundFileNamed("pilotSquish3", waitForCompletion: false))
            if let explosion = SKEmitterNode(fileNamed: "PilotBlood") {
                explosion.numParticlesToEmit = 8
                explosion.position = pilot.position
                addChild(explosion)
                //shot.removeFromParent()
            }
            if !isGameOver {
                gameOverScreen()
                secondNode.removeFromParent()
            }
        }
        else if secondNode.name == "turretSprite" {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                addChild(explosion)
            }
            self.run(SKAction.playSoundFileNamed("explosionnew", waitForCompletion: false))
            shot.removeFromParent()
            firstNode.removeFromParent()
            
            //print("hi")
            //gameOverScreen()
        }
        
        else if firstNode.name == "border" && secondNode.name == "playerWeapon" {
            
            
            if let BulletExplosion = SKEmitterNode(fileNamed: "BulletExplosion") {
                BulletExplosion.position = secondNode.position
                
                
                var angle = CGFloat(3.14159)
                
                if secondNode.position.x > frame.maxX - 100 {
                    angle = CGFloat(3.14159)
                }
                else if secondNode.position.x < frame.minX + 100 {
                    angle = CGFloat(0)
                }
                else if secondNode.position.y > frame.maxY - 200 {
                    angle = CGFloat(-3.14 / 2)
                }
                else if secondNode.position.y < frame.minY + 200 {
                    angle = CGFloat(3.14 / 2)
                }
                
                
                BulletExplosion.emissionAngle = angle
                secondNode.removeFromParent()
                addChild(BulletExplosion)
                print("bllet hit da wall")
            }
            
        }
            
        

        else if let enemy = firstNode as? EnemyNode {
            enemy.shields -= 1
            
            if enemy.shields == 0 {
                /*             if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                 explosion.position = enemy.position
                 addChild(explosion)
                 print("a")
                 }
                 enemy.removeFromParent()
                 print("1")
                 */
            }
            /*        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
             explosion.position = enemy.position
             addChild(explosion)
             print("b")
             }
             secondNode.removeFromParent()
             print("2")*/
        }
        /*
        else {
            self.run(SKAction.playSoundFileNamed("explosionnew", waitForCompletion: false))
            firstNode.removeFromParent()
            if secondNode.name == "playerWeapon" {
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = secondNode.position
                    addChild(explosion)
                }
                secondNode.removeFromParent()
            }
        }
        
        */
    }
    
    func gameOverScreen() {
        isPlayerAlive = false
        isGameOver = true
        
        self.pauseButtonNode.alpha = 0
        self.backButtonNode.alpha = 1
        self.turnButtonNode.alpha = 0
        self.shootButtonNode.alpha = 0
        self.playAgainButtonNode.alpha = 1
        self.dimPanel.alpha = 0.3
        
        self.bullet1.alpha = 0
        self.bullet2.alpha = 0
        self.bullet3.alpha = 0
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.run(scaleAction)
        
        gameOver.position.x = cameraNode.position.x
        gameOver.position.y = cameraNode.position.y + 50
        gameOver.zPosition = 100
        gameOver.size = CGSize(width: 619, height: 118)
        addChild(gameOver)
    }
    
    func victoryScreen() {
   //     isPlayerAlive = false
        isGameOver = true
        Global.sceneShake(shakeCount: 2, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1, sceneview: self.scene!)
        
        self.pauseButtonNode.alpha = 0
        self.turnButtonNode.alpha = 0
        self.shootButtonNode.alpha = 0
        self.backButtonNode.alpha = 1
        self.playAgainButtonNode.alpha = 1
        self.dimPanel.alpha = 0.3
        
        
        self.bullet1.alpha = 0
        self.bullet2.alpha = 0
        self.bullet3.alpha = 0
        
        let victory = SKSpriteNode(imageNamed: "victory")
        victory.run(scaleAction)
        victory.position.x = cameraNode.position.x
        victory.position.y = cameraNode.position.y + 50
        victory.zPosition = 100
        addChild(victory)
    }
    
    
}
