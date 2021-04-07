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
    
    override func didMove(to view: SKView) {
        
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    override func sceneDidLoad() {
        
        
        addChild(cameraNode)
        camera = cameraNode
        
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
                MSButtonNode(imageNamed: "lvl3"),
                MSButtonNode(imageNamed: "lvl3")
            ]
        
        levelStrings =
            [
                "GameScene",
                "Level1",
                "Level2",
                "Level3"
            ]
        
        
        backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
        backButtonNode!.alpha = 0
        backButtonNode!.selectedHandlers = {
            Global.loadScene(s: "Campaign")
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
            
            // ShadeNode and set handlers
            if completedLevels.contains(i-1){
                levelNodes[i].selectedHandler = {
                    Global.loadScene(s: self.levelStrings[i])
                }
            } else {
                node.selectedHandler = {
                    print("dont enter")
                    print(i)
                }
                node.color = UIColor.darkGray
                node.colorBlendFactor = 0.8
            }
            
            // Does this level have Unique Properties? - add it here in the case switch
            switch i {
            case 2:
                node.position.y += 100
                node.position.x += 300
                node.xScale = 0.2
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
