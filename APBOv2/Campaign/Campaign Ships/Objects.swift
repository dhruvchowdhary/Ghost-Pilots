import SpriteKit
import Foundation


class CPObject {
    var node: SKNode
    
    // Movement options
    var nodePhysics: SKPhysicsBody?
    
    // Activation methods
    var preformActionOnShoot = false
    var preformActionOnContact = false
    var isBreakable = false
    var health = 1
    
    var action: Actions = .None
    
    // Hazardous options
    var instantKill = false
    var blastRadius: CGFloat = 100
    var damage = 1
    
    // Rewardable options
    var rewardedObject = "NIL"
    
    init(imageNamed: String) {
        let pepenode = SKSpriteNode(imageNamed: imageNamed)
        node = pepenode
        nodePhysics = SKPhysicsBody(texture: pepenode.texture!, size: pepenode.size)
        node.physicsBody = nodePhysics
        node.physicsBody?.isDynamic = false
    }
    
    init (node: SKNode, action : Actions?){
        self.node = node
    }
}

class CPBullet: CPObject {
    init(){
        super.init(imageNamed: "bullet")
        isBreakable = true
        health = 1
        action = .DirectDamage
        
        nodePhysics?.isDynamic = true
        nodePhysics!.affectedByGravity = false
        node.physicsBody?.contactTestBitMask = CPUInt.bullet | CPUInt.enemy | CPUInt.immovableObject | CPUInt.object
        // This object will only ever need to push movables
        node.physicsBody?.collisionBitMask = 0
        nodePhysics!.categoryBitMask = CPUInt.bullet
    }
}


