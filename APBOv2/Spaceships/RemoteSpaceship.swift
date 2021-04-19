import Foundation
import SpriteKit
import Firebase

class RemoteSpaceship: SpaceshipBase {
    public var velocity = CGVector(dx: 0, dy: 0)
    public var isPilot = false
    
    init(playerID: String, imageTexture: String) {
        super.init(playerId: playerID)
        spaceShipNode.removeFromParent()
        spaceShipNode = SKSpriteNode(imageNamed: imageTexture);
        spaceShipNode.name = "shipnode"
        spaceShipParent.addChild(spaceShipNode)
        spaceShipNode.addChild(pilotThrust1!)
        spaceShipNode.addChild(trailDefault!)
        spaceShipNode.addChild(trailLightning!)
        
        spaceShipParent.name = "remoteparent"
        spaceShipParent.physicsBody = SKPhysicsBody.init(circleOfRadius: 24)
        spaceShipParent.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        spaceShipParent.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        
        spaceShipParent.physicsBody?.allowsRotation = false
    
        spaceShipParent.physicsBody?.contactTestBitMask = CollisionType.border.rawValue | CollisionType.bullet.rawValue | CollisionType.player.rawValue
        
        spaceShipParent.position.x += CGFloat((300 * Global.gameData.shipsToUpdate.count))
        spaceShipNode.zPosition = 5
        
        Global.multiplayerHandler.ListenForPosPayload(ref: posRef, shipSprite: spaceShipParent)
        Global.multiplayerHandler.ListenForShots(ref: shotsRef, spaceShip: self)
    }
    
    override func UniqueUpdateShip(deltaTime: Double) {
        if !isPilot {
            velocity = (CGVector(dx: cos(spaceShipNode.zRotation) * 260, dy: sin(spaceShipNode.zRotation) * 260 * Global.gameData.speedMultiplier))
        } else {
            velocity = CGVector(dx: 0, dy: 0)
        }
        spaceShipParent.physicsBody?.velocity = velocity
    }
    
    public func StopListenToShip(){
        Global.multiplayerHandler.StopListenForPayload(ref: posRef)
        Global.multiplayerHandler.StopListenForShots(ref: shotsRef, spaceShip: self)
    }
}

