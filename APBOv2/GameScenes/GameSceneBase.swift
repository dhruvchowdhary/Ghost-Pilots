import Foundation
import SpriteKit
import CoreMotion
import AudioToolbox

class GameSceneBase: SKScene {
    public var inputs: [InputType] = []
    
    override func didMove(to view: SKView) {
        
    }
    
    public override func update(_ currentTime: TimeInterval) {
        for ship in Global.gameData.shipsToUpdate {
            ship.updateShip(deltaTime: Float(currentTime), inputs: inputs)
        }
    }
}
