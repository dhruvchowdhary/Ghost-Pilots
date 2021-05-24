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
    public static var isImm = false
    public static var isPowered = true
    
    static func getImm () -> Bool{
        if isImm {return true}
        
        isImm = true
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: {_ in
            self.isImm = false
        })
        return false
    }
    
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
        
        gameData.skView.showsPhysics = false
        gameData.skView.showsDrawCount = false
        gameData.skView.showsFPS = false
        
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
