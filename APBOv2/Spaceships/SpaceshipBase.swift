import Foundation
import SpriteKit
import Firebase

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
        
        // TODO calculate movement from inputs
        
        let payload = Payload(shipPosX: shipSprite.position.x, shipPosY: shipSprite.position.y, shipAngleRad: shipSprite.zRotation, hasPowerup: false)
        let data = try! JSONEncoder().encode(payload)
        let json = String(data: data, encoding: .utf8)!
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/\(playerID)", Value: json)
        
    }
    
    private func UpdateRemoteShip(){
        let ref = Database.database().reference().child("Games/\(Global.gameData.gameID)/\(playerID)")
        ref.observeSingleEvent(of: .value) { snapshot in
            let snapVal = snapshot.value as! String
            if (snapVal == "Null"){
                return;
            } else {
                let jsonData = snapVal.data(using: .utf8)
                let payload = try! JSONDecoder().decode(Payload.self, from: jsonData!)
                
                self.shipSprite.position.x = payload.shipPosX
                self.shipSprite.position.y = payload.shipPosY
                self.shipSprite.zRotation = payload.shipAngleRad
            }
        }
    }
    
    private func UpdateAiShip() {
        // Uhhh, idk how your ai works, and this will have a specific enum
    }
}


enum ControllerType {
    case Remote, Local, AI
}

enum InputType {
    // Refers to button positions
    case Right, Left
}
