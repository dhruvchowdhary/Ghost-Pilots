
import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox

class GameSceneOnline: GameSceneBase {
    
    
    override func setUp() {
        Global.gameData.gameState = GameStates.FFA
        Global.multiplayerHandler.ListenForEliminatedChanges()
        if !Global.gameData.isHost{
            Global.multiplayerHandler.ListenToGeometry()
        }
    }
    
    override func didBegin(_ contact: SKPhysicsContact) {
        if !Global.gameData.isHost{
            Global.multiplayerHandler.ListenToGeometry()
        }
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }

        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]

        //print("first Node is   \(String(describing: firstNode.name))")
     //   print("second Node is  \(String(describing: secondNode.name))")


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
            print("ship was shot by bullet")
            
            secondNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/EliminatedList/\(Global.playerData.playerID)", Value: "true")

        }
        
        else if firstNode.name == "playerWeapon" && secondNode.name == "remoteparent" {
            print("ship was shot by bullet")
            firstNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: firstNode as! SKSpriteNode)!)
            
            
            
        }

    }
}
