import SpriteKit
import Foundation



class CPChaserSpaceship : CPSpaceshipBase {
    init(level: CPLevelBase){
        
        var setup = CPSpaceshipSetup(imageNamed: "enemy1")
        setup.isMoving = false
        setup.shipPhisics.contactTestBitMask = CPUInt.bullet
        super.init(spaceshipSetup: setup, lvl: level)
    }
    
    override func AiMovement(playerShip: CPPlayerShip) {
        if isDead {return}
        if isMoving{
            let y = (playerShip.shipNode?.position.y)! - (shipNode?.position.y)!
            let x = (playerShip.shipNode?.position.x)! - (shipNode?.position.x)!
            shipNode?.zRotation = atan2(y,x ) - CGFloat.pi * 1 / 2
            
            shipNode?.physicsBody?.velocity = CGVector(dx: x/2 + 200 * cos(shipNode!.zRotation), dy: y/2 + 200 * sin(shipNode!.zRotation))
        } else {
            if inRangeCheck(pos1: playerShip.shipNode!.position, pos2: shipNode!.position, range: attackRange){
                isMoving = true
            }
        }
    }
}


class CPTurret : CPSpaceshipBase {
    var base = SKSpriteNode(imageNamed: "pepeRed")
    
    let sleepCanonTex = SKTexture(imageNamed: "pepeGreen")
    let activeCanonTex = SKTexture(imageNamed: "pepeRed")
    let sleepBaseTex = SKTexture(imageNamed: "turretbaseeasy")
    let activeBaseTex = SKTexture(imageNamed: "turretbasehard")
    
    init(level: CPLevelBase){
        
        var setup = CPSpaceshipSetup(imageNamed: "turretshooterhard")
        setup.isMoving = false
        setup.bulletRegenRate = 1.5
        setup.bulletSpeeds = 150
        setup.attackRange = 350
        setup.canRotateBothDirections = true
        
        
        setup.isBulletOrbitVisible = false
        super.init(spaceshipSetup: setup, lvl: level)
        
        bulletTexString = "fireball"
        
        shipNode?.physicsBody = SKPhysicsBody(texture: activeBaseTex, size: CGSize(width: 100, height: 100))
        shipNode!.physicsBody?.contactTestBitMask = CPUInt.player
        shipNode!.physicsBody?.collisionBitMask = CPUInt.enemy
        shipNode!.physicsBody?.categoryBitMask = CPUInt.enemy
        shipNode?.physicsBody?.isDynamic = false
        
        shipNode?.xScale = 0.7
        shipNode?.yScale = 0.7
        shipNode?.zPosition = 100
        
        shipNode?.addChild(base)
        base.zPosition = -10
        
        shipNode?.physicsBody?.affectedByGravity = false
        
        health = 9999
        
        unfiredBullets = [SKSpriteNode(imageNamed: "bullet")]
    }
    
    override func AiMovement(playerShip: CPPlayerShip) {
        if isDead {return}
        
        rechargeBullet()
        
        if inRangeCheck(pos1: playerShip.shipNode!.position, pos2: shipNode!.position, range: attackRange){
            changeActivity(isActive: true)
            
            let y = (playerShip.shipNode?.position.y)! - (shipNode?.position.y)!
            let x = (playerShip.shipNode?.position.x)! - (shipNode?.position.x)!
            let targetRotation = atan2(y,x )
            let cRotation = (shipNode?.zRotation.truncatingRemainder(dividingBy: CGFloat.pi))!
            if cRotation < targetRotation {
                shipNode!.zRotation += CGFloat.pi/200
                base.zRotation -= CGFloat.pi/200
            } else {
                shipNode!.zRotation -= CGFloat.pi/200
                base.zRotation += CGFloat.pi/200
            }

            Shoot(shotType: .Bullet)
        } else {
            changeActivity(isActive: false)
        }
    }
    
    func changeActivity(isActive: Bool){
        if isActive{
            shipNode!.texture = activeCanonTex
            base.texture = activeBaseTex
        } else {
            shipNode!.texture = sleepCanonTex
            base.texture = sleepBaseTex
        }
    }
}
