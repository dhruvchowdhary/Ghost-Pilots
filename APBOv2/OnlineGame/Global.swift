import SceneKit
import Foundation
import SpriteKit

public struct Global {
    public static var playerData = PlayerData()
    public static var gameData = GameData()
    public static let multiplayerHandler = MultiplayerHandler()
    public static var gameViewController: GameViewController?
    public static let adHandler = AdHandler()
    public static var sceneString = ""
    
    static func loadScene(s: String) {
        sceneString = s
        
        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed: s) else {
            print("Could not make \(s), check the name is spelled correctly")
            return
        }
        /* 3) Ensure correct aspect mode */
        if UIDevice.current.userInterfaceIdiom == .pad {
            scene.scaleMode = .aspectFit
        } else {
            scene.scaleMode = .aspectFill
        }
        
        gameData.skView.showsPhysics = true
        gameData.skView.showsDrawCount = true
        gameData.skView.showsFPS = true
        
        // Run in main thread
        /* 4) Start game scene */
        gameData.skView.presentScene(scene)
    
    }
    
    static func loadSceneGame(s: String) {
        
        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed: s) else {
            print("Could not make \(s), check the name is spelled correctly")
            return
        }
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill
        
        gameData.skView.showsPhysics = false
        gameData.skView.showsDrawCount = false
        gameData.skView.showsFPS = false
        
        // Run in main thread
        /* 4) Start game scene */
        gameData.skView.presentScene(scene)
    
    }
}
