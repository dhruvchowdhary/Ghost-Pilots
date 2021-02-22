import Foundation
import SpriteKit

public class LocalSpaceship: SpaceshipBase {
    
    public var isRotating = false;
    public var spaceShipParent = SKNode()
    public var spaceShipNode: SKSpriteNode
    public var spaceShipHud = SKNode()
    
    public var isRecoiling = false
    public var recoilTimer: Double = 0
    
    var phaseButtonNode: MSButtonNode!
    var ejectButtonNode: MSButtonNode!
    var reviveButtonNode: MSButtonNode!
    var turnButtonNode: MSButtonNode!
    var shootButtonNode: MSButtonNode!
    
    
    var isPlayerAlive = true
    private var pilot = SKSpriteNode()
    var isPhase = false
    var isGameOver = false
    var bullets: [SKSpriteNode]!
    
    var playerShields = 1
    var powerupMode = 0
    
    let pilotThrust1 = SKEmitterNode(fileNamed: "PilotThrust")
    
    init() {
        spaceShipNode = SKSpriteNode(imageNamed: "player");
        
        spaceShipNode.physicsBody = SKPhysicsBody.init(texture: spaceShipNode.texture!, size: spaceShipNode.size)
        spaceShipNode.name = "player"
        spaceShipNode.zPosition = 5
        
        spaceShipParent.addChild(spaceShipNode)
        spaceShipParent.addChild(spaceShipHud)
        
        spaceShipNode.physicsBody!.categoryBitMask = CollisionType.player.rawValue

        spaceShipNode.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.powerup.rawValue
        spaceShipNode.physicsBody!.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.powerup.rawValue
        
        spaceShipNode.physicsBody?.isDynamic = false
        super.init(shipSprite: spaceShipParent, playerId: UIDevice.current.identifierForVendor!.uuidString)
        
        // Pulls all components from hud and adds them as children to the spaceship node
        // Scalling the components is wack and prolly needs to be reworked
        let hud = SKScene(fileNamed: "Hud.sks")
        for x in hud!.children {
            x.removeFromParent()
//            x.yScale = x.yScale/2.3
//            x.xScale = x.xScale/2.3
//            x.position.x = x.position.x/2.3
//            x.position.y = x.position.y/2.3
            spaceShipHud.addChild(x as! SKSpriteNode)
        }
        Global.gameData.camera.setScale(2.4)
        Global.gameData.camera.removeFromParent()
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
        ejectButtonNode.alpha = 0.8
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
        }
        turnButtonNode.selectedHandlers = {
            self.isRotating = false
            self.turnButtonNode.xScale = self.turnButtonNode.xScale / 1.1
            self.turnButtonNode.yScale = self.turnButtonNode.yScale / 1.1
        }
        
        shootButtonNode = spaceShipHud.childNode(withName: "shootButton") as? MSButtonNode
        
        shootButtonNode.selectedHandler = {
            self.shootButtonNode.alpha = 0.6
            self.shootButtonNode.xScale = self.shootButtonNode.xScale * 1.1
            self.shootButtonNode.yScale = self.shootButtonNode.yScale * 1.1
            
            if self.isPlayerAlive && self.bullets.count > 0{
                Global.gameData.playerShip?.Shoot(shotType: 0)
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
        
        
    }
    
    override func UniqueUpdateShip(deltaTime: Double) {
        // Handle rotation and movement
        if (isRotating){
            spaceShipNode.zRotation += CGFloat(Double.pi * 1.3 * deltaTime)
        }
        
        if isRecoiling {
            recoilTimer -= deltaTime
            if recoilTimer < 0
            {
                isRecoiling = false
            }
            else {
                spaceShipParent.position.x -= cos(spaceShipNode.zRotation) * CGFloat(deltaTime) * 250
                spaceShipParent.position.y -= sin(spaceShipNode.zRotation) * CGFloat(deltaTime) * 250
            }
        } else {
            spaceShipParent.position.x += cos(spaceShipNode.zRotation) * CGFloat(deltaTime) * 250
            spaceShipParent.position.y += sin(spaceShipNode.zRotation) * CGFloat(deltaTime) * 250
        }
        
        // For online only, but no control yet
        
        var bullets: [[CGFloat]] = [[]]
        let bulletSprites = Global.gameData.gameScene.liveBullets
        for bulletInt in 0..<bulletSprites.count {
            bullets[0][bulletInt] = bulletSprites[bulletInt].position.x
            bullets[1][bulletInt] = bulletSprites[bulletInt].position.y
            bullets[2][bulletInt] = bulletSprites[bulletInt].zRotation
        }
        
        let payload = Payload(shipPosX: shipSprite.position.x, shipPosY: shipSprite.position.y, shipAngleRad: shipSprite.zRotation, hasPowerup: false, bullets: bullets)
        let data = try! JSONEncoder().encode(payload)
        let json = String(data: data, encoding: .utf8)!
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/\(playerID)", Value: json)
    }
    
    public func Ghost(){
        // Idk if this will even be used
    }
}
