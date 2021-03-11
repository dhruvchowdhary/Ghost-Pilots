import Foundation
import SpriteKit
import Firebase

public class SpaceshipBase {
    public var lastTimeUpdated: Float?
    public var spaceShipParent = SKNode()
    public var spaceShipNode = SKSpriteNode()
    public var spaceShipHud = SKNode()
    public var playerID: String
    public var isLocal = false;

    public var position = (0.0,0.0)
    public var angle = 0 // In degrees
    public var shipLabel = SKLabelNode(text: "name")
    var unfiredBullets: [SKSpriteNode] =
        [SKSpriteNode(imageNamed: "bullet"),
         SKSpriteNode(imageNamed: "bullet"),
         SKSpriteNode(imageNamed: "bullet")]
    let thruster1 = SKEmitterNode(fileNamed: "Thrusters")
    
    let pilotThrust1 = SKEmitterNode(fileNamed: "PilotThrust")
    
    var timeUntilNextBullet: Double = 0.8;

    var unfiredBulletsCount = 0
    public var unfiredBulletRotator = SKNode();

    public var posRef: DatabaseReference = DatabaseReference()
    public var shotsRef: DatabaseReference = DatabaseReference()

    init(playerId: String) {
        self.playerID = playerId
        shipLabel.text = playerId
        shipLabel.zPosition = 1
        spaceShipHud.addChild(shipLabel)
        shipLabel.fontName = "AvenirNext-Bold"
        shipLabel.position = CGPoint(x: 0, y: 35)

        spaceShipParent.addChild(spaceShipNode)
        spaceShipParent.addChild(spaceShipHud)
            
        thruster1?.name = "thruster1"
        thruster1?.position = CGPoint(x: -30, y: 0)
        
        thruster1?.zPosition = -5
        spaceShipNode.addChild(thruster1!)
        
        
        pilotThrust1?.name = "pilotThrust1"
        pilotThrust1?.position = CGPoint(x: -20, y: 0)
        
        pilotThrust1?.zPosition = -5
        spaceShipNode.addChild(pilotThrust1!)
        
        pilotThrust1?.alpha = 0

        posRef = Database.database().reference().child("Games/\(Global.gameData.gameID)/MainGame/\(playerId)/Pos")
        shotsRef = Database.database().reference().child("Games/\(Global.gameData.gameID)/MainGame/\(playerId)/Shots")


        for s in unfiredBullets {
            s.alpha = 0
        }
    }


    func UpdateShip(deltaTime: Double){
        unfiredBulletRotator.zRotation -= CGFloat(Double.pi/35)
        UniqueUpdateShip(deltaTime: deltaTime)

        // For online only, but no control yet
        if unfiredBulletsCount < 3 {
            timeUntilNextBullet -= deltaTime;
        }

        if (timeUntilNextBullet < 0 && unfiredBulletsCount < 3) {
            unfiredBullets[unfiredBulletsCount].alpha = 1;
            unfiredBulletsCount += 1
            timeUntilNextBullet = 1.3
        }
    }
    // Only to be ovveridden
    func UniqueUpdateShip(deltaTime: Double){
        print("Error: UniqueUpdateShip Was not properly overrided")

    }

    public func Shoot(shotType: Int){
        print (Global.gameData.shipsToUpdate)
        switch shotType {
        case 0:
            if unfiredBulletsCount > 0 {
                let bullet = SKSpriteNode(imageNamed: "bullet")
                
                
                bullet.name = "playerWeapon"
                bullet.physicsBody = SKPhysicsBody(texture: bullet.texture!, size: bullet.size)
                bullet.physicsBody?.categoryBitMask = CollisionType.bullet.rawValue
                bullet.physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.border.rawValue
                
                bullet.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.border.rawValue
                
                bullet.physicsBody?.mass = 10
                bullet.zRotation = spaceShipNode.zRotation
                bullet.position = spaceShipParent.position
                bullet.position.x += 40 * cos(spaceShipNode.zRotation)
                bullet.position.y += 40 * sin(spaceShipNode.zRotation)
                Global.gameData.gameScene.liveBullets.append(bullet)
                Global.gameData.gameScene.addChild(bullet)
                self.unfiredBulletsCount -= 1
                unfiredBullets[unfiredBulletsCount].alpha = 0;
                self.spaceShipNode.run(SKAction.playSoundFileNamed("Laser1new", waitForCompletion: false))
            }
        case 1:
            print("Triple Shot")
        case 2:
            print("Laser")
        case 3:
            print("Mine")
        default:
            print("Error, LocalSpaceship given an invalid powerup number")
        }
    }

}
