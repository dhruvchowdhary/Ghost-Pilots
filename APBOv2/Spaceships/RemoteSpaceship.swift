import Foundation
import SpriteKit

class RemoteSpaceship: SpaceshipBase {
    init(playerID: String) {
        let spaceShipNode = SKSpriteNode(imageNamed: "player");
        spaceShipNode.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        spaceShipNode.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        super.init(shipSprite: spaceShipNode, playerId: playerID, controller: ControllerType.Remote)
    }
}
