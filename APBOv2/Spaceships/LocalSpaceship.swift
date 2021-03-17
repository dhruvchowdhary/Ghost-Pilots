import Foundation
import SpriteKit
import AudioToolbox

public class LocalSpaceship: SpaceshipBase {
    
    public var isRotating = false;
    
    public var isRecoiling = false
    public var recoilTimer: Double = 0
    
    var phaseButtonNode: MSButtonNode!
    var ejectButtonNode: MSButtonNode!
    var reviveButtonNode: MSButtonNode!
    var turnButtonNode: MSButtonNode!
    var shootButtonNode: MSButtonNode!
    var pauseButtonNode: MSButtonNode!
    
    var rotation = CGFloat(0)
    var isPlayerAlive = true
    private var pilot = SKSpriteNode()
    var isPhase = false
    var isGameOver = false
    var indicateEnd = false
    
    var playerShields = 1
    var powerupMode = 0
    var doubleTap = 0
    let scaleAction = SKAction.scale(to: 2.2, duration: 0.4)
    
 //   let pilotThrust1 = SKEmitterNode(fileNamed: "PilotThrust")
   
    var framesTilPos = 3;
    
    var currentShotCountBuddy = 0;
    
    let gameOver = SKSpriteNode(imageNamed: "infectiongameover")
    
