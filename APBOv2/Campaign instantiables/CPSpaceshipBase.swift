import Foundation
import SpriteKit

class CPSpaceshipBase {
    var shipSpeed: Float
    var isBulletOrbitVisible: Bool
    var shipNode: SKSpriteNode?
    var bulletRegenRate: Float
    var canRotateBothDirections: Bool
    var isAiHandled: Bool
    
    init (spaceshipSetup: CPSpaceshipSetup){
        shipNode = spaceshipSetup.shipNode
        shipNode?.physicsBody = spaceshipSetup.shipPhisics
        shipSpeed = spaceshipSetup.speed
        isBulletOrbitVisible = spaceshipSetup.isBulletOrbitVisible
        bulletRegenRate = spaceshipSetup.bulletRegenRate
        canRotateBothDirections = false
        isAiHandled = spaceshipSetup.isAiHandled
    }
    
    func destroyShip(){}
    
    func handleAImovement(playerShip: CPSpaceshipBase){}
    
}

struct CPSpaceshipSetup {
    init(imageNamed: String ){
        shipNode = SKSpriteNode(imageNamed: imageNamed)
        shipPhisics = SKPhysicsBody(texture: SKTexture(imageNamed: imageNamed), size: SKTexture(imageNamed: imageNamed).size())
    }
    var speed: Float = 100.0
    var shipNode: SKSpriteNode
    var shipPhisics: SKPhysicsBody
    var isBulletOrbitVisible = false
    var bulletRegenRate: Float = 1.0 // Sec
    var shipRotationSpeed: Float = 1.0 //radians
    var canRotateBothDirections = false
    var isAiHandled = false
    
    // Everything beyond is possible for later
    // var destroyShipAnims:
    // var
}
