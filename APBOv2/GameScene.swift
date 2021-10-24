//
//  GameScene.swift
//  APBOv2
//
//  Created by 90306670 on 10/20/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//
import SpriteKit
import CoreMotion
import AudioToolbox

let degreesToRadians = CGFloat.pi / 180
let radiansToDegrees = 180 / CGFloat.pi
let maxHealth = 100
let healthBarWidth: CGFloat = 40
let healthBarHeight: CGFloat = 4
let cannonCollisionRadius: CGFloat = 70
let playerCollisionRadius: CGFloat = 10
let shotCollisionRadius: CGFloat = 20



enum CollisionType: UInt32 {
    case player = 1
    
    case pilot = 16
    // case playerWeapon = 2
    case enemy = 4
    case bullet = 8
    case border = 2
    case powerup = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var path = UIBezierPath()
    private var pilot = SKSpriteNode()
    private var pilotWalkingFrames: [SKTexture] = []
    let fadeOut = SKAction.fadeOut(withDuration: 1)
    let fadeIn = SKAction.fadeIn(withDuration: 0.5)
    let cameraNode =  SKCameraNode()

    let EnemyThruster = SKEmitterNode(fileNamed: "EnemyThruster")
    var i = 3
    var backButtonNode: MSButtonNode!
    var pauseButtonNode: MSButtonNode!
    var turnButtonNode: MSButtonNode!
    
    var shootButtonNode: MSButtonNode!
    //var tripleButtonNode: MSButtonNode!
    
    var powerSpawn = false
    var restartButtonNode: MSButtonNode!
    var playAgainButtonNode: MSButtonNode!
    var phaseButtonNode: MSButtonNode!
    var ejectButtonNode: MSButtonNode!
   // var reviveButtonNode: MSButtonNode!
    
    var poweruprandInt = 0
    var currentShip = "player1"
    let playerHealthBar = SKSpriteNode()
    let cannonHealthBar = SKSpriteNode()
    let scoreboardbackground = SKSpriteNode(imageNamed: "scoreboard")
    let skin = SKSpriteNode(imageNamed: Global.gameData.selectedSkin.rawValue)
    var playerHP = maxHealth
    var cannonHP = maxHealth
    var isPlayerAlive = true
    var isGameOver = false
    var isPhase = false
    var varisPaused = 1 //1 is false
    var playerShields = 1
    var waveNumber = 0
    var waveCounter = 0
    var levelNumber = 0
    var powerupMode = 0
    //    let turretSprite = SKSpriteNode(imageNamed: "turretshooter")
    //    let cannonSprite = SKSpriteNode(imageNamed: "turretbase")
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    let positions = Array(stride(from: -360, through: 360, by: 90))
    var player = SKSpriteNode(imageNamed: "player")
   // let pilot = SKSpriteNode(imageNamed: "pilot")
    let shot = SKSpriteNode(imageNamed: "bullet")
    //
    let powerup = SKSpriteNode(imageNamed: "tripleshot")

    //let powerup = SKSpriteNode(imageNamed: "tripleshot")
    var pilotForward = false
    var pilotDirection = CGFloat(0.000)
    var lastUpdateTime: CFTimeInterval = 0
    var count = 0
    var doubleTap = 0;
    let thruster1 = SKEmitterNode(fileNamed: "Thrusters")
    let pilotThrust1 = SKEmitterNode(fileNamed: "PilotThrust")
    let spark1 = SKEmitterNode(fileNamed: "Spark")
    let rotate = SKAction.rotate(byAngle: -1, duration: 0.5)
    var direction = 0.0
    let dimPanel = SKSpriteNode(color: UIColor.black, size: CGSize(width: 20000, height: 10000) )
    
    
   
    let points = SKLabelNode(text: "\(Global.gameData.score)")
    let pointsLabel = SKLabelNode(text: "Points")
    var enemyPoints = SKLabelNode(text: "+1")
    let highScoreLabel = SKLabelNode(text: "High Score")
    let highScorePoints = SKLabelNode(text: "0")
    var numPoints = Global.gameData.score
    var highScore = 0
    var speedAdd = 0
    
    var rotation = CGFloat(0)
    var numAmmo = 3
    var regenAmmo = false
    
  //  let scaleAction = SKAction.scale(to: 0.2, duration: 0.4)
    
    let bullet1 = SKSpriteNode(imageNamed: "bullet")
    let bullet2 = SKSpriteNode(imageNamed: "bullet")
    let bullet3 = SKSpriteNode(imageNamed: "bullet")
    let shape = SKShapeNode()
    
    
    let endlessLeaderboard = SKLabelNode(text: "Leaderboard")
    let leaderboardButtonNode = MSButtonNode(imageNamed: "specialButton")
   // let polyniteEarned = (numPoints / 100)
    
    let reviveButtonNode = MSButtonNode(imageNamed: "reviveButton-1")
    let reviveTimer = SKSpriteNode(imageNamed: "reviveTimer")
    let reviveTimerNumber = SKLabelNode(text: "5")
    
    
  //  public let gameScene = GameScene()
    
    var reviveTime = 5
    var deathPosition = CGPoint()
    
    var pauseTime = 3
    let pauseTimer = SKSpriteNode(imageNamed: "reviveTimer")
    let pauseTimerNumber = SKLabelNode(text: "3")
    
    override func didMove(to view: SKView) {
        
        Global.gameData.gameState = GameStates.Endless
        
        createPath()
        addChild(cameraNode)
              camera = cameraNode
              cameraNode.position.x = 0
              cameraNode.position.y = 0
        
        let zoomInActionipad = SKAction.scale(to: 1.7, duration: 0.01)
        
         let zoomInActioniphone = SKAction.scale(to: 1.06, duration: 0.01)
        if UIDevice.current.userInterfaceIdiom == .pad {
                        cameraNode.run(zoomInActionipad)
               
        }
      /*
        else {
             cameraNode.run(zoomInActioniphone)
            
            
        }
        */
        

        
        

        shape.path = UIBezierPath(roundedRect: CGRect(x: -1792/2-1000, y: -828/2, width: 1792+2000, height: 828), cornerRadius: 40).cgPath
        shape.position = CGPoint(x: frame.midX, y: frame.midY)
        shape.fillColor = .clear
        shape.strokeColor = UIColor.white
        shape.lineWidth = 10
        shape.name = "border"
        shape.physicsBody = SKPhysicsBody(edgeChainFrom: shape.path!)
       
        shape.physicsBody?.categoryBitMask = CollisionType.border.rawValue
        shape.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue | CollisionType.player.rawValue | CollisionType.pilot.rawValue
        shape.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue | CollisionType.player.rawValue | CollisionType.pilot.rawValue
        addChild(shape)
        
    

        /*
        let borderBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: 80, height: 80))
        borderBody.friction = 0
        self.physicsBody = borderBody
 */
        
        let highScoreDefaults = UserDefaults.standard
        if (highScoreDefaults.value(forKey: "highScore1") != nil) {
            highScore = highScoreDefaults.value(forKey: "highScore1") as! NSInteger
            highScorePoints.text = "\(highScore)"
        }
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        //size = view.bounds.size
        backgroundColor = SKColor(red: 14.0/255, green: 23.0/255, blue: 57.0/255, alpha: 1)
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = 1
            addChild(particles)
        }
        
        thruster1?.position = CGPoint(x: -30, y: 0)
        thruster1?.targetNode = self.scene
        player.addChild(thruster1!)
        
        bullet1.zPosition = 5
        bullet2.zPosition = 5
        bullet3.zPosition = 5
        addChild(bullet1)
        addChild(bullet2)
        addChild(bullet3)
        
        self.dimPanel.zPosition = 50
        self.dimPanel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(self.dimPanel)
        self.dimPanel.alpha = 0
        
        
        
        
        addChild(scoreboardbackground)
        scoreboardbackground.size = CGSize(width: 300, height: 90)
        scoreboardbackground.alpha = 0.8
        scoreboardbackground.position = CGPoint(x: frame.midX, y: frame.maxY-82)
        scoreboardbackground.zPosition = 9
        points.position = CGPoint(x: frame.midX, y: frame.maxY-105)
        points.zPosition = 10
        points.fontColor = UIColor.blue
        points.fontSize = 65
        points.fontName = "AvenirNext-Bold"
        addChild(points)
        
        
        
