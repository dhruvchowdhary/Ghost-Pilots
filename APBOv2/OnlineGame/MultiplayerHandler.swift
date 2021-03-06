import Foundation
import Firebase
import SpriteKit

public class MultiplayerHandler{
    var guestsRef: DatabaseReference?
    var statusRef: DatabaseReference?
    var currentBulletCounts: [(String, Int)] = []
    
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
        guestsRef?.observe(DataEventType.value, with: { (snapshot) in
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
    
    public func ListenForPayload(ref: DatabaseReference, shipSprite: SKSpriteNode){
        ref.observe(DataEventType.value) { ( snapshot ) in
            if (snapshot.exists()) {
                let snapVal = snapshot.value as! String
                if (snapVal != "PeePee"){
                    let jsonData = snapVal.data(using: .utf8)
                    let payload = try! JSONDecoder().decode(Payload.self, from: jsonData!)
                    print("=========")
                    print(payload.shipPosX)
                    print(" vs ")
                    print(shipSprite.position.x)
                    shipSprite.position.x = payload.shipPosX
                    shipSprite.position.y = payload.shipPosY
                    shipSprite.zRotation = payload.shipAngleRad
                }
            } else {
                print ("Snapshot does not exist");
            }
        }
    }
    
    public func ListenForShots(ref: DatabaseReference, spaceShip: SpaceshipBase ){
        
        currentBulletCounts.append((spaceShip.playerID, 0))
        
        ref.observe(DataEventType.value) { ( snapshot ) in
            if (snapshot.exists()) {
                for var tup in self.currentBulletCounts{
                    if tup.0 == spaceShip.playerID{
                        var e = snapshot.childSnapshot(forPath: spaceShip.playerID + String(tup.1)).value as! String;
                        e.removeFirst(spaceShip.playerID.count)
                        let i: Int = Int(e)!
                        spaceShip.Shoot(shotType: i)
                        tup.1 += 1
                    }
                }
            }
        }
    }
    
    public func StopListenForShots(ref: DatabaseReference, spaceShip: SpaceshipBase ){
        ref.removeAllObservers()
        for i in 0..<currentBulletCounts.count {
            if currentBulletCounts[i].0 == spaceShip.playerID {
                currentBulletCounts.remove(at: i)
                break;
            }
        }
        
    }
    
    public func StopListenForPayload(ref: DatabaseReference){
        ref.removeAllObservers()
    }
    
    public func ListenForGameStatus(){
        statusRef = Database.database().reference().child("Games/\(Global.gameData.gameID)/Status")
        statusRef!.observe(DataEventType.value) { ( snapshot ) in
            if (snapshot.exists()){
                if (snapshot.value as! String == "Game"){
                    let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
                    lobbyScene.StartGame()
                }
            }
        }
    }
    
}
