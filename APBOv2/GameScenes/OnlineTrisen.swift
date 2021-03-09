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
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        
        borderShape.zPosition = 5
    
        addChild(borderShape)
        
        let triPos = 300
        let triHeight = 359 / 2
        let triWidth = 379 / 2
        
        let tri1 = SKSpriteNode(imageNamed: "triangle")
        tri1.size = CGSize(width: triWidth, height: triHeight)
        tri1.physicsBody = SKPhysicsBody(texture: tri1.texture!, size: tri1.size)
        
        tri1.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        tri1.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        tri1.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        tri1.zPosition = 5
        
        tri1.position = CGPoint(x: 0, y: triPos * Int(sqrt(3)) / 2)
    
        addChild(tri1)
        tri1.name = "border"
        
        
        let tri2 = SKSpriteNode(imageNamed: "triangle")
        tri2.size = CGSize(width: triWidth, height: triHeight)
        tri2.physicsBody = SKPhysicsBody(texture: tri2.texture!, size: tri2.size)
        
        tri2.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        tri2.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        tri2.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        tri2.zPosition = 5
        
        tri2.position = CGPoint(x: -triPos, y: -triPos * Int(sqrt(3)) / 2)
    
        addChild(tri2)
        tri2.name = "border"
        
        let tri3 = SKSpriteNode(imageNamed: "triangle")
        tri3.size = CGSize(width: triWidth, height: triHeight)
        tri3.physicsBody = SKPhysicsBody(texture: tri3.texture!, size: tri3.size)
        
        tri3.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        tri3.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        tri3.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        tri3.zPosition = 5
        
        tri3.position = CGPoint(x: triPos, y: -triPos * Int(sqrt(3)) / 2)
    
        addChild(tri3)
        tri3.name = "border"
        
        

        tri1.physicsBody?.isDynamic = false
        
        
        
    
        
        
    }
}
