import Foundation
import SpriteKit
import Firebase

// Created on game creation
public class GameData{
    public var score = 0
    public var revived = false
    public var gameID = 00000
    public var shipsToUpdate: [SpaceshipBase] = []
    public var playerShip: LocalSpaceship? //Also included in shipsToUpdate
    public var camera = SKCameraNode()
    public var gameScene = GameSceneBase()
    public var skView = SKView();
    public var isHost = false
    public var host = "";
    public var isBackground = false;
    public var map = "OnlineCubis"
    public var mode = "ffa"
    public var isFull = false
    public var infected = false
    public var isPilot = false
    public var gameState: GameStates = GameStates.MainMenu
    public var speedMultiplier: CGFloat = 1.0
    public var polyniteCount = 0
    public var selectedSkin: SelectedSkin = SelectedSkin.DEFAULTDECAL
    public var selectedTrail: SelectedTrail = SelectedTrail.DEFAULTTRAIL
    


    
    init() {
    }
    
    public func addPolyniteCount(delta: Int){
        polyniteCount += delta
        DataPusher.PushData(path: "Users/\(UIDevice.current.identifierForVendor!)/Polynite", Value: String(polyniteCount))
    }
    
    public func spendPolynite(amountToSpend: Int) -> Bool{
        if amountToSpend > polyniteCount {
            return false
        } else {
            polyniteCount -= amountToSpend
            DataPusher.PushData(path: "Users/\(UIDevice.current.identifierForVendor!)/Polynite", Value: String(polyniteCount))
        }
        return true
    }
    
    // =================
    // For the Host to run
    public func CreateNewGame(){
        isHost = true
        MultiplayerHandler.GenerateUniqueGameCode()
    }
    
    
    public func SetUniqueCode(code: Int){
        // we have created a code, we must now finish init game
        gameID = code
        DataPusher.PushData(path: "Games/\(code)/Host", Value: Global.playerData.playerID)
        DataPusher.PushData(path: "Games/\(code)/Map", Value: map)
        DataPusher.PushData(path: "Games/\(code)/Mode", Value: mode)
        DataPusher.PushData(path: "Games/\(code)/Status", Value: "Lobby")
        DataPusher.PushData(path: "Games/\(code)/PlayerList/\(Global.playerData.playerID)", Value: "PePeNotGone")
        Global.gameData.host = Global.playerData.playerID
        
        //IGNORE THIS FAKE NEWS
        Global.multiplayerHandler.MakeGamePublic()
        //IGNORE THIS FAKE NEWS
        
        Global.loadScene(s: "LobbyMenu")
    }
    
    public func MapChange(){
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Map", Value: map)
    }
    public func ModeChange(){
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Mode", Value: mode)
    }
    
    // ==============
    // For guest to run

    
    public func ResetGameData(toLobby: Bool){
        isPilot = false
        Global.multiplayerHandler.StopListenForInfectedChanges()
        Global.multiplayerHandler.StopListenForPilotChanges()
  //      Global.multiplayerHandler.StopListenForColorChanges()
        Global.multiplayerHandler.StopListenForEliminatedChanges()
        Global.multiplayerHandler.StopListenToAstroball()
        Global.multiplayerHandler.StopListenForAstroBallChanges()
        
        let zoomOut = SKAction.scale(to: 1, duration: 0.001)
        Global.gameData.camera.run(zoomOut)
        
        for x in shipsToUpdate{
            if let ship = x as? RemoteSpaceship {
                ship.StopListenToShip()
            }
        }
        if isHost {
            Global.multiplayerHandler.ClearInfectedList()
            Global.multiplayerHandler.ClearEliminatedList()
            Global.multiplayerHandler.ClearPilotList()
            
        }
        MultiplayerHandler.ref.child("Games/\(gameID)/MainGame/\(Global.playerData.playerID)/Shots").removeValue()
        if !toLobby {
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerList/\(Global.playerData.playerID)", Value: "PePeGone")
            host = ""
            map = "OnlineCubis"
            mode = "ffa"
            Global.multiplayerHandler.StopListenForModeChanges()
            Global.multiplayerHandler.StopListenForMapChanges()
            Global.multiplayerHandler.StopListenForGuestChanges()
            Global.multiplayerHandler.StopListenForHostChanges()
            Global.multiplayerHandler.StopListenForGameStatus()
            
            if isHost {
                Global.multiplayerHandler.SetNewHost()
            }
            gameID = 666
        }
        
        
        Global.gameData.playerShip?.spaceShipHud.position = .zero
        shipsToUpdate = []
        playerShip?.spaceShipParent.removeFromParent()
    }
    
    public func addCompletedLevel(i: Int){
        var completedLevels = UserDefaults.standard.value(forKey: "completedLevels") as! [Int]
        if completedLevels.contains(i){
            return
        } else {
            completedLevels.append(i)
            UserDefaults.standard.setValue (completedLevels, forKey: "completedLevels")
        }
    }
}

public enum GameStates {
    case MainMenu, OnlineMenu, SoloMenu, LobbyMenu, AstroBall, Infection, FFA, HostMenu, Endless, TurretBoss, Levels
}

public enum SelectedSkin: String {
    case DEFAULTDECAL, TIGER , SWIRL
}

public enum SelectedTrail: String {
    case DEFAULTTRAIL, LIGHTNING
}
