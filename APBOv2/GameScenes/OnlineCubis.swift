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
        borderShape.strokeColor = UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        borderShape.lineWidth = 20
        borderShape.name = "border"
        borderShape.physicsBody = SKPhysicsBody(edgeChainFrom: borderShape.path!)
        
        borderShape.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        
        borderShape.zPosition = 5
    
        addChild(borderShape)
        
        let cubePos = 200
        let cubesize = 100
        
        let cube1 = SKSpriteNode(imageNamed: "cube")
        cube1.size = CGSize(width: cubesize, height: cubesize)
        cube1.physicsBody = SKPhysicsBody(texture: cube1.texture!, size: cube1.size)
        
        cube1.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        cube1.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        cube1.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        cube1.zPosition = 5
        
        cube1.position = CGPoint(x: cubePos - cubePos / 2, y: cubePos - cubePos / 2)
   
        addChild(cube1)
        cube1.name = "border"
        
        let cube2 = SKSpriteNode(imageNamed: "cube")
        cube2.size = CGSize(width: cubesize, height: cubesize)
        cube2.physicsBody = SKPhysicsBody(texture: cube2.texture!, size: cube2.size)
        
        cube2.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        cube2.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        cube2.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        cube2.zPosition = 5
        
        cube2.position = CGPoint(x: -cubePos - cubePos / 2, y: cubePos - cubePos / 2)
   
        addChild(cube2)
        cube2.name = "border"
        
        let cube3 = SKSpriteNode(imageNamed: "cube")
        cube3.size = CGSize(width: cubesize, height: cubesize)
        cube3.physicsBody = SKPhysicsBody(texture: cube3.texture!, size: cube3.size)
        
        cube3.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        cube3.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        cube3.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        cube3.zPosition = 5
        
        cube3.position = CGPoint(x: -cubePos - cubePos / 2, y: -cubePos - cubePos / 2)
   
        addChild(cube3)
        cube3.name = "border"
        
        let cube4 = SKSpriteNode(imageNamed: "cube")
        cube4.size = CGSize(width: cubesize, height: cubesize)
        cube4.physicsBody = SKPhysicsBody(texture: cube4.texture!, size: cube4.size)
        
        cube4.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        cube4.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        cube4.physicsBody?.contactTestBitMask = CollisionType.player.rawValue  | CollisionType.bullet.rawValue
        cube4.zPosition = 5
        
        cube4.position = CGPoint(x: cubePos - cubePos / 2, y: -cubePos - cubePos / 2)
   
        addChild(cube4)
        cube4.name = "border"
        
        
        
        
        /*
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
        
        */
        
    }
}
