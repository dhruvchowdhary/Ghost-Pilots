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
    var eliminatedRef: DatabaseReference?
    var astroBallRef: DatabaseReference?
    var colorRef: DatabaseReference?
    var astroballRef: DatabaseReference?
    var geoRefs: [DatabaseReference] = []
    var currentBulletCounts: [(String, Int)] = []
    var hasFoundGame = false
    
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
                    if (e.key == Global.playerData.playerID){
                        // Uh oh mario, we have been removed from the game
                        let scene = OnlineMenu()
                        Global.gameData.skView.presentScene(scene)
                        scene.KickedFromGame()
                    }
                }
                if e.value as! String == "PePeKicked" || e.value as! String == "PePeGone"{
                    var indexesToRM: [Int] = []
                    // Haha somone left loser
                    for i in 0..<Global.gameData.shipsToUpdate.count {
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
            if snapshot.value as! String == Global.playerData.playerID
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
                    if payload.posX != nil{
                        shipSprite.position.x = payload.posX!
                        shipSprite.position.y = payload.posY!
                        shipSprite.childNode(withName: "shipnode")!.zRotation = payload.angleRad
                    } else {
                        shipSprite.childNode(withName: "shipnode")!.zRotation = payload.angleRad
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
                        if Global.gameData.shipsToUpdate.count > 1 {
                            if infectedList.count == Global.gameData.shipsToUpdate.count {
                                //  print("gameover!!!!")
                                Global.gameData.playerShip!.setGameOver(winner: "infected")
                            }
                        }
                    }
                }
            }
        })
    }
    
    public func ListenForEliminatedChanges() {
        self.eliminatedRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/EliminatedList")
        eliminatedRef?.observe(DataEventType.value, with: { (snapshot) in
            var eliminatedList: [String] = []
            for child in snapshot.children {
                let e = child as! DataSnapshot
                if e.value as! String == "true"{
                    for i in 0..<Global.gameData.shipsToUpdate.count {
                        if Global.gameData.shipsToUpdate[i].playerID == e.key {
                            Global.gameData.shipsToUpdate[i].spaceShipParent.childNode(withName: "shipnode")?.alpha = 0
                            Global.gameData.shipsToUpdate[i].spaceShipParent.physicsBody = nil
                           
                            
                      //      Global.gameData.playerShip?.spaceShipHud.position = CGPoint(x: frame.midX, y: frame.midY)
                   //         let infected = SKAction.setTexture(SKTexture(imageNamed: "apboGreen"))
                    //        Global.gameData.shipsToUpdate[i].spaceShipParent.childNode(withName: "shipnode")!.run(infected)
                            
                            eliminatedList.append(e.key)
                            if Global.playerData.playerID == e.key {
                                print("dead camera set")
                                Global.gameData.playerShip?.spaceShipHud.position = CGPoint(x: 0, y: 0)
                            }
                        }
                        //   print(infectedList.count)
                        //   print(Global.gameData.shipsToUpdate.count)
                        if Global.gameData.shipsToUpdate.count > 1 {
                            if eliminatedList.count == Global.gameData.shipsToUpdate.count {
                                //  print("gameover!!!!")
                                Global.gameData.playerShip!.setGameOver(winner: "infected")
                            }
                        }
                    }
                }
            }
        })
    }
    
    public func ListenForAstroBallChanges() {
        self.astroBallRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/AstroBall")
        astroBallRef?.observe(DataEventType.value, with: { (snapshot) in
            
            guard let redHP = snapshot.childSnapshot(forPath: "redHP").value as? String else {return}
            guard let blueHP = snapshot.childSnapshot(forPath: "blueHP").value as? String else {return}
            
            let astroScene = Global.gameData.skView.scene as! AstroBall
            astroScene.setColorHP(redHPString: redHP, blueHPString: blueHP)
            
            if Global.gameData.gameState == GameStates.AstroBall {
                switch blueHP {
                case "8":
                    let crack8 = SKAction.setTexture(SKTexture(imageNamed: "blueGoal1"))
                    (Global.gameData.skView.scene?.childNode(withName: "blueGoal") as! SKSpriteNode).run(crack8)
                case "7":
                    let crack7 = SKAction.setTexture(SKTexture(imageNamed: "blueGoal2"))
                    (Global.gameData.skView.scene?.childNode(withName: "blueGoal") as! SKSpriteNode).run(crack7)
                case "6":
                    let crack6 = SKAction.setTexture(SKTexture(imageNamed: "blueGoal3"))
                    (Global.gameData.skView.scene?.childNode(withName: "blueGoal") as! SKSpriteNode).run(crack6)
                case "5":
                    let crack5 = SKAction.setTexture(SKTexture(imageNamed: "blueGoal4"))
                    (Global.gameData.skView.scene?.childNode(withName: "blueGoal") as! SKSpriteNode).run(crack5)
                case "4":
                    let crack4 = SKAction.setTexture(SKTexture(imageNamed: "blueGoal5"))
                    (Global.gameData.skView.scene?.childNode(withName: "blueGoal") as! SKSpriteNode).run(crack4)
                case "3":
                    let crack3 = SKAction.setTexture(SKTexture(imageNamed: "blueGoal6"))
                    (Global.gameData.skView.scene?.childNode(withName: "blueGoal") as! SKSpriteNode).run(crack3)
                case "2":
                    let crack2 = SKAction.setTexture(SKTexture(imageNamed: "blueGoal7"))
                    (Global.gameData.skView.scene?.childNode(withName: "blueGoal") as! SKSpriteNode).run(crack2)
                case "1":
                    let crack1 = SKAction.setTexture(SKTexture(imageNamed: "blueGoal8"))
                    (Global.gameData.skView.scene?.childNode(withName: "blueGoal") as! SKSpriteNode).run(crack1)
                case "0":
                    (Global.gameData.skView.scene?.childNode(withName: "blueGoal") as? SKSpriteNode)?.removeFromParent()
                    print("redWon")
                    Global.gameData.playerShip!.setGameOver(winner: "redWon")
                default:
                    print("it cracked a lil")
                }
                
                
                switch redHP {
                case "8":
                    
                    let crack8 = SKAction.setTexture(SKTexture(imageNamed: "redGoal1"))
                    (Global.gameData.skView.scene?.childNode(withName: "redGoal") as! SKSpriteNode).run(crack8)
                case "7":
                    let crack7 = SKAction.setTexture(SKTexture(imageNamed: "redGoal2"))
                    (Global.gameData.skView.scene?.childNode(withName: "redGoal") as! SKSpriteNode).run(crack7)
                case "6":
                    let crack6 = SKAction.setTexture(SKTexture(imageNamed: "redGoal3"))
                    (Global.gameData.skView.scene?.childNode(withName: "redGoal") as! SKSpriteNode).run(crack6)
                case "5":
                    let crack5 = SKAction.setTexture(SKTexture(imageNamed: "redGoal4"))
                    (Global.gameData.skView.scene?.childNode(withName: "redGoal") as! SKSpriteNode).run(crack5)
                case "4":
                    let crack4 = SKAction.setTexture(SKTexture(imageNamed: "redGoal5"))
                    (Global.gameData.skView.scene?.childNode(withName: "redGoal") as! SKSpriteNode).run(crack4)
                case "3":
                    let crack3 = SKAction.setTexture(SKTexture(imageNamed: "redGoal6"))
                    (Global.gameData.skView.scene?.childNode(withName: "redGoal") as! SKSpriteNode).run(crack3)
                case "2":
                    let crack2 = SKAction.setTexture(SKTexture(imageNamed: "redGoal7"))
                    (Global.gameData.skView.scene?.childNode(withName: "redGoal") as! SKSpriteNode).run(crack2)
                case "1":
                    let crack1 = SKAction.setTexture(SKTexture(imageNamed: "redGoal8"))
                    (Global.gameData.skView.scene?.childNode(withName: "redGoal") as! SKSpriteNode).run(crack1)
                case "0":
                    (Global.gameData.skView.scene?.childNode(withName: "redGoal") as? SKSpriteNode)?.removeFromParent()
                    print("blueWon")
                    Global.gameData.playerShip!.setGameOver(winner: "blueWon")
                default:
                    print("it cracked a lil")
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
            }
        })
    }
    
    public func ListenForColorChangesLobby() {
        self.colorRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/PlayerColor")
        colorRef?.observe(DataEventType.value, with: { (snapshot) in
            for child in snapshot.children {
                let e = child as! DataSnapshot
                if Global.gameData.gameState == GameStates.LobbyMenu {
                    //               if Global.playerData.playerID != e.key {
                    print(e)
                    let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
                    let color = SKAction.setTexture(SKTexture(imageNamed: e.value! as! String))
                    lobbyScene.childNode(withName: "pepe")!.childNode(withName: e.key)?.childNode(withName: "colorButtonNode")?.run(color)
                }
            }
        })
    }
    
    public func StopListenForAstroBallChanges(){
        self.astroBallRef?.removeAllObservers()
    }
    
    public func StopListenForInfectedChanges(){
        self.infectedRef?.removeAllObservers()
    }
    
    public func StopListenForEliminatedChanges(){
        self.eliminatedRef?.removeAllObservers()
    }
    
    public func StopListenForMapChanges(){
        self.mapRef?.removeAllObservers()
    }
    
    public func StopListenForModeChanges(){
        self.modeRef?.removeAllObservers()
    }
    
    public func ListenForModeChanges(){
        self.modeRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Mode")
        modeRef?.observe(.value, with: { (snapshot) in
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
        statusRef!.observe(.value) { ( snapshot ) in
            if (snapshot.exists()){
                if (snapshot.value as! String == "Game"){
                    if Global.gameData.gameState == GameStates.LobbyMenu {
                        let lobbyScene = Global.gameData.skView.scene as! LobbyMenu
                        lobbyScene.StartGame()
                    }
                } else if (snapshot.value as! String == "Lobby"){
                    if Global.gameData.gameState != GameStates.LobbyMenu{
                        Global.gameData.gameState = GameStates.LobbyMenu
                        Global.gameData.ResetGameData(toLobby: true)
                        Global.loadScene(s: "LobbyMenu")
                    }
                }
            }
        }
    }
    
    public func ClearInfectedList(){
        MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/InfectedList").removeValue()
    }
    
    public func StopListenForGameStatus(){
        statusRef?.removeAllObservers()
    }
    
    public func SetNewHost(){
        MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/PlayerList").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(){
                for c in snapshot.children {
                    let player = c as! DataSnapshot
                    if player.value as! String == "PePeNotGone" {
                        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Host", Value: player.key)
                        Global.gameData.isHost = false
                        return
                    }
                }
                if Global.gameData.isHost {
                    MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)").removeValue()
                    Global.gameData.isHost = false
                }
            }
        }
    }
    
    public func ListenToAstroball(){
        astroballRef = MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Astroball")
        astroballRef?.observe(.value, with: { (Snapshot) in
            if Global.gameData.gameState == GameStates.AstroBall {
                if !Snapshot.exists(){
                    return
                }
                let astroballScene = Global.gameData.skView.scene as! AstroBall
                let snapVal = Snapshot.value as! String
                let jsonData = snapVal.data(using: .utf8)
                let payload = try! JSONDecoder().decode(Payload.self, from: jsonData!)
                if payload.posX != nil{
                    astroballScene.astroball?.position.x = payload.posX!
                    astroballScene.astroball?.position.y = payload.posY!
                    astroballScene.astroball?.physicsBody?.velocity = payload.velocity!
                    astroballScene.astroball?.zRotation = payload.angleRad
                } else {
                    astroballScene.astroball?.physicsBody?.velocity = payload.velocity!
                    astroballScene.astroball?.zRotation = payload.angleRad
                }
            }
        })
    }
    
    public func StopListenToAstroball(){
        astroballRef?.removeAllObservers()
    }
    
    public func SetGeoRefs(){
        geoRefs = []
        let geoPieces: Int?
        switch Global.gameData.map{
        case "OnlineTrisen":
            geoPieces = 3
        case "OnlineCubis":
            geoPieces = 4
        case "OnlineHex":
            geoPieces = 6
        default:
            fatalError("Map name is incorrecty marked in Multihandler")
        }
        for i in 0..<geoPieces!{
            geoRefs.append(MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Geo/\(i)"))
        }
    }
    
    public func ListenToGeometry(){
        
        for i in 0..<geoRefs.count{
            geoRefs[i].observe(.value, with: { (Snapshot) in
                if !Snapshot.exists() || Global.gameData.gameState != GameStates.AstroBall{
                    return
                }
                
                let astroballScene = Global.gameData.skView.scene as! AstroBall
                let snapVal = Snapshot.value as! String
                let jsonData = snapVal.data(using: .utf8)
                let payload = try! JSONDecoder().decode(Payload.self, from: jsonData!)
                if payload.posX != nil{
                    astroballScene.geo[i].position.x = payload.posX!
                    astroballScene.geo[i].position.y = payload.posY!
                    astroballScene.geo[i].physicsBody?.velocity = payload.velocity!
                    astroballScene.geo[i].zRotation = payload.angleRad
                } else {
                    guard let pepe = astroballScene.geo[i].physicsBody?.velocity else {
                        return
                    }
                    astroballScene.geo[i].physicsBody?.velocity = payload.velocity!
                    astroballScene.geo[i].zRotation = payload.angleRad
                }
            })
        }
    }
    
    func StopListenToGeometry(){
        for r in geoRefs {
            r.removeAllObservers()
        }
    }
    
    func MakeGamePublic(){
        if Global.gameData.isHost {
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/isPublic", Value: "TRUE")
            DataPusher.PushData(path: "Games/LFG/\(Global.gameData.gameID)", Value: "PePeLonely")
        }
    }
    
    func MakeGamePrivate(){
        if Global.gameData.isHost {
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/isPublic", Value: "FALSE")
            MultiplayerHandler.ref.child("Games/LFG/\(Global.gameData.gameID)").removeValue()
        }
    }
    
    func FindPublicGame(){
        hasFoundGame = false
        MultiplayerHandler.ref.child("Games/LFG").observeSingleEvent(of: .value) { Snapshot in
            if Snapshot.exists(){
                for c in Snapshot.children {
                    let lobby = c as! DataSnapshot
                    MultiplayerHandler.ref.child("Games/\(lobby.key)").observeSingleEvent(of: .value) { snapshot in
                        if snapshot.exists(){
                            print("1")
                            if snapshot.childSnapshot(forPath: "Status").value as! String == "Lobby"{
                                print("lobby status")
                                var isEmpty = true
                                for j in Snapshot.childSnapshot(forPath: "PlayerList").children{
                                    if (j as! DataSnapshot).value as! String == "PePeNotGone" {
                                        isEmpty = false
                                    }
                                }
                                if isEmpty {
                                    MultiplayerHandler.ref.child("Games/\(lobby.key)").removeValue()
                                } else {
                                    if !self.hasFoundGame {
                                        print("3")
                                        // Add some sort of max player count check here
                                        DataPusher.PushData(path: "Games/\(lobby.key)/PlayerList/\(Global.playerData.playerID)", Value: "PePeNotGone")
                                        Global.gameData.gameID = Int(lobby.key)!
                                        Global.gameData.isHost = false
                                        self.hasFoundGame = true
                                        Global.loadScene(s: "LobbyMenu")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
