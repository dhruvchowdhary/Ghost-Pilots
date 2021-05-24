import SpriteKit
import Foundation



class CPChaserSpaceship : CPSpaceshipBase {
    init(level: CPLevelBase){
        
        var setup = CPSpaceshipSetup(imageNamed: "enemy1")
        setup.isMoving = false
        setup.shipPhisics.contactTestBitMask = CPUInt.bullet
        super.init(spaceshipSetup: setup, lvl: level)
    }
    
    override func AiMovement(playerShip: CPPlayerShip) {
        if isDead {return}
        if isMoving{
            let y = (playerShip.shipNode?.position.y)! - (shipNode?.position.y)!
            let x = (playerShip.shipNode?.position.x)! - (shipNode?.position.x)!
            shipNode?.zRotation = atan2(y,x ) - CGFloat.pi * 1 / 2
            
            shipNode?.physicsBody?.velocity = CGVector(dx: x/2 + 200 * cos(shipNode!.zRotation), dy: y/2 + 200 * sin(shipNode!.zRotation))
        } else {
            if inRangeCheck(pos1: playerShip.shipNode!.position, pos2: shipNode!.position, range: attackRange){
                isMoving = true
            }
        }
    }
}

class CPBoss : CPSpaceshipBase {
    var shootTimer: CGFloat = 0
    var holdingVel = CGVector(dx: 0, dy: -150)
    var face = SKSpriteNode(imageNamed: "Slice0")
    
    var loadDone = false
    var timeUp = false
    var bullets: [SKSpriteNode] = []
    var bulletC: [CPBullet] = []
    
    var runDir = CGVector()
    var isPepe = true
    
    init(level: CPLevelBase) {
        let setup = CPSpaceshipSetup(imageNamed: "BossBase")
        
        super.init(spaceshipSetup: setup, lvl: level)
        
        shipNode?.physicsBody!.restitution = 0.75
        shipNode?.physicsBody?.angularDamping = 0
        shipNode?.physicsBody?.linearDamping = 0
        shipNode?.physicsBody!.categoryBitMask = CPUInt.player
        shipNode?.physicsBody!.contactTestBitMask = CPUInt.player | CPUInt.APRound | CPUInt.bullet
        shipNode?.physicsBody!.collisionBitMask = CPUInt.walls | CPUInt.enemy | CPUInt.Boss
        
        health = 0
        
        shipNode?.addChild(face)
        face.zPosition += 5
        face.physicsBody = SKPhysicsBody()
        face.physicsBody?.affectedByGravity = false
        bulletSpeeds = 275
    }
    
    func takeAShot() {
        Timer.scheduledTimer(withTimeInterval: TimeInterval(0.45), repeats: false) { [self] (timer) in
            timeUp = true
            if loadDone {self.okForRealz()}
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            for i in 0..<4 {
                let bulClass = CPBullet(tex: "bullet")
                let newBul = bulClass.node as! SKSpriteNode
                newBul.physicsBody?.categoryBitMask = CPUInt.bullet
                newBul.physicsBody?.contactTestBitMask = CPUInt.bullet | CPUInt.immovableObject | CPUInt.walls
                
                 bullets.append(newBul)
                bulletC.append(bulClass)
                
                // There is no feasable way to have 100 sec bullet
                Timer.scheduledTimer(withTimeInterval: TimeInterval(100), repeats: false) { (timer) in
                    self.firedBullets.removeFirst()
                    self.firedBulletVelocites.removeFirst()
                }
            }
            DispatchQueue.main.async { [self] in
                self.loadDone = true
                if timeUp {okForRealz()}
            }
        }
    }
    
    func okForRealz(){
        if isDead {return}
        if level.isGamePaused {return}
        for i in 0..<4{
            let newBul = bullets.first!
            let bulClass = bulletC.first!
            bullets.removeFirst()
            bulletC.removeFirst()
            newBul.position = self.shipNode!.position
            newBul.position.x += CGFloat(220 * cos(self.shipNode!.zRotation + (CGFloat(i) * CGFloat.pi/2)))
            newBul.position.y += CGFloat(220 * sin(self.shipNode!.zRotation + (CGFloat(i) * CGFloat.pi/2)))
            self.level.addObjectToScene(node: newBul,nodeClass: bulClass)
            newBul.zRotation = self.shipNode!.zRotation + (CGFloat(i) * CGFloat.pi/2)
            let velocity = CGVector(dx: cos(newBul.zRotation) * CGFloat(self.bulletSpeeds), dy: sin(newBul.zRotation) * CGFloat(self.bulletSpeeds))
            newBul.physicsBody?.velocity = velocity
            firedBullets.append(newBul)
            firedBulletVelocites.append(newBul.physicsBody!.velocity)
        }
        loadDone = false
        timeUp = false
        isPepe = true
    }
    
