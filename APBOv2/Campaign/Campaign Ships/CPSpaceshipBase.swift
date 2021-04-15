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
    var isAiHandled: Bool
    var currentRotate: RotateDir
    var isMoving: Bool
    var rotationSpeed: Float
    var dashCD: TimeInterval = 10000000
    var canDash = true
    var hudNode = SKNode()
    var rotatingBulletOffset: Double
    var bulletSpeeds: Double
    var isBulletRecharging = false
    
    init (spaceshipSetup: CPSpaceshipSetup){
        shipNode = spaceshipSetup.shipNode
        shipNode?.physicsBody = spaceshipSetup.shipPhisics
        shipSpeed = spaceshipSetup.speed
        isBulletOrbitVisible = spaceshipSetup.isBulletOrbitVisible
        bulletRegenRate = spaceshipSetup.bulletRegenRate
        canRotateBothDirections = false
        isAiHandled = spaceshipSetup.isAiHandled
        currentRotate = RotateDir.NoRotate
        isMoving = spaceshipSetup.isMoving
        rotationSpeed = spaceshipSetup.shipRotationSpeed
        dashCD = spaceshipSetup.dashCD
        rotatingBulletOffset = spaceshipSetup.rotatingBulletOffset
        bulletSpeeds = spaceshipSetup.bulletSpeeds
        
        
        if isBulletOrbitVisible{
            for i in 0..<unfiredBullets.count {
                let bul = unfiredBullets[i]
                bul.position.x = CGFloat(rotatingBulletOffset * cos(Double.pi * Double(i) * 0.6666666))
                bul.position.y = CGFloat(rotatingBulletOffset * sin(Double.pi * Double(i) * 0.6666666))
                bulletRotater.addChild(bul)
            }
            let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1))
            bulletRotater.run(rotate)
            hudNode.addChild(bulletRotater)
        }
        
    }
    
    func playerShipUpdate(){
        
    }
    
    public func Shoot(shotType: ShotType){
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
        let newBul = SKSpriteNode(imageNamed: "bullet")
        newBul.physicsBody = SKPhysicsBody(texture: newBul.texture!, size: newBul.size)
        newBul.physicsBody?.affectedByGravity = false
        newBul.physicsBody?.collisionBitMask = 1
        
        newBul.position = shipNode!.position
        newBul.position.x += CGFloat(rotatingBulletOffset) * cos(shipNode!.zRotation)
        newBul.position.y += CGFloat(rotatingBulletOffset) * sin(shipNode!.zRotation)
        shipNode?.scene?.addChild(newBul)
        newBul.zRotation = shipNode!.zRotation
        let velocity = CGVector(dx: cos(shipNode!.zRotation) * CGFloat(bulletSpeeds), dy: sin(shipNode!.zRotation) * CGFloat(bulletSpeeds))
        newBul.physicsBody?.velocity = velocity
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
            let timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(dashCD), repeats: false) { (timer) in
                self.canDash = true
            }
        }
    }
    
    func rechargeBullet(){
        if !isBulletRecharging {
            for bul in unfiredBullets{
                if bul.alpha == 0 {
                    isBulletRecharging = true
                    Timer.scheduledTimer(withTimeInterval: TimeInterval(bulletRegenRate), repeats: false, block: {_ in
                        bul.alpha = 100
                        self.isBulletRecharging = false
                        self.rechargeBullet()
                    })
                    return
                }
            }
        }
    }
    
    func destroyShip(){}
    
    func handleAImovement(playerShip: CPSpaceshipBase){}
    
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
            let velocity = CGVector(dx: cos(shipNode!.zRotation) * CGFloat(shipSpeed), dy: sin(shipNode!.zRotation) * CGFloat(shipSpeed))
            shipNode!.physicsBody?.velocity = velocity
        } else {
            shipNode?.physicsBody?.velocity = CGVector()
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
    var isAiHandled = false
    var isPresetAi = false
    var presetAiType = PresetAi.Chaser
    var isMoving = true
    var canDash = true
    var dashCD: TimeInterval = 0.5
    var rotatingBulletOffset: Double = 65
    var bulletSpeeds: Double = 450.0
}


enum PresetAi {
    case Chaser
}

enum RotateDir {
    case Clockwise, CounterClock, NoRotate
}

enum ShotType {
    case Bullet, Laser, Mine, TripleShot
}
