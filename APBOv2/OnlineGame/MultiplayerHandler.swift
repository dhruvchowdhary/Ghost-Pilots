import Foundation
import Firebase

public class MultiplayerHandler{
    var guestsRef: DatabaseReference?
    static var ref: DatabaseReference! = Database.database().reference()
    
    public func updateShips(gameData : GameData){
    }
    
    public func StartTrackingGame(GameID: Int){
        
    }
    
    /// The host will do this, then this will call ReccieveUniqueGameCode
    public static func GenerateUniqueGameCode(){
        let code = Int.random(in: 10000...99999)
        ref.child("Games/\(code)").observeSingleEvent(of: .value) { snapshot in
            if (snapshot.exists()){
                self.GenerateUniqueGameCode()
            } else {
                Global.gameData.SetUniqueCode(code: code)
            }
        }
    }
    
    public func listenForGuestChanges(){
        self.guestsRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Players")
        let schildAdded = guestsRef?.observe(DataEventType.value, with: { (snapshot) in
            let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
            var playerList: [String] = []
            for child in snapshot.children {
                let e = child as! DataSnapshot
                print(e.key)
                playerList.append(e.key)
            }
            lobbyScene.setPlayerList(playerList: playerList)
        })
    }
    
}