        /*
        pointsLabel.position = CGPoint(x: frame.midX+130, y: frame.maxY-70)
        pointsLabel.zPosition = 10
        pointsLabel.fontColor = UIColor.blue
        pointsLabel.fontSize = 45
        pointsLabel.fontName = "AvenirNext-Bold"
        addChild(pointsLabel)
 */
        /*
        highScorePoints.position = CGPoint(x: frame.midX-130, y: frame.maxY-135)
        highScorePoints.zPosition = 10
        highScorePoints.fontColor = UIColor.white
        highScorePoints.fontSize = 65
        highScorePoints.fontName = "AvenirNext-Bold"
        addChild(highScorePoints)
        highScoreLabel.position = CGPoint(x: frame.midX-130, y: frame.maxY-70)
        highScoreLabel.zPosition = 10
        highScoreLabel.fontColor = UIColor.white
        highScoreLabel.fontSize = 45
        highScoreLabel.fontName = "AvenirNext-Bold"
        addChild(highScoreLabel)
        */
        enemyPoints.zPosition = 2
        enemyPoints.fontColor = UIColor.white
        enemyPoints.fontSize = 45
        enemyPoints.fontName = "AvenirNext-Bold"
        enemyPoints.alpha = 0
        addChild(enemyPoints)
        
        player.name = "player"
        player.position.x = frame.midX-700
        player.position.y = frame.midY-80
        player.zPosition = 5
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
        player.physicsBody?.isDynamic = false
        if (Global.gameData.selectedSkin.rawValue != "DEFAULTDECAL") {
            skin.zPosition = 10
            player.addChild(skin)
        }
        if (Global.gameData.selectedTrail.rawValue != "trailDefault") {
            let trail = SKEmitterNode(fileNamed: Global.gameData.selectedTrail.rawValue)
            trail?.targetNode = self.scene
            player.addChild(trail!)
            thruster1?.removeFromParent()
        }

        
        reviveButtonNode.position = CGPoint(x: frame.midX, y: frame.midY)
        reviveTimer.position = CGPoint(x:  reviveButtonNode.position.x + 120, y:  reviveButtonNode.position.y - 120)
        reviveTimerNumber.position = CGPoint(x:  reviveTimer.position.x, y:  reviveTimer.position.y - 30)
        scene?.addChild(reviveTimer)
        scene?.addChild(reviveButtonNode)
        scene?.addChild(reviveTimerNumber)
        reviveButtonNode.xScale = 0.2
        reviveButtonNode.yScale = 0.2
        
        reviveTimer.xScale = 0.17
        reviveTimer.yScale = 0.17
        reviveTimer.alpha = 0
        reviveTimer.zPosition = 400
        
        reviveTimerNumber.zPosition = 401
        reviveTimerNumber.fontColor = UIColor.black
        reviveTimerNumber.fontSize = 80
        reviveTimerNumber.fontName = "AvenirNext-Bold"
        reviveTimerNumber.alpha = 0
        
        reviveButtonNode.alpha = 0
        reviveButtonNode.zPosition = 300
        reviveButtonNode.selectedHandler = { [self] in
            playerShields = 1
            self.reviveTime = 50
            Global.gameData.score = self.numPoints
            Global.gameData.revived = true
            
       //     Global.gameData.isReviveReady2 = true
       //     Global.gameData.isReviveReady = true
            
            
       //     self.scene?.view?.isPaused = true
            
            Global.adHandler.presentRewardedForRevive()
            
//print("HELLO")
 
        }
        