    override func destroyShip() {
        level.collectedReward(id: 69)
        isMoving = false
        isDead = true
        shipNode?.removeFromParent()
        ghostNode.removeFromParent()
        isDead = true
    }
    
    override func changeHealth(delta: Int) {
        health -= delta
        if health > 4 {
            destroyShip()
        } else {
            face.texture = SKTexture(imageNamed: "Slice" + String(health))
        }
        shipNode?.physicsBody!.velocity = runDir
    }
    
    override func AiMovement(playerShip: CPPlayerShip) {
        if shipNode?.physicsBody?.velocity == CGVector() {
            shipNode?.physicsBody?.velocity = holdingVel
        }
        
        if isPepe {
            takeAShot()
            isPepe = false
        }
        
//        let y = (playerShip.shipNode?.position.y)! - (shipNode?.position.y)!
//        let x = (playerShip.shipNode?.position.x)! - (shipNode?.position.x)!
        let xd = cos(playerShip.shipNode!.zRotation ) * 200
        let yd = sin(playerShip.shipNode!.zRotation ) * 200
        
        runDir = CGVector(dx: xd, dy: yd)
        
//        shipNode?.zRotation += CGFloat.pi/10
//        face.zRotation -= CGFloat.pi/10
        
        shipNode?.physicsBody?.angularVelocity = CGFloat(7 + Int.random(in: Range(2...4)))
        holdingVel = (shipNode?.physicsBody!.velocity)!
        face.zRotation = -shipNode!.zRotation
        face.position = CGPoint()
        
    }
    
    override func resolveHealthDelta() {
        
    }
}

class CPTurret : CPSpaceshipBase {
    var base = SKSpriteNode(imageNamed: "pepeRed")
    
    let sleepCanonTex = SKTexture(imageNamed: "pepeGreen")
    let activeCanonTex = SKTexture(imageNamed: "pepeRed")
    let sleepBaseTex = SKTexture(imageNamed: "turretbaseeasy")
    let activeBaseTex = SKTexture(imageNamed: "turretbasehard")
    
    init(level: CPLevelBase){
        
        var setup = CPSpaceshipSetup(imageNamed: "turretshooterhard")
        setup.isMoving = false
        setup.bulletRegenRate = 1.5
        setup.bulletSpeeds = 150
        setup.attackRange = 450
        setup.canRotateBothDirections = true
        
        
        setup.isBulletOrbitVisible = false
        super.init(spaceshipSetup: setup, lvl: level)
        
        bulletTexString = "fireball"
        
        shipNode?.physicsBody = SKPhysicsBody(texture: activeBaseTex, size: CGSize(width: 100, height: 100))
        shipNode!.physicsBody?.contactTestBitMask = CPUInt.player
        shipNode!.physicsBody?.collisionBitMask = CPUInt.enemy
        shipNode!.physicsBody?.categoryBitMask = CPUInt.enemy
        shipNode?.physicsBody?.isDynamic = false
        
        shipNode?.xScale = 0.7
        shipNode?.yScale = 0.7
        shipNode?.zPosition = 100
        
        shipNode?.addChild(base)
        base.zPosition = -10
        
        shipNode?.physicsBody?.affectedByGravity = false
        
        health = 9999
        
        unfiredBullets = [SKSpriteNode(imageNamed: "bullet")]
    }
    
    override func AiMovement(playerShip: CPPlayerShip) {
        if isDead {return}
        
        rechargeBullet()
        
        if inRangeCheck(pos1: playerShip.shipNode!.position, pos2: shipNode!.position, range: attackRange){
            changeActivity(isActive: true)
            
            let y = (playerShip.shipNode?.position.y)! - (shipNode?.position.y)!
            let x = (playerShip.shipNode?.position.x)! - (shipNode?.position.x)!
            let targetRotation = atan2(y,x )
            let cRotation = (shipNode?.zRotation.truncatingRemainder(dividingBy: CGFloat.pi))!
            if cRotation < targetRotation {
                shipNode!.zRotation += CGFloat.pi/200
                base.zRotation -= CGFloat.pi/200
            } else {
                shipNode!.zRotation -= CGFloat.pi/200
                base.zRotation += CGFloat.pi/200
            }

            Shoot(shotType: .Bullet)
        } else {
            changeActivity(isActive: false)
        }
    }
    
    func changeActivity(isActive: Bool){
        if isActive{
            shipNode!.texture = activeCanonTex
            base.texture = activeBaseTex
        } else {
            shipNode!.texture = sleepCanonTex
            base.texture = sleepBaseTex
        }
    }
}
