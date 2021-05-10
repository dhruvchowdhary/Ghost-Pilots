import Foundation
import SpriteKit

class CPSpaceshipBase {
    var shipSpeed: Float
    
    var isBulletOrbitVisible: Bool
    var bulletRotater = SKNode()
    var unfiredBullets: [SKSpriteNode] =
        [SKSpriteNode(imageNamed: "bullet"),
         SKSpriteNode(imageNamed: "bullet"),
         SKSpriteNode(imageNamed: "bullet")]
    
    var shipNode: SKSpriteNode?
    var bulletRegenRate: Float
    var canRotateBothDirections: Bool
    var currentRotate: RotateDir
    var isMoving: Bool
    var rotationSpeed: Float
    var dashCD: TimeInterval = 10000000
    var canDash = true
    var hudNode = SKNode()
    var rotatingBulletOffset: Double
    var bulletSpeeds: Double
    var isBulletRecharging = false
    var level: CPLevelBase
    var isDead = false
    var isGhost = false
    var attackRange: CGFloat
    var rotateAction: SKAction?
    var ghostNode = SKSpriteNode(imageNamed: "apboWhitePilot")
    var shipNodeOutScene: SKSpriteNode?
    var firedBullets: [SKNode] = []
    var firedBulletVelocites: [CGVector] = []
    var hasGhostMode = false
    var bulletTexString: String?
    
    var health = 1
    var maxHealth = 9999
    