    init(imageTexture: String) {
        super.init(playerId: Global.playerData.playerID)
        spaceShipNode.removeFromParent()
        spaceShipNode = SKSpriteNode(imageNamed: imageTexture);
        spaceShipParent.addChild(spaceShipNode)
        spaceShipNode.addChild(thruster1!)
        
        
       // print("redWonnnn")
       
        
     //   spaceShipNode.addChild(pilotThrust1!)
        
        /*
        thruster1!.name = "thruster1"
        thruster1!.position = CGPoint(x: -30, y: 0)
        
        thruster1!.zPosition = -5
        spaceShipNode.addChild(thruster1!)
        
        
        pilotThrust1!.name = "pilotThrust1"
        pilotThrust1!.position = CGPoint(x: -20, y: 0)
        
        pilotThrust1!.zPosition = -5
        spaceShipNode.addChild(pilotThrust1!)
        
        pilotThrust1!.alpha = 0
        */
       // spaceShipNode.physicsBody = SKPhysicsBody.init(texture: spaceShipNode.texture!, size: spaceShipNode.size)
        spaceShipNode.name = "shipnode"
        
        spaceShipNode.zPosition = 5
       
        spaceShipParent.physicsBody = SKPhysicsBody.init(circleOfRadius: 24)
        spaceShipParent.physicsBody?.allowsRotation = false
        spaceShipParent.name = "parent"
        spaceShipParent.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        spaceShipParent.physicsBody?.contactTestBitMask = CollisionType.border.rawValue | CollisionType.bullet.rawValue | CollisionType.player.rawValue
        spaceShipParent.physicsBody?.collisionBitMask = CollisionType.border.rawValue | CollisionType.bullet.rawValue | CollisionType.player.rawValue
        
        spaceShipParent.physicsBody?.isDynamic = true
        isLocal = true
        
        // Pulls all components from hud and adds them as children to the spaceship node
        // Scalling the components is wack and prolly needs to be reworked
        let hud = SKScene(fileNamed: "Hud.sks")
        for x in hud!.children {
            x.removeFromParent()
            spaceShipHud.addChild(x)
        }
        
        for i in 0..<unfiredBullets.count {
            unfiredBullets[i].position.x = CGFloat(50 * cos(Double.pi * Double(i) * 0.6666666))
            unfiredBullets[i].position.y = CGFloat(50 * sin(Double.pi * Double(i) * 0.6666666))
            unfiredBulletRotator.addChild(unfiredBullets[i])
        }
        spaceShipParent.addChild(unfiredBulletRotator)
        
        
        Global.gameData.camera.removeFromParent()
        Global.gameData.camera.name = "camera"
        spaceShipHud.addChild(Global.gameData.camera)
        
        reviveButtonNode = spaceShipHud.childNode(withName: "reviveButton") as? MSButtonNode
        reviveButtonNode.alpha = 0
        reviveButtonNode.selectedHandler = {
            GameViewController().playAd()
        }
        
        phaseButtonNode = spaceShipHud.childNode(withName: "phaseButton") as? MSButtonNode
        phaseButtonNode.alpha = 0
        phaseButtonNode.selectedHandler = {
            if self.isPlayerAlive == false {
                print("is phase")
                self.pilot.alpha = 0.7
                self.phaseButtonNode.alpha = 0.6
                self.isPhase = true
            }
        }
        phaseButtonNode.selectedHandlers = {
            if self.isPlayerAlive == false && !self.isGameOver {
                print("not phase")
                self.pilot.alpha = 1
                self.phaseButtonNode.alpha = 0.8
                self.isPhase = false
            }
        }
        ejectButtonNode = spaceShipHud.childNode(withName: "ejectButton") as? MSButtonNode
        ejectButtonNode.alpha = 0
        ejectButtonNode.selectedHandler = {
            if self.isPlayerAlive == true {
                self.ejectButtonNode.alpha = 0
                self.phaseButtonNode.alpha = 0.8
                self.playerShields = -5
            }
        }
        
        turnButtonNode = spaceShipHud.childNode(withName: "turnButton") as? MSButtonNode
        turnButtonNode.selectedHandler = {
            self.isRotating = true
            self.turnButtonNode.xScale = self.turnButtonNode.xScale * 1.1
            self.turnButtonNode.yScale = self.turnButtonNode.yScale * 1.1
            if self.doubleTap == 1 {
                self.spaceShipNode.zRotation = self.spaceShipNode.zRotation - 3.141592/2 + self.rotation + 0.24
                let movement = SKAction.moveBy(x: 60 * cos(self.spaceShipNode.zRotation), y: 60 * sin(self.spaceShipNode.zRotation), duration: 0.15)
                self.spaceShipParent.run(movement)
                self.thruster1?.particleColorSequence = nil
                self.thruster1?.particleColorBlendFactor = 1.0
                self.thruster1?.particleColor = UIColor(red: 240.0/255, green: 50.0/255, blue: 53.0/255, alpha:1)
                
                self.spaceShipNode.run(SKAction.playSoundFileNamed("swishnew", waitForCompletion: false))
                
                self.doubleTap = 0
                self.rotation = 0
            } else {
                self.doubleTap = 1
                let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in
                    self.doubleTap = 0
                }
            }
        }
        turnButtonNode.selectedHandlers = {
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { (timer) in
                self.thruster1?.particleColor = UIColor(red: 67/255, green: 181/255, blue: 169/255, alpha:1)
            }
            self.isRotating = false
            self.turnButtonNode.xScale = self.turnButtonNode.xScale / 1.1
            self.turnButtonNode.yScale = self.turnButtonNode.yScale / 1.1
        }
        
        pauseButtonNode = spaceShipHud.childNode(withName: "pause") as? MSButtonNode
        pauseButtonNode.alpha = 0
        
        shootButtonNode = spaceShipHud.childNode(withName: "shootButton") as? MSButtonNode
        shootButtonNode.selectedHandler = {
            self.shootButtonNode.alpha = 0.6
            self.shootButtonNode.xScale = self.shootButtonNode.xScale * 1.1
            self.shootButtonNode.yScale = self.shootButtonNode.yScale * 1.1
            
            if self.isPlayerAlive && self.unfiredBullets.count > 0 {
                Global.gameData.playerShip?.Shoot(shotType: 0)
                self.shotsRef.child("shot " + String(self.currentShotCountBuddy)).setValue("e")
                self.currentShotCountBuddy += 1;
                
          //   self.spaceShipNode.run(SKAction.playSoundFileNamed("Laser1new", waitForCompletion: false))
            }
        }
        shootButtonNode.selectedHandlers = {
            self.shootButtonNode.xScale = self.shootButtonNode.xScale/1.1
            self.shootButtonNode.yScale = self.shootButtonNode.yScale/1.1
            if !self.isGameOver {
                self.shootButtonNode.alpha = 0.8
                self.pilotThrust1?.particleAlpha = 0
            } else {
                self.shootButtonNode.alpha = 0
            }
        }
        
