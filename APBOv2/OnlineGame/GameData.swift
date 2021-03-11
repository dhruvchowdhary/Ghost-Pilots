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
    
    // =================
    // For the Host to run
    
    public func CreateNewGame(){
        isHost = true
        MultiplayerHandler.GenerateUniqueGameCode()
    }
    
    
    public func SetUniqueCode(code: Int){
        // we have created a code, we must now finish init game
        gameID = code
        DataPusher.PushData(path: "Games/\(code)/Host", Value: Global.playerData.username)
        DataPusher.PushData(path: "Games/\(code)/Map", Value: map)
        DataPusher.PushData(path: "Games/\(code)/Mode", Value: mode)
        DataPusher.PushData(path: "Games/\(code)/Status", Value: "Lobby")
        DataPusher.PushData(path: "Games/\(code)/PlayerList/\(Global.playerData.username)", Value: "PePeNotGone")
        Global.gameData.host = Global.playerData.username
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

    
    public func ResetGameData(){
        Global.multiplayerHandler.StopListenForGuestChanges()
        Global.multiplayerHandler.StopListenForHostChanges()
        Global.multiplayerHandler.StopListenForModeChanges()
        Global.multiplayerHandler.StopListenForMapChanges()
        
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerList/\(Global.playerData.username)", Value: "PePeGone")
        
        
        Global.multiplayerHandler.StopListenForGuestChanges()
        for x in shipsToUpdate{
            if let ship = x as? RemoteSpaceship {
                ship.StopListenToShip()
            }
        }
        
        if isHost {
            Global.multiplayerHandler.SetNewHost()
        }
        
        shipsToUpdate = []
        host = ""
        map = "OnlineCubis"
        mode = "ffa"
        playerShip?.spaceShipParent.removeFromParent()
    }
}
