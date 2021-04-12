import Foundation
import SpriteKit

class CPLevel1 : CPLevelBase {
    
    override func didMove(to view: SKView) {
        boundriesNode = 
        playerShip = CPSpaceshipBase(spaceshipSetup: CPSpaceshipSetup())
        ManualSetup()
    }
    
}