        let backButtonNode = spaceShipHud.childNode(withName: "backButton") as? MSButtonNode
        backButtonNode!.selectedHandlers = {
            Global.gameData.ResetGameData(toLobby: false)
            Global.loadScene(s: "OnlineMenu")
        }
     //   backButtonNode!.alpha = 1
        
        let restartButtonNode = spaceShipHud.childNode(withName: "restartButton") as? MSButtonNode
        restartButtonNode!.alpha = 0
        
        let playAgainButtonNode = spaceShipHud.childNode(withName: "playAgainButton") as? MSButtonNode
        playAgainButtonNode!.alpha = 0
        
        if UIScreen.main.bounds.width < 779 {
            if UIScreen.main.bounds.width > 567 {
                turnButtonNode.size = CGSize(width: 200, height: 184.038)
                turnButtonNode.position.x = spaceShipHud.position.x + 620
                turnButtonNode.position.y = spaceShipHud.position.y - 300
                
                shootButtonNode.size = CGSize(width: 200, height: 184.038)
                shootButtonNode.position.x = spaceShipHud.position.x - 620
                shootButtonNode.position.y =  spaceShipHud.position.y - 300
                
                backButtonNode!.size = CGSize(width: 131.25, height: 93.75)
                backButtonNode!.position.x = spaceShipHud.position.x - 620
                backButtonNode!.position.y =  spaceShipHud.position.y + 330
            } else {
                turnButtonNode.size = CGSize(width: 200, height: 184.038)
                turnButtonNode.position.x = spaceShipHud.position.x + 620
                turnButtonNode.position.y = spaceShipHud.position.y - 300
                
                shootButtonNode.size = CGSize(width: 200, height: 184.038)
                shootButtonNode.position.x = spaceShipHud.position.x - 620
                shootButtonNode.position.y =  spaceShipHud.position.y - 300
                
                backButtonNode!.size = CGSize(width: 131.25, height: 93.75)
                backButtonNode!.position.x = spaceShipHud.position.x - 620
                backButtonNode!.position.y =  spaceShipHud.position.y + 330
            }
        }
    }
    
    func setGameOver(winner: String) {
        
        let GameOverFX = SKEmitterNode(fileNamed: "GameOverFX")
        
        if indicateEnd == false {
            print("GAME OVER!!!!!")
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            switch Global.gameData.mode {
            case "ffa":
               print("ffa ended")
            case "astroball":
                print("astroball ended")
                if winner == "redWon" {
                    let redWon = SKAction.setTexture(SKTexture(imageNamed: "astroballredwin"))
 
                    gameOver.run(redWon)
                    
                    gameOver.zPosition = 1000
                    
                    gameOver.size = CGSize(width: 1469 / 1.5, height: 311 / 1.5)
                    spaceShipHud.addChild(gameOver)
                    //gameOver.run(scaleAction)
                    gameOver.alpha = 1
                    
                    print("redWonnnn")
                    GameOverFX!.zPosition = 99
                    GameOverFX!.alpha = 1
                    GameOverFX?.particleColorSequence = nil
                    GameOverFX?.particleColorBlendFactor = 1.0
                    GameOverFX?.particleColor = UIColor(red: 255/255, green: 85/255, blue: 85/255, alpha:1)
                    self.spaceShipHud.addChild(GameOverFX!)
                    
                  
                    
                    
                    print("uh ohred")
                    indicateEnd = true
                    let wait1 = SKAction.wait(forDuration: 5)
                    spaceShipNode.run(wait1, completion:  {
                        if Global.gameData.isHost {
                            self.gameOver.removeFromParent()
                            GameOverFX?.removeFromParent()
                            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/redHP", Value: "9")
                            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/blueHP", Value: "9")
                            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Status", Value: "Lobby")
                        }
                        
                    })
                }
                else if winner == "blueWon" {
                    let bluewon = SKAction.setTexture(SKTexture(imageNamed: "astroballbluewin"))
                    gameOver.run(bluewon)
                    
                    gameOver.zPosition = 1000
                    
                    gameOver.size = CGSize(width: 1469 / 1.5, height: 311 / 1.5)
                    spaceShipHud.addChild(gameOver)
                    //gameOver.run(scaleAction)
                    gameOver.alpha = 1
                    
                    print("bluewonnnn")
                    GameOverFX!.zPosition = 99
                    GameOverFX!.alpha = 1
                    GameOverFX?.particleColorSequence = nil
                    GameOverFX?.particleColorBlendFactor = 1.0
                    GameOverFX?.particleColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
                    self.spaceShipHud.addChild(GameOverFX!)
                    print("uh ohblue")
                    indicateEnd = true
                    let wait1 = SKAction.wait(forDuration: 5)
                    spaceShipNode.run(wait1, completion:  {
                        if Global.gameData.isHost {
                            self.gameOver.removeFromParent()
                            GameOverFX?.removeFromParent()
                            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/redHP", Value: "9")
                            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/blueHP", Value: "9")
                            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Status", Value: "Lobby")
                        }
                        
                    })
                    
                }
                
            case "infection":
                
                  gameOver.zPosition = 1000
                  gameOver.size = CGSize(width: 1469 / 1.5, height: 311 / 1.5)
                  spaceShipParent.addChild(gameOver)
                  //gameOver.run(scaleAction)
                  gameOver.alpha = 1
                  
               
                GameOverFX!.zPosition = 99
                GameOverFX!.alpha = 1
                GameOverFX?.particleColorSequence = nil
                GameOverFX?.particleColorBlendFactor = 1.0
                GameOverFX?.particleColor = UIColor(red: 128/255, green: 198/255, blue: 128/255, alpha:1)
                spaceShipParent.addChild(GameOverFX!)
                
                
                  indicateEnd = true
                  let wait1 = SKAction.wait(forDuration: 5)
                  spaceShipNode.run(wait1, completion:  {
                      if Global.gameData.isHost {
                        self.gameOver.removeFromParent()
                        GameOverFX?.removeFromParent()
                          DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Status", Value: "Lobby")
                        
                      }
                      
                  })
                
            default:
                print("default ended")
               
            }
            
            
           
           
          
        }
    }
    

    override func UniqueUpdateShip(deltaTime: Double) {
        

    
            // Handle rotation and movement
            if (isRotating){
                spaceShipNode.zRotation -= CGFloat(Double.pi * 1.3 * deltaTime)
            }
            
            if isRecoiling {
                recoilTimer -= deltaTime
                if recoilTimer < 0
                {
                    isRecoiling = false
                }
                else {
                    let velocity = (CGVector(dx: cos(spaceShipNode.zRotation) * 220, dy: sin(spaceShipNode.zRotation) * 220 * Global.gameData.speedMultiplier))
                    spaceShipParent.physicsBody?.velocity = velocity
                }
            } else {
                let velocity = (CGVector(dx: cos(spaceShipNode.zRotation) * 220, dy: sin(spaceShipNode.zRotation) * 220 * Global.gameData.speedMultiplier))
                spaceShipParent.physicsBody?.velocity = velocity
            }
        
        
        if framesTilPos < 0 {
            let payload = Payload(posX: spaceShipParent.position.x, posY: spaceShipParent.position.y, angleRad: spaceShipNode.zRotation, velocity: nil)
            let data = try! JSONEncoder().encode(payload)
            let json = String(data: data, encoding: .utf8)!
            posRef.setValue(json)
            framesTilPos = 3
        } else {
            let payload = Payload(posX: nil, posY: nil, angleRad: spaceShipNode.zRotation, velocity: nil)
            let data = try! JSONEncoder().encode(payload)
            let json = String(data: data, encoding: .utf8)!
            posRef.setValue(json)
            framesTilPos -= 1
        }
    }
    
    public func Ghost(){
        // Idk if this will even be used
    }
}
