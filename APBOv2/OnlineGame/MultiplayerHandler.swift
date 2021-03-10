import Foundation
import Firebase
import SpriteKit

public class MultiplayerHandler{
    var guestsRef: DatabaseReference?
    var statusRef: DatabaseReference?
    var mapRef: DatabaseReference?
    var modeRef: DatabaseReference?
    var currentBulletCounts: [(String, Int)] = []
    
    public static var ref: DatabaseReference! = Database.database().reference()
    
    
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
        self.guestsRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/PlayerList")
        guestsRef?.observe(DataEventType.value, with: { (snapshot) in
            guard let lobbyScene = Global.gameData.skView.scene as? LobbyMenu else  {
                return
            }
            var playerList: [String] = []
            for child in snapshot.children {
                let e = child as! DataSnapshot
                if e.value as! String == "PePeGone"{
                    if (e.key == Global.playerData.username){
                        // Uh oh mario, we have been removed from the game
                        let scene = OnlineMenu()
                        Global.gameData.skView.presentScene(scene)
                        scene.KickedFromGame()
                    }
                    // Haha somone left loser
                    for i in 0..<Global.gameData.shipsToUpdate.count {
                        if Global.gameData.shipsToUpdate[i].playerID == e.key {
                            Global.gameData.shipsToUpdate.remove(at: i)
                        }
                    }
                } else {
                    playerList.append(e.key)
                }
            }
            lobbyScene.setPlayerList(playerList: playerList)
        })
    }
    
    public func StopListenForGuestChanges(){
        guestsRef?.removeAllObservers()
    }
    
    public func ListenForPosPayload(ref: DatabaseReference, shipSprite: SKNode){
        ref.observe(DataEventType.value) { ( snapshot ) in
            if (snapshot.exists()) {
                let snapVal = snapshot.value as! String
                if (snapVal != "e"){
                    let jsonData = snapVal.data(using: .utf8)
                    let payload = try! JSONDecoder().decode(Payload.self, from: jsonData!)
                    if payload.shipPosX != nil{
                        shipSprite.position.x = payload.shipPosX!
                        shipSprite.position.y = payload.shipPosY!
                        shipSprite.childNode(withName: "player")!.zRotation = payload.shipAngleRad
                    } else {
                        shipSprite.childNode(withName: "player")!.zRotation = payload.shipAngleRad
                    }
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
                        var e = snapshot.childSnapshot(forPath: "shot " + String(tup.1)).value as! String;
                        //e.removeFirst(5)
                        //let i: Int = Int()!
                        spaceShip.Shoot(shotType: 0)
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
    
    public func ListenForMapChanges(){
        self.mapRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Map")
        mapRef?.observe(DataEventType.value, with: { (snapshot) in
            if !Global.gameData.isHost {
                let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
                Global.gameData.map = snapshot.value as! String
                lobbyScene.pullMap()
            }
        })
    }
    
    public func ListenForModeChanges(){
        self.modeRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Mode")
        modeRef?.observe(DataEventType.value, with: { (snapshot) in
            if !Global.gameData.isHost {
                let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
                Global.gameData.mode = snapshot.value as! String
                lobbyScene.pullMode()
            }
        })
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
