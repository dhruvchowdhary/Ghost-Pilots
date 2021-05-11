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
    let save = UserDefaults.standard
    var totalGameTime: Double = 0
    
    var zoomScale: CGFloat = 0.25
    var zoomOrigin: CGPoint = CGPoint()
    var freezeTime: TimeInterval = 5
    
    var bulletsRegenTimers: [Timer] = []
    
    private var zoomUnitToPercent: CGFloat = 0
    private var isZoomin = false
    private var completedZoomPercent: CGFloat = 1.0
    private var zoomrate: CGFloat =  0.0
    private var checkpoints: [CPCheckpoint] = []
    
    var pauseTime = 3
    let pauseTimer = SKSpriteNode(imageNamed: "reviveTimer")
    let pauseTimerNumber = SKLabelNode(text: "3")
    
    let dimPanel = SKSpriteNode(color: UIColor.black, size: CGSize(width: 20000, height: 10000) )
    
    // this will be overriden in the levels and then callback manual setup
    override func didMove(to view: SKView) {
        
        walls = createBounds()
        for i in walls! {
            
            // Need to set the physics body here
            if let e = i as? SKShapeNode {
                i.physicsBody = SKPhysicsBody(edgeLoopFrom: e.path!)
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
        
        for i in createEnemyShips() {
            addObjectToScene(node: i.shipNode!, nodeClass: i)
            addChild(i.vanityNode)
            managedShips.append(i)
        }
        
        for i in createCheckpoints() {
            addObjectToScene(node: i.node, nodeClass: i)
            checkpoints.append(i)
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
        
        for i in createGameObjects() {
            addObjectToScene(node: i.node, nodeClass: i)
            i.level = self
        }
        
        
        
        self.dimPanel.zPosition = 50
        self.dimPanel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(self.dimPanel)
        self.dimPanel.alpha = 0
        
        pauseTimer.position = CGPoint(x:  frame.midX, y: frame.midY)
        pauseTimerNumber.position = CGPoint(x:  pauseTimer.position.x, y:  pauseTimer.position.y - 40)
        camera?.addChild(pauseTimer)
        camera?.addChild(pauseTimerNumber)
        pauseTimer.xScale = 0.3
        pauseTimer.yScale = 0.3
        pauseTimer.alpha = 0
        pauseTimer.zPosition = 400
        
        pauseTimerNumber.zPosition = 401
        pauseTimerNumber.fontColor = UIColor.black
        pauseTimerNumber.fontSize = 120
        pauseTimerNumber.fontName = "AvenirNext-Bold"
        pauseTimerNumber.alpha = 0
        
     
        
        
    }
    
    func collectedReward(id:Int){
        for cp in checkpoints {
            if cp.rewardId == id {
                cp.unlockedAction()
            }
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
        // add a popup here
        togglePause()
        playerShip?.backButton.isHidden = true
        playerShip?.pauseButton.isHidden = true
    }
    
    func youWin(){
        completeLevel()
        Global.loadScene(s: "Campaign")
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
    public func completeLevel(){
        // grab the level's int
        let str = String(describing: self.classForCoder)
        let index = str.index(str.startIndex, offsetBy: 7)
        let gg = Int(str[index...])
        
        var completedLevels: [Int] = []
        if (save.value(forKey: "completedLevels") != nil) {
            completedLevels = save.value(forKey: "completedLevels") as! [Int]
        } else {
            fatalError("what the actual frick")
        }
        // First completion
        if !completedLevels.contains(gg!) {
            completedLevels.append(gg!)
            save.setValue(completedLevels, forKey: "completedLevels")
            Global.gameData.addPolyniteCount(delta: 50)
        }
    }
    
    public func togglePause(){
        
        pauseTime = 3
        
        
        // Handle all skactions
        if !isGamePaused {
            isGamePaused = !isGamePaused
            
            dimPanel.alpha = 0.3
            for timer in bulletsRegenTimers {
                timer.invalidate()
            }
            bulletsRegenTimers = []
            speed = 0
            lastRecordedTime = 0
            
            // All the ships and their sub bullets
            for i in managedShips {
                i.togglePause(isPaused: isGamePaused)
            }
            playerShip?.togglePause(isPaused: isGamePaused)
            switchHud()
            
        } else {
          
            
            pauseTimerNumber.alpha = 1
            pauseTimer.alpha = 1
            pauseTimerNumber.text = String(pauseTime)
            dimPanel.alpha = 0
            
            for i in 1..<4 {
                let pauseTimerr = Timer.scheduledTimer(withTimeInterval: TimeInterval(i), repeats: false) { [self] (timer) in
                    pauseTime -= 1
                    pauseTimerNumber.text = String(pauseTime)
                    print("HIIII")
                    if pauseTime == 0 {
                        isGamePaused = !isGamePaused
                        print("HELLLLO")
                        speed = 1
                        bulletsRegenTimers.append(Timer.scheduledTimer(withTimeInterval: TimeInterval(playerShip!.bulletRegenRate), repeats: false, block: {_ in
                            self.playerShip?.unfiredBullets[2].alpha = 100
                            self.playerShip!.isBulletRecharging = false
                            self.playerShip!.rechargeBullet()
                            
                        }))
                        pauseTimerNumber.alpha = 0
                        pauseTimer.alpha = 0
                        // All the ships and their sub bullets
                        for i in managedShips {
                            i.togglePause(isPaused: isGamePaused)
                        }
                        playerShip?.togglePause(isPaused: isGamePaused)
                        
                        for timer in bulletsRegenTimers {
                            timer.invalidate()
                        }
                        bulletsRegenTimers = []
                        speed = 0
                        lastRecordedTime = 0
                        switchHud()
                        
                    }
                }
            }

           
        }
        
        
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
        
        totalGameTime += Double(currentTime - lastRecordedTime)
        print(totalGameTime)
        
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
    case HarmlessExplode, DamagingExplode, RewardObject, DirectDamage, None, Custom
}
