import Foundation
import SpriteKit
import Firebase

class RemoteSpaceship: SpaceshipBase {
    
    public var posRef: DatabaseReference = DatabaseReference()
    public var shotsRef: DatabaseReference = DatabaseReference()
    
    init(playerID: String) {
        let spaceShipNode = SKSpriteNode(imageNamed: "player");
        spaceShipNode.physicsBody = SKPhysicsBody.init(circleOfRadius: 24)
        spaceShipNode.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        spaceShipNode.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue
        
        super.init(shipSprite: spaceShipNode, playerId: playerID)
        shipSprite.position.x += CGFloat((300 * Global.gameData.shipsToUpdate.count))
        
        posRef = Database.database().reference().child("Games/\(Global.gameData.gameID)/Players/\(playerID)/Pos")
        shotsRef = Database.database().reference().child("Games/\(Global.gameData.gameID)/Players/\(Global.playerData.username)/Shots")
        Global.multiplayerHandler.ListenForPayload(ref: posRef, shipSprite: self.shipSprite as! SKSpriteNode)
        Global.multiplayerHandler.ListenForShots(ref: shotsRef, spaceShip: self)
    }
    
    override func UniqueUpdateShip(deltaTime: Double) {
        
    }
}

