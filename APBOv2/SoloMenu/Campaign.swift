import Foundation
import SpriteKit

class Campaign: SKScene {
    var levelNodes: [MSButtonNode] = []
    var levelStrings: [String] = []
    let linesMaster = SKNode()
    var completedLevels: [Int] = []
    let save = UserDefaults.standard
    
    override func sceneDidLoad() {
        if (save.value(forKey: "completedLevels") != nil) {
            completedLevels = save.value(forKey: "completedLevels") as! [Int]
        }
        
        levelNodes =
        [
            MSButtonNode(imageNamed: "lvl1"),
            MSButtonNode(imageNamed: "lvl2"),
            MSButtonNode(imageNamed: "lvl3")
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
            
            // ShadeNode
            
            node.selectedHandlers = {
                if i != 0 {
                    if self.completedLevels.contains(i-1){
                        
                    }
                }
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
            linesMaster.addChild(newLine)
        }
        addChild(linesMaster)
    }
    
}
