import Foundation
import SpriteKit
import Firebase

class RemoteSpaceship: SpaceshipBase {
    init(playerID: String) {
        let spaceShipNode = SKSpriteNode(imageNamed: "player");
        spaceShipNode.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        spaceShipNode.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        
        // Attach
        
        super.init(shipSprite: spaceShipNode, playerId: playerID)
    }
    
    override func UpdateShip(deltaTime: Float, inputs: [InputType]) {
        let ref = Database.database().reference().child("Games/\(Global.gameData.gameID)/\(playerID)")
        ref.observeSingleEvent(of: .value) { snapshot in
            let snapVal = snapshot.value as! String
            if (snapVal == "Null"){
                return;
            } else {
                let jsonData = snapVal.data(using: .utf8)
                let payload = try! JSONDecoder().decode(Payload.self, from: jsonData!)
                
                self.shipSprite.position.x = payload.shipPosX
                self.shipSprite.position.y = payload.shipPosY
                self.shipSprite.zRotation = payload.shipAngleRad
            }
        }
    }
}

