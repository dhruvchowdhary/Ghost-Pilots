import SpriteKit
import Foundation

class CPCheckpoint {
    var isCustomInteract = false
    var isStartpoint = false
    var isEndpoint = false
    // 999 = all enemys on the scene
    var kilsReqToUnlock = 999
    var unlockedAction = {}
    var node: SKSpriteNode
    
    init(pos: CGPoint) {
        node = SKSpriteNode(imageNamed: "BlackHole")
        node.scale(to: CGSize(width: 125, height: 130))
        let rotation = SKAction.rotate(byAngle: -CGFloat.pi/3, duration: 1)
        node.run(SKAction.repeatForever(rotation))
        node.position = pos
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.affectedByGravity = false
        
        // ignore collisions with everything, only contacts with player
        node.physicsBody!.contactTestBitMask = 100
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = 10
        node.physicsBody?.isDynamic = false
    }
}
