import Foundation
import SpriteKit

class CPLevelBase: SKScene, SKPhysicsContactDelegate {
    var managedShips: [CPSpaceshipBase] = []
    var playerShip: CPPlayerShip?
    var isSetup = false
    var walls: [SKNode]?
    var lastRecordedTime: Double = 0.0
    var isGamePaused = false
    var colHandle: CPCollisionHandler?
    var LITERALLYEVERYOBJECTINTEHSCENE: [AnyObject] = []
    
    var zoomScale: CGFloat = CGFloat()
    var zoomOrigin: CGPoint = CGPoint()
    var freezeTime: TimeInterval = 00
    
    var isZoomin = false
    var completedZoomPercent = 0.0
    var zoomrate =  0.0
    
    // this will be overriden in the levels and then callback manual setup
    override func didMove(to view: SKView) {
        walls = createBounds()
        for i in walls! {
            
            // Need to set the physics body here
            if let e = i as? SKShapeNode {
                i.physicsBody = SKPhysicsBody(edgeChainFrom: e.path!)
            }
            
            if let e = i as? SKSpriteNode {
                i.physicsBody = SKPhysicsBody(texture: e.texture!, size: e.size)
            }
            
            if (i.physicsBody == nil){
                fatalError("I Blame Vincent")
            }
            
            i.physicsBody!.categoryBitMask = CPUInt.walls
            i.physicsBody!.collisionBitMask = CPUInt.empty
            i.physicsBody!.contactTestBitMask = CPUInt.empty
            
            i.zPosition = 5
            
            addObjectToScene(node: i, nodeClass: CPObject(node: i, action: Actions.None))
            
            // Hide and zoom out
            playerShip?.setHudHidden(isHidden: true)
            togglePause()
            camera?.setScale(zoomScale)
            Timer.scheduledTimer(withTimeInterval: freezeTime, repeats: false) { (timer) in
                self.handleCameraZoomIn()
            }
        }
        
        for i in createGameObjects() {
            addObjectToScene(node: i.node, nodeClass: i)
        }
        
        for i in createEnemyShips() {
            addObjectToScene(node: i.shipNode!, nodeClass: i)
            managedShips.append(i)
        }
        
        for i in createCheckpoints() {
            addObjectToScene(node: i.node, nodeClass: i)
        }
        
        self.physicsWorld.contactDelegate = self
        
        // Setup player ship
        createPlayerShip()
        scene?.camera = playerShip?.camera
        addObjectToScene(node: (playerShip?.shipParent)!, nodeClass: playerShip!)
        playerShip?.shipNode?.name = playerShip?.shipParent.name
        
        addBackground()
        colHandle = CPCollisionHandler(sceneClass: self)
        
        handleCameraZoomIn()
    }
    
    func setupCameraZoomIn(){
        fatalError("Need to override setupCameraZoomIn")
    }
    
    func createGameObjects() -> [CPObject]{
        fatalError("Need to override createGameObjects")
    }
    
    func createEnemyShips() -> [CPSpaceshipBase]{
        fatalError("Need to ovveride createEnemyShips")
    }
    
    func createCheckpoints() -> [CPCheckpoint]{
        fatalError("Need to ovveride createCheckPoints")
    }
    
    func createBounds() -> [SKNode] {
        //this must be ovveridden by ech level,can use some preset options
        fatalError("Need to ovveride create bounds")
    }
    
    func youLose(){
        
    }
    
    func youWin(){
        Global.gameData.addPolyniteCount(delta: 1)
        Global.loadScene(s: "MainMenu")
    }
    
    func createPlayerShip(){
        playerShip = CPPlayerShip(lvl: self)
    }
    
    func handleCameraZoomIn() {
        if isZoomin{
            if (completedZoomPercent < 0.5){
               // zo
            } else {
                
            }
        } else {
        }
    }
    
    func addBackground() {
        backgroundColor = SKColor(red: 14.0/255, green: 23.0/255, blue: 57.0/255, alpha: 1)
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            particles.zPosition = -100
            addChild(particles)
        }
    }
    
    public func togglePause(){
        isGamePaused = !isGamePaused
        
        // All the ships and their sub bullets
        for i in managedShips {
            i.togglePause(isPaused: isGamePaused)
        }
        playerShip?.togglePause(isPaused: isGamePaused)
        
        // Handle all skactions
        if isGamePaused {
            speed = 0
            lastRecordedTime = 0
        } else {
            speed = 1
        }
        
        switchHud()
    }
    
    public func matrixMode(speed: CGFloat) {
        scene?.speed = speed
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        colHandle!.collision(nodeA: contact.bodyA.node!, nodeB: contact.bodyB.node!, possibleNodes: LITERALLYEVERYOBJECTINTEHSCENE)
    }
    
    func triggerExplosion(origin: CGPoint, radius: CGFloat){
        
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
        for ship in managedShips {
            ship.AiMovement(playerShip: playerShip!)
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
    // 999 = all enemys on the scene
    var kilsReqToUnlock = 999
    var node: SKSpriteNode
    
    init(pos: CGPoint, texture: String) {
        node = SKSpriteNode(imageNamed: texture)
        node.position = pos
        node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.size)
        node.physicsBody?.affectedByGravity = false
        
        // ignore collisions with everything, only contacts with player
        node.physicsBody!.contactTestBitMask = 100
        node.physicsBody?.collisionBitMask = 0
        node.physicsBody?.contactTestBitMask = 10
        node.physicsBody?.isDynamic = false
    }
}

public enum Actions{
    case HarmlessExplode, DamagingExplode, RewardObject, DirectDamage, None
}