    init (spaceshipSetup: CPSpaceshipSetup, lvl: CPLevelBase){
        shipNode = spaceshipSetup.shipNode
        shipNode?.physicsBody = spaceshipSetup.shipPhisics
        shipSpeed = spaceshipSetup.speed
        isBulletOrbitVisible = spaceshipSetup.isBulletOrbitVisible
        bulletRegenRate = spaceshipSetup.bulletRegenRate
        canRotateBothDirections = false
        currentRotate = RotateDir.NoRotate
        isMoving = spaceshipSetup.isMoving
        rotationSpeed = spaceshipSetup.shipRotationSpeed
        dashCD = spaceshipSetup.dashCD
        rotatingBulletOffset = spaceshipSetup.rotatingBulletOffset
        bulletSpeeds = spaceshipSetup.bulletSpeeds
        level = lvl
        attackRange = spaceshipSetup.attackRange
        hasGhostMode = spaceshipSetup.hasGhostMode
        
        if isBulletOrbitVisible{
            for i in 0..<unfiredBullets.count {
                let bul = unfiredBullets[i]
                bul.position.x = CGFloat(rotatingBulletOffset * cos(Double.pi * Double(i) * 0.6666666))
                bul.position.y = CGFloat(rotatingBulletOffset * sin(Double.pi * Double(i) * 0.6666666))
                bulletRotater.addChild(bul)
            }
            rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1))
            bulletRotater.run(rotateAction!)
            hudNode.addChild(bulletRotater)
        }
        
        ghostNode.scale(to: CGSize(width: 35, height: 35))
        ghostNode.physicsBody = SKPhysicsBody(texture: ghostNode.texture!, size: ghostNode.size)
        level.addObjectToScene(node: ghostNode, nodeClass: self)
        ghostNode.removeFromParent()
        
    }
    
    func AiMovement(playerShip: CPPlayerShip){
        // if you want ai movement you have to override this
    }
    
    func playerShipUpdate(){
        hudNode.position = shipNode!.position
    }
    
    
    func inRangeCheck(pos1: CGPoint,pos2: CGPoint, range: CGFloat) -> Bool{
        let x = (pos1.x - pos2.x)
        let xDelta = (x * x)
        let yDelta = ((pos1.y - pos2.y) * (pos1.y - pos2.y))
        //print(range)
        if  xDelta + yDelta < (range * range)
        {
            return true
        }
        return false
    }
    
    public func Shoot(shotType: ShotType){
        if isGhost {return}
        switch shotType {
        case .Bullet:
            for bul in unfiredBullets{
                if bul.alpha != 0 {
                    
                    // Fire bullet
                    bul.alpha = 0
                    createFiringBullet()
                    rechargeBullet()
                    
                    // Prevent fallthrough to other bullets
                    return
                }
            }
        
        case .Laser:
            print("Laser")
        case .Mine:
            print("Mine")
        case .TripleShot:
            print("TripleShot")
        }
    }
    
    func createFiringBullet() {
        let bulClass = CPBullet(tex: bulletTexString ?? "bullet")
        let newBul = bulClass.node as! SKSpriteNode
        
        newBul.position = shipNode!.position
        newBul.position.x += CGFloat(rotatingBulletOffset) * cos(shipNode!.zRotation)
        newBul.position.y += CGFloat(rotatingBulletOffset) * sin(shipNode!.zRotation)
        level.addObjectToScene(node: newBul,nodeClass: bulClass)
        newBul.zRotation = shipNode!.zRotation
        let velocity = CGVector(dx: cos(shipNode!.zRotation) * CGFloat(bulletSpeeds), dy: sin(shipNode!.zRotation) * CGFloat(bulletSpeeds))
        newBul.physicsBody?.velocity = velocity
        
        newBul.physicsBody?.categoryBitMask = CPUInt.bullet
        newBul.physicsBody?.contactTestBitMask = CPUInt.player | CPUInt.bullet | CPUInt.enemy | CPUInt.immovableObject | CPUInt.object | CPUInt.walls
        
        firedBullets.append(newBul)
        firedBulletVelocites.append(newBul.physicsBody!.velocity)
        
        // There is no feasable way to have 100 sec bullet
        Timer.scheduledTimer(withTimeInterval: TimeInterval(100), repeats: false) { (timer) in
            self.firedBullets.removeFirst()
            self.firedBulletVelocites.removeFirst()
        }
    }
    
    public func Dash(forwardMagnitude: CGFloat, deltaRotation: CGFloat, forwardDuration: Double, rotationDuration: Double){
        if canDash {
            // dash
            let rotation = SKAction.rotate(byAngle: deltaRotation, duration: TimeInterval(rotationDuration))
            shipNode!.run(rotation, completion: {
                let movement = SKAction.moveBy(x: forwardMagnitude * cos(self.shipNode!.zRotation), y: forwardMagnitude * sin(self.shipNode!.zRotation), duration: TimeInterval(forwardDuration))
                self.shipNode!.run(movement)
            })
            
            canDash = false
            Timer.scheduledTimer(withTimeInterval: TimeInterval(dashCD), repeats: false) { (timer) in
                self.canDash = true
            }
        }
    }
    
    func togglePause(isPaused: Bool){
        shipNode?.physicsBody!.velocity = CGVector()
        for i in firedBullets {
            if isPaused{
                i.physicsBody!.velocity = CGVector()
            } else {
                i.physicsBody!.velocity = firedBulletVelocites[firedBullets.firstIndex(of: i)!]
            }
        }
    }
    
    func rechargeBullet(){
        if !isBulletRecharging {
            for bul in unfiredBullets{
                if bul.alpha == 0 {
                    isBulletRecharging = true
                    let pepe2 = (Timer.scheduledTimer(withTimeInterval: TimeInterval(bulletRegenRate), repeats: false, block: {_ in
                        bul.alpha = 100
                        self.isBulletRecharging = false
                        self.rechargeBullet()
                    }))
                    if self is CPPlayerShip{
                        level.bulletsRegenTimers.append(pepe2)
                    }
                    return
                }
            }
        }
    }
    
    public func destroyShip(){
        isMoving = false
        isDead = true
        shipNode?.removeFromParent()
        ghostNode.removeFromParent()
        
    }
    
    func ghostMode(){
        destroyShip()
    }
    
    func ManualUpdate(deltaTime: CGFloat){
        playerShipUpdate()
        rotationUpdate(deltaTime: deltaTime)
        movementUpdate()
    }
    
    func rotationUpdate(deltaTime: CGFloat){
        switch currentRotate {
        case .Clockwise:
            shipNode?.zRotation -= CGFloat(rotationSpeed) * deltaTime
        case .CounterClock:
            shipNode?.zRotation += CGFloat(rotationSpeed) * deltaTime
        default: break;
        }
    }
    
    func movementUpdate(){
        if isMoving {
            if isGhost {
                let velocity = (CGVector(dx: cos(shipNode!.zRotation + CGFloat(Double.pi/2)) * 260, dy: sin(shipNode!.zRotation + CGFloat(Double.pi/2)) * 260 * Global.gameData.speedMultiplier))
                shipNode!.physicsBody?.velocity.dx = velocity.dx
                shipNode!.physicsBody?.velocity.dy = velocity.dy
            } else {
                let velocity = CGVector(dx: cos(shipNode!.zRotation) * CGFloat(shipSpeed), dy: sin(shipNode!.zRotation) * CGFloat(shipSpeed))
                shipNode!.physicsBody?.velocity = velocity
            }
        } else {
            if isGhost {
            } else {
                shipNode?.physicsBody?.velocity = CGVector()
            }
        }
    }
    
    func changeHealth(delta: Int){
        health += delta
        resolveHealthDelta()
    }
    
    func resolveHealthDelta() {
        if health < 0 {
            destroyShip()
        } else if health < 1 {
            ghostMode()
        } else if health > maxHealth {
            health = maxHealth
            // this is to prevent overheal, may be adjusted later
        }
    }
}

struct CPSpaceshipSetup {
    // Defaults to create a player ship
    
    init(imageNamed: String ){
        shipNode = SKSpriteNode(imageNamed: imageNamed)
        shipPhisics = SKPhysicsBody(texture: SKTexture(imageNamed: imageNamed), size: SKTexture(imageNamed: imageNamed).size())
        shipPhisics.isDynamic = true
        shipPhisics.affectedByGravity = false
        shipPhisics.angularDamping = 1000000000
    }
    var speed: Float = 225.0
    var shipNode: SKSpriteNode
    var shipPhisics: SKPhysicsBody
    var isBulletOrbitVisible = true
    var bulletRegenRate: Float = 1
    var shipRotationSpeed: Float = Float(Double.pi) * 1.3
    var canRotateBothDirections = false
    var isMoving = true
    var canDash = true
    var dashCD: TimeInterval = 0.5
    var rotatingBulletOffset: Double = 65
    var bulletSpeeds: Double = 450.0
    var attackRange: CGFloat = 450
    var hasGhostMode = false
}


enum AiType {
    case Chaser, None
}

enum RotateDir {
    case Clockwise, CounterClock, NoRotate
}

enum ShotType {
    case Bullet, Laser, Mine, TripleShot
}
