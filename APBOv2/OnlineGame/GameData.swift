import Foundation
import SpriteKit
import Firebase

// Created on game creation
public class GameData{
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
    public var infected = false
    public var gameState: GameStates = GameStates.MainMenu
    public var speedMultiplier: CGFloat = 1.0
    
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
        Global.multiplayerHandler.StopListenForInfectedChanges()

        Global.multiplayerHandler.StopListenToAstroball()
        Global.multiplayerHandler.StopListenForAstroBallChanges()
        
        for x in shipsToUpdate{
            if let ship = x as? RemoteSpaceship {
                ship.StopListenToShip()
            }
        }
        if isHost {
            Global.multiplayerHandler.ClearInfectedList()
        }
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
        }
        Global.gameData.playerShip?.spaceShipHud.position = .zero
        shipsToUpdate = []
        playerShip?.spaceShipParent.removeFromParent()
    }
}

public enum GameStates {
    case MainMenu, OnlineMenu, SoloMenu, LobbyMenu, AstroBall, Infection, FFA, HostMenu, Endless, TurretBoss, Levels
}
