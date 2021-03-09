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
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        
        borderShape.zPosition = 5
    
        addChild(borderShape)
        
        
        let hexPos = 300
        let hexWidth = 477 / 3
        let hexHeight = 413 / 3
        
        let v = 10
        
        let hex1 = SKSpriteNode(imageNamed: "hexagon")
        hex1.size = CGSize(width: hexWidth, height: hexHeight)
        hex1.physicsBody = SKPhysicsBody(texture: hex1.texture!, size: hex1.size)
        hex1.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex1.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex1.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex1.zPosition = 5
        hex1.position = CGPoint(x:  hexPos, y: hexPos)
        addChild(hex1)
        hex1.name = "border"
        
        let hex2 = SKSpriteNode(imageNamed: "hexagon")
        hex2.size = CGSize(width: hexWidth, height: hexHeight)
        hex2.physicsBody = SKPhysicsBody(texture: hex2.texture!, size: hex2.size)
        hex2.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex2.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex2.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex2.zPosition = 5
        hex2.position = CGPoint(x: hexPos * 2, y: 0)
        addChild(hex2)
        hex2.name = "border"
        
        let hex3 = SKSpriteNode(imageNamed: "hexagon")
        hex3.size = CGSize(width: hexWidth, height: hexHeight)
        hex3.physicsBody = SKPhysicsBody(texture: hex3.texture!, size: hex3.size)
        hex3.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex3.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex3.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex3.zPosition = 5
        hex3.position = CGPoint(x: hexPos, y: -hexPos)
        addChild(hex3)
        hex3.name = "border"
        
        let hex4 = SKSpriteNode(imageNamed: "hexagon")
        hex4.size = CGSize(width: hexWidth, height: hexHeight)
        hex4.physicsBody = SKPhysicsBody(texture: hex4.texture!, size: hex4.size)
        hex4.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex4.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex4.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex4.zPosition = 5
        hex4.position = CGPoint(x: -hexPos , y: -hexPos)
        addChild(hex4)
        hex4.name = "border"
        
        let hex5 = SKSpriteNode(imageNamed: "hexagon")
        hex5.size = CGSize(width: hexWidth, height: hexHeight)
        hex5.physicsBody = SKPhysicsBody(texture: hex3.texture!, size: hex3.size)
        hex5.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex5.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex5.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex5.zPosition = 5
        hex5.position = CGPoint(x: -hexPos * 2 , y: 0)
        addChild(hex5)
        hex5.name = "border"
        
        let hex6 = SKSpriteNode(imageNamed: "hexagon")
        hex6.size = CGSize(width: hexWidth, height: hexHeight)
        hex6.physicsBody = SKPhysicsBody(texture: hex6.texture!, size: hex6.size)
        hex6.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex6.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex6.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        hex6.zPosition = 5
        hex6.position = CGPoint(x: -hexPos, y: hexPos)
        addChild(hex6)
        hex6.name = "border"
        
        
        
        
    }
}
