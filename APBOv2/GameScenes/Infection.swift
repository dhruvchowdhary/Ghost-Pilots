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


class Infection: GameSceneBase {
    override func didBegin(_ contact: SKPhysicsContact) {
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
            print("ship was shot by bullet")
            
            secondNode.removeFromParent()
            liveBullets.remove(at: liveBullets.firstIndex(of: secondNode as! SKSpriteNode)!)
            
            
            let infected = SKAction.setTexture(SKTexture(imageNamed: "apboGreen"))
            secondNode.childNode(withName: "shipnode")!.run(infected)
            
        }
    }

}
