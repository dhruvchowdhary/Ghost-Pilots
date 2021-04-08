import Foundation
import SpriteKit

class CPLevelBase: SKScene {
    var aiManagedShips: [CPSpaceshipBase] = []
    var playerShip: CPSpaceshipBase?
    var isSetup = false
    
    override func didMove(to view: SKView) {
        
        isSetup = true
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