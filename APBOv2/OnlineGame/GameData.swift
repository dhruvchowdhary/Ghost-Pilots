import Foundation
import SpriteKit

// Created on game creation
public class GameData{
    public var gameID = 00000
    public var shipsToUpdate: [SpaceshipBase] = []
    public var playerShip: LocalSpaceship? //Also included in shipsToUpdate
    public var camera = SKCameraNode()
    public var gameScene = GameSceneBase()
    
    
    // =================
    // For the Host to run
    
    public func CreateNewGame(){
        MultiplayerHandler.GenerateUniqueGameCode()
    }
    
    
    public func SetUniqueCode(code: Int){
        // we have created a code, we must now finish init game
        DataPusher.PushData(path: "Games/\(code)/\(UIDevice.current.identifierForVendor?.uuidString)", Value: "Null")
        DataPusher.PushData(path: "Games/\(code)/Status", Value: "Lobby")
        gameID = code
    }
    
    // ==============
    // For guest to run

}
