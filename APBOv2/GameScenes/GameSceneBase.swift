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
    
    let borderwidth = 2000
    let borderheight = 800
    
    public override func didMove(to view: SKView) {
        for ship in Global.gameData.shipsToUpdate{
            addChild(ship.spaceShipParent)
        }
        
        // World physics
        physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        
        // Sets up the boundries
       
        shapes()
        
        
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
        
        
        if firstNode.name == "border" && secondNode.name == "playerWeapon" {
                   
                   
                   if let BulletExplosion = SKEmitterNode(fileNamed: "BulletExplosion") {
                       BulletExplosion.position = secondNode.position
          
                       secondNode.removeFromParent()
                       addChild(BulletExplosion)
                  //  borderShape.strokeColor
                    liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
                   }
            
        } 
        
        
    }
    
    func shapes() {
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

        
        
    
    }
}

