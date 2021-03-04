import Foundation
import Firebase
import SpriteKit

public class MultiplayerHandler{
    var guestsRef: DatabaseReference?
    public static var ref: DatabaseReference! = Database.database().reference()
    
    public func updateShips(gameData : GameData){
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
        var isInGame = false
        self.guestsRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Players")
        let childAdded = guestsRef?.observe(DataEventType.value, with: { (snapshot) in
            let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
            var playerList: [String] = []
            for child in snapshot.children {
                let e = child as! DataSnapshot
                if e.value as! String == "Host" {
                    Global.gameData.host = e.key
                    if (Global.gameData.host == Global.playerData.username){
                        Global.gameData.isHost = true
                    }
                }
                if (e.key == Global.playerData.username){
                    isInGame = true
                }
                playerList.append(e.key)
            }
            lobbyScene.setPlayerList(playerList: playerList)
            
            if (!isInGame){
                // Uh oh mario, we have been removed from the game
                let scene = OnlineMenu()
                Global.gameData.skView.presentScene(scene)
                scene.KickedFromGame()
            }
        })
    }
    
    public func StopListenForGuestChanges(){
        guestsRef?.removeAllObservers()
    }
    
    public func listenForPayload(ref: DatabaseReference, shipSprite: SKSpriteNode){
        ref.observe(DataEventType.value) { ( snapshot ) in
            if (snapshot.value != nil) {
                let snapVal = snapshot.value as! String
                if (snapVal != "PeePee"){
                    let jsonData = snapVal.data(using: .utf8)
                    let payload = try! JSONDecoder().decode(Payload.self, from: jsonData!)
    
                    shipSprite.position.x = payload.shipPosX
                    shipSprite.position.y = payload.shipPosY
                    shipSprite.zRotation = payload.shipAngleRad
                }
            }
        }
    }
    
    public func StopListenForPayload(ref: DatabaseReference){
        ref.removeAllObservers()
    }
    
}
