import SpriteKit
import StoreKit

class SoloMenu: SKScene {
     let endlessLeaderboard = SKLabelNode(text: "Leaderboard")
    /* UI Connections */
    var endlessButtonNode: MSButtonNode!
    var levelsButtonNode: MSButtonNode!
    var turretBossButtonNode: MSButtonNode!
    var backButtonNode: MSButtonNode!
    var leaderboardButtonNode: MSButtonNode!
    var useCount = UserDefaults.standard.integer(forKey: "useCount")
    
    override func didMove(to view: SKView) {
        Global.gameData.gameState = GameStates.SoloMenu
        
        useCount += 1 //Increment the useCount
        UserDefaults.standard.set(useCount, forKey: "useCount")
        if useCount == 1 {
            loadTutorial()
        } else {
            if useCount == 6 {
                SKStoreReviewController.requestReview() //Request the review.
            }
            /* Setup your scene here */
            if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: frame.midX, y: frame.midY)
                //      particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
            }
            Global.sceneShake(shakeCount: 4, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1, sceneview: self.scene!)
            self.run(SKAction.playSoundFileNamed("menuThumpnew", waitForCompletion: false))
            /* Set UI connections */
            backButtonNode = self.childNode(withName: "back") as? MSButtonNode
            backButtonNode.selectedHandlers = {
//                let e = LocalSpaceship()
//                Global.gameData.playerShip = e
//                Global.gameData.shipsToUpdate.append(e)
//                self.loadScene(s: "GameSceneBase")
                //Global.loadScene(s: "MainMenu")
                Global.loadScene(s: "MainMenu")
            }
            
            if UIDevice.current.userInterfaceIdiom != .pad {
                if UIScreen.main.bounds.width < 779 {
                    backButtonNode.position.x = -600
                    backButtonNode.position.y =  300
                }
            }
            
            endlessButtonNode = self.childNode(withName: "endlessButton") as? MSButtonNode
            endlessButtonNode.selectedHandlers = {
                self.loadGame()
            }
            
            turretBossButtonNode = self.childNode(withName: "turretbossButton") as? MSButtonNode
            turretBossButtonNode.selectedHandlers = {
                self.loadTurretBoss()
            }
            
    /*        levelsButtonNode = self.childNode(withName: "levelsButton") as? MSButtonNode
            levelsButtonNode.selectedHandlers = {
                Global.loadScene(s: "LoadLevelsMenu")
            }*/
         
            
            leaderboardButtonNode = self.childNode(withName: "leaderboardButton") as? MSButtonNode
            leaderboardButtonNode.selectedHandlers = {
                if GameCenter.shared.isAuthenticated {
                    NotificationCenter.default.post(name: Notification.Name("showLeaderboard"), object: nil)
                } else {
                    let alert = UIAlertController(title: "Game Center Error", message: "You are currently not logged into Game Center! Log in to view the leaderboard." , preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
                self.leaderboardButtonNode.alpha = 1
            }
            
            leaderboardButtonNode.position = CGPoint(x: frame.maxX - 275 , y: frame.minY + 175)
                   endlessLeaderboard.fontName = "AvenirNext-Bold"
                   endlessLeaderboard.position = CGPoint(x: leaderboardButtonNode.position.x, y: leaderboardButtonNode.position.y - 125)
                         endlessLeaderboard.fontColor = UIColor.white
                         endlessLeaderboard.zPosition = 2
                         endlessLeaderboard.fontSize = 40
                         addChild(endlessLeaderboard)
        }
    }
    
    func loadGame() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Game scene */
        guard let scene = GameScene(fileNamed:"GameScene") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }

        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill

        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false

        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    func loadTurretBoss() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Game scene */
        guard let scene = TurretBossMenu(fileNamed:"TurretBossMenu") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }

        /* 3) Ensure correct aspect mode */
        if UIDevice.current.userInterfaceIdiom == .pad {
            scene.scaleMode = .aspectFit
        } else {
            scene.scaleMode = .aspectFill
        }

        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false

        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func loadTutorial() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Game scene */
        guard let scene = Tutorial(fileNamed:"Tutorial") else {
            print("Could not make Tutorial, check the name is spelled correctly")
            return
        }

        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill

        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false

        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
}
