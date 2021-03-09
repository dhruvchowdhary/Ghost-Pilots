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
        DataPusher.PushData(path: "Games/\(code)/Status", Value: "Lobby")
        DataPusher.PushData(path: "Games/\(code)/Players/\(Global.playerData.username)", Value: "e")
        Global.gameData.host = Global.playerData.username
        Global.loadScene(s: "LobbyMenu")
    }
    
    // ==============
    // For guest to run

    
    public func ResetGameData(){
        Global.multiplayerHandler.StopListenForGuestChanges()
        for x in shipsToUpdate{
            if let ship = x as? RemoteSpaceship {
                ship.StopListenToShip()
            }
        }
        shipsToUpdate = []
        isHost = false
        host = ""
        map = "OnlineCubis"
        playerShip?.spaceShipParent.removeFromParent()
        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/\(Global.playerData.username)", Value: "NULL")
    }
}
