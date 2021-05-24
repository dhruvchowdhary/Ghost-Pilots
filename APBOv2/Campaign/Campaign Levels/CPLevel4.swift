import Foundation
import SpriteKit

class CPLevel4 : CPLevelBase {
    
    override func setupCameraZoomIn() {
        Global.isPowered = true
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
        return bounds
    }
    
    override func createGameObjects() -> [CPObject] {
        var pepe: [CPObject] = []
        
        pepe.append(laserDrop())
        pepe[0].node.xScale = 0.05
        pepe[0].node.yScale = 0.05
        pepe[0].node.position = CGPoint(x: 100, y: 1900)
        
        pepe.append(laserDrop())
        pepe[1].node.xScale = 0.05
        pepe[1].node.yScale = 0.05
        pepe[1].node.position = CGPoint(x: 1900, y: 1900)
        
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
        
        pepe.append(CPBoss(level: self))
        pepe[0].shipNode?.position = CGPoint(x: 1000, y: 1000)
        
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
