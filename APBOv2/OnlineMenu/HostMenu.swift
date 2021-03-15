//
//  HostMenu.swift
//  APBOv2
//
//  Created by 90306670 on 2/17/21.
//  Copyright © 2021 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

class HostMenu: SKScene {
    var backButtonNode: MSButtonNode!
    var startButtonNode: MSButtonNode!
    
    var leftModeButtonNode: MSButtonNode!
    var rightModeButtonNode: MSButtonNode!
    var modeImage = SKNode(fileNamed: "ffa")
    let modeArray = ["ffa", "astroball", "infection"]
    var i = 0
    
    var leftMapButtonNode: MSButtonNode!
    var rightMapButtonNode: MSButtonNode!
    var mapImage = SKNode(fileNamed: "OnlineCubis")
    var mapArray = ["OnlineCubis", "OnlineTrisen", "OnlineHex"]
    var j = 0
    
    private var astroWalkingFrames: [SKTexture] = []
    private var infectionWalkingFrames: [SKTexture] = []
    private var ffaWalkingFrames: [SKTexture] = []
    
    
    override func didMove(to view: SKView) {
        Global.gameData.gameState = GameStates.HostMenu
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        self.sceneShake(shakeCount: 4, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1)
        self.run(SKAction.playSoundFileNamed("menuThumpnew", waitForCompletion: false))
        
        backButtonNode = self.childNode(withName: "back") as? MSButtonNode
        backButtonNode.selectedHandlers = {
            Global.loadScene(s: "OnlineMenu")
        }
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIScreen.main.bounds.width < 779 {
                backButtonNode.position.x = -600
                backButtonNode.position.y =  300
            }
        }
        
        startButtonNode = self.childNode(withName: "startButton") as? MSButtonNode
        startButtonNode.selectedHandlers = {
            // create game code
            Global.gameData.CreateNewGame()
        }
        
        modeImage = self.childNode(withName: "modeImage")
        
        buildffa()
        animateffa()
        leftModeButtonNode = self.childNode(withName: "leftMode") as? MSButtonNode
        leftModeButtonNode.selectedHandlers = { [self] in
            // go left mode
            if self.i==0 {
                self.i = self.modeArray.endIndex - 1
            } else {
                self.i = self.i-1
            }
            Global.gameData.mode = self.modeArray[self.i]
            //let modePicChange = SKAction.setTexture(SKTexture(imageNamed: self.modeArray[self.i]))
            //self.modeImage!.run(modePicChange)
            self.leftModeButtonNode.alpha = 1
            
            switch self.i {
            case 0:
                self.removeAction(forKey: "mode")
                self.buildffa()
                self.animateffa()
            case 1:
                self.removeAction(forKey: "mode")
                self.buildAstro()
                self.animateAstro()
            case 2:
                self.removeAction(forKey: "mode")
                self.buildInfection()
                self.animateInfection()
                
            default:
                print("no mode")
            }
    
        }
        
        rightModeButtonNode = self.childNode(withName: "rightMode") as? MSButtonNode
        rightModeButtonNode.selectedHandlers = {
            // go right mode
            if self.i == self.modeArray.endIndex - 1 {
                self.i = 0
            } else {
                self.i = self.i+1
            }
            Global.gameData.mode = self.modeArray[self.i]
            //let modePicChange = SKAction.setTexture(SKTexture(imageNamed: self.modeArray[self.i]))
            //self.modeImage!.run(modePicChange)
            self.rightModeButtonNode.alpha = 1
           // print(self.i)
            switch self.i {
            case 0:
                self.removeAction(forKey: "mode")
                self.buildffa()
                self.animateffa()
            case 1:
                self.removeAction(forKey: "mode")
                self.buildAstro()
                self.animateAstro()
            case 2:
                self.removeAction(forKey: "mode")
                self.buildInfection()
                self.animateInfection()
            default:
                print("no mode")
            }
        }
        
