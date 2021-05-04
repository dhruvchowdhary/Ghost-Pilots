import Foundation
import SpriteKit

class CPLevel1 : CPLevelBase {
    
    override func setupCameraZoomIn() {
        zoomScale = 3
        zoomOrigin = CGPoint(x: 1000, y: 950)
    }
    
    override func createBounds() -> [SKNode] {
        let borderShape = SKShapeNode()
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 1000, height: 2000), cornerRadius: 40).cgPath
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        borderShape.lineWidth = 20
        
        return [borderShape]
    }
    
    override func createGameObjects() -> [CPObject] {
        let pepe: [CPObject] = []
        return pepe
    }
    
    override func createPlayerShip() {
        playerShip?.shipNode?.position.x = 500
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
        
        let endpoint = CPCheckpoint(pos: CGPoint(x: 500,y: 1700))
        endpoint.isEndpoint = true
        pepe.append(endpoint)
        
        
        return pepe
    }
}
