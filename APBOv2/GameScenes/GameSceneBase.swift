import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox

public class GameSceneBase: SKScene, SKPhysicsContactDelegate {
    let zoomInActionipad = SKAction.scale(to: 1.7, duration: 0.01)
    
    private var pilot = SKSpriteNode()
       private var pilotWalkingFrames: [SKTexture] = []
       let fadeOut = SKAction.fadeOut(withDuration: 1)
          let fadeIn = SKAction.fadeIn(withDuration: 0.5)
    let cameraNode =  SKCameraNode()

    let EnemyThruster = SKEmitterNode(fileNamed: "EnemyThruster")
    var i = 3
    var backButtonNode: MSButtonNode!
    var pauseButtonNode: MSButtonNode!
    var turnButtonNode: MSButtonNode!
    
    var shootButtonNode: MSButtonNode!
    //var tripleButtonNode: MSButtonNode!
    
    var powerSpawn = false
    var restartButtonNode: MSButtonNode!
    var playAgainButtonNode: MSButtonNode!
    var phaseButtonNode: MSButtonNode!
    var ejectButtonNode: MSButtonNode!
    var reviveButtonNode: MSButtonNode!
    
    var poweruprandInt = 0
    var currentShip = "player1"
    let playerHealthBar = SKSpriteNode()
    let cannonHealthBar = SKSpriteNode()
    var playerHP = maxHealth
    var cannonHP = maxHealth
    var isPlayerAlive = true
    var isGameOver = false
    var isPhase = false
    var varisPaused = 1 //1 is false
    var playerShields = 1
    var waveNumber = 0
    var waveCounter = 0
    var levelNumber = 0
    var powerupMode = 0
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    let positions = Array(stride(from: -360, through: 360, by: 90))
    let shot = SKSpriteNode(imageNamed: "bullet")
    let powerup = SKSpriteNode(imageNamed: "tripleshot")
    var pilotForward = false
    var pilotDirection = CGFloat(0.000)
    var count = 0
    var doubleTap = 0;
    let thruster1 = SKEmitterNode(fileNamed: "Thrusters")
    let pilotThrust1 = SKEmitterNode(fileNamed: "PilotThrust")
    let spark1 = SKEmitterNode(fileNamed: "Spark")
    let rotate = SKAction.rotate(byAngle: -1, duration: 0.5)
    var direction = 0.0
    let dimPanel = SKSpriteNode(color: UIColor.black, size: CGSize(width: 20000, height: 10000) )
    
    let points = SKLabelNode(text: "0")
    let pointsLabel = SKLabelNode(text: "Points")
    var enemyPoints = SKLabelNode(text: "+1")
    let highScoreLabel = SKLabelNode(text: "High Score")
    let highScorePoints = SKLabelNode(text: "0")
    var numPoints = 0
    var highScore = 0
    var speedAdd = 0
    
    var rotation = CGFloat(0)
    var numAmmo = 3
    var regenAmmo = false
    let mass = 10.0
    let scaleAction = SKAction.scale(to: 2.2, duration: 0.4)
    
    var lastUpdateTime: Double = 42069.0
    
    public var liveBullets: [SKSpriteNode] = []
    let shape = SKShapeNode()
    
    let borderwidth = 2000
    let borderheight = 800
    
    var pilotmode = false
    
    public override func didMove(to view: SKView) {
        for ship in Global.gameData.shipsToUpdate{
            ship.spaceShipParent.removeFromParent()
            addChild(ship.spaceShipParent)
            ship.spaceShipParent.position = CGPoint(x: frame.midX, y: frame.midY + 300)
        }
        
        // World physics
        physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        
        // Sets up the boundries
        selectmap()
        
        camera = Global.gameData.camera
        
        // Background
        backgroundColor = SKColor(red: 14.0/255, green: 23.0/255, blue: 57.0/255, alpha: 1)
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            particles.zPosition = -100
            addChild(particles)
        }
        
        Global.gameData.gameScene = self
        
        // Dims the screen on game paused
        self.dimPanel.zPosition = 50
        self.dimPanel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(self.dimPanel)
        self.dimPanel.alpha = 0;
        
