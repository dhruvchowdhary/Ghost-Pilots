import Foundation
import SpriteKit
import Firebase

class RemoteSpaceship: SpaceshipBase {
    
    init(playerID: String, imageTexture: String) {
        super.init(playerId: playerID)
        spaceShipNode.removeFromParent()
        spaceShipNode = SKSpriteNode(imageNamed: imageTexture);
        spaceShipNode.name = "player"
        spaceShipParent.addChild(spaceShipNode)
        spaceShipNode.addChild(thruster1!)
        spaceShipParent.physicsBody = SKPhysicsBody.init(circleOfRadius: 24)
        spaceShipParent.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        spaceShipParent.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        
        spaceShipParent.physicsBody?.categoryBitMask = CollisionType.enemy.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        
        
        spaceShipParent.position.x += CGFloat((300 * Global.gameData.shipsToUpdate.count))
        spaceShipNode.zPosition = 5
        
        Global.multiplayerHandler.ListenForPosPayload(ref: posRef, shipSprite: spaceShipParent)
        Global.multiplayerHandler.ListenForShots(ref: shotsRef, spaceShip: self)
    }
    
    override func UniqueUpdateShip(deltaTime: Double) {
       // let velocity = (CGVector(dx: cos(spaceShipNode.zRotation) * 220, dy: sin(spaceShipNode.zRotation) * 220))
        //spaceShipParent.physicsBody?.velocity = velocity
        spaceShipParent.position.x += cos(spaceShipNode.zRotation) * CGFloat(deltaTime) * 250
       spaceShipParent.position.y += sin(spaceShipNode.zRotation) * CGFloat(deltaTime) * 250
    }
    
    public func StopListenToShip(){
        Global.multiplayerHandler.StopListenForPayload(ref: posRef)
        Global.multiplayerHandler.StopListenForShots(ref: shotsRef, spaceShip: self)
        
    }
}

