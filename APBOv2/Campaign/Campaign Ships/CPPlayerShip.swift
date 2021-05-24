import Foundation
import SpriteKit

class CPPlayerShip: CPSpaceshipBase {
    var camera = SKCameraNode()
    var isUsingSemiFocus = false
    var focusedPoints: [(SKNode, Float)] = []
    var shipParent = SKNode()
    var possibleDash = false
    let phaseButton = MSButtonNode(imageNamed: "phaseButton")
    let ejectButton = MSButtonNode(imageNamed: "ejectButton")
    let reviveButton = MSButtonNode(imageNamed: "reviveButton")
    let pauseButton = MSButtonNode(imageNamed: "pause")
    let backButton = MSButtonNode(imageNamed: "back")
    let shootButton = MSButtonNode(imageNamed: "shootButton")
    let turnButton = MSButtonNode(imageNamed: "turnButton")
    let restartButton = MSButtonNode(imageNamed: "restart")
    let playAgainButton = MSButtonNode(imageNamed: "playAgainButton")
    var tempNode: SKSpriteNode?
    
    init(lvl: CPLevelBase) {
        
        //Change our ship physics to be able to rotate on walls
        super.init(spaceshipSetup: CPSpaceshipSetup(imageNamed: "player"),lvl: lvl)
        
        // Create the hud to attach to player
        createHud()
        shipParent.addChild(shipNode!)
        shipParent.addChild(hudNode)
        shipNode?.zPosition += 100
        shipNode?.physicsBody?.allowsRotation = false
        
        shipNode?.physicsBody?.contactTestBitMask = CPUInt.enemy | CPUInt.bullet | CPUInt.object | CPUInt.checkpoint | CPUInt.Boss | CPUInt.Powerup
        shipNode?.physicsBody?.collisionBitMask =  CPUInt.object | CPUInt.walls | CPUInt.immovableObject | CPUInt.Boss
        shipNode?.physicsBody?.categoryBitMask = CPUInt.player
        let zoomInActionipad = SKAction.scale(to: 1.7, duration: 0.01)
        if UIDevice.current.userInterfaceIdiom == .pad {
                        hudNode.run(zoomInActionipad)
        }
        
    }
    
//    override func playerShipUpdate() {
//        hudNode.position = shipNode!.position
//    }
    
    override func ghostMode(){
        // If triggered manully, wont make a diff
        health = 0
        isGhost = true
        isMoving = false
        phaseButton.zPosition = 100
        ejectButton.zPosition = -100
        
        ghostNode.physicsBody!.categoryBitMask = (shipNode?.physicsBody!.categoryBitMask)!
        ghostNode.physicsBody!.contactTestBitMask = (shipNode?.physicsBody!.contactTestBitMask)!
        ghostNode.physicsBody!.collisionBitMask = (shipNode?.physicsBody!.collisionBitMask)!
        ghostNode.zRotation = shipNode!.zRotation - CGFloat.pi/2
        ghostNode.zPosition += 100
        ghostNode.physicsBody?.allowsRotation = false
        ghostNode.position = shipNode!.position
        ghostNode.physicsBody!.affectedByGravity = false
        ghostNode.physicsBody!.velocity = (shipNode?.physicsBody!.velocity)!
        ghostNode.name = shipNode?.name
        
        bulletRotater.isHidden = true
        shipNodeOutScene = shipNode
        shipNode?.removeFromParent()
        shipParent.addChild(ghostNode)
        shipNode = ghostNode
        
        let wait = SKAction.wait(forDuration: 6)
        let thing = SKAction.run { [self] in
            health = 2
            isGhost = false
            isMoving = true
            phaseButton.zPosition = -100
            ejectButton.zPosition = 100
            
            
            ghostNode.removeFromParent()
            shipParent.addChild(shipNodeOutScene!)
            
            shipNodeOutScene?.position = ghostNode.position
            shipNodeOutScene?.zRotation = ghostNode.zRotation + CGFloat.pi/2
            shipNode = shipNodeOutScene
            print("finishh")
            
        }
        
        self.shipNode!.run(SKAction.sequence([wait,thing]))
    }
    
    func powerUp(){
        
    }
    