    for ship in Global.gameData.shipsToUpdate{
        ship.thruster1?.targetNode = self.scene
        ship.pilotThrust1?.targetNode = self.scene
        }
    }
    public override func update(_ currentTime: TimeInterval) {
        if Global.gameData.isBackground {
            lastUpdateTime = 42069.0
            return;
        }
        if lastUpdateTime != 42069.0 {
            for ship in Global.gameData.shipsToUpdate {
                ship.UpdateShip(deltaTime: Double(currentTime) - lastUpdateTime)
                
            }
                
        for bullet in liveBullets {
            bullet.position.x += 10 * cos( bullet.zRotation )
            bullet.position.y += 10 * sin( bullet.zRotation )
            /*
            if abs(bullet.position.x) > (2000 / 2) || abs(bullet.position.y) > (2000 / 2) {
                
                if let BulletExplosion = SKEmitterNode(fileNamed: "BulletExplosion") {
                    BulletExplosion.position = bullet.position
                    

                    bullet.removeFromParent()
                    addChild(BulletExplosion)
                }
         
                liveBullets.remove(at: liveBullets.firstIndex(of: bullet)!)
                }
 */
            }
        }
        lastUpdateTime = Double(currentTime)
        
    }
    
    func loadScene(s: String){
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        guard let scene = SKScene(fileNamed: s) else {
            print ("could not find scene");
            return
        }
        skView.presentScene(scene)
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        print("first Node is   \(String(describing: firstNode.name))")
        print("second Node is  \(String(describing: secondNode.name))")
        
        
        if firstNode.name == "border" && secondNode.name == "playerWeapon" {
                   if let BulletExplosion = SKEmitterNode(fileNamed: "BulletExplosion") {
                       BulletExplosion.position = secondNode.position
                       addChild(BulletExplosion)
                  //  borderShape.strokeColor
                   }
            secondNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
            
            
        }
        else if firstNode.name == "parent" && secondNode.name == "playerWeapon" {
            print("player is shot")
            secondNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
            
        }
        
        
        
        
    }
    
    func cubis() {
        
        
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
        cube1.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        cube1.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        cube1.zPosition = 5
        
        cube1.position = CGPoint(x: cubePos, y: cubePos)
        
        addChild(cube1)
        cube1.name = "border"
        
        let cube2 = SKSpriteNode(imageNamed: "cube")
        cube2.size = CGSize(width: cubesize, height: cubesize)
        cube2.physicsBody = SKPhysicsBody(texture: cube2.texture!, size: cube2.size)
        
        cube2.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        cube2.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        cube2.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        cube2.zPosition = 5
        
        cube2.position = CGPoint(x: -cubePos, y: cubePos)
   
        addChild(cube2)
        cube2.name = "border"
        
        let cube3 = SKSpriteNode(imageNamed: "cube")
        cube3.size = CGSize(width: cubesize, height: cubesize)
        cube3.physicsBody = SKPhysicsBody(texture: cube3.texture!, size: cube3.size)
        
        cube3.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        cube3.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        cube3.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        cube3.zPosition = 5
        
        cube3.position = CGPoint(x: -cubePos, y: -cubePos)
   
        addChild(cube3)
        cube3.name = "border"
        
        let cube4 = SKSpriteNode(imageNamed: "cube")
        cube4.size = CGSize(width: cubesize, height: cubesize)
        cube4.physicsBody = SKPhysicsBody(texture: cube4.texture!, size: cube4.size)
        
        cube4.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        cube4.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        cube4.physicsBody?.contactTestBitMask = CollisionType.player.rawValue  | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        cube4.zPosition = 5
        
        cube4.position = CGPoint(x: cubePos, y: -cubePos)
   
        addChild(cube4)
        cube4.name = "border"
        
        
        cube1.physicsBody!.mass = CGFloat(mass)
        cube2.physicsBody!.mass = CGFloat(mass)
        cube3.physicsBody!.mass = CGFloat(mass)
        cube4.physicsBody!.mass = CGFloat(mass)
    }
    
    func trisen() {
        let borderShape = SKShapeNode()
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -borderwidth/2, y: -borderheight/2, width: borderwidth, height: borderheight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor(red: 255/255, green: 85/255, blue: 85/255, alpha:1)
        borderShape.lineWidth = 20
        borderShape.name = "border"
        borderShape.physicsBody = SKPhysicsBody(edgeChainFrom: borderShape.path!)
        
        borderShape.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        
        borderShape.zPosition = 5
    
        addChild(borderShape)
        
        let triPos = 300
        let triHeight = 359 / 2
        let triWidth = 379 / 2
        
        let tri1 = SKSpriteNode(imageNamed: "triangle")
        tri1.size = CGSize(width: triWidth, height: triHeight)
        tri1.physicsBody = SKPhysicsBody(texture: tri1.texture!, size: tri1.size)
        
        tri1.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        tri1.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        tri1.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        tri1.zPosition = 5
        
        tri1.position = CGPoint(x: 0, y: triPos * Int(sqrt(3)) / 2)
    
        addChild(tri1)
        tri1.name = "border"
        
        
        let tri2 = SKSpriteNode(imageNamed: "triangle")
        tri2.size = CGSize(width: triWidth, height: triHeight)
        tri2.physicsBody = SKPhysicsBody(texture: tri2.texture!, size: tri2.size)
        
        tri2.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        tri2.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        tri2.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        tri2.zPosition = 5
        
        tri2.position = CGPoint(x: -triPos, y: -triPos * Int(sqrt(3)) / 2)
    
        addChild(tri2)
        tri2.name = "border"
        
        let tri3 = SKSpriteNode(imageNamed: "triangle")
        tri3.size = CGSize(width: triWidth, height: triHeight)
        tri3.physicsBody = SKPhysicsBody(texture: tri3.texture!, size: tri3.size)
        
        tri3.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        tri3.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        tri3.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        tri3.zPosition = 5
        
        tri3.position = CGPoint(x: triPos, y: -triPos * Int(sqrt(3)) / 2)
    
        addChild(tri3)
        tri3.name = "border"

       // tri1.physicsBody?.isDynamic = false
        
        tri1.physicsBody!.mass = CGFloat(mass)
        tri2.physicsBody!.mass = CGFloat(mass)
        tri3.physicsBody!.mass = CGFloat(mass)
    }
    
    func hex() {
        let borderShape = SKShapeNode()
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -borderwidth/2, y: -borderheight/2, width: borderwidth, height: borderheight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha:1)
        borderShape.lineWidth = 20
        borderShape.name = "border"
        borderShape.physicsBody = SKPhysicsBody(edgeChainFrom: borderShape.path!)
        
        borderShape.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        
        borderShape.zPosition = 5
    
        addChild(borderShape)
        
        let hexPos = 300
        let hexWidth = 477 / 3
        let hexHeight = 413 / 3
        
       
        
        let hex1 = SKSpriteNode(imageNamed: "hexagon")
        hex1.size = CGSize(width: hexWidth, height: hexHeight)
        hex1.physicsBody = SKPhysicsBody(texture: hex1.texture!, size: hex1.size)
        hex1.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex1.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex1.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex1.zPosition = 5
        hex1.position = CGPoint(x:  hexPos, y: hexPos)
        addChild(hex1)
        hex1.name = "border"
        
        let hex2 = SKSpriteNode(imageNamed: "hexagon")
        hex2.size = CGSize(width: hexWidth, height: hexHeight)
        hex2.physicsBody = SKPhysicsBody(texture: hex2.texture!, size: hex2.size)
        hex2.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex2.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex2.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex2.zPosition = 5
        hex2.position = CGPoint(x: hexPos * 2, y: 0)
        addChild(hex2)
        hex2.name = "border"
        
        let hex3 = SKSpriteNode(imageNamed: "hexagon")
        hex3.size = CGSize(width: hexWidth, height: hexHeight)
        hex3.physicsBody = SKPhysicsBody(texture: hex3.texture!, size: hex3.size)
        hex3.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex3.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex3.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex3.zPosition = 5
        hex3.position = CGPoint(x: hexPos, y: -hexPos)
        addChild(hex3)
        hex3.name = "border"
        
        let hex4 = SKSpriteNode(imageNamed: "hexagon")
        hex4.size = CGSize(width: hexWidth, height: hexHeight)
        hex4.physicsBody = SKPhysicsBody(texture: hex4.texture!, size: hex4.size)
        hex4.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex4.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex4.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex4.zPosition = 5
        hex4.position = CGPoint(x: -hexPos , y: -hexPos)
        addChild(hex4)
        hex4.name = "border"
        
        let hex5 = SKSpriteNode(imageNamed: "hexagon")
        hex5.size = CGSize(width: hexWidth, height: hexHeight)
        hex5.physicsBody = SKPhysicsBody(texture: hex3.texture!, size: hex3.size)
        hex5.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex5.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex5.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex5.zPosition = 5
        hex5.position = CGPoint(x: -hexPos * 2 , y: 0)
        addChild(hex5)
        hex5.name = "border"
        
        let hex6 = SKSpriteNode(imageNamed: "hexagon")
        hex6.size = CGSize(width: hexWidth, height: hexHeight)
        hex6.physicsBody = SKPhysicsBody(texture: hex6.texture!, size: hex6.size)
        hex6.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        hex6.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex6.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        hex6.zPosition = 5
        hex6.position = CGPoint(x: -hexPos, y: hexPos)
        addChild(hex6)
        hex6.name = "border"
        
        hex1.physicsBody!.mass = CGFloat(mass)
        hex2.physicsBody!.mass = CGFloat(mass)
        hex3.physicsBody!.mass = CGFloat(mass)
        hex4.physicsBody!.mass = CGFloat(mass)
        hex5.physicsBody!.mass = CGFloat(mass)
        hex6.physicsBody!.mass = CGFloat(mass)
    }
    
    func empty() {
        let borderShape = SKShapeNode()
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -borderwidth/2, y: -borderheight/2, width: borderwidth, height: borderheight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor.white
        borderShape.lineWidth = 20
        borderShape.name = "border"
        borderShape.physicsBody = SKPhysicsBody(edgeChainFrom: borderShape.path!)
        
        borderShape.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.border.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.border.rawValue
        
        borderShape.zPosition = 5
    
        addChild(borderShape)
    }
    
    func selectmap() {
        // based on map selected variable switch case
        switch Global.gameData.map {
         case "OnlineCubis":
            cubis()
         
         case "OnlineTrisen":
            trisen()
         
         case "OnlineHex":
            hex()
 
        default:
            empty()
        }
    }
}

