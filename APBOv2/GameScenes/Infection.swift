//
//  Infection.swift
//  APBOv2
//
//  Created by 64005832 on 3/10/21.
//  Copyright © 2021 Dhruv Chowdhary. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox
import Firebase

var gameOver = false

class Infection: GameSceneBase {
    var infectedRef: DatabaseReference?
    
    override func setUp() {
        Global.gameData.gameState = GameStates.Infection
        Global.multiplayerHandler.ListenForInfectedChanges()
        if !Global.gameData.isHost{
            Global.multiplayerHandler.ListenToGeometry()
        }
    }
    
    override func SetPosition() {
        if Global.playerData.color != "apboGreen" {
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
        } else { //color should be "apboGreen"
            Global.gameData.playerShip?.spaceShipNode.zRotation = CGFloat.random(in: 0 ... .pi*2)
            Global.gameData.playerShip?.spaceShipParent.position = CGPoint(x: 0, y: 0)
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

        //print("first Node is   \(String(describing: firstNode.name))")
     //   print("second Node is  \(String(describing: secondNode.name))")


        if firstNode.name == "border" && secondNode.name == "playerWeapon" {
                   if let BulletExplosion = SKEmitterNode(fileNamed: "BulletExplosion") {
                       BulletExplosion.position = secondNode.position
                       addChild(BulletExplosion)
                   }
            secondNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
            
            
        }
        else if firstNode.name == "parent" && secondNode.name == "playerWeapon" {
//            print("ship was shot by bullet")
            
            secondNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/InfectedList/\(Global.playerData.playerID)", Value: "true")
        //    ListenForInfectedChanges(playerID: Global.playerData.playerID!, secondNode: secondNode)
           // Global.multiplayerHandler.ListenForInfectedChanges(username: Global.playerData.username, secondNode: firstNode)
            
        }
        
        else if firstNode.name == "playerWeapon" && secondNode.name == "remoteparent" {
//            print("ship was shot by bullet")
            firstNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: firstNode as! SKSpriteNode)!)
            
            
         //   Global.multiplayerHandler.ListenForInfectedChanges(username: Global.playerData.username, secondNode: secondNode)
    //        if remoteparent isin infectedlist {
     //       }
            
        }
        /*
        
        else if firstNode.name == "parent" && secondNode.name == "remoteparent" {
            print("ship was shot by bullet")
            
        
            let infected = SKAction.setTexture(SKTexture(imageNamed: "apboGreen"))
            firstNode.childNode(withName: "shipnode")!.run(infected)
            
        }
 */
    }
}
