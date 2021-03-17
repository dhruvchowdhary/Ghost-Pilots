
import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox


class AstroBall: GameSceneBase {
    var framesTilPos = 10
    var astroball: SKSpriteNode?
    let astroballRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Astroball")
    var redHP = 5
    var blueHP = 5
    
   var redHPLabel = SKLabelNode(text: "0")
    var blueHPLabel = SKLabelNode(text: "0")
     
    public override func didMove(to view: SKView) {
        
        
        addChild(redHPLabel)
        addChild(blueHPLabel)
        
        redHPLabel.position = CGPoint(x: frame.midX + 600, y: frame.midY)
        redHPLabel.zPosition = 100
        redHPLabel.fontColor = UIColor(red: 255/255, green: 85/255, blue: 85/255, alpha:1)
        redHPLabel.fontSize = 95
        redHPLabel.fontName = "AvenirNext-Bold"
        
        redHPLabel.name = "redHPLabel"
       
        
        blueHPLabel.position = CGPoint(x: frame.midX - 600, y: frame.midY)
        blueHPLabel.zPosition = 100
        blueHPLabel.fontColor =  UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        blueHPLabel.fontSize = 95
        blueHPLabel.fontName = "AvenirNext-Bold"
        
        blueHPLabel.name = "blueHPLabel"
      
        
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/redHP", Value: String(redHP))
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/blueHP", Value: String(blueHP))
        
        Global.gameData.gameState = GameStates.AstroBall
        Global.multiplayerHandler.SetGeoRefs()
        
        if !Global.gameData.isHost{
            Global.multiplayerHandler.ListenToAstroball()
            Global.multiplayerHandler.ListenToGeometry()
        }
        
        
        for ship in Global.gameData.shipsToUpdate{
            ship.spaceShipParent.removeFromParent()
            addChild(ship.spaceShipParent)
            ship.spaceShipParent.physicsBody!.mass = 10
            ship.spaceShipParent.position = CGPoint(x: loadShipPosX, y: loadShipPosY)
            loadShipPosX = loadShipPosX + 50
            
            if !Global.gameData.isHost {
                
            }
        }
        // World physics
        //physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
        
        // Sets up the boundries
        selectmap()
        loadBall()
        
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
    //    ship.pilotThrust1?.targetNode = self.scene
        }
    }
    
    
    public override func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
      //  print("first Node is   \(String(describing: firstNode.name))")
       // print("second Node is  \(String(describing: secondNode.name))")
        
        
        if (firstNode.name == "border" || firstNode.name == "astroball" || firstNode.name == "blueGoal" || firstNode.name == "redGoal") && secondNode.name == "playerWeapon" {
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
        
        else if firstNode.name == "parent" && secondNode.name == "playerWeapon" {
            print("player is shot")
            secondNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
            
        }
        
        else if firstNode.name == "astroball" && secondNode.name == "redGoal" {
         
           if Global.gameData.isHost {
                DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/redHP", Value: String(redHP - 1))
            }
            redHP = redHP - 1
        //
            
        }
        
        else if firstNode.name == "astroball" && secondNode.name == "blueGoal" {
        if Global.gameData.isHost {
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/blueHP", Value: String(blueHP - 1))
        }
        blueHP = blueHP - 1
    
        
        }
    }
    
    func setColorHP(redHPString: String, blueHPString: String) {

        blueHPLabel.text = "\(blueHPString)"
        redHPLabel.text = "\(redHPString)"
        
       print("labels set")
    }
    
    func loadBall() {
        let astroball = SKSpriteNode(imageNamed: "asteroid")
        self.astroball = astroball
    
        astroball.position = CGPoint(x: frame.midX, y: frame.midY)
        
        astroball.name = "astroball"
        astroball.size = CGSize(width: 200, height: 200)
        astroball.physicsBody = SKPhysicsBody(texture: astroball.texture!, size: astroball.size)
        
        astroball.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        astroball.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        astroball.physicsBody!.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        
        astroball.zPosition = 4
        astroball.physicsBody!.mass = 1
        astroball.physicsBody!.friction = 0
        astroball.physicsBody!.linearDamping = 0
        astroball.physicsBody!.angularDamping = 0
        astroball.physicsBody!.restitution = 1
        astroball.physicsBody!.isDynamic = true
    
        addChild(astroball)
        
        let blueGoal = SKSpriteNode(imageNamed: "blueGoal")
        
        
        blueGoal.zPosition = 5
        blueGoal.name = "blueGoal"
        
        blueGoal.physicsBody = SKPhysicsBody(texture: blueGoal.texture!, size: blueGoal.texture!.size())
        
        blueGoal.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        blueGoal.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        blueGoal.physicsBody!.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        
        
        blueGoal.position = CGPoint(x: -800, y: frame.midY)
        
        blueGoal.physicsBody?.isDynamic = false
    
        addChild(blueGoal)
        
        let redGoal = SKSpriteNode(imageNamed: "redGoal")
        
        
        redGoal.zPosition = 5
        redGoal.name = "redGoal"
        
        redGoal.physicsBody = SKPhysicsBody(texture: redGoal.texture!, size: redGoal.texture!.size())
        
        redGoal.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        redGoal.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        redGoal.physicsBody!.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue | CollisionType.border.rawValue
        
        
        redGoal.position = CGPoint(x: 800, y: frame.midY)
        
        redGoal.physicsBody?.isDynamic = false
    
        addChild(redGoal)
        
       
    
    }
    
    override func uniqueGamemodeUpdate() {
        let c = Global.gameData.playerShip?.spaceShipHud
        let y = (astroball!.position.y - Global.gameData.playerShip!.spaceShipParent.position.y) / 3
        let x = (astroball!.position.x - Global.gameData.playerShip!.spaceShipParent.position.x) / 3
        c?.position.x = x
        c?.position.y = y
        
        if Global.gameData.isHost {
            if framesTilPos < 0 {
                let payload = Payload(posX: astroball!.position.x, posY: astroball!.position.y, angleRad: astroball!.zRotation, velocity: astroball!.physicsBody!.velocity)
                let data = try! JSONEncoder().encode(payload)
                let json = String(data: data, encoding: .utf8)!
                astroballRef.setValue(json)
                
                for g in 0..<geo.count {
                    let payload = Payload(posX: geo[g].position.x, posY: geo[g].position.y, angleRad: geo[g].zRotation, velocity: geo[g].physicsBody!.velocity)
                    let data = try! JSONEncoder().encode(payload)
                    let json = String(data: data, encoding: .utf8)!
                    Global.multiplayerHandler.geoRefs[g].setValue(json)
                }
                
                framesTilPos = 2
            } else {
                let payload = Payload(posX: nil, posY: nil, angleRad: astroball!.zRotation, velocity: astroball!.physicsBody!.velocity)
                let data = try! JSONEncoder().encode(payload)
                let json = String(data: data, encoding: .utf8)!
                astroballRef.setValue(json)
                
                for g in 0..<geo.count {
                    let payload = Payload(posX: nil, posY: nil, angleRad: geo[g].zRotation, velocity: geo[g].physicsBody!.velocity)
                    let data = try! JSONEncoder().encode(payload)
                    let json = String(data: data, encoding: .utf8)!
                    Global.multiplayerHandler.geoRefs[g].setValue(json)
                }
                
                framesTilPos -= 1
            }
            
            
        }
    }
}
