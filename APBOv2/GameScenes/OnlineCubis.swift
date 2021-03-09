import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox


class OnlineCubis: GameSceneBase {

    
    override func shapes() {
        
        let borderShape = SKShapeNode()
        
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -borderwidth/2, y: -borderheight/2, width: borderwidth, height: borderheight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor.white
        borderShape.lineWidth = 20
        borderShape.name = "border"
        borderShape.physicsBody = SKPhysicsBody(edgeChainFrom: borderShape.path!)
        
        borderShape.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        
        borderShape.zPosition = 5
    
        addChild(borderShape)
        
        
        let squarepos = 200
        let squaresize = 150
        
        let square1 = SKShapeNode()
        square1.path = UIBezierPath(roundedRect: CGRect(x: squarepos - squaresize / 2, y: squarepos - squaresize / 2, width: squaresize , height: squaresize), cornerRadius: 10).cgPath
        square1.fillColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        square1.strokeColor = UIColor.white
        square1.lineWidth = 10
        square1.physicsBody = SKPhysicsBody(edgeChainFrom: square1.path!)
        square1.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        square1.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        square1.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        square1.zPosition = 5
    
        addChild(square1)
        
        let square2 = SKShapeNode()
        square2.path = UIBezierPath(roundedRect: CGRect(x: -squarepos - squaresize / 2, y: squarepos - squaresize / 2, width: squaresize , height: squaresize), cornerRadius: 10).cgPath
        square2.fillColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        square2.strokeColor = UIColor.white
        square2.lineWidth = 10
        square2.physicsBody = SKPhysicsBody(edgeChainFrom: square2.path!)
        square2.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        square2.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        square2.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        square2.zPosition = 5
    
        addChild(square2)
        
        let square3 = SKShapeNode()
        square3.path = UIBezierPath(roundedRect: CGRect(x: squarepos - squaresize / 2, y: -squarepos - squaresize / 2, width: squaresize , height: squaresize), cornerRadius: 10).cgPath
        square3.fillColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        square3.strokeColor = UIColor.white
        square3.lineWidth = 10
        square3.physicsBody = SKPhysicsBody(edgeChainFrom: square3.path!)
        square3.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        square3.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        square3.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        square3.zPosition = 5
    
        addChild(square3)
        
        let square4 = SKShapeNode()
        square4.path = UIBezierPath(roundedRect: CGRect(x: -squarepos - squaresize / 2, y: -squarepos - squaresize / 2, width: squaresize , height: squaresize), cornerRadius: 10).cgPath
        square4.fillColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        square4.strokeColor = UIColor.white
        square4.lineWidth = 10
        square4.physicsBody = SKPhysicsBody(edgeChainFrom: square4.path!)
        square4.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        square4.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        square4.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        square4.zPosition = 5
    
        addChild(square4)
        
        
        
    }
}
