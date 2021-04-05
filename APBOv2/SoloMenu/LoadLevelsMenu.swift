import SpriteKit
import StoreKit

class LoadLevelsMenu: SKScene {
    let cameraNode =  SKCameraNode()
    
    var previousCameraPoint = CGPoint.zero
    
    /* UI Connections */
    var buttonPlay: MSButtonNode!
    var backButtonNode: MSButtonNode!
    var level1ButtonNode: MSButtonNode!
    var level2ButtonNode: MSButtonNode!
    var level3ButtonNode: MSButtonNode!
    var useCount = UserDefaults.standard.integer(forKey: "useCount")
    var difficulty = UserDefaults.standard.integer(forKey: "difficulty")
    
    override func didMove(to view: SKView) {
        
        addChild(cameraNode)
        camera = cameraNode
       // cameraNode.position.x = frame.width / 2
       // cameraNode.position.y = frame.height / 2
        
       
        
        let panGesture = UIPanGestureRecognizer()
            panGesture.addTarget(self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGesture)
    
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
        level1ButtonNode.selectedHandler = {
            self.level1ButtonNode.alpha = 1

        }
        
        level2ButtonNode = self.childNode(withName: "level2") as? MSButtonNode
        level2ButtonNode.selectedHandlers = {
            self.loadLevel2()
        }
        level2ButtonNode.selectedHandler = {
            self.level2ButtonNode.alpha = 1

        }
        
        level3ButtonNode = self.childNode(withName: "level3") as? MSButtonNode
        level3ButtonNode.selectedHandlers = {
            self.loadLevel3()
        }
        level3ButtonNode.selectedHandler = {
            self.level3ButtonNode.alpha = 1

        }
        
        loadPath()
        
        level1ButtonNode.position = CGPoint(x: -700, y: -240)
        level2ButtonNode.position = CGPoint(x: -500, y: 240)
        level3ButtonNode.position = CGPoint(x: -300, y: -180)
            
            
            if UIDevice.current.userInterfaceIdiom != .pad {
                if UIScreen.main.bounds.width < 779 {
                    backButtonNode.position.x = -600
                    backButtonNode.position.y =  300
                }
            }
            
    
    
    }
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
       // The camera has a weak reference, so test it
       guard let camera = self.camera else {
         return
       }
        
        let zoomInActionipad = SKAction.scale(to: 1.7, duration: 0.01)
        
    

            camera.run(zoomInActionipad)
            
       // If the movement just began, save the first camera position
       if sender.state == .began {
         previousCameraPoint = camera.position
       }
       // Perform the translation
       let translation = sender.translation(in: self.view)
       let newPosition = CGPoint(
         x: previousCameraPoint.x + translation.x * -1,
         y: previousCameraPoint.y + translation.y
       )
       camera.position = newPosition
     }
    
    
    func loadPath() {
        
        let path = UIBezierPath()
         
         UIColor.white.setStroke()
         path.lineWidth = 20

        path.move(to: .zero)
         path.stroke()
         
     path.addLine(to: CGPoint(x: 200 , y: 480))
        path.addLine(to: CGPoint(x: 400 , y: 60))

     
     let shapeNode = SKShapeNode(path: path.cgPath)
     shapeNode.position.x = -700
     shapeNode.position.y = -240
        shapeNode.strokeColor = UIColor.white
     shapeNode.zPosition = 2
     shapeNode.lineWidth = 10
     shapeNode.alpha = 1
     addChild(shapeNode)
  
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

