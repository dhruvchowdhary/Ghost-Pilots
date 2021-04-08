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
    var buttonOnline: MSButtonNode!
    var tutorialButtonNode: MSButtonNode!
    var scenesAreLoaded = false;
    
    let title = SKLabelNode(text: "GHOST PILOTS")
    let ghostParticles = SKEmitterNode(fileNamed: "ghost")
    let enemyParticles = SKEmitterNode(fileNamed: "enemy")
    let enemy2Particles = SKEmitterNode(fileNamed: "enemy2")
    let enemy3Particles = SKEmitterNode(fileNamed: "enemy3")
    let playerParticles = SKEmitterNode(fileNamed: "Player")
    let blueParticles = SKEmitterNode(fileNamed: "bluePlayer")
    let greenParticles = SKEmitterNode(fileNamed: "greenPlayer")
    let yellowParticles = SKEmitterNode(fileNamed: "yellowPlayer")
    let orangeParticles = SKEmitterNode(fileNamed: "orangePlayer")
  //  let pinkParticles = SKEmitterNode(fileNamed: "pinkPlayer")
    let purpleParticles = SKEmitterNode(fileNamed: "purplePlayer")
    
    var buttonShop: MSButtonNode!
    let polynite = SKSpriteNode(imageNamed: "polynite2")
    let polyniteBox = SKSpriteNode(imageNamed: "polynitebox")
    let polyniteLabel = SKLabelNode(text: "0")
    var polyniteAmount = UserDefaults.standard.integer(forKey: "polyniteAmount")
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        Global.gameData.skView = self.view!

        title.fontName = "AvenirNext-Bold"
        title.position = CGPoint(x: frame.midX, y: frame.midY + 180)
        title.fontColor = UIColor.white
        title.zPosition = 2
        title.fontSize = 120
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
        randomParticle(party: enemy2Particles!)
        randomParticle(party: enemy3Particles!)
        randomParticle(party: blueParticles!)
        randomParticle(party: greenParticles!)
        randomParticle(party: yellowParticles!)
        randomParticle(party: orangeParticles!)
  //      randomParticle(party: pinkParticles!)
        randomParticle(party: purpleParticles!)
        addChild(playerParticles!)
        addChild(ghostParticles!)
        addChild(enemyParticles!)
        addChild(enemy2Particles!)
        addChild(enemy3Particles!)
        addChild(blueParticles!)
        addChild(greenParticles!)
        addChild(yellowParticles!)
        addChild(orangeParticles!)
  //      addChild(pinkParticles!)
        addChild(purpleParticles!)
        let timer = Timer.scheduledTimer(withTimeInterval: 31, repeats: true) { (timer) in
            self.randomParticle(party: self.playerParticles!)
            self.randomParticle(party: self.ghostParticles!)
            self.randomParticle(party: self.enemyParticles!)
            self.randomParticle(party: self.enemy2Particles!)
            self.randomParticle(party: self.enemy3Particles!)
            self.randomParticle(party: self.blueParticles!)
            self.randomParticle(party: self.greenParticles!)
            self.randomParticle(party: self.yellowParticles!)
            self.randomParticle(party: self.orangeParticles!)
    //        self.randomParticle(party: self.pinkParticles!)
            self.randomParticle(party: self.purpleParticles!)

            self.playerParticles?.resetSimulation()
            self.ghostParticles?.resetSimulation()
            self.enemyParticles?.resetSimulation()
            self.enemy2Particles?.resetSimulation()
            self.enemy3Particles?.resetSimulation()
            self.blueParticles?.resetSimulation()
            self.greenParticles?.resetSimulation()
            self.yellowParticles?.resetSimulation()
            self.orangeParticles?.resetSimulation()
    //        self.pinkParticles?.resetSimulation()
            self.purpleParticles?.resetSimulation()
        }
        
        /* Set UI connections */
        polyniteBox.size = CGSize(width: 391.466 / 1.5, height: 140.267 / 1.5)
        polyniteBox.position = CGPoint(x: frame.midX + 720, y: frame.midY + 340)
        polyniteBox.zPosition = 9
        addChild(polyniteBox)
        
        polynite.position = CGPoint(x: polyniteBox.position.x - 80 , y: polyniteBox.position.y)
        polynite.zPosition = 10
        polynite.size = CGSize(width: 104 / 1.5, height: 102.934 / 1.5 )
        addChild(polynite)
        
        polyniteLabel.text = "\(Global.gameData.polyniteCount)"
        polyniteLabel.position = CGPoint(x: polyniteBox.position.x , y: polyniteBox.position.y - 20)
        polyniteLabel.fontName = "AvenirNext-Bold"
        polyniteLabel.fontColor = UIColor.black
        polyniteLabel.zPosition = 10
        polyniteLabel.fontSize = 80 / 1.5
        addChild(polyniteLabel)
        
        buttonShop = self.childNode(withName: "shop") as? MSButtonNode
        buttonShop.position = CGPoint(x: polyniteBox.position.x , y: polyniteBox.position.y - 140)
        buttonShop.zPosition = 9
        buttonShop.selectedHandler = {
            self.buttonShop.alpha = 0.7
        }
        buttonShop.selectedHandlers = {
            Global.loadScene(s: "Shop")
        }
        
        
        buttonPlay = self.childNode(withName: "soloButton") as? MSButtonNode
        buttonPlay.selectedHandler = {
            self.buttonPlay.alpha = 0.7
        }
        buttonPlay.selectedHandlers = {
            Global.loadScene(s: "SoloMenu")
        }
        
        buttonOnline = self.childNode(withName: "onlineButton") as? MSButtonNode
        buttonOnline.selectedHandler = {
            self.buttonOnline.alpha = 0.7
        }
        buttonOnline.selectedHandlers = {
            Global.loadScene(s: "OnlineMenu")
        }
        
        tutorialButtonNode = self.childNode(withName: "tutorial") as? MSButtonNode
        if UIDevice.current.userInterfaceIdiom == .pad {
   //         let scale = 1.2
   //         tutorialButtonNode.position.x = (frame.midX - 640) * CGFloat(scale)
     //       tutorialButtonNode.position.y =  (frame.midY - 410) * CGFloat(scale)
     //       tutorialButtonNode.setScale(CGFloat(1.25 * scale))
        } else if UIScreen.main.bounds.width > 779 {
            buttonShop.position.x = frame.midX + 710
            tutorialButtonNode.position.x = frame.midX - 720
            tutorialButtonNode.position.y =  frame.midY - 290
        } else {
            polyniteBox.position.x = frame.midX + 600
            polynite.position.x = polyniteBox.position.x - 80
            polyniteLabel.position.x = polyniteBox.position.x + 50
            buttonShop.position.x = polyniteBox.position.x
            tutorialButtonNode.position.x = frame.midX - 620
            tutorialButtonNode.position.y =  frame.midY - 300
        }
        tutorialButtonNode.alpha = 1
        tutorialButtonNode.selectedHandlers = {
            self.tutorial()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        //      playerParticles?.position = CGPoint(x: 896, y: 414)
    }
    
    func randomParticle(party: SKEmitterNode) {
        let randomNum = Int.random(in: 0...4)
        if randomNum == 1 {
            party.position = CGPoint(x: 0, y: 519)
            party.particlePositionRange = CGVector(dx: 896, dy: 0)
            party.emissionAngle = 3*3.141592/2
            party.emissionAngleRange = 3.141592/2
            let randomNum3 = Int.random(in: -15...15)
            party.particleSpeed = CGFloat(55 + randomNum3)
        } else if randomNum == 2 {
            party.position = CGPoint(x: -991, y: 0)
            party.particlePositionRange = CGVector(dx: 0, dy: 414)
            party.emissionAngle = 0
            party.emissionAngleRange = 3.141592/2
            let randomNum3 = Int.random(in: 4...15)
            party.particleSpeed = CGFloat(90 + randomNum3)
        } else if randomNum == 3 {
            party.position = CGPoint(x: 0, y: -519)
            party.particlePositionRange = CGVector(dx: 896, dy: 0)
            party.emissionAngle = 3.141592/2
            party.emissionAngleRange = 3.141592/2
            let randomNum3 = Int.random(in: -15...15)
            party.particleSpeed = CGFloat(55 + randomNum3)
        } else if randomNum == 4 {
            party.position = CGPoint(x: 991, y: 0)
            party.particlePositionRange = CGVector(dx: 0, dy: 414)
            party.emissionAngle = 3.141592
            party.emissionAngleRange = 3.141592/2.4
            let randomNum3 = Int.random(in: 4...15)
            party.particleSpeed = CGFloat(90 + randomNum3)
        }
        let randomNum2 = Int.random(in: -5...5)
        let rotationDirection = Int.random(in: 0...1)
        if rotationDirection == 0 {
            party.particleRotationSpeed = -(3.141592/2 + CGFloat(randomNum2)/5 - 1)
        } else {
            party.particleRotationSpeed = 3.141592/2 + CGFloat(randomNum2)/5 - 1
        }
        
 /*       if randomNum == 2 || randomNum == 4 {
            let randomNum3 = Int.random(in: 5...15)
            party.particleSpeed = CGFloat(95 + randomNum3)
        } else {
            let randomNum3 = Int.random(in: -15...15)
            party.particleSpeed = CGFloat(55 + randomNum3)
        }*/
        
        let randomNum4 = CGFloat.random(in: 1...3.5)
        party.particleScale = randomNum4
        self.ghostParticles?.particleScale = 1
    }
    
    func tutorial() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = Tutorial(fileNamed:"Tutorial") else {
            
            print("Could not make OnlineMenu, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
  //      if UIDevice.current.userInterfaceIdiom == .pad {
    //        scene.scaleMode = .aspectFit
      //  } else {
            scene.scaleMode = .aspectFill
        //}
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}

