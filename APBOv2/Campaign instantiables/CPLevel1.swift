import Foundation
import SpriteKit

class CPLevel1 : CPLevelBase {
    
    override func didMove(to view: SKView) {
        let borderShape = SKShapeNode()
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -1000, y: -1000, width: 2000, height: 2000), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        borderShape.lineWidth = 20
        borderShape.name = "border"
        borderShape.physicsBody = SKPhysicsBody(edgeChainFrom: borderShape.path!)
        
        borderShape.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        
        borderShape.zPosition = 5
        
        boundriesNode = borderShape
        
        playerShip = CPSpaceshipBase(spaceshipSetup: CPSpaceshipSetup(imageNamed: "Player"))
        ManualSetup()
    }
    
}
