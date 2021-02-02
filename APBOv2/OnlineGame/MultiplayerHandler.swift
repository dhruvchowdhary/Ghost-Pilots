import Foundation
import Firebase

class MultiplayerHandler{
    static var ref: DatabaseReference! = Database.database().reference()
    
    public func updateShips(gameData : GameData){
        DataPusher.PushData(path: "Games/\(gameData.gameID)/\(UIDevice.current.identifierForVendor!.uuidString)/ShipPosX", Value: String(gameData.shipPos[0]))
        DataPusher.PushData(path: "Games/\(gameData.gameID)/\(UIDevice.current.identifierForVendor!.uuidString)/ShipPosY", Value: String(gameData.shipPos[1]))
        DataPusher.PushData(path: "Games/\(gameData.gameID)/\(UIDevice.current.identifierForVendor!.uuidString)/ShipAngle", Value: String(gameData.shipAngle))
    }
    
    public func StartTrackingGame(GameID: Int){
        
    }
    
    /// The host will do this, then this will call ReccieveUniqueGameCode
    public static func GenerateUniqueGameCode(){
        let code = Int.random(in: 10000...99999)
        ref.child("Games").observeSingleEvent(of: .value) { snapshot in
            if (!snapshot.hasChild(String(code))){
                self.GenerateUniqueGameCode()
            } else {
                Global.gameData.SetUniqueCode(code: code)
            }
        }
    }
}
