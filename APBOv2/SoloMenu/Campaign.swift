import Foundation
import SpriteKit

class Campaign: SKScene {
    var levelNodes: [SKSpriteNode] = []
    var swipeGuesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
    
    override func sceneDidLoad() {
        for node in scene!.children {
            if ((node.name?.contains("pepe")) != nil){
                levelNodes.append(node as! SKSpriteNode)
            }
        }
        
        swipeGuesture.direction = .
        //Global.gameData.skView.addGestureRecognizer(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
    }
    
    func presentScene(Scene: String){
        //Global.gameData.skView.removeGestureRecognizer(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer){
        
    }
    
}
