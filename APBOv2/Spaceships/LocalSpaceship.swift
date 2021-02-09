import Foundation
import SpriteKit

class LocalSpaceship: SpaceshipBase {
    init() {
        let spaceShipNode = SKSpriteNode(imageNamed: "player");
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
        var bullets: [SKSpriteNode] = [
            SKSpriteNode(imageNamed: "bullet"),
            SKSpriteNode(imageNamed: "bullet"),
            SKSpriteNode(imageNamed: "bullet")
        ]
        for bullet in bullets {
            spaceShipNode.addChild(bullet)
        }
    }
    
    override func UpdateShip(deltaTime: Float, inputs: [InputType]) {
        // Checks for first update call
        if lastTimeUpdated == nil {
            lastTimeUpdated = deltaTime
            return
        }
        
        // A scaler based off deltaTime
        let scaler = lastTimeUpdated! - deltaTime
        
        // TODO calculate movement from inputs
        
        let payload = Payload(shipPosX: shipSprite.position.x, shipPosY: shipSprite.position.y, shipAngleRad: shipSprite.zRotation, hasPowerup: false)
        let data = try! JSONEncoder().encode(payload)
        let json = String(data: data, encoding: .utf8)!
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/\(playerID)", Value: json)
    }
}
