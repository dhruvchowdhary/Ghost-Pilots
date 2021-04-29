import Foundation
import SpriteKit

class CPLevel1 : CPLevelBase {
    
    override func createBounds() -> [SKNode] {
        let borderShape = SKShapeNode()
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -100, y: -200, width: 2000, height: 2000), cornerRadius: 40).cgPath
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        borderShape.lineWidth = 20
        
        return [borderShape]
    }
    
    override func createGameObjects() -> [CPObject] {
        let pepe: [CPObject] = []
        return pepe
    }
    
    override func createEnemyShips() -> [CPSpaceshipBase] {
        var pepe: [CPSpaceshipBase] = []
        
        for _ in 0..<20{
            pepe.append(CPChaserSpaceship(level: self))
        }
        
        pepe[0].shipNode?.position = CGPoint(x: 500, y: 500)
        pepe[1].shipNode?.position = CGPoint(x: 600, y: 500)
        pepe[2].shipNode?.position = CGPoint(x: 700, y: 500)
        pepe[3].shipNode?.position = CGPoint(x: 500, y: 1000)
        pepe[4].shipNode?.position = CGPoint(x: 600, y: 1000)
        pepe[5].shipNode?.position = CGPoint(x: 700, y: 1000)
        
        
        return pepe
    }
    
    override func createCheckpoints() -> [CPCheckpoint] {
        var pepe: [CPCheckpoint] = []
        
        let endpoint = CPCheckpoint(pos: CGPoint(x: 1700,y: 1700), texture: "player")
        endpoint.isEndpoint = true
        pepe.append(endpoint)
        
        
        return pepe
    }
}
