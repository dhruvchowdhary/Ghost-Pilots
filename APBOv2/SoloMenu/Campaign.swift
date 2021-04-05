import Foundation
import SpriteKit

class Campaign: SKScene {
    var levelNodes: [MSButtonNode] = []
    var levelStrings: [String] = []
    let linesMaster = SKNode()
    var completedLevels: [Int] = [-1]
    let save = UserDefaults.standard
    
    override func sceneDidLoad() {
        if (save.value(forKey: "completedLevels") != nil) {
            completedLevels = save.value(forKey: "completedLevels") as! [Int]
        } else {
            save.setValue (completedLevels, forKey: "completedLevels")
        }
        
        levelNodes =
        [
            MSButtonNode(imageNamed: "lvl1"),
            MSButtonNode(imageNamed: "lvl2"),
            MSButtonNode(imageNamed: "lvl3"),
            MSButtonNode(imageNamed: "")
        ]
        
        levelStrings =
        [
            "Level1",
            "Level2",
            "Level3"
        ]
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        for i in 0..<levelNodes.count {
            let node = levelNodes[i]
            
            // Scale the node here
            node.xScale = 0.07
            node.yScale = 0.07
            
            // Position node
            node.position.y = 100
            node.position.y += CGFloat(-200 * (i % 2))
            node.position.x = -300
            node.position.x += CGFloat(75 * i)
            node.zPosition = 5
            
            // ShadeNode and set handlers
            if completedLevels.contains(i-1){
                print(i)
                levelNodes[i].selectedHandler = {
                    print(i)
                    //Global.loadScene(s: self.levelStrings[i])
                }
            } else {
                node.selectedHandler = {
                    print("dont enter")
                    print(i)
                }
                node.color = UIColor.darkGray
                node.colorBlendFactor = 0.8
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
        addChild(linesMaster)
    }
    
}
