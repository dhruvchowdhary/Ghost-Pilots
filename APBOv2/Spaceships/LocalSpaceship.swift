import Foundation
import SpriteKit

public class LocalSpaceship: SpaceshipBase {
    
    public var isRotating = false;
    public var spaceShipNode: SKSpriteNode
    
    public var isRecoiling = false
    public var recoilTimer: Float = 0
    
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
        spaceShipNode.physicsBody = SKPhysicsBody.init()
        spaceShipNode.name = "player"
        spaceShipNode.zPosition = 5
        
        let cameraNode = SKCameraNode()
        spaceShipNode.addChild(cameraNode)
        Global.gameData.camera = cameraNode
        
        
        spaceShipNode.physicsBody!.categoryBitMask = CollisionType.player.rawValue

        spaceShipNode.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.powerup.rawValue
        spaceShipNode.physicsBody!.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.bullet.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.powerup.rawValue
        
        spaceShipNode.physicsBody?.isDynamic = false
        super.init(shipSprite: spaceShipNode, playerId: UIDevice.current.identifierForVendor!.uuidString)
        
        // Bullets
        bullets = [
            SKSpriteNode(imageNamed: "bullet"),
            SKSpriteNode(imageNamed: "bullet"),
            SKSpriteNode(imageNamed: "bullet")
        ]
        for bullet in bullets {
            //spaceShipNode.addChild(bullet)
        }
        
        // Pulls all components from hud and adds them as children to the spaceship node
        // Scalling the components is wack and prolly needs to be reworked
        let hud = SKScene(fileNamed: "Hud.sks")
        for x in hud!.children {
            x.removeFromParent()
//            x.yScale = x.yScale/2.3
//            x.xScale = x.xScale/2.3
//            x.position.x = x.position.x/2.3
//            x.position.y = x.position.y/2.3
            spaceShipNode.addChild(x as! SKSpriteNode)
        }
        cameraNode.setScale(2.4)
        
        reviveButtonNode = spaceShipNode.childNode(withName: "reviveButton") as? MSButtonNode
        reviveButtonNode.alpha = 0
        reviveButtonNode.selectedHandler = {
            GameViewController().playAd()
        }
        
        phaseButtonNode = spaceShipNode.childNode(withName: "phaseButton") as? MSButtonNode
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
        ejectButtonNode = spaceShipNode.childNode(withName: "ejectButton") as? MSButtonNode
        ejectButtonNode.alpha = 0.8
        ejectButtonNode.selectedHandler = {
            if self.isPlayerAlive == true {
                self.ejectButtonNode.alpha = 0
                self.phaseButtonNode.alpha = 0.8
                self.playerShields = -5
            }
        }
        
        turnButtonNode = spaceShipNode.childNode(withName: "turnButton") as? MSButtonNode
        turnButtonNode.selectedHandler = {}
        
        shootButtonNode = spaceShipNode.childNode(withName: "shootButton") as? MSButtonNode
        
        shootButtonNode.selectedHandler = {
            self.shootButtonNode.alpha = 0.6
            self.shootButtonNode.xScale = self.shootButtonNode.xScale * 1.1
            self.shootButtonNode.yScale = self.shootButtonNode.yScale * 1.1
            
            if self.isPlayerAlive && self.bullets.count > 0{
                Global.gameData.playerShip?.Shoot(shotType: self.powerupMode)
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
    
    override func UpdateShip(deltaTime: Float) {
        // Checks for first update call
        if lastTimeUpdated == nil {
            lastTimeUpdated = deltaTime
            return
        }
        
        // A scaler based off deltaTime
        let scaler = lastTimeUpdated! - deltaTime
        
        let payload = Payload(shipPosX: shipSprite.position.x, shipPosY: shipSprite.position.y, shipAngleRad: shipSprite.zRotation, hasPowerup: false)
        let data = try! JSONEncoder().encode(payload)
        let json = String(data: data, encoding: .utf8)!
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/\(playerID)", Value: json)
        
        // Handle rotation and movement
        if (isRotating){
            spaceShipNode.zRotation += CGFloat(Float(Double.pi)/2 * scaler)
        }
        if isRecoiling {
            recoilTimer -= scaler
            if recoilTimer < 0
            {
                isRecoiling = false
            }
            else {
                spaceShipNode.position.x += CGFloat(1*scaler)
            }
        } else {
            spaceShipNode.position.x -= CGFloat(1*scaler)
        }
    }
    
    public func Shoot(shotType: Int){
        switch shotType {
        case 0:
            print("Normal Shot")
        case 1:
            print("Triple Shot")
        case 2:
            print("Laser")
        case 3:
            print("Mine")
        default:
            print("Error, LocalSpaceship given an invalid powerup number")
        }
        let thruster = SKEmitterNode(fileNamed: "Thrusters")
        thruster!.position = CGPoint(x: -30, y: 0)
        //thruster!.targetNode = self.scene
        // Idk if the above line is nessasary
        spaceShipNode.addChild(thruster!)
    }
    
    public func Ghost(){
        // Idk if this will even be used
    }
}
