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
    
    init(lvl: CPLevelBase) {
        
        //Change our ship physics to be able to rotate on walls
        super.init(spaceshipSetup: CPSpaceshipSetup(imageNamed: "player"),lvl: lvl)
        
        // Create the hud to attach to player
        createHud()
        shipParent.addChild(shipNode!)
        shipParent.addChild(hudNode)
        
        shipNode?.physicsBody?.contactTestBitMask = CPUInt.player
        
    }
    
//    override func playerShipUpdate() {
//        hudNode.position = shipNode!.position
//    }
    
    override func ghostMode(){
        // If triggered manully, wont make a diff
        health = 0
        isGhost = true
        
        print("das")
        phaseButton.zPosition = 100
        ejectButton.zPosition = -100
        
        ghostNode.position = shipNode!.position
        
        bulletRotater.isHidden = true
        shipNodeOutScene = shipNode
        shipParent.addChild(ghostNode)
        shipNode?.removeFromParent()
        shipNode = ghostNode
    }
    
    override func destroyShip() {
        // Epic explosion here
        reviveButton.isHidden = false
        level.youLose()
    }
    
    func setHudHidden(isHidden: Bool) {
        hudNode.childNode(withName: "shootButton")!.isHidden = isHidden
        hudNode.childNode(withName: "back")!.isHidden = true
        hudNode.childNode(withName: "turnButton")!.isHidden = isHidden
        hudNode.childNode(withName: "phaseButton")?.isHidden = true
        hudNode.childNode(withName: "restart")?.isHidden = true
        hudNode.childNode(withName: "ejectButton")?.isHidden = isHidden
        hudNode.childNode(withName: "pause")?.isHidden = isHidden
    }
    
    func enterSpaceship(){
        
    }
    
    func createHud(){
        hudNode.zPosition = 1000
        hudNode.addChild(camera)
        
        let pauseButton = MSButtonNode(imageNamed: "pause")
        pauseButton.name = "pause"
        pauseButton.isUserInteractionEnabled  = true
        pauseButton.position.x = 790
        pauseButton.position.y = 300
        pauseButton.size = CGSize(width: 80, height: 100)
        hudNode.addChild(pauseButton)
        pauseButton.selectedHandler = {
            (Global.gameData.skView.scene as! CPLevelBase).togglePause()
        }
        
        
        let shootButton = MSButtonNode(imageNamed: "shootButton")
        shootButton.name = "shootButton"
        shootButton.isUserInteractionEnabled = true
        shootButton.position.x = -720
        shootButton.position.y = -280
        shootButton.size = CGSize(width: 213, height: 196)
        hudNode.addChild(shootButton)
        shootButton.selectedHandler = {
            self.Shoot(shotType: .Bullet)
        }
        
        
        let backButton = MSButtonNode(imageNamed: "back")
        backButton.name = "back"
        backButton.position.x = -790
        backButton.position.y = 300
        backButton.size = CGSize(width: 140, height: 90)
        backButton.isHidden = true
        backButton.selectedHandler = {
            Global.loadScene(s: "MainMenu")
        }
        hudNode.addChild(backButton)
        
        
        let turnButton = MSButtonNode(imageNamed: "turnButton")
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
            turnButton.xScale = turnButton.xScale / 1.1
            turnButton.yScale = turnButton.yScale / 1.1
            self.currentRotate = .NoRotate
        }
        
        
        let restartButton = MSButtonNode(imageNamed: "restart")
        restartButton.name = "restart"
        restartButton.position.x = 655
        restartButton.position.y = 300
        restartButton.isHidden = true
        restartButton.size = CGSize(width: 93, height: 100)
        restartButton.selectedHandler = {
            Global.loadScene(s: Global.sceneString)
        }
        hudNode.addChild(restartButton)
        
        
        let playAgainButton = MSButtonNode(imageNamed: "playAgainButton")
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
    }
    
    func addSemiFocus(focusPoint: (SKNode, Float)){
        
    }
    
    func calculateCamera(){
        
    }
}