    override func destroyShip() {
        // Epic explosion here
        shipNode?.removeFromParent()
        ghostNode.removeFromParent()
        reviveButton.isHidden = false
        print("g;fdsgadsgjsaghsa;")
        level.youLose()
    }
    
    func setHudHidden(isHidden: Bool) {
        hudNode.childNode(withName: "shootButton")!.isHidden = isHidden
        hudNode.childNode(withName: "back")!.isHidden = true
        hudNode.childNode(withName: "turnButton")!.isHidden = isHidden
        hudNode.childNode(withName: "phaseButton")?.isHidden = true
        hudNode.childNode(withName: "restart")?.isHidden = true
        hudNode.childNode(withName: "ejectButton")?.isHidden = true
        hudNode.childNode(withName: "pause")?.isHidden = isHidden
    }
    
    func enterSpaceship(){
        
    }
    
    func createHud(){
        hudNode.zPosition = 1000
        hudNode.addChild(camera)
        
        pauseButton.name = "pause"
        pauseButton.isUserInteractionEnabled  = true
        pauseButton.position.x = 790
        pauseButton.position.y = 300
        pauseButton.size = CGSize(width: 80, height: 100)
        hudNode.addChild(pauseButton)
        pauseButton.selectedHandler = {
            (Global.gameData.skView.scene as! CPLevelBase).togglePause()
        }
        
        
        shootButton.name = "shootButton"
        shootButton.isUserInteractionEnabled = true
        shootButton.position.x = -720
        shootButton.position.y = -280
        shootButton.size = CGSize(width: 213, height: 196)
        hudNode.addChild(shootButton)
        shootButton.selectedHandler = {
            if self.isGhost {
                self.isMoving = true
            } else if Global.isPowered {
                
                let laserBody = SKSpriteNode(imageNamed: "laserbeampic")
                laserBody.name = "laser"
                laserBody.size = CGSize(width: 2000, height: 30)
                laserBody.zRotation = self.shipNode!.zRotation //- CGFloat.pi/4
                laserBody.position.y = self.shipNode!.position.y + 1000 * sin(self.shipNode!.zRotation)// - CGFloat.pi/4)
                laserBody.position.x = self.shipNode!.position.x + 1000 * cos(self.shipNode!.zRotation)// - CGFloat.pi/4)
                //laserBody.anchorPoint = CGPoint(x: 0, y: 0.5)
                laserBody.physicsBody = SKPhysicsBody(texture: laserBody.texture!, size: laserBody.size)
                
                laserBody.physicsBody?.categoryBitMask = CPUInt.APRound
                laserBody.physicsBody?.contactTestBitMask = CPUInt.enemy | CPUInt.bullet | CPUInt.Boss
                laserBody.physicsBody?.collisionBitMask = CPUInt.empty
                
                
                let joint = SKPhysicsJointPin.joint(withBodyA: laserBody.physicsBody!, bodyB: self.shipNode!.physicsBody!, anchor: self.shipNode!.position)
                
                self.level.addObjectToScene(node: laserBody, nodeClass: APRound())
                
                self.level.physicsWorld.add(joint)
                
                
                
                let shrink = SKAction.resize(toHeight: 0, duration: 0.4)
                laserBody.run(shrink)
                
                let wait = SKAction.wait(forDuration:0.4)
                let action = SKAction.run {
                    laserBody.removeFromParent()
                }
                self.shipNode!.run(SKAction.sequence([wait,action]))
                
                Global.isPowered = false
            } else {
                self.Shoot(shotType: .Bullet)
            }
        }
        
        shootButton.selectedHandlers = {
            
            if self.isGhost {
                self.isMoving = false
                self.shipNode?.physicsBody!.velocity = CGVector(dx: (self.shipNode?.physicsBody!.velocity.dx)!*0.5, dy: (self.shipNode?.physicsBody!.velocity.dy)!*0.5)
            }
        }
        
        
        backButton.name = "back"
        backButton.position.x = -790
        backButton.position.y = 300
        backButton.size = CGSize(width: 140, height: 90)
        backButton.isHidden = true
        backButton.selectedHandler = {
            Global.loadScene(s: "MainMenu")
        }
        hudNode.addChild(backButton)
        
        
        turnButton.name = "turnButton"
        turnButton.isUserInteractionEnabled  = true
        turnButton.position.x = 725
        turnButton.position.y = -280
        turnButton.zPosition = 100
        turnButton.size = CGSize(width: 213, height: 196)
        hudNode.addChild(turnButton)
        turnButton.selectedHandler = { [self] in
            self.currentRotate = .Clockwise
            turnButton.xScale = turnButton.xScale * 1.1
            turnButton.yScale = turnButton.yScale * 1.1
            if isGhost {return}
            if possibleDash {
                self.Dash(forwardMagnitude: 60, deltaRotation: CGFloat(-Double.pi/2), forwardDuration: 0.20, rotationDuration: 0.03)
            } else {
                possibleDash = true
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: {_ in
                    possibleDash = false
                })
            }
        }
        turnButton.selectedHandlers = {
            self.turnButton.xScale = self.turnButton.xScale / 1.1
            self.turnButton.yScale = self.turnButton.yScale / 1.1
            self.currentRotate = .NoRotate
        }
        
        
        restartButton.name = "restart"
        restartButton.position.x = 655
        restartButton.position.y = 300
        restartButton.isHidden = true
        restartButton.size = CGSize(width: 93, height: 100)
        restartButton.selectedHandler = {
            Global.loadScene(s: Global.sceneString)
        }
        hudNode.addChild(restartButton)
        
        
        playAgainButton.position.x = 0
        playAgainButton.position.y = -224.6
        playAgainButton.size = CGSize(width: 510, height: 149)
        playAgainButton.name = "playAgainButton"
        playAgainButton.isHidden = true
        hudNode.addChild(playAgainButton)
        
        
        phaseButton.name = "phaseButton"
        hudNode.addChild(phaseButton)
        phaseButton.position.x = 575
        phaseButton.position.y = -180
        phaseButton.isHidden = true
        phaseButton.size = CGSize(width: 157, height: 150)
        phaseButton.selectedHandler = {
            
        }
        phaseButton.selectedHandlers = {
            
        }
// Old implemetation
// =============================================
//        phaseButton.selectedHandler = {
//            if self.isPlayerAlive == false {
//                self.pilot.alpha = 0.7
//                self.phaseButtonNode.alpha = 0.6
//                self.isPhase = true
//            }
//        }
//        phaseButtonNode.selectedHandlers = {
//            if self.isPlayerAlive == false && !self.isGameOver {
//                self.pilot.alpha = 1
//                self.phaseButtonNode.alpha = 0.8
//                self.isPhase = false
//            }
//        }
        
        
        ejectButton.name = "ejectButton"
        hudNode.addChild(ejectButton)
        ejectButton.position.x = 575
        ejectButton.position.y = -180
        ejectButton.size = CGSize(width: 157, height: 150)
        ejectButton.selectedHandler = {
            self.ghostMode()
        }
        
        
        hudNode.addChild(reviveButton)
        reviveButton.position.x = 334
        reviveButton.position.y = -226
        reviveButton.size = CGSize(width: 157, height: 150)
        reviveButton.name = "reviveButton"
        reviveButton.isHidden = true
        reviveButton.selectedHandler = {
        }
        
