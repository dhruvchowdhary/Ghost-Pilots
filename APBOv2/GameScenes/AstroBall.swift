
import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox


class AstroBall: GameSceneBase {
    var framesTilPos = 10
    var astroball: SKSpriteNode?
    let astroballRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Astroball")
    var redHP = 9
    var blueHP = 9
    var redHPLabel = SKLabelNode(text: "9")
    var blueHPLabel = SKLabelNode(text: "9")
  
    
    override func setUp() {
        Global.multiplayerHandler.ListenForAstroBallChanges()
        redHPLabel.zPosition = 100
        redHPLabel.fontColor = UIColor(red: 255/255, green: 85/255, blue: 85/255, alpha:1)
        redHPLabel.fontSize = 95
        redHPLabel.position = CGPoint(x: frame.midX + 625, y: frame.midY)
        redHPLabel.fontName = "AvenirNext-Bold"
        redHPLabel.text = String(redHP)
        redHPLabel.name = "redHPLabel"
        addChild(redHPLabel)
        
        loadBall()
        
        blueHPLabel.zPosition = 100
        blueHPLabel.fontColor =  UIColor(red: 0/255, green: 121/255, blue: 255/255, alpha:1)
        blueHPLabel.fontSize = 95
        blueHPLabel.position = CGPoint(x: frame.midX - 625, y: frame.midY)
        blueHPLabel.fontName = "AvenirNext-Bold"
        blueHPLabel.text = String(blueHP)
        blueHPLabel.name = "blueHPLabel"
        addChild(blueHPLabel)
      
        if Global.gameData.isHost {
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/redHP", Value: String(redHP))
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/blueHP", Value: String(blueHP))
        }
        
        Global.gameData.gameState = GameStates.AstroBall
        
        if !Global.gameData.isHost{
            Global.multiplayerHandler.ListenToAstroball()
            Global.multiplayerHandler.ListenToGeometry()
        }
    }
    override func SetPosition() {
        print(Global.playerData.color)
        if Global.playerData.color == "apboBlue" {
            Global.gameData.playerShip?.spaceShipParent.position = CGPoint(x: -800, y: 300)
        } else { //color should be "player"
            Global.gameData.playerShip?.spaceShipNode.zRotation = .pi
            Global.gameData.playerShip?.spaceShipParent.position = CGPoint(x: 800, y: 300)
        }
        for ship in Global.gameData.shipsToUpdate {
            ship.spaceShipParent.removeFromParent()
            addChild(ship.spaceShipParent)
            ship.spaceShipParent.physicsBody!.mass = 10
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
        
        
        if (((firstNode.name == "border" || firstNode.name == "astroball" || firstNode.name == "blueGoal") && secondNode.name == "playerWeapon") || (firstNode.name == "playerWeapon" && secondNode.name == "redGoal")) {
                  
            if secondNode.name == "playerWeapon" {
                
                if let BulletExplosion = SKEmitterNode(fileNamed: "BulletExplosion") {
                    BulletExplosion.position = secondNode.position
                    addChild(BulletExplosion)
               //  borderShape.strokeColor
                }
                
                secondNode.removeFromParent()
                liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
                
                
            } else {
                
                if let BulletExplosion = SKEmitterNode(fileNamed: "BulletExplosion") {
                    BulletExplosion.position = firstNode.position
                    addChild(BulletExplosion)
               //  borderShape.strokeColor
                }
                
                firstNode.removeFromParent()
                liveBullets.remove(at: liveBullets.firstIndex(of: firstNode as! SKSpriteNode)!)
            }
            
            
        }
        else if firstNode.name == "parent" && secondNode.name == "playerWeapon" {
//            print("player is shot")
            secondNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
            
            
        } else if firstNode.name == "astroball" && secondNode.name == "redGoal" {
            
            if Global.gameData.isHost {
                DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/redHP", Value: String(redHP - 1))
            }
            redHP = redHP - 1
            self.astroball?.run(SKAction.playSoundFileNamed("astroballGoalHit", waitForCompletion: false))
            
        } else if firstNode.name == "astroball" && secondNode.name == "blueGoal" {
            if Global.gameData.isHost {
                DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/AstroBall/blueHP", Value: String(blueHP - 1))
            }
            blueHP = blueHP - 1
            self.astroball?.run(SKAction.playSoundFileNamed("astroballGoalHit", waitForCompletion: false))
            
        }
//        if firstNode.name == "astroball"{
//            if Global.gameData.isHost {
//                if framesTilPos < 0 {
//                    let payload = Payload(posX: astroball!.position.x, posY: astroball!.position.y, angleRad: astroball!.zRotation, velocity: astroball!.physicsBody!.velocity)
//                    let data = try! JSONEncoder().encode(payload)
//                    let json = String(data: data, encoding: .utf8)!
//                    astroballRef.setValue(json)
//
//                    for g in 0..<geo.count {
//                        let payload = Payload(posX: geo[g].position.x, posY: geo[g].position.y, angleRad: geo[g].zRotation, velocity: geo[g].physicsBody!.velocity)
//                        let data = try! JSONEncoder().encode(payload)
//                        let json = String(data: data, encoding: .utf8)!
//                        Global.multiplayerHandler.geoRefs[g].setValue(json)
//                    }
//
//                    framesTilPos = 0
//                } else {
//                    framesTilPos -= 1
//                }
//            }
//
//        }
    }
    
    func setColorHP(redHPString: String, blueHPString: String) {
        blueHPLabel.text = "\(blueHPString)"
        redHPLabel.text = "\(redHPString)"
//       print("labels set")
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
        astroball.physicsBody!.mass = 3
        astroball.physicsBody!.friction = 0
        astroball.physicsBody!.linearDamping = 0
        astroball.physicsBody!.angularDamping = 0
        astroball.physicsBody!.restitution = 1.1
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

                framesTilPos = 0
            } else {
//                let payload = Payload(posX: nil, posY: nil, angleRad: astroball!.zRotation, velocity: astroball!.physicsBody!.velocity)
//                let data = try! JSONEncoder().encode(payload)
//                let json = String(data: data, encoding: .utf8)!
//                astroballRef.setValue(json)
//
//                for g in 0..<geo.count {
//                    let payload = Payload(posX: nil, posY: nil, angleRad: geo[g].zRotation, velocity: geo[g].physicsBody!.velocity)
//                    let data = try! JSONEncoder().encode(payload)
//                    let json = String(data: data, encoding: .utf8)!
//                    Global.multiplayerHandler.geoRefs[g].setValue(json)
//                }

                framesTilPos -= 1
            }


        }
    }
}
