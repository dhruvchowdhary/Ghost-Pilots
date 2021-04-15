import Foundation
import SpriteKit

class CPLevelBase: SKScene, SKPhysicsContactDelegate {
    var aiManagedShips: [CPSpaceshipBase] = []
    var playerShip: CPPlayerShip?
    var isSetup = false
    var boundriesNode: SKNode?
    var lastRecordedTime: Double = 0.0
    var isGamePaused = false
    let colHandle = CPCollisionHandler()
    var LITERALLYEVERYOBJECTINTEHSCENE: [AnyObject] = []
    
    // this will be overriden in the levels and then callback manual setup
    override func didMove(to view: SKView) {
         boundriesNode = createBounds()
        addObjectToScene(node: boundriesNode!, nodeClass: CPObject(node: boundriesNode!))
        
        
        self.physicsWorld.contactDelegate = self
        
        // Setup player ship
        createPlayerShip()
        scene?.camera = playerShip?.camera
        addObjectToScene(node: (playerShip?.shipParent)!, nodeClass: playerShip!)
        
        
        addBackground()
        isSetup = true
    }
    
    // This is called by the base class when the proper arrays have been updated
    func ManualSetup(){
    }
    
    func createBounds() -> SKNode{
        //this must be ovveridden by ech level,can use some preset options
        fatalError("Must ovveride create bounds")
    }
    
    func createPlayerShip(){
        playerShip = CPPlayerShip()
    }
    
    func addBackground() {
        // Ok fine, this does not need to be in the array
        backgroundColor = SKColor(red: 14.0/255, green: 23.0/255, blue: 57.0/255, alpha: 1)
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            particles.zPosition = -100
            addChild(particles)
        }
    }
    
    public func togglePause(){
        isGamePaused = !isGamePaused
        if isGamePaused {
            speed = 0
        } else {
            speed = 1
        }
        switchHud()
        for i in aiManagedShips {
            i.shipNode?.physicsBody?.velocity = CGVector()
        }
        playerShip?.shipNode?.physicsBody?.velocity = CGVector()
    }
    
    public func matrixMode(speed: CGFloat) {
        scene?.speed = speed
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        colHandle.collision(nodeA: contact.bodyA.node!, nodeB: contact.bodyB.node!, possibleNodes: LITERALLYEVERYOBJECTINTEHSCENE)
    }
    
    func switchHud(){
        let hud = playerShip?.hudNode
        hud?.childNode(withName: "shootButton")!.isHidden = isGamePaused
        hud?.childNode(withName: "back")!.isHidden = !isGamePaused
        hud?.childNode(withName: "turnButton")!.isHidden = isGamePaused
        hud?.childNode(withName: "phaseButton")?.isHidden = isGamePaused
        hud?.childNode(withName: "restart")?.isHidden = !isGamePaused
        hud?.childNode(withName: "ejectButton")?.isHidden = isGamePaused
    }
    
    func switchShips(){
        playerShip?.shipNode?.removeAllActions()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if isGamePaused {
            //Ion know do some pause stuff here
            return
        }
        
        if lastRecordedTime == 0 {
            lastRecordedTime = currentTime
        }
        
        if !isSetup{return}
        for ship in aiManagedShips {
            ship.handleAImovement(playerShip: playerShip!)
        }
        
        playerShip?.ManualUpdate(deltaTime: CGFloat((currentTime - lastRecordedTime)))
        
        lastRecordedTime = currentTime
    }
    
    func addObjectToScene(node: SKNode, nodeClass: AnyObject){
        LITERALLYEVERYOBJECTINTEHSCENE.append(nodeClass)
        node.name = String(LITERALLYEVERYOBJECTINTEHSCENE.count - 1)
        scene?.addChild(node)
    }
}

class CPCheckpoint {
    var isCustomInteract = false
    var isStartpoint = false
    var isEndpoint = false
    var node = SKNode()
    
    init(pos: CGPoint) {
        node.position = pos
        node.physicsBody = SKPhysicsBody()
        node.physicsBody!.contactTestBitMask = 100
    }
}

class CPObject {
    var node: SKNode
    
    // Movement options
    var nodePhysics: SKPhysicsBody?
    
    // Activation methods
    var preformActionOnShoot = false
    var preformActionOnContact = false
    
    // Hazardous options
    var isKill = false
    
    // Rewardable options
    var rewardedObject = "NIL"
    
    init(imageNamed: String) {
        let pepenode = SKSpriteNode(imageNamed: imageNamed)
        node = pepenode
        nodePhysics = SKPhysicsBody(texture: pepenode.texture!, size: pepenode.size)
        node.physicsBody = nodePhysics
        node.physicsBody?.isDynamic = false
    }
    
    init (node: SKNode){
        self.node = node
    }
    
}
