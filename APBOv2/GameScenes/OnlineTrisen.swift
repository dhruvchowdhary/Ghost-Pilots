import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox


class OnlineTrisen: GameSceneBase {

    
    
    
    override func shapes() {
        
        let borderShape = SKShapeNode()
        
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -borderwidth/2, y: -borderheight/2, width: borderwidth, height: borderheight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor(red: 255/255, green: 85/255, blue: 85/255, alpha:1)
        borderShape.lineWidth = 20
        borderShape.name = "border"
        borderShape.physicsBody = SKPhysicsBody(edgeChainFrom: borderShape.path!)
        
        borderShape.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        
        borderShape.zPosition = 5
    
        addChild(borderShape)
        
        
    
        
    
        let path = UIBezierPath()
         
        path.addLine(to: CGPoint(x: -57.74, y: -100))
        path.addLine(to: CGPoint(x: 57.4 * 2, y: -100))
        path.addLine(to: CGPoint(x: 57.4, y: 0))
           
        path.close()
     
     
        let triangle1 = SKShapeNode(path: path.cgPath)
        triangle1.position.x = 0
        triangle1.position.y = 0
        triangle1.strokeColor = UIColor.white
        triangle1.zPosition = 5
        triangle1.lineWidth = 3
        triangle1.alpha = 1
        triangle1.fillColor = UIColor(red: 255/255, green: 85/255, blue: 85/255, alpha:1)
        addChild(triangle1)
        

    
        
        
    }
}
