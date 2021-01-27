import Foundation

// Created on game creation
public class GameData{
    var gameID = 00000
    var shipPos = [0,0]
    var shipAngle = 0.0  // In degrees
    var shipSpeed = 0.0 // Idk how this is stored yet, doesnt need to be update until predict mov implemeted
    /// Host Init
    init() {
        gameID = Int.random(in: 10000...99999)
        if 
    }
    
    /// Guest Init
    init(GameID: Int) {
        
    }
}
