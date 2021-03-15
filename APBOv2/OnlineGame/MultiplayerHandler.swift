import Foundation
import Firebase
import SpriteKit

public class MultiplayerHandler{
    var guestsRef: DatabaseReference?
    var hostRef: DatabaseReference?
    var statusRef: DatabaseReference?
    var mapRef: DatabaseReference?
    var modeRef: DatabaseReference?
    var infectedRef: DatabaseReference?
    var colorRef: DatabaseReference?
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
        self.guestsRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/PlayerList")
        guestsRef?.observe(DataEventType.value, with: { (snapshot) in
            var playerList: [String] = []
            for child in snapshot.children {
                let e = child as! DataSnapshot
                if e.value as! String == "PePeKicked"{
                    if (e.key == Global.playerData.username){
                        // Uh oh mario, we have been removed from the game
                        let scene = OnlineMenu()
                        Global.gameData.skView.presentScene(scene)
                        scene.KickedFromGame()
                    }
                    var indexesToRM: [Int] = []
                    // Haha somone left loser
                    for i in 0..<Global.gameData.shipsToUpdate.count {
                        print("gotem")
                        if Global.gameData.shipsToUpdate[i].playerID == e.key {
                            Global.gameData.shipsToUpdate[i].spaceShipParent.removeFromParent()
                            indexesToRM.insert(i, at: 0)
                        }
                    }
                    for i in indexesToRM {
                        Global.gameData.shipsToUpdate.remove(at: i)
                    }
                } else {
                    playerList.append(e.key)
                }
            }
            if Global.gameData.gameState == GameStates.LobbyMenu {
               let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
                lobbyScene.setPlayerList(playerList: playerList)
            }
        })
    }
    
    public func StopListenForGuestChanges(){
        guestsRef?.removeAllObservers()
    }
    
    public func ListenForHostChanges(){
        self.hostRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Host")
        hostRef?.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.value as! String == Global.playerData.username
            {
                Global.gameData.isHost = true
            }
            Global.gameData.host = snapshot.value as! String
        })
    }
    
    public func StopListenForHostChanges(){
        self.hostRef?.removeAllObservers()
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
                        shipSprite.childNode(withName: "shipnode")!.zRotation = payload.shipAngleRad
                    } else {
                        shipSprite.childNode(withName: "shipnode")!.zRotation = payload.shipAngleRad
                    }
                }
            } else {
                print ("Snapshot does not exist");
            }
        }
    }
    
    public func ListenForInfectedChanges() {
        self.infectedRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/InfectedList")
        infectedRef?.observe(DataEventType.value, with: { (snapshot) in
            var infectedList: [String] = []
            for child in snapshot.children {
                let e = child as! DataSnapshot
                if e.value as! String == "true"{
                    for i in 0..<Global.gameData.shipsToUpdate.count {
                        if Global.gameData.shipsToUpdate[i].playerID == e.key {
                            let infected = SKAction.setTexture(SKTexture(imageNamed: "apboGreen"))
                            Global.gameData.shipsToUpdate[i].spaceShipParent.childNode(withName: "shipnode")!.run(infected)
                            
                            infectedList.append(e.key)
                        }
                     //   print(infectedList.count)
                     //   print(Global.gameData.shipsToUpdate.count)
                        if infectedList.count == Global.gameData.shipsToUpdate.count {
                          //  print("gameover!!!!")
                            Global.gameData.playerShip!.setGameOver()
                            
                        }
                    }
                }
            }
        })
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
                
                if Global.gameData.gameState == GameStates.LobbyMenu {
                    let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
                    Global.gameData.map = snapshot.value as! String
                    lobbyScene.pullMap()
                }
            }
        })
    }
    
    public func ListenForColorChanges() {
        self.colorRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/PlayerColor")
        colorRef?.observe(DataEventType.value, with: { (snapshot) in
            for child in snapshot.children {
                print("i got here")
                let e = child as! DataSnapshot
            //    self.pullGameStatus()
               // print(Global.gameData.status)
              //  if Global.gameData.status == "Game" {
                    for i in 0..<Global.gameData.shipsToUpdate.count {
                        if Global.gameData.shipsToUpdate[i].playerID == e.key {
                            let color = SKAction.setTexture(SKTexture(imageNamed: e.value as! String))
                            Global.gameData.shipsToUpdate[i].spaceShipParent.childNode(withName: "shipnode")!.run(color)
                        }
                    }
             //   } else {
                    //change da texture of da shipbuttonnode in lobby
               // }
            }
        })
    }
    
    public func StopListenForInfectedChanges(){
        self.infectedRef?.removeAllObservers()
    }
    
    public func StopListenForMapChanges(){
        self.mapRef?.removeAllObservers()
    }
    
    public func StopListenForModeChanges(){
        self.modeRef?.removeAllObservers()
    }
    
    public func ListenForModeChanges(){
        self.modeRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Mode")
        modeRef?.observe(DataEventType.value, with: { (snapshot) in
            if Global.gameData.gameState == GameStates.LobbyMenu {
                let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
                if !Global.gameData.isHost {
                    Global.gameData.mode = snapshot.value as! String
                    lobbyScene.pullMode()
                }
                lobbyScene.setPlayerList(playerList: lobbyScene.list)
            }
        })
    }

    
    
    public func ListenForGameStatus(){
        statusRef = Database.database().reference().child("Games/\(Global.gameData.gameID)/Status")
        statusRef!.observe(DataEventType.value) { ( snapshot ) in
            if (snapshot.exists()){
                if (snapshot.value as! String == "Game"){
                    if Global.gameData.gameState == GameStates.LobbyMenu {
                        let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
                        lobbyScene.StartGame()
                    }
                } else if (snapshot.value as! String == "Lobby"){
                    Global.gameData.gameState = GameStates.LobbyMenu
                    Global.gameData.ResetGameData(toLobby: true)
                    Global.loadScene(s: "LobbyMenu")
                }
            }
        }
    }
    
    public func SetNewHost(){
        MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/PlayerList").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(){
                for c in snapshot.children {
                    let player = c as! DataSnapshot
                    if player.value as! String == "PePeNotGone" {
                        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Host", Value: player.key)
                        Global.gameData.isHost = false
                    }
                }
                if Global.gameData.isHost {
                    print("killed it")
                    MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)").removeValue()
                    Global.gameData.isHost = false
                }
            }
        }
    }
    
}
