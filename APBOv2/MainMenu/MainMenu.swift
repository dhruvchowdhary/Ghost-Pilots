//
//  MainMenu.swift
//  APBOv2
//
//  Created by 90306670 on 11/18/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    /* UI Connections */
    var lastUpdateTime: CFTimeInterval = 0
    var buttonPlay: MSButtonNode!
    let title = SKLabelNode(text: "GHOST PILOT")
    
    let playerParticles = SKEmitterNode(fileNamed: "Player")
    let ghostParticles = SKEmitterNode(fileNamed: "ghost")
    let enemyParticles = SKEmitterNode(fileNamed: "enemy")
    let blueParticles = SKEmitterNode(fileNamed: "bluePlayer")
    let greenParticles = SKEmitterNode(fileNamed: "greenPlayer")
    let yellowParticles = SKEmitterNode(fileNamed: "yellowPlayer")
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        title.fontName = "AvenirNext-Bold"
        title.position = CGPoint(x: frame.midX, y: frame.midY + 195)
        title.fontColor = UIColor.white
        title.zPosition = 2
        title.fontSize = 160
        addChild(title)
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        randomParticle(party: playerParticles!)
        randomParticle(party: ghostParticles!)
        randomParticle(party: enemyParticles!)
        randomParticle(party: blueParticles!)
        randomParticle(party: greenParticles!)
        randomParticle(party: yellowParticles!)
        addChild(playerParticles!)
        addChild(ghostParticles!)
        addChild(enemyParticles!)
        addChild(blueParticles!)
        addChild(greenParticles!)
        addChild(yellowParticles!)
        let timer = Timer.scheduledTimer(withTimeInterval: 25, repeats: true) { (timer) in
            self.randomParticle(party: self.playerParticles!)
            self.randomParticle(party: self.ghostParticles!)
            self.randomParticle(party: self.enemyParticles!)
            self.randomParticle(party: self.blueParticles!)
            self.randomParticle(party: self.greenParticles!)
            self.randomParticle(party: self.yellowParticles!)
            self.playerParticles?.resetSimulation()
            self.ghostParticles?.resetSimulation()
            self.enemyParticles?.resetSimulation()
            self.blueParticles?.resetSimulation()
            self.greenParticles?.resetSimulation()
            self.yellowParticles?.resetSimulation()
        }
        
        /* Set UI connections */
        buttonPlay = self.childNode(withName: "soloButton") as? MSButtonNode
        buttonPlay.selectedHandlers = {
            self.loadGame()
        }
        
        buttonPlay = self.childNode(withName: "onlineButton") as? MSButtonNode
        buttonPlay.selectedHandlers = {
            self.loadOnlineMenu()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        //      playerParticles?.position = CGPoint(x: 896, y: 414)
    }
    
    func randomParticle(party: SKEmitterNode) {
        let randomNum = Int.random(in: 0...4)
        if randomNum == 1 {
            party.position = CGPoint(x: 0, y: 424)
            party.particlePositionRange = CGVector(dx: 896, dy: 0)
            party.emissionAngle = 3*3.141592/2
            party.emissionAngleRange = 3.141592/2
        } else if randomNum == 2 {
            party.position = CGPoint(x: -906, y: 0)
            party.particlePositionRange = CGVector(dx: 0, dy: 414)
            party.emissionAngle = 0
            party.emissionAngleRange = 3.141592/2
        } else if randomNum == 3 {
            party.position = CGPoint(x: 0, y: -424)
            party.particlePositionRange = CGVector(dx: 896, dy: 0)
            party.emissionAngle = 3.141592/2
            party.emissionAngleRange = 3.141592/2
        } else if randomNum == 4 {
            party.position = CGPoint(x: 906, y: 0)
            party.particlePositionRange = CGVector(dx: 0, dy: 414)
            party.emissionAngle = 3.141592
            party.emissionAngleRange = 3.141592/2.4
        }
        let randomNum2 = Int.random(in: -4...4)
        party.particleRotationSpeed = 3.141592/2 + CGFloat(randomNum2)/5 - 1
        
        let randomNum3 = Int.random(in: -15...15)
        party.particleSpeed = CGFloat(55 + randomNum3)
        
        let randomNum4 = CGFloat.random(in: 1...3.5)
        party.particleScale = randomNum4
        self.ghostParticles?.particleScale = 1
    }
    
    func loadGame() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = SoloMenu(fileNamed:"SoloMenu") else {
            print("Could not make SoloMenu, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func loadOnlineMenu() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = OnlineMenu(fileNamed:"OnlineMenu") else {
            
            print("Could not make OnlineMenu, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}

