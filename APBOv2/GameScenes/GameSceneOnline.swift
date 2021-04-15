
import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox

class GameSceneOnline: GameSceneBase {
    
    
    override func setUp() {
        Global.gameData.gameState = GameStates.FFA
        Global.multiplayerHandler.ListenForPilotChanges()
        Global.multiplayerHandler.ListenForEliminatedChanges()
        if !Global.gameData.isHost{
            Global.multiplayerHandler.ListenToGeometry()
        }
    }
    
    override func SetPosition() {
        for i in 0..<Global.gameData.shipsToUpdate.count {
            if Global.gameData.shipsToUpdate[i].playerID == Global.playerData.playerID {
                switch i {
                case 0:
                    Global.gameData.playerShip?.spaceShipParent.position = topLeft
                case 1:
                    Global.gameData.playerShip?.spaceShipParent.position = bottomRight
                    Global.gameData.playerShip?.spaceShipNode.zRotation = .pi
                case 2:
                    Global.gameData.playerShip?.spaceShipParent.position = topRight
                    Global.gameData.playerShip?.spaceShipNode.zRotation = .pi*3/2
                case 3:
                    Global.gameData.playerShip?.spaceShipParent.position = bottomLeft
                    Global.gameData.playerShip?.spaceShipNode.zRotation = .pi/2
                case 4:
                    Global.gameData.playerShip?.spaceShipParent.position = topMiddle
                    Global.gameData.playerShip?.spaceShipNode.zRotation = .pi*3/2
                case 5:
                    Global.gameData.playerShip?.spaceShipParent.position = bottomMiddle
                    Global.gameData.playerShip?.spaceShipNode.zRotation = .pi/2
                default:
                    Global.gameData.playerShip?.spaceShipParent.position = topLeft
                }
            }
        }
        for ship in Global.gameData.shipsToUpdate {
            ship.spaceShipParent.removeFromParent()
            addChild(ship.spaceShipParent)
            ship.spaceShipParent.physicsBody!.mass = 10
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }

        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]

      //  print("first Node is   \(String(describing: firstNode.name))")
      //  print("second Node is  \(String(describing: secondNode.name))")


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
//            print("my ship was shot by bullet")
            
            secondNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
            
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PilotList/\(Global.playerData.playerID)", Value: "true")
            firstNode.name = "pilot"
        }
        
        else if firstNode.name == "pilot" && secondNode.name == "playerWeapon" {
//            print("my pilot was shot by bullet")
            
            secondNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
            
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/EliminatedList/\(Global.playerData.playerID)", Value: "true")

        }
        else if firstNode.name == "pilot" && secondNode.name == "remoteparent" {
//            print("my pilot was run over by ship")
            
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/EliminatedList/\(Global.playerData.playerID)", Value: "true")

        }
        
        else if firstNode.name == "playerWeapon" && secondNode.name == "remoteparent" {
//            print("I shot a ship")
            firstNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: firstNode as! SKSpriteNode)!)
            
        }

    }
}
