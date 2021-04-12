//
//  MainMenu.swift
//  APBOv2
//
//  Created by 90306670 on 11/18/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit

class Shop: SKScene {
    
    /* UI Connections */
    var backButtonNode: MSButtonNode!
    var trailsButtonNode: MSButtonNode!
    var skinsButtonNode: MSButtonNode!
    var shopLightningBoltButtonNode: MSButtonNode!
    let trailLabel = SKLabelNode(text: "TRAILS")
    
    let polynite = SKSpriteNode(imageNamed: "polynite2")
    let polyniteBox = SKSpriteNode(imageNamed: "polynitebox")
    let polyniteLabel = SKLabelNode(text: "0")
    var shopTab = "skins"
    
    let shopEquip = SKSpriteNode(imageNamed: "shopEquip")
    
    var decalNodes: [MSButtonNode] = []
    var decalStrings: [String] = []
    var decalPrices: [Int] = []
    //var purchasedDecals: [String] = []
    //var equippedDecal = UserDefaults.standard.string(forKey: "equippedDecal")
    
    var trailNodes: [MSButtonNode] = []
    var trailStrings: [String] = []
    var trailPrices: [Int] = []
    //var purchasedTrails: [String] = []
    
   // var equippedTrail = UserDefaults.standard.string(forKey: "equippedTrail")
    
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        Global.gameData.skView = self.view!
        
        shopEquip.alpha = 0
        
        shopEquip.xScale = 0.3
        shopEquip.yScale = 0.3
        addChild(shopEquip)
        
        shopEquip.zPosition = 6
        
        Global.gameData.addPolyniteCount(delta: 900)
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        
        let shopDisplay = SKSpriteNode(imageNamed: "shop")
        shopDisplay.position = CGPoint(x: frame.midX, y: frame.midY + 300)
        shopDisplay.size =  CGSize(width: 298.611 / 1.2 , height: 172.222 / 1.2)
            addChild(shopDisplay)
        shopDisplay.zPosition = 5
        
     
       
        
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
        
        
        
        
        decalNodes =
            [
                MSButtonNode(imageNamed: "decalNodeStripe")
            ]
        
      
        
        decalStrings =
            [
                "decalStripe"
            ]
        
        decalPrices =
            [
                500
            ]
        
        trailNodes =
            [
                MSButtonNode(imageNamed: "trailNodeLightning")
            ]
        
        trailStrings =
            [
                "trailLightning"
            ]
        trailPrices =
            [
                100
            ]
        
        for i in 0..<trailNodes.count {
            
           
            
            let node = trailNodes[i]
            node.isUserInteractionEnabled = true
            node.state = .MSButtonStopAlphaChanges
            
            // Scale the node here
            node.xScale = 0.3
            node.yScale = 0.3
            node.alpha = 0
            
            // Position node
            if i != 0 {
                node.position.x = trailNodes[i-1].position.x + 400
                node.position.y = trailNodes[i-1].position.y
            } else {
                node.position.y = frame.midY - 150
                node.position.x = frame.midX - 400
            }
            
    
            node.zPosition = 5
            
            node.selectedHandler = { [self] in
                
                
                // ShadeNode and set handlers
                
                if Global.gameData.lockerTrails.contains(trailStrings[i]){
                    //already Purchased! might be equip function
                    
                    shopEquip.position = node.position
                    UserDefaults.standard.setValue(trailStrings[i], forKey: "equippedTrail")
                    
                
                    print("\(trailStrings[i]) equipped")
                    
                } else {
                    // purchasing
                    
                    print("bought \(trailStrings[i])")
                    Global.gameData.spendPolynite(amountToSpend: trailPrices[i])
                    polyniteLabel.text = "\(Global.gameData.polyniteCount)"
                    Global.gameData.lockerTrails.append(trailStrings[i])
                    shopEquip.alpha = 1
                    // subtract polynite according to price
                    
                    //node.alpha = 0.3
                    
                }
            }
            
            // Does this level have Unique Properties? - add it here in the case switch
            
            scene?.addChild(node)
        }
        
        
        for i in 0..<decalNodes.count {
            
           
            
            let node = decalNodes[i]
            node.isUserInteractionEnabled = true
            node.state = .MSButtonStopAlphaChanges
            node.alpha = 1
            // Scale the node here
            node.xScale = 0.3
            node.yScale = 0.3
            
            // Position node
            if i != 0 {
                node.position.x = decalNodes[i-1].position.x + 300
                node.position.y = decalNodes[i-1].position.y
            } else {
                node.position.y = frame.midY - 150
                node.position.x = frame.midX
            }
            
     
       
            node.zPosition = 5
            
            node.selectedHandler = { [self] in
                
                
                // ShadeNode and set handlers
                
                if Global.gameData.lockerDecals.contains(decalStrings[i]){
                    
                    shopEquip.position = node.position
                    
                    DataPusher.PushData(path: "Users/\(UIDevice.current.identifierForVendor!)/equippedDecal", Value: decalStrings[i])
                   
                    print("\(decalStrings[i]) equipped")
                    
                } else {
                    // purchasing
                    
                    print("bought \(decalStrings[i])")
                    // subtract polynite according to price
                    Global.gameData.spendPolynite(amountToSpend: decalPrices[i])
                    
                    
                    
                
                    
                    Global.gameData.lockerDecals.append(decalStrings[i])
                    
              
                    
                    
                    polyniteLabel.text = "\(Global.gameData.polyniteCount)"
                    
                    shopEquip.alpha = 1
              
                    //node.alpha = 0.3
                    
                }
            }
            
            // Does this level have Unique Properties? - add it here in the case switch
            
            scene?.addChild(node)
        }
        
        
        
        
        
