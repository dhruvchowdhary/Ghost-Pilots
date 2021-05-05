import Foundation
import SpriteKit

class CPLevel2 : CPLevelBase {
    
    let endpoint = CPCheckpoint(pos: CGPoint(x: 500,y: 1700))
    
    override func setupCameraZoomIn() {
        zoomScale = 3
        zoomOrigin = CGPoint(x: 500, y: 1000)
    }
    
    override func createBounds() -> [SKNode] {
        var bounds: [SKNode] = []
        
        let borderShape = SKShapeNode()
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 2000, height: 2000), cornerRadius: 40).cgPath
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        borderShape.lineWidth = 20
        bounds.append(borderShape)
        
        let wall: SKShapeNode = SKShapeNode(rect: CGRect(x: 500, y: 0, width: 250, height: 1000), cornerRadius: 40)
        //wall.physicsBody = SKPhysicsBody(: CGRect(x: 500, y: 0, width: 250, height: 1000))
        wall.fillColor = SKColor.blue
        bounds.append(wall)
        
        let wall2: SKShapeNode = SKShapeNode(rect: CGRect(x: 1500, y: 0, width: 250, height: 1000), cornerRadius: 40)
        skphy
        //wall2.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 1500, y: 0, width: 250, height: 1000))
        wall2.fillColor = SKColor.blue
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
        
        for i in 0..<10{
            pepe.append(CPChaserSpaceship(level: self))
        }
        
        for i in 0..<5{
            pepe[i].shipNode?.position.x = 900
            pepe[i].shipNode?.position.y = 200 * CGFloat(i) + 600
            pepe[i].shipNode?.zRotation = -CGFloat.pi * 3/2
        }
        
        for i in 5..<10{
            pepe[i].shipNode?.position.x = 100
            pepe[i].shipNode?.position.y = 200 * CGFloat(i - 5) + 600
            pepe[i].shipNode?.zRotation = CGFloat.pi * 3/2
        }
        
        
        return pepe
    }
    
    override func createCheckpoints() -> [CPCheckpoint] {
        var pepe: [CPCheckpoint] = []
        
        endpoint.isEndpoint = true
        endpoint.changeLock(lockedEhhh: true)
        endpoint.unlockedAction = {self.endpoint.changeLock(lockedEhhh: false)}
        pepe.append(endpoint)
        
        
        return pepe
    }
}
