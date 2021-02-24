import Foundation
import SpriteKit
import Firebase

class RemoteSpaceship: SpaceshipBase {
    init(playerID: String) {
        let spaceShipNode = SKSpriteNode(imageNamed: "player");
        spaceShipNode.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        spaceShipNode.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.bullet.rawValue
        
        
        // Attach
        
        super.init(shipSprite: spaceShipNode, playerId: playerID)
    }
    
    override func UniqueUpdateShip(deltaTime: Double) {
        let ref = Database.database().reference().child("Games/\(Global.gameData.gameID)/\(playerID)")
        ref.observeSingleEvent(of: .value) { snapshot in
            let snapVal = snapshot.childSnapshot(forPath: "Payload").value as! String
            if (snapshot.hasChildren()) {
                let jsonData = snapVal.data(using: .utf8)
                let payload = try! JSONDecoder().decode(Payload.self, from: jsonData!)
                
                self.shipSprite.position.x = payload.shipPosX
                self.shipSprite.position.y = payload.shipPosY
                self.shipSprite.zRotation = payload.shipAngleRad
            }
            
        }
    }
}

