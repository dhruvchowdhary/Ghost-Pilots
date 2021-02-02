import Foundation

// Created on game creation
public class GameData{
    var gameID = 00000
    var shipPos = [0,0]
    var shipAngle = 0.0  // In degrees
    var shipSpeed = 0.0 // Idk how this is stored yet, doesnt need to be update until predict mov implemeted
    
    // =================
    // For the Host to run
    
    public func CreateNewGame(){
        MultiplayerHandler.GenerateUniqueGameCode()
    }
    
    
    public func SetUniqueCode(code: Int){
        // we have created a code, we must now finish init game
        DataPusher.PushData(path: "Games/\(code)/Host", Value: Global.playerData.playerID!)
        DataPusher.PushData(path: "Games/\(code)/Status", Value: "Lobby")
    }
    
    
    // ==============
    // For guest to run

}