        trailsButtonNode = self.childNode(withName: "trailsButtonUnselected") as? MSButtonNode
        trailsButtonNode.selectedHandlers = { [self] in
            self.trailsButtonNode.texture = SKTexture(imageNamed: "trailsButtonSelected")
            self.skinsButtonNode.texture = SKTexture(imageNamed: "skinsButtonUnselected")
            self.trailsButtonNode.alpha = 1
            self.shopTab = "trails"
            
            for i in 0..<trailNodes.count {
                trailNodes[i].alpha = 1
            }
            
            for i in 0..<decalNodes.count {
                decalNodes[i].alpha = 0
            }
            
            
            
            
        
        }
        
        trailsButtonNode.selectedHandler = {
            self.trailsButtonNode.alpha = 1
        }
        
        skinsButtonNode = self.childNode(withName: "skinsButtonSelected") as? MSButtonNode
        skinsButtonNode.selectedHandlers = { [self] in
            self.trailsButtonNode.texture = SKTexture(imageNamed: "trailsButtonUnselected")
            self.skinsButtonNode.texture = SKTexture(imageNamed: "skinsButtonSelected")
            self.skinsButtonNode.alpha = 1
            self.shopTab = "skins"
            
            for i in 0..<decalNodes.count {
                decalNodes[i].alpha = 1
            }
            
            for i in 0..<trailNodes.count {
                trailNodes[i].alpha = 0
            }
            

            
        }
        
        skinsButtonNode.selectedHandler = {
            self.skinsButtonNode.alpha = 1
        }
        
        
        trailsButtonNode.position = CGPoint(x: frame.midX + 150 , y: frame.midY + 100 )
        skinsButtonNode.position = CGPoint(x: frame.midX - 150, y: frame.midY + 100)
        
        
        backButtonNode = self.childNode(withName: "back") as? MSButtonNode
        backButtonNode.selectedHandlers = {
            self.loadMainMenu()
        //       skView.presentScene(scene)
        }
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIScreen.main.bounds.width < 779 {
                backButtonNode.position.x = -600
                backButtonNode.position.y =  300
            }
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            
        } else if UIScreen.main.bounds.width > 779 {
            
        } else {
            polyniteBox.position.x = frame.midX + 600
            polynite.position.x = polyniteBox.position.x - 80
            polyniteLabel.position.x = polyniteBox.position.x + 50
        }
        
        let borderShape = SKShapeNode()
        
        
        let borderwidth = 1200
        let borderheight = 550
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -borderwidth/2, y: -borderheight/2 - 75, width: borderwidth, height: borderheight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1)
        borderShape.strokeColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
        borderShape.lineWidth = 20
        borderShape.name = "border"
        borderShape.physicsBody = SKPhysicsBody(edgeChainFrom: borderShape.path!)
        
        borderShape.physicsBody!.categoryBitMask = CollisionType.border.rawValue
        borderShape.physicsBody!.collisionBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        borderShape.physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.bullet.rawValue
        
        borderShape.zPosition = 2
        
        addChild(borderShape)
     
    }
 
    
    
    func loadMainMenu() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Menu scene */
        guard let scene = GameScene(fileNamed:"MainMenu") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        if UIDevice.current.userInterfaceIdiom == .pad {
            scene.scaleMode = .aspectFit
        } else {
            scene.scaleMode = .aspectFill
        }
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
}
        
        
        
        

       
        
        
     
