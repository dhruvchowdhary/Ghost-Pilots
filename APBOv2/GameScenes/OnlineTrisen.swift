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
        
        let triPos = 200
        let trisize = 150
        
        let tri1 = SKSpriteNode(imageNamed: "triangle")
        tri1.size = CGSize(width: trisize, height: trisize)
        tri1.physicsBody = SKPhysicsBody(texture: tri1.texture!, size: tri1.size)
        
        tri1.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        tri1.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        tri1.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        tri1.zPosition = 5
        
        tri1.position = CGPoint(x: triPos, y: triPos)
    
        addChild(tri1)
        
        

        tri1.physicsBody?.isDynamic = false
        
        
        
    
        
        
    }
}
