import Foundation
import SpriteKit

class LocalSpaceship: SpaceshipBase {
    init() {
        let spaceShipNode = SKSpriteNode(imageNamed: "player");
        spaceShipNode.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        spaceShipNode.physicsBody!.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue | CollisionType.pilot.rawValue | CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue | CollisionType.powerup.rawValue
        super.init(shipSprite: spaceShipNode, playerId: UIDevice.current.identifierForVendor!.uuidString, controller: ControllerType.Local)
    }
}
