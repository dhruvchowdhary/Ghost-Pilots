import Foundation
import SpriteKit

class Campaign: SKScene {
    var levelNodes: [MSButtonNode] = []
    var levelStrings: [String] = []
    let linesMaster = SKNode()
    var completedLevels: [Int] = [-1,0]
    let save = UserDefaults.standard
    let cameraNode =  SKCameraNode()
    var previousCameraPoint = CGPoint.zero
    var backButtonNode: MSButtonNode?
    let panGesture = UIPanGestureRecognizer()
    var currentHandler = {}
    
    override func didMove(to view: SKView) {
        
        
        panGesture.addTarget(self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    override func sceneDidLoad() {
        
        
        addChild(cameraNode)
        camera = cameraNode
        camera?.zPosition = 100
        
        if (save.value(forKey: "completedLevels") != nil) {
            completedLevels = save.value(forKey: "completedLevels") as! [Int]
        } else {
            save.setValue (completedLevels, forKey: "completedLevels")
        }
        
        levelNodes =
            [
                MSButtonNode(imageNamed: "Mike"),
                MSButtonNode(imageNamed: "lvl1"),
                MSButtonNode(imageNamed: "lvl2"),
                MSButtonNode(imageNamed: "lvl3"),
                MSButtonNode(imageNamed: "easy"),
                MSButtonNode(imageNamed: "medium"),
                MSButtonNode(imageNamed: "hard"),
                MSButtonNode(imageNamed: "expert")
            ]
        
        levelStrings =
            [
                "GameScene",
                "Level1",
                "Level2",
                "Level3",
                "TurretBoss",
                "TurretBoss",
                "TurretBoss",
                "TurretBoss"
            ]
        
        
        backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
        backButtonNode?.removeFromParent()
        camera?.addChild(backButtonNode!)
        
        // Here is where i position the stuff
        backButtonNode?.xScale = 0.5
        backButtonNode?.yScale = 0.5
        backButtonNode?.position = CGPoint(x: -325,y: 125)
        backButtonNode?.zPosition = -10
        
        
        backButtonNode!.selectedHandlers = {
            Global.loadScene(s: "MainMenu")
        }
            
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        for i in 0..<levelNodes.count {
            let node = levelNodes[i]
            node.isUserInteractionEnabled = true
            node.state = .MSButtonStopAlphaChanges
            
            // Scale the node here
            node.xScale = 0.06
            node.yScale = 0.06
            
            // Position node
            if i != 0 {
                node.position = levelNodes[i-1].position
            } else {
                node.position.x = -300
            }
            
            node.position.y = CGFloat(-100 + 200 * (i % 2))
            node.position.x += CGFloat(150)
            node.zPosition = 5
            
            node.color = UIColor.yellow
            
            node.selectedHandler = {
                node.colorBlendFactor += 0.2
                
                // Set difficuties for turret bosses
                switch i {
                case 4,5,6,7:
                    UserDefaults.standard.setValue(i-3, forKey: "difficulty")
                default:
                    print("ok")
                }
                self.currentHandler = {
                    node.colorBlendFactor -= 0.2
                }
            }
            
            // ShadeNode and set handlers
            if completedLevels.contains(i-1){
                levelNodes[i].selectedHandlers = {
                    self.view!.removeGestureRecognizer(self.panGesture)
                    Global.loadScene(s: self.levelStrings[i])
                }
            } else {
                node.selectedHandlers = {
                    print("This stall is occupied")
                    //Possible alert the player msg here later
                }
                node.alpha = 0.3
            }
            
            // Does this level have Unique Properties? - add it here in the case switch
            switch i {
            case 0:
                node.position.y = 0
                node.position.x = -100
                node.xScale = 0.2
                node.yScale = 0.2
            case 1:
                node.position.y -= 100
                node.position.x += 150
            default:
                print("should be a normal lvl")
            }
            
            scene?.addChild(node)
        }
        drawLines()
    }
    
    func drawLines(){
        for i in 1..<levelNodes.count {
            // The path and shape for new line
            let newLine = SKShapeNode()
            let drawPath = CGMutablePath()
            
            let node0 = levelNodes[i-1]
            let node1 = levelNodes[i]
            
            drawPath.move(to: node0.position)
            drawPath.addLine(to: node1.position)
            newLine.path = drawPath
            newLine.strokeColor = SKColor.white
            newLine.isUserInteractionEnabled = false
            newLine.zPosition = 0
            newLine.lineWidth += 3
            if !completedLevels.contains(i-1){
                newLine.fillColor = UIColor.darkGray
                newLine.strokeColor = UIColor.darkGray
            }
            linesMaster.addChild(newLine)
        }
        linesMaster.zPosition = -10
        addChild(linesMaster)
    }
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        // The camera has a weak reference, so test it
        guard let camera = self.camera else {
            return
        }
        
        //  let zoomInActionipad = SKAction.scale(to: 1.7, duration: 0.01)
        
        //  camera.run(zoomInActionipad)
        
        // If the movement just began, save the first camera position
        if sender.state == .began {
            previousCameraPoint = camera.position
            currentHandler()
            currentHandler = {}
        }
        // Perform the translation
        let translation = sender.translation(in: self.view)
        
        var newPosition = CGPoint(
            x: previousCameraPoint.x + translation.x * -1,
            y: previousCameraPoint.y
        )
        if newPosition.x < 0 { newPosition.x = 0}
        camera.position = newPosition
        
        
    }
    
    
    
}
