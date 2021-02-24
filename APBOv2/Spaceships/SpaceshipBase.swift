import Foundation
import SpriteKit
import Firebase

public class SpaceshipBase {
    public var lastTimeUpdated: Float?
    public var shipSprite: SKNode
    public var playerID: String
    public var position = (0.0,0.0)
    public var angle = 0 // In degrees
    var unfiredBullets: [SKSpriteNode] = []
    
    init(shipSprite: SKNode, playerId: String) {
        self.shipSprite = shipSprite
        self.playerID = playerId
    }

    
    func UpdateShip(deltaTime: Double){
        UniqueUpdateShip(deltaTime: deltaTime)
    }
    // Only to be ovveridden
    func UniqueUpdateShip(deltaTime: Double){
        print("Error: UniqueUpdateShip Was not properly overrided")
        
    }
    
    public func Shoot(shotType: Int){
        switch shotType {
        case 0:
            if unfiredBullets.count > 0 {
                let bullet = unfiredBullets.removeLast()
                bullet.removeFromParent()
                bullet.zRotation = shipSprite.zRotation
                bullet.position = shipSprite.position
                Global.gameData.gameScene.liveBullets.append(bullet)
                Global.gameData.gameScene.addChild(bullet)
                print(unfiredBullets.count)
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
        let thruster = SKEmitterNode(fileNamed: "Thrusters")
        thruster!.position = CGPoint(x: -30, y: 0)
        //thruster!.targetNode = self.scene
        // Idk if the above line is nessasary
        shipSprite.addChild(thruster!)
    }
    
}
