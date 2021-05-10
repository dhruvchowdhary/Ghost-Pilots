
import Foundation
import SpriteKit

class CPLevel1 : CPLevelBase {
    
    override func setupCameraZoomIn() {
        zoomScale = 1.75
        zoomOrigin = CGPoint(x: 0, y: 600)
    }
    
    override func createBounds() -> [SKNode] {
        let borderShape = SKShapeNode(circleOfRadius: 700)
        borderShape.position.y += 600
        borderShape.strokeColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        borderShape.lineWidth = 20
        
        return [borderShape]
    }
    
    override func createGameObjects() -> [CPObject] {
        let pepe: [CPObject] = []
        return pepe
    }
    
    override func createPlayerShip() {
        playerShip?.shipNode?.zRotation = CGFloat.pi/2
        playerShip?.hudNode.position = (playerShip?.shipNode!.position)!
    }
    
    override func createEnemyShips() -> [CPSpaceshipBase] {
        var pepe: [CPSpaceshipBase] = []
        
        let ship = CPChaserSpaceship(level: self)
        ship.shipNode?.position = CGPoint(x: 200, y: 1000)
        pepe.append(ship)
        
        let ship2 = CPChaserSpaceship(level: self)
        ship2.shipNode?.position = CGPoint(x: -200, y: 1000)
        pepe.append(ship2)
        
//        for i in 0..<10{
//            pepe.append(CPChaserSpaceship(level: self))
//        }
//
//        for i in 0..<5{
//            pepe[i].shipNode?.position.x = 900
//            pepe[i].shipNode?.position.y = 200 * CGFloat(i) + 600
//            pepe[i].shipNode?.zRotation = -CGFloat.pi * 3/2
//        }
//
//        for i in 5..<10{
//            pepe[i].shipNode?.position.x = 100
//            pepe[i].shipNode?.position.y = 200 * CGFloat(i - 5) + 600
//            pepe[i].shipNode?.zRotation = CGFloat.pi * 3/2
//        }
        
        
        return pepe
    }
    
    override func createCheckpoints() -> [CPCheckpoint] {
        var pepe: [CPCheckpoint] = []
        
        let endpoint = CPCheckpoint(pos: CGPoint(x: 0,y: 1100))
        endpoint.isEndpoint = true
        pepe.append(endpoint)
        
        
        return pepe
    }
    
}
