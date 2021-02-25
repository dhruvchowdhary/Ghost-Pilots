import Foundation
import SpriteKit

// Created on game creation
public class GameData{
    public var gameID = 00000
    public var shipsToUpdate: [SpaceshipBase] = []
    public var playerShip: LocalSpaceship? //Also included in shipsToUpdate
    public var camera = SKCameraNode()
    public var gameScene = GameSceneBase()
    public var skView = SKView();
    
    
    // =================
    // For the Host to run
    
    public func CreateNewGame(){
        MultiplayerHandler.GenerateUniqueGameCode()
    }
    
    
    public func SetUniqueCode(code: Int){
        // we have created a code, we must now finish init game
        gameID = code
        DataPusher.PushData(path: "Games/\(code)/Host", Value: Global.playerData.username)
        DataPusher.PushData(path: "Games/\(code)/Status", Value: "Lobby")
        Global.loadScene(s: "LobbyMenu")
    }
    
    // ==============
    // For guest to run

}
