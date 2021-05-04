import SpriteKit
import Foundation



class CPChaserSpaceship : CPSpaceshipBase {
    init(level: CPLevelBase){
        
        var setup = CPSpaceshipSetup(imageNamed: "enemy1")
        setup.isMoving = false
        setup.shipPhisics.contactTestBitMask = CPUInt.bullet | CPUInt.immovableObject | CPUInt.walls | CPUInt.object
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
    init(level: CPLevelBase){
        
        var setup = CPSpaceshipSetup(imageNamed: "turretbasehard")
        setup.isMoving = false
        setup.bulletRegenRate = 1.5
        setup.attackRange = 250
        setup.canRotateBothDirections = true
        
        setup.isMoving = false
        setup.shipPhisics.contactTestBitMask = 1
        setup.shipPhisics.collisionBitMask = 1
        setup.shipPhisics.categoryBitMask = 11
        super.init(spaceshipSetup: setup, lvl: level)
    }
    
    override func AiMovement(playerShip: CPPlayerShip) {
        if isDead {return}
        if isMoving{
            let y = (playerShip.shipNode?.position.y)! - (shipNode?.position.y)!
            let x = (playerShip.shipNode?.position.x)! - (shipNode?.position.x)!
            shipNode?.zRotation = atan2(y,x ) - CGFloat.pi * 1 / 2
            shipNode?.physicsBody?.velocity = CGVector(dx: (playerShip.shipNode?.position.x)! - (shipNode?.position.x)!, dy: (playerShip.shipNode?.position.y)! - (shipNode?.position.y)!)
        } else {
            if inRangeCheck(pos1: playerShip.shipNode!.position, pos2: shipNode!.position, range: attackRange){
                isMoving = true
            }
        }
    }
}