        phaseButtonNode = self.childNode(withName: "phaseButton") as? MSButtonNode
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
                self.phaseButtonNode.alpha = 0.4
                self.isPhase = false
            }
        }
        
        ejectButtonNode = self.childNode(withName: "ejectButton") as? MSButtonNode
        ejectButtonNode.alpha = 0.4
        ejectButtonNode.selectedHandler = {
            if self.isPlayerAlive == true {
                self.ejectButtonNode.alpha = 0
                self.phaseButtonNode.alpha = 0.4
                self.playerShields = -5
            }
        }
        /*
             ejectButtonNode.selectedHandlers = {
                 if self.isPlayerAlive == false {
                              self.pilot.alpha = 1
                              self.phaseButtonNode.alpha = 1
                              self.isPhase = false
                          }
                 }
 */
        
        backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
        backButtonNode.alpha = 0
        backButtonNode.selectedHandlers = {
            Global.gameData.score = 0
            Global.gameData.revived = false
            print(self.numPoints)
            Global.gameData.addPolyniteCount(delta: self.numPoints / 100)
            Global.loadScene(s: "MainMenu")
            
            
            
        }
        
        restartButtonNode = self.childNode(withName: "restartButton") as? MSButtonNode
        restartButtonNode.alpha = 0
        restartButtonNode.selectedHandlers = {
            Global.gameData.score = 0
            Global.gameData.revived = false
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView? else {
                print("Could not get Skview")
                return
            }
            
            /* 2) Load Menu scene */
            guard let scene = GameScene(fileNamed:"GameScene") else {
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
            Global.gameData.score = 0
            Global.gameData.revived = false
            /* 1) Grab reference to our SpriteKit view */
            guard let skView = self.view as SKView? else {
                print("Could not get Skview")
                return
            }
            
            /* 2) Load Menu scene */
            guard let scene = GameScene(fileNamed:"GameScene") else {
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
        
        pauseButtonNode = self.childNode(withName: "pause") as? MSButtonNode
        pauseButtonNode.selectedHandler = {
            self.pauseButtonNode.alpha = 0.6
            print("HIII THERE")
        }
        pauseButtonNode.selectedHandlers = { [self] in
            if !self.isGameOver {
                if self.varisPaused == 0 {
                    self.varisPaused = 1
                    self.scene?.view?.isPaused = false
                    self.pauseButtonNode.alpha = 1
                    self.backButtonNode.alpha = 0
                    self.restartButtonNode.alpha = 0
                    self.dimPanel.alpha = 0

                }
                else {
                    self.backButtonNode.alpha = 1
                    self.restartButtonNode.alpha = 1
                    self.dimPanel.alpha = 0.3
                    self.varisPaused = 0
                    let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
                        if self.backButtonNode.alpha == 1
                        {
                            self.scene?.view?.isPaused = true
                        }
                    }
                }
            }
        }
        
        
        turnButtonNode = self.childNode(withName: "turnButton") as? MSButtonNode
        turnButtonNode.selectedHandler = {
            
            self.turnButtonNode.alpha = 0.6
            self.turnButtonNode.setScale(1.1)
            
            if self.varisPaused==1 && self.isPlayerAlive {
                self.turnButtonNode.setScale(1.1)
                self.turnButtonNode.alpha = 0.6
                self.count = 1
                if (self.doubleTap==1) {
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
                let timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { (timer) in
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
        shootButtonNode.selectedHandler = { [self] in
            self.shootButtonNode.alpha = 0.6
            self.shootButtonNode.setScale(1.1)
            
            if self.varisPaused==1 && self.isPlayerAlive {
                if self.isPlayerAlive {
             //       self.numPoints += 100
                //    self.points.text = "\(self.numPoints)"
                    if self.numAmmo > 0 {
                        if self.powerupMode == 0 {
                            if let ShootingExplosion = SKEmitterNode(fileNamed: "ShootingExplosion") {
                                self.player.addChild(ShootingExplosion)
                                ShootingExplosion.particleColorSequence = nil
                                ShootingExplosion.particleColorBlendFactor = 1.0
                                ShootingExplosion.position.x = 35
                                ShootingExplosion.particleColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha:1)
                            }
                        
                            
                            self.run(SKAction.playSoundFileNamed("Laser1new", waitForCompletion: false))
                            
                            if self.numAmmo == 3 {
                                self.bullet1.alpha = 0
                            }
                            else if self.numAmmo == 2 {
                                self.bullet2.alpha = 0
                            }
                            else if self.numAmmo == 1 {
                                self.bullet3.alpha = 0
                            }
                            
                            let shot = SKSpriteNode(imageNamed: "bullet")
                            shot.name = "playerWeapon"
                            shot.position = CGPoint(x: self.player.position.x + cos(self.player.zRotation)*40, y: self.player.position.y + sin(self.player.zRotation)*40)
                            shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
                            shot.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
                            shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                            shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                            self.addChild(shot)
                            
                            let movement = SKAction.moveBy(x: 15000 * cos(self.player.zRotation), y: 15000 * sin(self.player.zRotation), duration: 26)
                      //      let sequence = SKAction.sequence([movement, .removeFromParent()])
                            shot.run(movement)
                            
                            self.numAmmo = self.numAmmo - 1
                            
                            let recoil = SKAction.moveBy(x: -8 * cos(self.player.zRotation), y: -8 * sin(self.player.zRotation), duration: 0.01)
                            
                            self.player.run(recoil)
                            
                            /*
                             self.player.position = CGPoint(x:self.player.position.x - cos(self.player.zRotation) * 50 ,y:self.player.position.y - sin(self.player.zRotation) * 50)
                             
                             */
                            
                            Global.sceneShake(shakeCount: 1, intensity: CGVector(dx: 1.2*cos(self.player.zRotation), dy: 1.2*sin(self.player.zRotation)), shakeDuration: 0.04, sceneview: self.scene!)
                        }
                        
                        else if self.powerupMode == 1 {
                          
                            if self.i > 0 {
                                
                                if let ShootingExplosion = SKEmitterNode(fileNamed: "ShootingExplosion") {
                                    self.player.addChild(ShootingExplosion)
                                    ShootingExplosion.position.x = 35
                                    ShootingExplosion.particleColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 255.0/255, alpha:1)
                                    
                                          }
                                
                            self.run(SKAction.playSoundFileNamed("Laser1new", waitForCompletion: false))
                            
                            if self.numAmmo == 3 {
                                self.bullet1.alpha = 0
                            }
                            else if self.numAmmo == 2 {
                                self.bullet2.alpha = 0
                            }
                            else if self.numAmmo == 1 {
                                self.bullet3.alpha = 0
                            }
                            
                            print("tripleshot")
                            
                            let shot1 = SKSpriteNode(imageNamed: "tripleshotbullet")
                            shot1.size = CGSize(width: 12.5, height: 12.5)
                            shot1.name = "playerWeapon"
                            shot1.position = CGPoint(x: self.player.position.x + cos(self.player.zRotation)*40, y: self.player.position.y + sin(self.player.zRotation)*40)
                            shot1.physicsBody = SKPhysicsBody(rectangleOf: shot1.size)
                            shot1.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
                            shot1.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                            shot1.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                            self.addChild(shot1)
                            
                            let movement1 = SKAction.moveBy(x: 15000 * cos(self.player.zRotation), y: 15000 * sin(self.player.zRotation), duration: 26)
                      //      let sequence = SKAction.sequence([movement, .removeFromParent()])
                            shot1.run(movement1)
                            
                            let shot2 = SKSpriteNode(imageNamed: "tripleshotbullet")
                            shot2.size = CGSize(width: 12.5, height: 12.5)
                            shot2.name = "playerWeapon"
                            shot2.position = CGPoint(x: self.player.position.x + cos(self.player.zRotation)*40, y: self.player.position.y + sin(self.player.zRotation)*40)
                            shot2.physicsBody = SKPhysicsBody(rectangleOf: shot2.size)
                            shot2.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
                            shot2.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                            shot2.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                            self.addChild(shot2)
                            
                            let movement2 = SKAction.moveBy(x: 15000 * cos(self.player.zRotation + 10 * degreesToRadians), y: 15000 * sin(self.player.zRotation + 10 * degreesToRadians), duration: 26)
                      //      let sequence = SKAction.sequence([movement, .removeFromParent()])
                            shot2.run(movement2)
                            
                            let shot3 = SKSpriteNode(imageNamed: "tripleshotbullet")
                            shot3.size = CGSize(width: 12.5, height: 12.5)
                            shot3.name = "playerWeapon"
                            shot3.position = CGPoint(x: self.player.position.x + cos(self.player.zRotation - 10 * degreesToRadians)*40, y: self.player.position.y + sin(self.player.zRotation - 10 * degreesToRadians)*40)
                            shot3.physicsBody = SKPhysicsBody(rectangleOf: shot3.size)
                            shot3.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
                            shot3.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                            shot3.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                            self.addChild(shot3)
                            
                            let movement3 = SKAction.moveBy(x: 15000 * cos(self.player.zRotation - 10 * degreesToRadians ), y: 15000 * sin(self.player.zRotation - 10 * degreesToRadians), duration: 26)
                      //      let sequence = SKAction.sequence([movement, .removeFromParent()])
                            shot3.run(movement3)
                            
                            self.numAmmo = self.numAmmo - 1
                            
                            let recoil = SKAction.moveBy(x: -8 * cos(self.player.zRotation), y: -8 * sin(self.player.zRotation), duration: 0.01)
                            
                            self.player.run(recoil)
                        
                            
                                Global.sceneShake(shakeCount: 1, intensity: CGVector(dx: 1.2*cos(self.player.zRotation), dy: 1.2*sin(self.player.zRotation)), shakeDuration: 0.04, sceneview: self.scene!)
                            
                                
                                self.i -= 1
                            }
                            
                            if self.i == 0 {
                               
                                let shootbuttonPic = SKAction.setTexture(SKTexture(imageNamed: "shootButton"))
                                self.shootButtonNode.run(shootbuttonPic)
                                
                            self.powerupMode = 0
                                
                                
                            }
                        }
                        else if self.powerupMode == 2 {
                            print("laser")
                            
                            if self.i > 0 {
                                self.run(SKAction.playSoundFileNamed("laserFX", waitForCompletion: false))
                                
                                if self.numAmmo == 3 {
                                    self.bullet1.alpha = 0
                                }
                                else if self.numAmmo == 2 {
                                    self.bullet2.alpha = 0
                                }
                                else if self.numAmmo == 1 {
                                    self.bullet3.alpha = 0
                                }

                            
                                let laserBody = SKSpriteNode(imageNamed: "laserbeampic")
                                laserBody.name = "laser"
                                laserBody.size = CGSize(width: 2000, height: 30)
                              //  laserBody.position.x = 1000
                                laserBody.zRotation = self.player.zRotation
                                laserBody.position.y = self.player.position.y + 1000 * sin(self.player.zRotation)
                                laserBody.position.x = self.player.position.x + 1000 * cos(self.player.zRotation)
                                print(laserBody.position.x)
                                print(laserBody.position.y)
                                print(self.player.position.x)
                                print(self.player.position.y)
                                
                                //laserBody.anchorPoint = CGPoint(x: 0, y: 0.5)
                                laserBody.physicsBody = SKPhysicsBody(texture: laserBody.texture!, size: laserBody.size)
                           
                                laserBody.physicsBody?.categoryBitMask = CollisionType.powerup.rawValue
                                laserBody.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                                laserBody.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
                               
                           
                              //  laserBody.physicsBody.po
                               // laserBody.position = player.position
                             //   let pinPosition = connectingRod.convert
                             
                                
                                let joint = SKPhysicsJointPin.joint(withBodyA: laserBody.physicsBody!, bodyB: self.player.physicsBody!, anchor: self.player.position)
                                self.addChild(laserBody)
                             
                                self.physicsWorld.add(joint)
                 

                                let recoil = SKAction.moveBy(x: -8 * cos(self.player.zRotation), y: -8 * sin(self.player.zRotation), duration: 0.01)
                                
                                self.player.run(recoil)
                                laserBody.zPosition = -10
                                
                                let shrink = SKAction.resize(toHeight: 0, duration: 0.4)
                                laserBody.run(shrink)
                                
                                let wait = SKAction.wait(forDuration:0.4)
                                let action = SKAction.run {
                                    laserBody.removeFromParent()
                                }
                                self.run(SKAction.sequence([wait,action]))
                              
                                self.numAmmo = self.numAmmo - 1
                                self.i -= 1
                              
                                
                            }
                            if self.i == 0 {
                               
                                let shootbuttonPic = SKAction.setTexture(SKTexture(imageNamed: "shootButton"))
                                self.shootButtonNode.run(shootbuttonPic)
                                
                            self.powerupMode = 0
                            }
                            
                        }
                        else if self.powerupMode == 3 {
                            
                            
                            if self.i > 0 {
                            
                            self.run(SKAction.playSoundFileNamed("mineFX", waitForCompletion: false))
                            
                            if self.numAmmo == 3 {
                                self.bullet1.alpha = 0
                            }
                            else if self.numAmmo == 2 {
                                self.bullet2.alpha = 0
                            }
                            else if self.numAmmo == 1 {
                                self.bullet3.alpha = 0
                            }
                            
                            
                            print("mine")
                            let mine = SKSpriteNode(imageNamed: "mineRing")

                            mine.name = "mine"
                            mine.size = CGSize(width: 80, height: 80)
                            mine.physicsBody = SKPhysicsBody(texture: mine.texture!, size: mine.size)
                            
                            mine.physicsBody?.categoryBitMask = CollisionType.powerup.rawValue
                            mine.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue
                        mine.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
                            
                       
                                mine.position = self.player.position
                            mine.zPosition = 2
                                self.addChild(mine)
                                
                                self.numAmmo = self.numAmmo - 1
                                self.i -= 1
                                
                            }
                            
                            if self.i == 0 {
                               
                                let shootbuttonPic = SKAction.setTexture(SKTexture(imageNamed: "shootButton"))
                                self.shootButtonNode.run(shootbuttonPic)
                                
                            self.powerupMode = 0
                            }
                        }
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
        
        
        
    
        
        let _ = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
            self.player.zRotation = self.player.zRotation + 1.2 * CGFloat(self.direction)
            self.pilot.zRotation = self.pilot.zRotation + 1.2 * CGFloat(self.direction)
            if self.doubleTap == 1 {
                self.rotation = self.rotation - 1.2 * CGFloat(self.direction)
            } else {
                self.rotation = 0
            }
        }
    }
    
    
    
    /*  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     if (isGameOver) {
     if let newScene = SKScene(fileNamed: "GameScene") {
     newScene.scaleMode = .aspectFit
     self.dimPanel.alpha = 0
     let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
     view?.presentScene(newScene, transition: reveal)
     }
     }
     guard isGameOver else { return }
     
     let touch = touches.first
     let positionInScene = touch!.location(in: self)
     let touchedNode = self.atPoint(positionInScene)
     
     
     
     }*/
    

    
      func buildPilot() {
        let pilotAnimatedAtlas = SKTextureAtlas(named: "pilotImages")
        var walkFrames: [SKTexture] = []

        let numImages = pilotAnimatedAtlas.textureNames.count
        for i in 1...numImages {
          let pilotTextureName = "ghostpilots\(i)"
          walkFrames.append(pilotAnimatedAtlas.textureNamed(pilotTextureName))
        }
        pilotWalkingFrames = walkFrames
          
          let firstFrameTexture = pilotWalkingFrames[0]
          pilot = SKSpriteNode(texture: firstFrameTexture)
           pilot.zRotation = player.zRotation - 3.141592/2
          pilot.size = CGSize(width: 40, height: 40)
          
          pilot.physicsBody = SKPhysicsBody.init(rectangleOf: pilot.size)
        //  pilot.physicsBody = SKPhysicsBody(texture: firstFrameTexture , size: pilot.size)
           pilot.physicsBody?.categoryBitMask = CollisionType.pilot.rawValue
           pilot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
           pilot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue
           pilot.physicsBody?.isDynamic = false
           pilot.position = player.position
          pilot.name = "pilot"
        pilot.zPosition = 5
          addChild(pilot)
          
      }
      
    
    func createPath() {
           path = UIBezierPath()

            path.move(to: .zero)

            

                path.addLine(to: CGPoint(x: -10000, y: 0))
             
        /*
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: CGFloat(speeds))
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        run(sequence)
        
        */
        
        
       // return path
    }
    
    
      func animatePilot() {
        pilot.run(SKAction.repeatForever(
          SKAction.animate(with: pilotWalkingFrames,
                           timePerFrame: 0.2,
                           resize: false,
                           restore: true)),
          withKey:"walkingInPlacepilot")
      }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let fadeAlpha = SKAction.fadeAlpha(to: 1.0 , duration: 0.1)
        let squishNormal = SKAction.scale(to: 1.0, duration: 0.05)
     
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        /*
        if powerSpawn == true {
            let rotateAction = SKAction.rotate(byAngle: 1, duration: 20)
            powerup.run(rotateAction)
        }
 */
        if playerShields == -5 {
            self.run(SKAction.playSoundFileNamed("explosionnew", waitForCompletion: false))
            Global.sceneShake(shakeCount: 2, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1, sceneview: self.scene!)
                      
            
            playerShields = 1
            isPlayerAlive = false
            pilot.name = "pilot"
            
            let pilotGo = SKAction.setTexture(SKTexture(imageNamed: "pilotGo"))
  shootButtonNode.run(pilotGo)
            
                      pilot.size = CGSize(width: 40, height: 40)
                      pilot.zRotation = player.zRotation - 3.141592/2
                      pilot.position = player.position
                                 buildPilot()
                       animatePilot()
                      //            gameOver()
                      
                      pilotThrust1?.position = CGPoint(x: 0, y: -20)
                      pilotThrust1?.targetNode = self.scene
                      pilotThrust1?.particleAlpha = 0
                      pilot.addChild(pilotThrust1!)
                      
            
            let movement = SKAction.moveBy(x: 60 * cos(3.14159 / 2 + self.pilot.zRotation), y: 60 * sin(3.14159 / 2 + self.pilot.zRotation), duration: 0.5)
                             self.pilot.run(movement)
                      player.removeFromParent()
                  //    secondNode.removeFromParent()
                      
            /* respawn code
            
                      let wait = SKAction.wait(forDuration:7)
                      let action = SKAction.run {
                          self.spark1?.position = CGPoint(x: 0, y: 0)
                          self.spark1?.targetNode = self.scene
                          self.spark1?.particleAlpha = 1
                          self.pilot.addChild(self.spark1!)
                          self.spark1?.particleAlpha = 1
                          self.spark1?.particleLifetime = 1
                          if !self.isGameOver {
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
                      
            */
            
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
                      
        
        }
        
        
        let scale = 1.2
        if UIDevice.current.userInterfaceIdiom == .pad {
            if player.position.y < frame.minY + 35 {
                player.position.y = frame.minY + 35
            } else if player.position.y > frame.maxY - 35 {
                player.position.y = frame.maxY - 35
            }
            if player.position.x < frame.minX - 5  {
                player.position.x = frame.minX - 5
            } else if player.position.x > frame.maxX + 5 {
                player.position.x = frame.maxX + 5
            }
            
            if pilot.position.y < frame.minY + 20 {
                pilot.position.y = frame.minY + 20
            } else if pilot.position.y > frame.maxY - 20 {
                pilot.position.y = frame.maxY - 20
            }
            if pilot.position.x < frame.minX - 20 {
                pilot.position.x = frame.minX - 20
            } else if pilot.position.x > frame.maxX + 20 {
                pilot.position.x = frame.maxX + 20
            }
            
            turnButtonNode.position.x = (cameraNode.position.x + 640) * CGFloat(scale)
            turnButtonNode.position.y = (cameraNode.position.y - 410) * CGFloat(scale)
            turnButtonNode.setScale(CGFloat(1.25 * scale))
            
            shootButtonNode.position.x = (cameraNode.position.x - 640) * CGFloat(scale)
            shootButtonNode.position.y =  (cameraNode.position.y - 410) * CGFloat(scale)
            shootButtonNode.setScale(CGFloat(1.25 * scale))
            
            pauseButtonNode.position.x = (cameraNode.position.x + 640) * CGFloat(scale)
            pauseButtonNode.position.y =  (cameraNode.position.y + 430) * CGFloat(scale)
            pauseButtonNode.setScale(CGFloat(1.25 * scale))
            
            backButtonNode.position.x = (cameraNode.position.x - 640) * CGFloat(scale)
            backButtonNode.position.y = (cameraNode.position.y + 430) *  CGFloat(scale)
            backButtonNode.setScale(CGFloat(1.25 * scale))
            
            restartButtonNode.position.x = (cameraNode.position.x + 480) * CGFloat(scale)
            restartButtonNode.position.y =  (cameraNode.position.y + 430) * CGFloat(scale)
            restartButtonNode.setScale(CGFloat(1.25 * scale))
            
            playAgainButtonNode.position.x = cameraNode.position.x
            playAgainButtonNode.position.y = (cameraNode.position.y - 224 - 121) * CGFloat(scale)
            playAgainButtonNode.setScale(CGFloat(1.25 * scale))
            
//            reviveButtonNode.position.x = cameraNode.position.x + 340
//            reviveButtonNode.position.y = playAgainButtonNode.position.y
//          //  reviveButtonNode.setScale(CGFloat(1.25 * scale))
//
            phaseButtonNode.position.x = turnButtonNode.position.x - 205
            phaseButtonNode.position.y = turnButtonNode.position.y + 140
            phaseButtonNode.setScale(CGFloat(1.25 * scale))
            
            ejectButtonNode.position.x = turnButtonNode.position.x - 205
            ejectButtonNode.position.y = turnButtonNode.position.y + 140
            ejectButtonNode.setScale(CGFloat(1.25 * scale))
        } else {
            if UIScreen.main.bounds.width > 779 {
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
                
                if pilot.position.y < frame.minY + 20 {
                    pilot.position.y = frame.minY + 20
                } else if pilot.position.y > frame.maxY - 20 {
                    pilot.position.y = frame.maxY - 20
                }
                if pilot.position.x < frame.minX + 20  {
                    pilot.position.x = frame.minX + 20
                } else if pilot.position.x > frame.maxX - 20 {
                    pilot.position.x = frame.maxX - 20
                }
                turnButtonNode.size = CGSize(width: 240, height: 220.84507)
                turnButtonNode.position.x = cameraNode.position.x + 720
                turnButtonNode.position.y = cameraNode.position.y - 290
                
                shootButtonNode.size = CGSize(width: 240, height: 220.84507)
                shootButtonNode.position.x = cameraNode.position.x - 720
                shootButtonNode.position.y =  cameraNode.position.y - 290
                
                pauseButtonNode.size = CGSize(width: 90.141, height: 112.676)
                pauseButtonNode.position.x = cameraNode.position.x + 720
                pauseButtonNode.position.y =  cameraNode.position.y + 300
                
                backButtonNode.size = CGSize(width: 157.746, height: 112.676)
                backButtonNode.position.x = cameraNode.position.x - 720
                backButtonNode.position.y =  cameraNode.position.y + 300
                
                restartButtonNode.size = CGSize(width: 104.7893, height: 112.676)
                restartButtonNode.position.x = cameraNode.position.x + 570
                restartButtonNode.position.y =  cameraNode.position.y + 300
                
                playAgainButtonNode.position.x = frame.midX + cameraNode.position.x
                playAgainButtonNode.position.y = frame.midY + cameraNode.position.y - 200 - 121
//
//                reviveButtonNode.position.x = frame.midX + cameraNode.position.x + 340
//                reviveButtonNode.position.y = playAgainButtonNode.position.y
//
                phaseButtonNode.size = CGSize(width: 188.4, height: 180)
                phaseButtonNode.position.x = turnButtonNode.position.x - 168
                phaseButtonNode.position.y = turnButtonNode.position.y + 108
                
                ejectButtonNode.size = CGSize(width: 188.4, height: 180)
                ejectButtonNode.position.x = turnButtonNode.position.x - 168
                ejectButtonNode.position.y = turnButtonNode.position.y + 108
            } else if UIScreen.main.bounds.width > 567 {
                
                if player.position.y < frame.minY + 35 {
                    player.position.y = frame.minY + 35
                } else if player.position.y > frame.maxY - 35 {
                    player.position.y = frame.maxY - 35
                }
                if player.position.x < frame.minX + 135 + 60 {
                    player.position.x = frame.minX + 135 + 60
                } else if player.position.x > frame.maxX - 135 - 60{
                    player.position.x = frame.maxX - 135 - 60
                }
                
                if pilot.position.y < frame.minY + 20 {
                    pilot.position.y = frame.minY + 20
                } else if pilot.position.y > frame.maxY - 20 {
                    pilot.position.y = frame.maxY - 20
                }
                if pilot.position.x < frame.minX + 120 + 60 {
                    pilot.position.x = frame.minX + 120 + 60
                } else if pilot.position.x > frame.maxX - 120 - 60 {
                    pilot.position.x = frame.maxX - 120 - 60
                }
                
                
                turnButtonNode.size = CGSize(width: 200, height: 184.038)
                turnButtonNode.position.x = cameraNode.position.x + 620
                turnButtonNode.position.y = cameraNode.position.y - 300
                
                shootButtonNode.size = CGSize(width: 200, height: 184.038)
                shootButtonNode.position.x = cameraNode.position.x - 620
                shootButtonNode.position.y =  cameraNode.position.y - 300
                
                pauseButtonNode.size = CGSize(width: 75, height: 93.75)
                pauseButtonNode.position.x = cameraNode.position.x + 620
                pauseButtonNode.position.y =  cameraNode.position.y + 330
                
                backButtonNode.size = CGSize(width: 131.25, height: 93.75)
                backButtonNode.position.x = cameraNode.position.x - 620
                backButtonNode.position.y =  cameraNode.position.y + 330
                
                restartButtonNode.size = CGSize(width: 87.188, height: 93.75)
                restartButtonNode.position.x = cameraNode.position.x + 470
                restartButtonNode.position.y =  cameraNode.position.y + 330
                
                playAgainButtonNode.position.x = frame.midX + cameraNode.position.x
                playAgainButtonNode.position.y = frame.midY + cameraNode.position.y - 200 - 121
//
//                reviveButtonNode.position.x = frame.midX + cameraNode.position.x + 340
//                reviveButtonNode.position.y = playAgainButtonNode.position.y
                
                phaseButtonNode.size = CGSize(width: 157, height: 150)
                phaseButtonNode.position.x = turnButtonNode.position.x - 140
                phaseButtonNode.position.y = turnButtonNode.position.y + 90
                
                ejectButtonNode.size = CGSize(width: 157, height: 150)
                ejectButtonNode.position.x = turnButtonNode.position.x - 140
                ejectButtonNode.position.y = turnButtonNode.position.y + 90
                
            } else {
                if player.position.y < frame.minY + 35 {
                    player.position.y = frame.minY + 35
                } else if player.position.y > frame.maxY - 35 {
                    player.position.y = frame.maxY - 35
                }
                if player.position.x < frame.minX + 135 + 60 {
                    player.position.x = frame.minX + 135 + 60
                } else if player.position.x > frame.maxX - 135 - 60{
                    player.position.x = frame.maxX - 135 - 60
                }
                
                if pilot.position.y < frame.minY + 20 {
                    pilot.position.y = frame.minY + 20
                } else if pilot.position.y > frame.maxY - 20 {
                    pilot.position.y = frame.maxY - 20
                }
                if pilot.position.x < frame.minX + 120 + 60 {
                    pilot.position.x = frame.minX + 120 + 60
                } else if pilot.position.x > frame.maxX - 120 - 60 {
                    pilot.position.x = frame.maxX - 120 - 60
                }
                
                turnButtonNode.size = CGSize(width: 200, height: 184.038)
                turnButtonNode.position.x = cameraNode.position.x + 620
                turnButtonNode.position.y = cameraNode.position.y - 300
                
                shootButtonNode.size = CGSize(width: 200, height: 184.038)
                shootButtonNode.position.x = cameraNode.position.x - 620
                shootButtonNode.position.y =  cameraNode.position.y - 300
                
                pauseButtonNode.size = CGSize(width: 75, height: 93.75)
                pauseButtonNode.position.x = cameraNode.position.x + 620
                pauseButtonNode.position.y =  cameraNode.position.y + 330
                
                backButtonNode.size = CGSize(width: 131.25, height: 93.75)
                backButtonNode.position.x = cameraNode.position.x - 620
                backButtonNode.position.y =  cameraNode.position.y + 330
                
                restartButtonNode.size = CGSize(width: 87.188, height: 93.75)
                restartButtonNode.position.x = cameraNode.position.x + 470
                restartButtonNode.position.y =  cameraNode.position.y + 330
                
                playAgainButtonNode.position.x = frame.midX + cameraNode.position.x
                playAgainButtonNode.position.y = frame.midY + cameraNode.position.y - 200 - 121
                
//                reviveButtonNode.position.x = frame.midX + cameraNode.position.x + 340
//                reviveButtonNode.position.y = playAgainButtonNode.position.y
                
                phaseButtonNode.size = CGSize(width: 157, height: 150)
                phaseButtonNode.position.x = turnButtonNode.position.x - 140
                phaseButtonNode.position.y = turnButtonNode.position.y + 90
                
                ejectButtonNode.size = CGSize(width: 157, height: 150)
                ejectButtonNode.position.x = turnButtonNode.position.x - 140
                ejectButtonNode.position.y = turnButtonNode.position.y + 90
            }
        }
        
        
        if isPlayerAlive {
            
            //       player.physicsBody!.applyImpulse(CGVector(dx: player.position.x + cos(player.zRotation) * 0.1, dy: player.position.y + sin(player.zRotation) * 0.1))
            
            
          //  player.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
            
            player.position = CGPoint(x:player.position.x + cos(player.zRotation) * 3.7 ,y:player.position.y + sin(player.zRotation) * 3.7)
            pilotDirection = player.zRotation - 3.141592/2
            
            if currentShip == "enemy3" {
                let revolve1 = SKAction.moveBy(x: -CGFloat(80 * cos(2 * currentTime )), y: -CGFloat(80 * sin(2 * currentTime)), duration: 0.00000001)
                           
                           let revolve2 = SKAction.moveBy(x: -CGFloat(80 * cos(2 * currentTime + 2.0944)), y: -CGFloat(80 * sin(2 * currentTime + 2.0944)), duration: 0.00000001)
                           
                           let revolve3 = SKAction.moveBy(x: -CGFloat(80 * cos(2 * currentTime + 4.18879)), y: -CGFloat(80 * sin(2 * currentTime + 4.18879)), duration: 0.00000001)
                
                bullet1.run(revolve1)
                          bullet2.run(revolve2)
                          bullet3.run(revolve3)
            }
            else {
            let revolve1 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime )), y: -CGFloat(50 * sin(2 * currentTime)), duration: 0.00000001)
            
            let revolve2 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime + 2.0944)), y: -CGFloat(50 * sin(2 * currentTime + 2.0944)), duration: 0.00000001)
            
            let revolve3 = SKAction.moveBy(x: -CGFloat(50 * cos(2 * currentTime + 4.18879)), y: -CGFloat(50 * sin(2 * currentTime + 4.18879)), duration: 0.00000001)
                
                bullet1.run(revolve1)
                          bullet2.run(revolve2)
                          bullet3.run(revolve3)
            }
            
          
            
            bullet1.position = player.position
            bullet2.position = player.position
            bullet3.position = player.position
            
            if shot.position.y < frame.minY + 35 {
                shot.removeFromParent()
            } else if shot.position.y > frame.maxY - 35 {
                shot.removeFromParent()
            }
            if shot.position.x < frame.minX + 35  {
                shot.removeFromParent()
            } else if shot.position.x > frame.maxX - 35 {
                shot.removeFromParent()
            }
            

            
            if self.numAmmo < 3 {
                if !self.regenAmmo {
                    self.regenAmmo = true
                    let ammoTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { (timer) in
                        self.numAmmo = self.numAmmo + 1
                        
                        if self.numAmmo == 1 {
                            self.bullet3.alpha = 1
                        }
                        else if self.numAmmo == 2 {
                            self.bullet2.alpha = 1
                        }
                        else if self.numAmmo == 3 {
                            self.bullet1.alpha = 1
                        }
                        self.regenAmmo = false
                    }
                }
            }
        } else {
            
            self.bullet3.alpha = 0
            self.bullet2.alpha = 0
            self.bullet1.alpha = 0

            
            
            if self.pilotForward {
                pilot.position = CGPoint(x:pilot.position.x + cos(pilot.zRotation+3.141592/2) * 2 ,y:pilot.position.y + sin(pilot.zRotation+3.141592/2) * 2)
            } else {
                pilot.position = CGPoint(x:pilot.position.x + cos(pilotDirection + 3.141592/2) * 0.9 ,y:pilot.position.y + sin(pilotDirection + 3.141592/2) * 0.9)
            }
            
            
        }
        
        if enemyPoints.alpha > 0 {
            let timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { (timer) in
                self.enemyPoints.alpha = self.enemyPoints.alpha - 0.016
            }
        }
        
        for enemy in children {
            

        }
            /*
            if enemy.frame.maxX < 0 {
                if !frame.intersects(enemy.frame) {
                    enemy.removeFromParent()
                }
 */
            
        
        let activeEnemies = children.compactMap { $0 as? EnemyNode }
        if activeEnemies.isEmpty {
            createWave()
        }
        
        for enemy in activeEnemies {
            guard frame.intersects(enemy.frame) else { continue }
            
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                if enemy.position.x < frame.minX - 25 {
                    enemy.removeFromParent()
                
                    
                }
            } else {
                if enemy.position.x < frame.minX - 20 {
                    enemy.removeFromParent()
                    //  print("enemy removed)")
                }
            }
            
            if enemy.lastFireTime + 1 < currentTime {
                enemy.lastFireTime = currentTime
                
                let randInt = Int.random(in: 0...5)
                let wait = SKAction.wait(forDuration: 0.5)
                let action = SKAction.run {
                    enemy.fire(numPoints: self.speedAdd*25)
                    self.run(SKAction.playSoundFileNamed("miniLasernew", waitForCompletion: false))
                }
                
                if numPoints < 1000 {
                    if randInt < 2 {
                        self.run(SKAction.sequence([wait,action]))
                    }
                } else if numPoints < 2000 {
                    if randInt < 3 {
                        self.run(SKAction.sequence([wait,action]))
                    }
                } else if numPoints < 3000 {
                    if randInt < 4 {
                        self.run(SKAction.sequence([wait,action]))
                    }
                } else {
                    if randInt < 5 {
                        self.run(SKAction.sequence([wait,action]))
                    }
                }
            }
        }
        
        if Global.gameData.isReviveReady == true && Global.gameData.isReviveReady2 == true {
            print("reviveready2")
            Global.gameData.isReviveReady = false
            Global.gameData.isReviveReady2 = false
            print("attmpeting to clear scene")
            sceneClear()
        }

      
        
        

        
    }
    
    func createWave() {
       // guard !isGameOver else { return }
        
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[waveNumber]
        waveNumber += 1
        waveCounter += 1
  //     var rng = SystemRandomNumberGenerator()
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0...maximumEnemyType-1)
        if numPoints < 5000 {
            speedAdd = numPoints/25
        } else {
            speedAdd = 5000/25
        }
        let speedChange = (3-enemyType)*100 + speedAdd
      //      , using: &rng)
        
        let enemyOffsetX: CGFloat = 100
        let enemyStartX = 1000
        if currentWave.enemies.isEmpty {
            for(index, position) in positions.shuffled().enumerated() {
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffsetX * CGFloat(index * 3), moveStright: 0, speeds: speedChange)
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
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffset: enemyOffsetX * enemy.xOffset, moveStright: 0, speeds: speedChange)
                
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        
     //   print("first Node is   \(firstNode.name)")
    //    print("second Node is  \(secondNode.name)")
        
        //print("player collided with \(firstNode.name)")
        
        /* 
        if (firstNode.name == "1triple" || firstNode.name == "2laser" || firstNode.name == "3mine") && (secondNode.name == "0" || secondNode.name == "1" || secondNode.name == "2" || secondNode.name == "enemy" || secondNode.name == "enemyWeapon") {
            
            print(firstNode.name)
            print(secondNode.name)
         powerup.physicsBody = nil
        }
        else {
            powerup.physicsBody = SKPhysicsBody(texture: powerup.texture!, size: powerup.size)
        }
        
        
        */
        
        
        
        if secondNode.name == "player" {
           
            print("player collided with \(firstNode.name)")
            if firstNode.name == "1tripleshot" {
                let triplePower = SKAction.setTexture(SKTexture(imageNamed: "tripleshot"))
      shootButtonNode.run(triplePower)
                powerupMode = 1
                self.i = 3
                firstNode.removeFromParent()
                powerSpawn = false
            }
            else if firstNode.name == "2laser" {
                let laserPower = SKAction.setTexture(SKTexture(imageNamed: "laser"))
      shootButtonNode.run(laserPower)
                powerupMode = 2
                self.i = 1
                firstNode.removeFromParent()
                powerSpawn = false
            }
            
            else if firstNode.name == "3mine" {
                let minePower = SKAction.setTexture(SKTexture(imageNamed: "mine"))
      shootButtonNode.run(minePower)
                powerupMode = 3
                self.i = 3
                firstNode.removeFromParent()
                powerSpawn = false
            }
           
            else if firstNode.name == "0"||firstNode.name == "1" || firstNode.name == "2" || firstNode.name == "enemy" || firstNode.name == "enemyWeapon" {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                self.run(SKAction.playSoundFileNamed("explosionnew", waitForCompletion: false))
                Global.sceneShake(shakeCount: 2, intensity: CGVector(dx: 2.2, dy: 2.2), shakeDuration: 0.15, sceneview: self.scene!)
                if let explosion = SKEmitterNode(fileNamed: "ShipExplosion") {
                    explosion.position = secondNode.position
                    addChild(explosion)
                }
              
                playerShields -= 1
                
                if playerShields == 0 {
                    phaseButtonNode.alpha = 0.4
                    ejectButtonNode.alpha = 0
                    isPlayerAlive = false
                    pilot.name = "pilot"
                    let pilotGo = SKAction.setTexture(SKTexture(imageNamed: "pilotGo"))
          shootButtonNode.run(pilotGo)
                              pilot.size = CGSize(width: 40, height: 40)
                              pilot.zRotation = player.zRotation - 3.141592/2
                              pilot.position = player.position
                              pilot.zPosition = 5
                                         buildPilot()
                               animatePilot()
                              //            gameOver()
                              
                              pilotThrust1?.position = CGPoint(x: 0, y: -20)
                              pilotThrust1?.targetNode = self.scene
                              pilotThrust1?.particleAlpha = 0
                              pilot.addChild(pilotThrust1!)
                              
                              firstNode.removeFromParent()
                              secondNode.removeFromParent()
                        
            }
                          
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
                          
            
            }
        }
        
        else if (firstNode.name == "0"||firstNode.name == "1" || firstNode.name == "2" || firstNode.name == "enemy" ) && secondNode.name == "pilot" {
            
              if isPhase == true { //takeOver
                          isPhase = false
                if (Global.gameData.selectedSkin.rawValue != "DEFAULTDECAL") {
                    skin.removeFromParent()
                }
                self.run(SKAction.playSoundFileNamed("takeover", waitForCompletion: false))
                
                print("not phase")
                print("take over1")
                print("\(firstNode.name)")
                
                let playerShoot = SKAction.setTexture(SKTexture(imageNamed: "shootButton"))
                shootButtonNode.run(playerShoot)
                
                powerupMode = 0
           
             
                if firstNode.name == "0" {
                    
                          let enemy1pic = SKAction.setTexture(SKTexture(imageNamed: "enemy1blue"), resize: true)
                player.run(enemy1pic)
                    player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
                    
                   
                    player.physicsBody?.isDynamic = false
                    
                    player.name = "player"
                    
                    self.playerShields = 1
                    currentShip = "enemy1"
                    enemyPoints.position = firstNode.position
                    enemyPoints.text = "+" + "100"
                    enemyPoints.alpha = 1
                    numPoints += 100
                    points.text = "\(numPoints)"
                
                }
                else if firstNode.name == "1" {
                          let enemy2pic = SKAction.setTexture(SKTexture(imageNamed: "enemy2blue"), resize: true)
                player.run(enemy2pic)
                    player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
                    
                    player.name = "player"
                    player.physicsBody?.isDynamic = false
                self.playerShields = 2
                    enemyPoints.position = firstNode.position
                    enemyPoints.text = "+" + "200"
                    enemyPoints.alpha = 1
                    numPoints += 200
                    points.text = "\(numPoints)"
                
                    currentShip = "enemy2"
                }
                else if firstNode.name == "2" {
                          let enemy2pic = SKAction.setTexture(SKTexture(imageNamed: "enemy3blue"), resize: true)
                player.run(enemy2pic)
                    player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
                    player.name = "player"
                    player.physicsBody?.isDynamic = false
                    self.playerShields = 3
                    enemyPoints.position = firstNode.position
                    enemyPoints.text = "+" + "300"
                    enemyPoints.alpha = 1
                currentShip = "enemy3"
                    numPoints += 300
                    points.text = "\(numPoints)"
                
                }
                
                
                player.position = firstNode.position
                player.zRotation = pilot.zRotation + 3.14159 / 2
                                  //        self.isPlayerAlive = true
                                          self.addChild(self.player)
                          secondNode.removeFromParent()
                          isPlayerAlive = true
                
                             firstNode.removeFromParent()
                ejectButtonNode.alpha = 0.4
                phaseButtonNode.alpha = 0
                
                                                     self.pilotThrust1?.removeFromParent()

                                                     self.numAmmo = 3
                                                         
                                                     self.bullet1.alpha = 0
                                                     self.bullet1.run(self.fadeIn)
                                                     self.bullet2.alpha = 0
                                                     self.bullet2.run(self.fadeIn)
                                                     self.bullet3.alpha = 0
                                                     self.bullet3.run(self.fadeIn)
                                                 }
              else {
                self.run(SKAction.playSoundFileNamed("pilotSquish3", waitForCompletion: false))
                                     if let explosion = SKEmitterNode(fileNamed: "PilotBlood") {
                                         explosion.numParticlesToEmit = 8
                                         explosion.position = pilot.position
                                         addChild(explosion)
                                     }
                                     gameOver()
                                     secondNode.removeFromParent()
            }
            
            
            
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
                       }
                
            } else if secondNode.name == "pilot" && (firstNode.name == "enemyWeapon" || firstNode.name == "0" || firstNode.name == "1" || firstNode.name == "2" || firstNode.name == "enemy")  {
          //  print("\(firstNode.name)")
            if isPhase == false {
                self.run(SKAction.playSoundFileNamed("pilotSquish3", waitForCompletion: false))
                        if let explosion = SKEmitterNode(fileNamed: "PilotBlood") {
                            explosion.numParticlesToEmit = 8
                            explosion.position = pilot.position
                            addChild(explosion)
                        }
                        gameOver()
                        secondNode.removeFromParent()
            }
        }
            
        else if firstNode.name == "border" && secondNode.name == "enemyWeapon" {
         //   print("weapon removed")
            secondNode.removeFromParent()
            
        }
        else if firstNode.name == "enemyWeapon" && secondNode.name == "laser" {
            firstNode.removeFromParent()
        }
            else if firstNode.name == "border" && secondNode.name == "enemy" {
             //   print("weapon removed")
                secondNode.removeFromParent()
                
            }
            
            else if (secondNode.name == "0"||secondNode.name == "1" || secondNode.name == "2" || secondNode.name == "enemy") && firstNode.name == "border" {
             //   print("weapon removed")
                secondNode.removeFromParent()
                
            }
            else if (firstNode.name == "0"||firstNode.name == "1" || firstNode.name == "2" || firstNode.name == "enemy") && secondNode.name == "border" {
             //   print("weapon removed")
                firstNode.removeFromParent()
                
            }
            
        else if secondNode.name == "playerWeapon" && firstNode.name == "enemyWeapon" {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            self.run(SKAction.playSoundFileNamed("explosionnew", waitForCompletion: false))
            firstNode.removeFromParent()
            secondNode.removeFromParent()
            
        }
            
        else if let enemy = firstNode as? EnemyNode {
            
            if secondNode.name == "playerWeapon" || secondNode.name ==
            "player" || secondNode.name == "mine" || secondNode.name == "laser" {
                // print("hi")
                 enemy.shields -= 1
                 self.run(SKAction.playSoundFileNamed("explosionnew", waitForCompletion: false))
                 let generator = UIImpactFeedbackGenerator(style: .heavy)
                 generator.impactOccurred()
                Global.sceneShake(shakeCount: 2, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1, sceneview: self.scene!)
               
                if secondNode.name == "mine" {
                    print("mine exploded")
                    
                    if let explosion = SKEmitterNode(fileNamed: "mineExplosion") {
                        explosion.position = secondNode.position
                        addChild(explosion)
                    }
                    secondNode.removeFromParent()
                    enemy.shields = 0
                }
                if secondNode.name == "laser" {
                    print("laser fired to kill enemy")
                 //   secondNode.removeFromParent()
                    enemy.shields = 0
                }
                
                if enemy.shields == 0 {
                     if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                         explosion.position = enemy.position
                         addChild(explosion)
                     }
                     enemyPoints.position = enemy.position
                     enemyPoints.text = "+" + "\(enemy.scoreinc)"
                     enemyPoints.alpha = 1
                    
                     numPoints += enemy.scoreinc
                     points.text = "\(numPoints)"
                     
                         
                     if numPoints % 3 == 0 && powerSpawn == false {
                         print("powerup spawned")
                         powerSpawn = true
                        
                        
                    
                         powerup.position = firstNode.position
                        powerup.zPosition = 4
                         powerup.name = "powerup"
                        
                        powerup.size = CGSize(width: 48.858, height: 45.689)
                        powerup.physicsBody = SKPhysicsBody(texture: powerup.texture!, size: powerup.size)
                        
                        powerup.physicsBody?.categoryBitMask = CollisionType.powerup.rawValue
                        powerup.physicsBody?.collisionBitMask = CollisionType.player.rawValue
                        powerup.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
                        
                                    self.addChild(powerup)
         
                         poweruprandInt = Int.random(in: 1...3)
                                   
                                   if poweruprandInt == 1 {
                                                 let triplePower = SKAction.setTexture(SKTexture(imageNamed: "tripleshot"))
                                 //      shootButtonNode.run(triplePower)
                                 powerup.run(triplePower)
                                    
                                     powerup.size = CGSize(width: 48.858, height: 45.689)
                                     
                                     powerup.name! = "1tripleshot"
                                    
                                   }
                                   else if poweruprandInt == 2 {
                                       let laserPower = SKAction.setTexture(SKTexture(imageNamed: "laser"))
                                                   //                 shootButtonNode.run(laserPower)
                                     powerup.run(laserPower)
                                        powerup.size = CGSize(width: 48.858, height: 45.689)
                                     
                                     powerup.name! = "2laser"
                                   }
                                   else if poweruprandInt == 3 {
                                       let minePower = SKAction.setTexture(SKTexture(imageNamed: "mine"))
                                                        //            shootButtonNode.run(minePower)
                                     powerup.run(minePower)
                                       powerup.size = CGSize(width: 48.858, height: 45.689)
                                     powerup.name! = "3mine"
                                   }
                     }
                     
                
                    enemy.removeFromParent()
                    if numPoints > highScore {
                        highScore = numPoints
                        highScorePoints.text = "\(highScore)"
                        var highScoreDefaults = UserDefaults.standard
                        highScoreDefaults.setValue(highScore, forKey: "highScore1")
                        highScoreDefaults.synchronize()
                        GameCenter.shared.updateScore(value: highScore)
                    }
                }
                
                
               
                
                 if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                     explosion.position = enemy.position
                     addChild(explosion)
                 }
                if secondNode.name != "laser" {
                    secondNode.removeFromParent()
                }
                
            }
            }

            /*
            
        else  {
            print("else")
         //   self.run(SKAction.playSoundFileNamed("explosionnew", waitForCompletion: false))
        //    if let explosion = SKEmitterNode(fileNamed: "Explosion") {
        //        explosion.position = secondNode.position
        //        addChild(explosion)
        //    }
         //   firstNode.removeFromParent()
            secondNode.removeFromParent()
            
        }
 */
        
        
        /* miscellans collision
         else  {
            self.run(SKAction.playSoundFileNamed("explosionnew", waitForCompletion: false))
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
 */
    }
    func sceneClear() {
        
        // add dim panel timer countdown
        print("scene clear")
        let playerShoot = SKAction.setTexture(SKTexture(imageNamed: "shootButton"))
        shootButtonNode.run(playerShoot)
        
        addChild(player)
        player.position = deathPosition
        
        isPlayerAlive = true
        isGameOver = false
        
        
        self.backButtonNode.alpha = 0
        self.pauseButtonNode.alpha = 0.6
        self.turnButtonNode.alpha = 0.6
        self.shootButtonNode.alpha = 0.6
        self.ejectButtonNode.alpha = 0.6
        self.phaseButtonNode.alpha = 0
        self.bullet1.alpha = 1
        self.bullet2.alpha = 1
        self.bullet3.alpha = 1
        
        self.dimPanel.alpha = 0
        
        
        self.reviveButtonNode.alpha = 0
      
        reviveTimerNumber.alpha = 0
        reviveTimer.alpha = 0
    
        let activeEnemies = children.compactMap { $0 as? EnemyNode }
        for enemies in activeEnemies {
          //  enemies.speed = 0
            enemies.childNode(withName: "enemyWeapon")?.removeFromParent()
            
         //   enemyWeapon
            
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            self.run(SKAction.playSoundFileNamed("explosionnew", waitForCompletion: false))
            Global.sceneShake(shakeCount: 2, intensity: CGVector(dx: 2.2, dy: 2.2), shakeDuration: 0.15, sceneview: self.scene!)
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = enemies.position
                addChild(explosion)
            }
            
            switch enemies.name {
            case "0":
                enemyPoints.text = "+" + "100"
                numPoints += 100
            case "1":
                enemyPoints.text = "+" + "200"
                numPoints += 200
            case "2":
                enemyPoints.text = "+" + "300"
                numPoints += 300
                
            default:
                print("default enemy")
            }

            enemyPoints.position = enemies.position
           
            enemyPoints.alpha = 1
            
            points.text = "\(numPoints)"
            enemies.removeFromParent()
        }
    }
    
    func gameOverReal() {
        self.reviveButtonNode.alpha = 0
        self.playAgainButtonNode.alpha = 1
        reviveTimerNumber.alpha = 0
        reviveTimer.alpha = 0
        
        let gameOver = SKSpriteNode(imageNamed: "gameOverScore")
        
        gameOver.xScale = 0.2
        gameOver.yScale = 0.2
        gameOver.zPosition = 100
     //   gameOver.run(scaleAction)
        gameOver.position = CGPoint(x: frame.midY, y: frame.midY + 80)
        
      //  gameOver.size = CGSize(width: 619, height: 118)
        addChild(gameOver)
        
        leaderboardButtonNode.selectedHandlers = {
            if GameCenter.shared.isAuthenticated {
                NotificationCenter.default.post(name: Notification.Name("showLeaderboard"), object: nil)
            } else {
                let alert = UIAlertController(title: "Game Center Error", message: "You are currently not logged into Game Center! Log in to view the leaderboard." , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            self.leaderboardButtonNode.alpha = 1
        }
        
        
        leaderboardButtonNode.position = CGPoint(x: frame.maxX - 280 , y: frame.minY + 175)
        leaderboardButtonNode.zPosition = 200
        leaderboardButtonNode.xScale = 0.18
        leaderboardButtonNode.yScale = 0.18
        endlessLeaderboard.fontName = "AvenirNext-Bold"
        endlessLeaderboard.position = CGPoint(x: leaderboardButtonNode.position.x, y: leaderboardButtonNode.position.y - 125)
        endlessLeaderboard.fontColor = UIColor.white
        endlessLeaderboard.zPosition = 200
        endlessLeaderboard.fontSize = 40
        
        leaderboardButtonNode.alpha = 1
        endlessLeaderboard.alpha = 1
        addChild(leaderboardButtonNode)
        addChild(endlessLeaderboard)
        
        
        
        let scoreLabel = SKLabelNode(text: "\(numPoints)")
      
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY+58)
        scoreLabel.zPosition = 200
        scoreLabel.fontColor = UIColor.blue
        scoreLabel.fontSize = 65
        scoreLabel.fontName = "AvenirNext-Bold"
        addChild(scoreLabel)
        
        
       
        let polyniteEarnedLabel = SKLabelNode(text: "+\(numPoints / 100)")
        
      
        polyniteEarnedLabel.position = CGPoint(x: frame.midX, y: frame.midY - 135)
        polyniteEarnedLabel.zPosition = 200
        polyniteEarnedLabel.fontColor = UIColor.blue
        polyniteEarnedLabel.fontSize = 65
        polyniteEarnedLabel.fontName = "AvenirNext-Bold"
        addChild(polyniteEarnedLabel)
        
        
    }
    
    func gameOver() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        direction = 0
        isPlayerAlive = false
        isGameOver = true
        
        deathPosition = pilot.position
    

        self.backButtonNode.alpha = 1
        self.pauseButtonNode.alpha = 0
        self.turnButtonNode.alpha = 0
        self.shootButtonNode.alpha = 0
        self.ejectButtonNode.alpha = 0
        self.phaseButtonNode.alpha = 0
        self.bullet1.alpha = 0
        self.bullet2.alpha = 0
        self.bullet3.alpha = 0
        
        self.dimPanel.alpha = 0.3
       
        
     //   self.scene?.view?.isPaused = true
        
        if !Global.gameData.revived {
            self.reviveButtonNode.alpha = 1
           // reviveTime = 5
            reviveTimerNumber.alpha = 1
            reviveTimer.alpha = 1
            reviveTimerNumber.text = String(reviveTime)
            

            for i in 1..<6 {
                let wait = SKAction.wait(forDuration: TimeInterval(i))
                let action = SKAction.run { [self] in
                    reviveTime -= 1
                    reviveTimerNumber.text = String(reviveTime)
                    
                    if reviveTime == 0 {
                        gameOverReal()
                    }
                }
                self.run(SKAction.sequence([wait,action]))
            }
            
        }
        else {
            //reviveTime = 0
            
        gameOverReal()
            
            
        }
      
//
//
//        let wait = SKAction.wait(forDuration: 20)
//        let action = SKAction.run { [self] in
//            self.reviveButtonNode.alpha = 0
//            self.playAgainButtonNode.alpha = 1
//            reviveTimerNumber.alpha = 0
//            reviveTimer.alpha = 0
//
//            let gameOver = SKSpriteNode(imageNamed: "gameOverScore")
//
//            gameOver.xScale = 0.2
//            gameOver.yScale = 0.2
//            gameOver.zPosition = 100
//         //   gameOver.run(scaleAction)
//            gameOver.position = CGPoint(x: frame.midY, y: frame.midY + 80)
//
//          //  gameOver.size = CGSize(width: 619, height: 118)
//            addChild(gameOver)
//
//            leaderboardButtonNode.selectedHandlers = {
//                if GameCenter.shared.isAuthenticated {
//                    NotificationCenter.default.post(name: Notification.Name("showLeaderboard"), object: nil)
//                } else {
//                    let alert = UIAlertController(title: "Game Center Error", message: "You are currently not logged into Game Center! Log in to view the leaderboard." , preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                    self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
//                }
//                self.leaderboardButtonNode.alpha = 1
//            }
//
//
//            leaderboardButtonNode.position = CGPoint(x: frame.maxX - 280 , y: frame.minY + 175)
//            leaderboardButtonNode.zPosition = 200
//            leaderboardButtonNode.xScale = 0.18
//            leaderboardButtonNode.yScale = 0.18
//                   endlessLeaderboard.fontName = "AvenirNext-Bold"
//                   endlessLeaderboard.position = CGPoint(x: leaderboardButtonNode.position.x, y: leaderboardButtonNode.position.y - 125)
//                         endlessLeaderboard.fontColor = UIColor.white
//                         endlessLeaderboard.zPosition = 200
//                         endlessLeaderboard.fontSize = 40
//
//            leaderboardButtonNode.alpha = 1
//            endlessLeaderboard.alpha = 1
//            addChild(leaderboardButtonNode)
//            addChild(endlessLeaderboard)
//
//
//
//            let scoreLabel = SKLabelNode(text: "\(numPoints)")
//
//            scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY+58)
//            scoreLabel.zPosition = 200
//            scoreLabel.fontColor = UIColor.blue
//            scoreLabel.fontSize = 65
//            scoreLabel.fontName = "AvenirNext-Bold"
//            addChild(scoreLabel)
//
//
//
//            let polyniteEarnedLabel = SKLabelNode(text: "+\(numPoints / 100)")
//
//
//            polyniteEarnedLabel.position = CGPoint(x: frame.midX, y: frame.midY - 135)
//            polyniteEarnedLabel.zPosition = 200
//            polyniteEarnedLabel.fontColor = UIColor.blue
//            polyniteEarnedLabel.fontSize = 65
//            polyniteEarnedLabel.fontName = "AvenirNext-Bold"
//            addChild(polyniteEarnedLabel)
//
//
//
//
//        }
//
//
//            self.run(SKAction.sequence([wait,action]))
//
//
//
//
//
//
        
        
    }
    
}
