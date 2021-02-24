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
    
    let scaleAction = SKAction.scale(to: 2.2, duration: 0.4)
    
    var lastUpdateTime: Double = 42069.0
    
    public var liveBullets: [SKSpriteNode] = []
    let shape = SKShapeNode()
    
    public override func didMove(to view: SKView) {
        for ship in Global.gameData.shipsToUpdate{
            if (ship.shipSprite.parent != nil) {
                addChild(ship.shipSprite.parent!.parent!.parent!)
                
            } else {
                addChild(ship.shipSprite)
            }
        }
        
        // World physics
        physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        
        // Sets up the boundries
        let borderShape = SKShapeNode()
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -1792/2-1000, y: -828/2, width: 1792+2000, height: 828), cornerRadius: 40).cgPath
        borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = .clear
        borderShape.strokeColor = UIColor.blue
        borderShape.lineWidth = 10
        borderShape.name = "border"
        borderShape.physicsBody = SKPhysicsBody(edgeChainFrom: borderShape.path!)
        
        borderShape.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        
        borderShape.zPosition = 5
        //borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue
        //borderShape.physicsBody!.contactTestBitMask = CollisionType.player.rawValue
        addChild(borderShape)
        
        
        
        // Background
        backgroundColor = SKColor(red: 14.0/255, green: 23.0/255, blue: 57.0/255, alpha: 1)
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            particles.zPosition = 1
            addChild(particles)
        }
        
        Global.gameData.gameScene = self
        
        // Dims the screen on game paused
        self.dimPanel.zPosition = 50
        self.dimPanel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(self.dimPanel)
        self.dimPanel.alpha = 0
        
        camera = Global.gameData.camera
        // Button Setup
    }
    public override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime != 42069.0 {
            for ship in Global.gameData.shipsToUpdate {
                ship.UpdateShip(deltaTime: Double(currentTime) - lastUpdateTime)
            }
        }
        lastUpdateTime = Double(currentTime)
        
        for bullet in liveBullets {
            bullet.position.x += 100 * cos( bullet.zRotation )
            bullet.position.y += 100 * sin( bullet.zRotation )
            
            if abs(bullet.position.x) > 2000 {
                bullet.removeFromParent()
                liveBullets.remove(at: liveBullets.firstIndex(of: bullet)!)
            }
        }
        
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
}

