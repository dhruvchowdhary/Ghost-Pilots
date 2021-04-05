import Foundation
import SpriteKit

class Campaign: SKScene {
    var levelNodes: [SKSpriteNode] = []
    
    override func sceneDidLoad() {
        for node in scene!.children {
            if ((node.name?.contains("pepe")) != nil){
                levelNodes.append(node as! SKSpriteNode)
            }
        }
    }
}
