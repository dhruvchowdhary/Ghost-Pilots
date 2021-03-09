import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox


class OnlineHex: GameSceneBase {

    
    override func shapes() {
        
        let borderShape = SKShapeNode()
        
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -borderwidth/2, y: -borderheight/2, width: borderwidth, height: borderheight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha:1)
        borderShape.lineWidth = 20
        borderShape.name = "border"
        borderShape.physicsBody = SKPhysicsBody(edgeChainFrom: borderShape.path!)
        
        borderShape.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        
        borderShape.zPosition = 5
    
        addChild(borderShape)
        
        
        let hexPos = 200
        let hexsize = 150
        
        let hex1 = SKSpriteNode(imageNamed: "hexagon")
        
        hex1.physicsBody = SKPhysicsBody(texture: hex1.texture!, size: hex1.texture!.size())
        
        hex1.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex1.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        hex1.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        hex1.zPosition = 5
        
        hex1.position = CGPoint(x: hexPos, y: hexPos)
        hex1.size = CGSize(width: hexsize, height: hexsize)
        addChild(hex1)
        
        
        
        
    }
}
