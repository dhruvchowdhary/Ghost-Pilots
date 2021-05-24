import SpriteKit
import Foundation


public class CPObject {
    var node: SKNode
    
    // Movement options
    var nodePhysics: SKPhysicsBody?
    
    // Activation methods
    var preformActionOnShoot = false
    var preformActionOnContact = false
    var isBreakable = false
    var health = 1
    var id = 0
    
    var action: Actions = .None
    
    // Hazardous options
    var instantKill = false
    var blastRadius: CGFloat = 100
    var damage = 1
    var level: CPLevelBase?
    var customAction = {
        
    }
    
    var deathParticles = SKEmitterNode()
    
    // Rewardable options
    var rewardedObject = "NIL"
    
    init(imageNamed: String) {
        let pepenode = SKSpriteNode(imageNamed: imageNamed)
        node = pepenode
        nodePhysics = SKPhysicsBody(texture: pepenode.texture!, size: pepenode.size)
        node.physicsBody = nodePhysics
        node.physicsBody?.categoryBitMask = CPUInt.object
        node.physicsBody?.collisionBitMask = CPUInt.player | CPUInt.enemy | CPUInt.walls | CPUInt.immovableObject
        node.physicsBody?.contactTestBitMask = CPUInt.player | CPUInt.enemy
        node.physicsBody?.isDynamic = false
    }
    
    func changeHealth(delta: Int){
        print(health)
        if isBreakable {
            health += delta
            if health < 1 {
                level?.collectedReward(id: id)
                node.removeFromParent()
            }
        }
    }
    
    init (node: SKNode, action : Actions?){
        self.node = node
    }
}

public class laserSpawn: CPObject {
    
}

public class laserDrop: CPObject {
    let obj = SKSpriteNode(imageNamed: "laser")
    var isready = true
    init() {
        super.init(node: obj, action: .Custom)
        node.physicsBody = SKPhysicsBody(texture: obj.texture!, size: obj.size)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.contactTestBitMask = CPUInt.player
        node.physicsBody?.collisionBitMask = CPUInt.empty
        node.physicsBody?.categoryBitMask = CPUInt.Powerup
        action = .Custom
        customAction = { [self] in
            print("feahkaghjkjhkegakjagskhjsgghjkajkhsgjhkasjkhdgjkhasdhjkgjkhdajklh")
            if !isready {return}
            if node.alpha == 0 {return}
            Global.isPowered = true
            node.alpha = 0
            let act = SKAction.run {
                self.spawnPowerup()
            }
            let wait = SKAction.wait(forDuration: 8)
            obj.run(SKAction.sequence([wait,act]))
        }
    }
    
    func spawnPowerup(){
        isready = true
        node.alpha = 1
    }
}

public class APRound: CPObject {
    init(){
        super.init(imageNamed: "bullet")
        health = 500
        action = .DirectDamage
    }
}

public class CPBullet: CPObject {
    init(tex: String){
        super.init(imageNamed: "bullet")
        if tex == "fireball" { }
        isBreakable = true
        health = 1
        action = .DirectDamage
        
        nodePhysics?.isDynamic = true
        nodePhysics!.affectedByGravity = false
        node.physicsBody?.contactTestBitMask = CPUInt.bullet | CPUInt.enemy | CPUInt.immovableObject
        // This object will only ever need to push movables
        node.physicsBody?.collisionBitMask = 0
        nodePhysics!.categoryBitMask = CPUInt.bullet
    }
    
    
}