        mapImage = self.childNode(withName: "mapImage")
        leftMapButtonNode = self.childNode(withName: "leftMap") as? MSButtonNode
        leftMapButtonNode.selectedHandlers = {
            // go left map
            if self.j==0 {
                self.j = self.mapArray.endIndex - 1
            } else {
                self.j = self.j-1
            }
            Global.gameData.map = self.mapArray[self.j]
            let mapPicChange = SKAction.setTexture(SKTexture(imageNamed: self.mapArray[self.j]))
            self.mapImage!.run(mapPicChange)
            self.leftMapButtonNode.alpha = 1
        }
        
        rightMapButtonNode = self.childNode(withName: "rightMap") as? MSButtonNode
        rightMapButtonNode.selectedHandlers = {
            // go right map
            if self.j == self.mapArray.endIndex - 1 {
                self.j = 0
            } else {
                self.j = self.j+1
            }
            Global.gameData.map = self.mapArray[self.j]
            let mapPicChange = SKAction.setTexture(SKTexture(imageNamed: self.mapArray[self.j]))
            self.mapImage!.run(mapPicChange)
            self.rightMapButtonNode.alpha = 1
        }
        
    }
    
    func sceneShake(shakeCount: Int, intensity: CGVector, shakeDuration: Double) {
        let sceneView = self.scene!.view! as UIView
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = shakeDuration / Double(shakeCount)
        shakeAnimation.repeatCount = Float(shakeCount)
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x - intensity.dx, y: sceneView.center.y - intensity.dy))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: sceneView.center.x + intensity.dx, y: sceneView.center.y + intensity.dy))
        sceneView.layer.add(shakeAnimation, forKey: "position")
    }
    
    func buildffa() {
      let ffaAnimatedAtlas = SKTextureAtlas(named: "ffaImages")
      var walkFrames: [SKTexture] = []

      let numImages = ffaAnimatedAtlas.textureNames.count
      for i in 1...numImages {
        let ffaTextureName = "ffa\(i)"
        walkFrames.append(ffaAnimatedAtlas.textureNamed(ffaTextureName))
      }
      ffaWalkingFrames = walkFrames
        
 
    }
      func animateffa() {
        
        modeImage!.run(SKAction.repeatForever(
          SKAction.animate(with: ffaWalkingFrames,
                           timePerFrame: 0.3,
                           resize: false,
                           restore: true)),
          withKey:"mode")
      }
    
    func buildAstro() {
      let astroAnimatedAtlas = SKTextureAtlas(named: "astroImages")
      var walkFrames: [SKTexture] = []

      let numImages = astroAnimatedAtlas.textureNames.count
      for i in 1...numImages {
        let astroTextureName = "astroball\(i)"
        walkFrames.append(astroAnimatedAtlas.textureNamed(astroTextureName))
      }
      astroWalkingFrames = walkFrames
        
     
        
    }
      func animateAstro() {
        modeImage!.run(SKAction.repeatForever(
          SKAction.animate(with: astroWalkingFrames,
                           timePerFrame: 0.05,
                           resize: false,
                           restore: true)),
          withKey:"mode")
      }
    
    func buildInfection() {
      let infectionAnimatedAtlas = SKTextureAtlas(named: "infectionImages")
      var walkFrames: [SKTexture] = []

      let numImages = infectionAnimatedAtlas.textureNames.count
      for i in 1...numImages {
        let infectionTextureName = "infection\(i)"
        walkFrames.append(infectionAnimatedAtlas.textureNamed(infectionTextureName))
      }
      infectionWalkingFrames = walkFrames
        

        
    }
      func animateInfection() {
        modeImage!.run(SKAction.repeatForever(
          SKAction.animate(with: infectionWalkingFrames,
                           timePerFrame: 0.05,
                           resize: false,
                           restore: true)),
          withKey:"mode")
      }
    
    
    
    
    
}
