import SpriteKit
import Foundation

class CPCheckpoint {
    var isCustomInteract = false
    var isStartpoint = false
    var isEndpoint = false
    // 999 = all enemys on the scene
    var kilsReqToUnlock = 999
    var unlockedAction = {}
    var isLocked = false
    var node: SKSpriteNode
    var rewardId = 69
    
    init(pos: CGPoint) {
        node = SKSpriteNode(imageNamed: "BlackHole")
        node.scale(to: CGSize(width: 125, height: 130))
        let rotation = SKAction.rotate(byAngle: -CGFloat.pi/3, duration: 1)
        node.run(SKAction.repeatForever(rotation))
        node.position = pos
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.affectedByGravity = false
        
        // ignore collisions with everything, only contacts with player
        node.physicsBody!.contactTestBitMask = CPUInt.player
        node.physicsBody?.collisionBitMask = CPUInt.empty
        node.physicsBody?.categoryBitMask = CPUInt.checkpoint
        node.physicsBody?.isDynamic = false
    }
    
    
    func changeLock(lockedEhhh: Bool){
        if isLocked == lockedEhhh{return}
        isLocked = lockedEhhh
        if lockedEhhh {
            
            let lock = SKSpriteNode(imageNamed: "lock")
            lock.color = SKColor.white
            lock.colorBlendFactor = 1
            lock.alpha = 0.8
            lock.name = "lock"
            lock.scale(to: CGSize(width: 70, height: 70))
            node.speed = 0
            node.addChild(lock)
            lock.zRotation -= node.zRotation
            lock.zPosition = 50
        } else {
            node.speed = 1
            node.childNode(withName: "lock")?.removeFromParent()
        }
    }
}
