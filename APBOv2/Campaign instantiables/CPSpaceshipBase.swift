import Foundation
import SpriteKit

class CPSpaceshipBase {
    var shipSpeed: Float
    var isBulletOrbitVisible: Bool
    var shipNode: SKSpriteNode?
    var bulletRegenRate: Float
    var canRotateBothDirections: Bool
    var isAiHandled: Bool
    var currentRotate: RotateDir
    var isMoving: Bool
    
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
    }
    
    func shipUpdate(){
        if isMoving {
            // Set ship movement and rotation
        }
    }
    
    public func Shoot(shotType: ShotType){
        switch shotType {
        case .Bullet:
            print("Bullet")
        case .Laser:
            print("Laser")
        case .Mine:
            print("Mine")
        case .TripleShot:
            print("TripleShot")
        }
    }
    
    func turn(dir: RotateDir){
        
    }
    
    func destroyShip(){}
    
    func handleAImovement(playerShip: CPSpaceshipBase){}
    
}

struct CPSpaceshipSetup {
    // Defaults to create a player ship
    
    init(imageNamed: String ){
        shipNode = SKSpriteNode(imageNamed: imageNamed)
        shipPhisics = SKPhysicsBody(texture: SKTexture(imageNamed: imageNamed), size: SKTexture(imageNamed: imageNamed).size())
    }
    var speed: Float = 100.0
    var shipNode: SKSpriteNode
    var shipPhisics: SKPhysicsBody
    var isBulletOrbitVisible = false
    var bulletRegenRate: Float = 1.0 // Sec
    var shipRotationSpeed: Float = 1.0 // (pi/6) per sec
    var canRotateBothDirections = false
    var isAiHandled = false
    var isPresetAi = false
    var presetAiType = PresetAi.Chaser
    var isMoving = true
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
