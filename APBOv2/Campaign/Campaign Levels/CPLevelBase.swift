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
    
    var zoomScale: CGFloat = 0.25
    var zoomOrigin: CGPoint = CGPoint()
    var freezeTime: TimeInterval = 5
    
    var bulletsRegenTimers: [Timer] = []
    
    private var zoomUnitToPercent: CGFloat = 0
    private var isZoomin = false
    private var completedZoomPercent: CGFloat = 1.0
    private var zoomrate: CGFloat =  0.0
    
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
                fatalError("Ion even know")
            }
            
            i.physicsBody!.categoryBitMask = CPUInt.walls
            i.physicsBody!.collisionBitMask = CPUInt.empty
            i.physicsBody!.contactTestBitMask = CPUInt.empty
            
            i.zPosition = 5
            
            addObjectToScene(node: i, nodeClass: CPObject(node: i, action: Actions.None))
            
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
        playerShip = CPPlayerShip(lvl: self)
        createPlayerShip()
        scene?.camera = playerShip?.camera
        addObjectToScene(node: (playerShip?.shipParent)!, nodeClass: playerShip!)
        playerShip?.shipNode?.name = playerShip?.shipParent.name
        
        addBackground()
        colHandle = CPCollisionHandler(sceneClass: self)
        
        // Hide and zoom out
        setupCameraZoomIn()
        playerShip?.setHudHidden(isHidden: true)
        camera?.speed = 1
        camera?.setScale(zoomScale)
        camera?.position = zoomOrigin
        zoomUnitToPercent = zoomScale - 1
        let pepe = Timer.scheduledTimer(withTimeInterval: freezeTime, repeats: false) { (timer) in
            self.isZoomin = true
        }
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
        //this must be overridden by ech level,can use some preset options
        fatalError("Need to ovveride create bounds")
    }
    
    func createPlayerShip(){
        fatalError("Need to ovveride createPlayerShip")
    }
    
    func youLose(){
        
    }
    
    func youWin(){
        Global.gameData.addPolyniteCount(delta: 1)
        Global.loadScene(s: "MainMenu")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isZoomin = true
    }
    // Need to take a serious deep dive into playership mechs
    func handleCameraZoomIn(dTime: TimeInterval) {
        completedZoomPercent = (zoomScale - 1) / zoomUnitToPercent
        if isZoomin {
            if completedZoomPercent < 0.65 {
                zoomrate -= CGFloat(dTime)*2.05
            } else {
                zoomrate += CGFloat(dTime)*4
            }
            
            if (zoomScale - (zoomrate * CGFloat(dTime))) < 1{
                completedZoomPercent = 0
                camera?.setScale(1)
                camera?.position = CGPoint()
                
                isSetup = true
                playerShip?.setHudHidden(isHidden: false)
            } else {
                zoomScale -= zoomrate * CGFloat(dTime)
                camera?.setScale(zoomScale)
                camera?.position = CGPoint(x: (completedZoomPercent * zoomOrigin.x), y: completedZoomPercent * zoomOrigin.y )
            }
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
            for timer in bulletsRegenTimers {
                timer.invalidate()
            }
            bulletsRegenTimers = []
            speed = 0
            lastRecordedTime = 0
        } else {
            speed = 1
            bulletsRegenTimers.append(Timer.scheduledTimer(withTimeInterval: TimeInterval(playerShip!.bulletRegenRate), repeats: false, block: {_ in
                self.playerShip?.unfiredBullets[2].alpha = 100
                self.playerShip!.isBulletRecharging = false
                self.playerShip!.rechargeBullet()
            }))
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
        
        if !isSetup{
            handleCameraZoomIn(dTime: (currentTime - lastRecordedTime))
            lastRecordedTime = currentTime
            return
        }
        
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


public enum Actions{
    case HarmlessExplode, DamagingExplode, RewardObject, DirectDamage, None
}
