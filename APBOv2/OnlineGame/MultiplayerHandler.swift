import Foundation
import Firebase

class MultiplayerHandler{
    static var ref: DatabaseReference! = Database.database().reference()
    
    public func updateShips(gameData : GameData){
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
