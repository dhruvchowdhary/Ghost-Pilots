import Foundation
import SpriteKit

class CPLevelBase: SKScene {
    var aiManagedShips: [CPSpaceshipBase] = []
    var playerShip: CPSpaceshipBase?
    var isSetup = false
    var boundriesNode: SKSpriteNode?
    
    // this will be overriden in the levels and then callback manual setup
    override func didMove(to view: SKView) {}
    
    // This is called by the base class when the proper arrays have been updated
    func ManualSetup(){
        addChild(boundriesNode!)
        addChild((playerShip?.shipNode)!)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if !isSetup{return}
        
        for ship in aiManagedShips {
            ship.handleAImovement(playerShip: playerShip!)
        }
    }
    
    
}

struct CPSetup {
    var createBackground: () -> SKNode = {return SKNode()}
    var hazards: [Hazard] = []
    init(){
        
    }
}

class Hazard {
    init(spriteNode: SKSpriteNode) {
        
    }
    
    convenience init (imageNamed: String){
        self.init(spriteNode: SKSpriteNode(imageNamed: imageNamed))
    }
    
    
}
