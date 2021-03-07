import SpriteKit
import StoreKit

class LoadLevelsMenu: SKScene {
    
    /* UI Connections */
    var buttonPlay: MSButtonNode!
    var backButtonNode: MSButtonNode!
    var level1ButtonNode: MSButtonNode!
    var level2ButtonNode: MSButtonNode!
    var level3ButtonNode: MSButtonNode!
    var useCount = UserDefaults.standard.integer(forKey: "useCount")
    var difficulty = UserDefaults.standard.integer(forKey: "difficulty")
    
    override func didMove(to view: SKView) {
    
            /* Setup your scene here */
            if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: frame.midX, y: frame.midY)
                //      particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
            }
            self.sceneShake(shakeCount: 4, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1)
            self.run(SKAction.playSoundFileNamed("menuThumpnew", waitForCompletion: false))
            /* Set UI connections */
            backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
            backButtonNode.selectedHandlers = {
                self.loadMainMenu()
                //       skView.presentScene(scene)
            }
        
        level1ButtonNode = self.childNode(withName: "level1") as? MSButtonNode
        level1ButtonNode.selectedHandlers = {
            self.loadLevel1()
        }
        
        level2ButtonNode = self.childNode(withName: "level2") as? MSButtonNode
        level2ButtonNode.selectedHandlers = {
            self.loadLevel2()
        }
        
        level3ButtonNode = self.childNode(withName: "level3") as? MSButtonNode
        level3ButtonNode.selectedHandlers = {
            self.loadLevel3()
        }
            
            
            if UIDevice.current.userInterfaceIdiom != .pad {
                if UIScreen.main.bounds.width < 779 {
                    backButtonNode.position.x = -600
                    backButtonNode.position.y =  300
                }
            }
            
    
    
    }
    
    func sceneShake(shakeCount: Int, intensity: CGVector, shakeDuration: Double) {
        let sceneView = self.scene!.view! as UIView
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = shakeDuration / Double(shakeCount)
        shakeAnimation.repeatCount = Float(shakeCount)
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x - intensity.dx, y: sceneView.center.y - intensity.dy))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x + intensity.dx, y: sceneView.center.y + intensity.dy))
        sceneView.layer.add(shakeAnimation, forKey: "position")
    }
    
    func loadLevel1() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed:"Level1") else {
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
    
    func loadLevel2() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed:"Level2") else {
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
    
    func loadLevel3() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed:"Level3") else {
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
    
    func loadMainMenu() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }

        /* 2) Load Menu scene */
        guard let scene = GameScene(fileNamed:"SoloMenu") else {
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
}

