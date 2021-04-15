import Foundation
import SpriteKit

class CPCollisionHandler {
    var ricoCount = 0
    
    public func collision(nodeA: SKNode, nodeB: SKNode, possibleNodes: [AnyObject] ){
        var checkpoint: CPCheckpoint // we cant have two chekpoints interact with each other
        
        var spaceship: CPSpaceshipBase // The playership may be referenced seperately later
        
        //if let checkpoint =
        // Figure out which nodes we are dealing with
        
        // Check if we have hit any checkpoints - these only interact with the player
        
        // if we didnt hit any spaceships, it might be a stray bullet
        
        // We probably dont need to handle this
    }
    
    func determineNode(){
        
    }
    
    enum NodeTypes {
        case ship, object, checkpoint
    }
}
