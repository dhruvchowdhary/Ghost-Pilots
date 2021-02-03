import Foundation
import SpriteKit

class SpaceshipBase {
    private var lastTimeUpdated: Float?
    public var shipSprite: SKSpriteNode
    private var playerID: String
    public var position = (0.0,0.0)
    public var angle = 0 // In degrees
    var controller: ControllerType
    
    init(shipSprite: SKSpriteNode, playerId: String, controller: ControllerType) {
        self.shipSprite = shipSprite
        self.playerID = playerId
        self.controller = controller
    }

    
    // Only to be called by the child
    func updateShip(deltaTime: Float, inputs: [InputType]){
        switch controller {
        case .Local:
            UpdateLocalShip(deltaTime: deltaTime, inputs: inputs)
        case .Remote:
            UpdateRemoteShip()
        case .AI:
            UpdateAiShip()
        }
    }
    
    private func UpdateLocalShip(deltaTime: Float, inputs: [InputType]){
        // Checks for first update call
        if lastTimeUpdated == nil {
            lastTimeUpdated = deltaTime
            return
        }
        
        
        // A scaler based off deltaTime
        let scaler = lastTimeUpdated! - deltaTime
        
        // TODO: add input array dictating movement
    }
    
    private func UpdateRemoteShip(){
        
    }
    
    private func UpdateAiShip() {
        
    }
}


enum ControllerType {
    case Remote, Local, AI
}

enum InputType {
    // Refers to button positions
    case Right, Left
}
