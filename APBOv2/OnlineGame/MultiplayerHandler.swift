import Foundation
import Firebase

class MultiplayerHandler{
    public func updateShips(gameData : GameData){
        DataPusher.PushData(path: "Games/\(gameData.gameID)/\(UIDevice.current.identifierForVendor!.uuidString)/ShipPosX", Value: String(gameData.shipPos[0]))
        DataPusher.PushData(path: "Games/\(gameData.gameID)/\(UIDevice.current.identifierForVendor!.uuidString)/ShipPosY", Value: String(gameData.shipPos[1]))
        DataPusher.PushData(path: "Games/\(gameData.gameID)/\(UIDevice.current.identifierForVendor!.uuidString)/ShipAngle", Value: String(gameData.shipAngle))
    }
    
    public func StartTrackingGame(GameID: Int){
        
    }
}
