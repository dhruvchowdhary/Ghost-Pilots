
import Foundation
import SpriteKit

class CPLevel3 : CPLevelBase {
    
    override func setupCameraZoomIn() {
        zoomScale = 2.6
        zoomOrigin = CGPoint(x: 0, y: 900)
    }
    
    override func createBounds() -> [SKNode] {
        var bounds: [SKNode] = []
        
        let borderShape = SKShapeNode()
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2000, height: 2000), cornerRadius: 40).cgPath
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        borderShape.lineWidth = 20
        bounds.append(borderShape)
        
        let wall: SKShapeNode = SKShapeNode(rect: CGRect(x: 500, y: 10, width: 250, height: 1300), cornerRadius: 40)
        wall.fillColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        bounds.append(wall)
        
        let wall2: SKShapeNode = SKShapeNode(rect: CGRect(x: 1250, y: 10, width: 250, height: 1300), cornerRadius: 40)
        wall2.fillColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        bounds.append(wall2)
        
        return bounds
    }
    
    override func createGameObjects() -> [CPObject] {
        var pepe: [CPObject] = []
        
        let key = CPObject(imageNamed: "key")
        key.id = 69
        key.node.position = CGPoint(x: 100, y: 100)
        key.node.xScale = 0.2
        key.node.yScale = 0.2
        key.action = .RewardObject
        key.node.physicsBody!.collisionBitMask = CPUInt.empty
        pepe.append(key)
        return pepe
    }
    
    override func createPlayerShip() {
        playerShip?.shipNode?.position.x = 1000
        playerShip?.shipNode?.position.y = 100
        playerShip?.shipNode?.zRotation = CGFloat.pi/2
        playerShip?.hudNode.position = (playerShip?.shipNode!.position)!
    }
    
    override func createEnemyShips() -> [CPSpaceshipBase] {
        var pepe: [CPSpaceshipBase] = []
        
        for i in 0..<4{
            let turr = CPTurret(level: self)
            turr.shipNode!.position = CGPoint(x: 500 + 300 * i, y: 1900)
            pepe.append(turr)
        }
        
        
        return pepe
    }
    
    override func createCheckpoints() -> [CPCheckpoint] {
        var pepe: [CPCheckpoint] = []
        
        let endpoint = CPCheckpoint(pos: CGPoint(x: 1900,y: 100))
        endpoint.isEndpoint = true
        endpoint.changeLock(lockedEhhh: true)
        endpoint.unlockedAction = {endpoint.changeLock(lockedEhhh: false)}
        pepe.append(endpoint)
        
        
        return pepe
    }
}