        let scale = 0.7
        if UIDevice.current.userInterfaceIdiom == .pad {
            turnButton.position.x = (hudNode.position.x + 640) * CGFloat(scale)
            turnButton.position.y = (hudNode.position.y - 410) * CGFloat(scale)
            turnButton.setScale(CGFloat(1.25 * scale))
            
            shootButton.position.x = (hudNode.position.x - 640) * CGFloat(scale)
            shootButton.position.y =  (hudNode.position.y - 410) * CGFloat(scale)
            shootButton.setScale(CGFloat(1.25 * scale))
            
            pauseButton.position.x = (hudNode.position.x + 640) * CGFloat(scale)
            pauseButton.position.y =  (hudNode.position.y + 430) * CGFloat(scale)
            pauseButton.setScale(CGFloat(1.25 * scale))
            
            backButton.position.x = (hudNode.position.x - 640) * CGFloat(scale)
            backButton.position.y = (hudNode.position.y + 430) *  CGFloat(scale)
            backButton.setScale(CGFloat(1.25 * scale))
            
            restartButton.position.x = (hudNode.position.x + 480) * CGFloat(scale)
            restartButton.position.y =  (hudNode.position.y + 430) * CGFloat(scale)
            restartButton.setScale(CGFloat(1.25 * scale))
            
            playAgainButton.position.x = hudNode.position.x
            playAgainButton.position.y = (hudNode.position.y - 224 - 121) * CGFloat(scale)
            playAgainButton.setScale(CGFloat(1.25 * scale))
            
//            reviveButtonNode.position.x = hudNode.position.x + 340
//            reviveButtonNode.position.y = playAgainButtonNode.position.y
//          //  reviveButtonNode.setScale(CGFloat(1.25 * scale))
//
            phaseButton.position.x = (turnButton.position.x) * CGFloat(scale)
            phaseButton.position.y = (turnButton.position.y) * CGFloat(scale)
            phaseButton.setScale(CGFloat(1.25 * scale))
            
            ejectButton.position.x = (turnButton.position.x) * CGFloat(scale)
            ejectButton.position.y = (turnButton.position.y) * CGFloat(scale)
            ejectButton.setScale(CGFloat(1.25 * scale))
        } else { //is phone
            if UIScreen.main.bounds.width < 779 {
                if UIScreen.main.bounds.width > 567 {
                    turnButton.size = CGSize(width: 200, height: 184.038)
                    turnButton.position.x = hudNode.position.x + 620
                    turnButton.position.y = hudNode.position.y - 300
                    
                    shootButton.size = CGSize(width: 200, height: 184.038)
                    shootButton.position.x = hudNode.position.x - 620
                    shootButton.position.y =  hudNode.position.y - 300
                    
                    backButton.size = CGSize(width: 131.25, height: 93.75)
                    backButton.position.x = hudNode.position.x - 620
                    backButton.position.y =  hudNode.position.y + 330
                    
                    restartButton.size = CGSize(width: 87.188, height: 93.75)
                    restartButton.position.x = hudNode.position.x + 470
                    restartButton.position.y =  hudNode.position.y + 330
                    
                    pauseButton.size = CGSize(width: 75, height: 93.75)
                    pauseButton.position.x = hudNode.position.x + 620
                    pauseButton.position.y =  hudNode.position.y + 330
                    
                    phaseButton.size = CGSize(width: 157, height: 150)
                    phaseButton.position.x = turnButton.position.x - 140
                    phaseButton.position.y = turnButton.position.y + 90
                    
                    ejectButton.size = CGSize(width: 157, height: 150)
                    ejectButton.position.x = turnButton.position.x - 140
                    ejectButton.position.y = turnButton.position.y + 90
                } else {
                    turnButton.size = CGSize(width: 200, height: 184.038)
                    turnButton.position.x = hudNode.position.x + 620
                    turnButton.position.y = hudNode.position.y - 300
                    
                    shootButton.size = CGSize(width: 200, height: 184.038)
                    shootButton.position.x = hudNode.position.x - 620
                    shootButton.position.y =  hudNode.position.y - 300
                    
                    backButton.size = CGSize(width: 131.25, height: 93.75)
                    backButton.position.x = hudNode.position.x - 620
                    backButton.position.y =  hudNode.position.y + 330
                    
                    restartButton.size = CGSize(width: 87.188, height: 93.75)
                    restartButton.position.x = hudNode.position.x + 470
                    restartButton.position.y =  hudNode.position.y + 330
                    
                    pauseButton.size = CGSize(width: 75, height: 93.75)
                    pauseButton.position.x = hudNode.position.x + 620
                    pauseButton.position.y =  hudNode.position.y + 330
                    
                    phaseButton.size = CGSize(width: 157, height: 150)
                    phaseButton.position.x = turnButton.position.x - 140
                    phaseButton.position.y = turnButton.position.y + 90
                    
                    ejectButton.size = CGSize(width: 157, height: 150)
                    ejectButton.position.x = turnButton.position.x - 140
                    ejectButton.position.y = turnButton.position.y + 90
                }
            }
        }
    }
    
    func addSemiFocus(focusPoint: (SKNode, Float)){
        
    }
    
    func calculateCamera(){
        
    }
}
