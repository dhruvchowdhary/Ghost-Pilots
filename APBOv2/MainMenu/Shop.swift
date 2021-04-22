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

    //  var shopLightningBoltButtonNode: MSButtonNode!

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
    
    public var lockerDecals: [String] = ["DEFAULTDECAL"]
    public var lockerTrails: [String] = ["DEFAULTTRAIL"]
    public var equippedDecal: String = "DEFAULTDECAL"
    public var equippedTrail: String = "DEFAULTTRAIL"
    
    
    var decalNameTitle: [SKLabelNode] = []
    var trailNameTitle: [SKLabelNode] = []
    
    let buyPopup = SKShapeNode()
    
    var isBuying = false
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        Global.gameData.skView = self.view!

        
        //loading shop
        let shopRef = MultiplayerHandler.ref.child("Users/\(UIDevice.current.identifierForVendor!)/ShopStuff")
        shopRef.observeSingleEvent(of:.value, with: { [self] (Snapshot) in
            if !Snapshot.exists(){
                return
            }
            let snapVal = Snapshot.value as! String
            let jsonData = snapVal.data(using: .utf8)
            let payload = try! JSONDecoder().decode(ShopPayload.self, from: jsonData!)
            
            if payload.equippedTrail != nil{
                equippedDecal = payload.equippedDecal
                equippedTrail = payload.equippedTrail
                lockerTrails = payload.lockerTrails
                lockerDecals = payload.lockerDecals
                //   print(equippedDecal)
                print(payload)
            }
        })
        
        // buy defaults
        checkForDecalStuff(node: MSButtonNode(imageNamed: "DEFAULTDECALPurchased"), string: "DEFAULTDECAL")
        
     //  pushShopStuff()
        
        
        let buyPopupWidth = 600
        let buyPopupHeight = 600
        
        buyPopup.path = UIBezierPath(roundedRect: CGRect(x: -buyPopupWidth/2, y: -buyPopupHeight/2, width: buyPopupWidth, height: buyPopupHeight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        buyPopup.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1)
        buyPopup.strokeColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
        buyPopup.lineWidth = 20
        buyPopup.name = "buyPopup"
        
        buyPopup.zPosition = 20
        buyPopup.alpha = 0
        
        
        addChild(buyPopup)
        
        
        shopEquip.alpha = 0
        shopEquip.xScale = 0.3
        shopEquip.yScale = 0.3
        addChild(shopEquip)
        
        shopEquip.zPosition = 6
        
        Global.gameData.skView = self.view!

        Global.gameData.addPolyniteCount(delta: 100)
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        
        let shopDisplay = SKSpriteNode(imageNamed: "shop")
        shopDisplay.position = CGPoint(x: frame.midX, y: frame.midY + 320)
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
        polyniteLabel.position = CGPoint(x: polyniteBox.position.x + 30 , y: polyniteBox.position.y - 20)
        polyniteLabel.fontName = "AvenirNext-Bold"
        polyniteLabel.fontColor = UIColor.black
        polyniteLabel.zPosition = 10
        polyniteLabel.fontSize = 80 / 1.5
        addChild(polyniteLabel)
        
        backButtonNode = self.childNode(withName: "back") as? MSButtonNode
        backButtonNode.selectedHandlers = {
            self.loadMainMenu()
        }
        
        
        
  
      
        decalNodes =
            [
                MSButtonNode(imageNamed: "DEFAULTDECALPurchased"), MSButtonNode(imageNamed: "decalNodeStripe"), MSButtonNode(imageNamed: "decalNodeSwirl")
            ]
        
        
        
        decalStrings =
            [
                "DEFAULTDECAL", "TIGER", "SWIRL"
            ]
        
        decalPrices =
            [
                0,500, 500
            ]
        decalNameTitle =
            [
                SKLabelNode(text: "DEFAULT"), SKLabelNode(text: "TIGER"), SKLabelNode(text: "SWIRL")
            ]
        
        trailNodes =
            [
                MSButtonNode(imageNamed: "DEFAULTTRAILPurchased"), MSButtonNode(imageNamed: "trailNodeLightning")
            ]
        
        trailStrings =
            [
                "DEFAULTTRAIL", "LIGHTNING"
            ]
        trailPrices =
            [
                0,100
            ]
        trailNameTitle =
            [
                SKLabelNode(text: "DEFAULT"), SKLabelNode(text: "Lightning")
            ]
        
        let wait1 = SKAction.wait(forDuration:0.1)
        let action1 = SKAction.run { [self] in
            for i in 0..<trailNodes.count {
                
                let name = trailNameTitle[i]
                
           
                name.fontName = "AvenirNext-Bold"
                name.fontColor = UIColor.black
                name.zPosition = 10
                name.fontSize = 80 / 1.5
                name.alpha = 0
                
                let node = trailNodes[i]
                node.isUserInteractionEnabled = true
                node.state = .MSButtonStopAlphaChanges
                
                // Scale the node here
                node.xScale = 0.3
                node.yScale = 0.3
                node.alpha = 0
                
                // Position node
                if i != 0 {
                    node.position.x = trailNodes[i-1].position.x + 300
                    node.position.y = trailNodes[i-1].position.y
                    name.position.x = node.position.x
                    name.position.y = node.position.y + 170
                } else {
                    node.position.y = frame.midY - 190
                    node.position.x = frame.midX - 300
                    name.position.x = node.position.x
                    name.position.y = node.position.y + 170
                }
                
                node.zPosition = 5
                name.zPosition = 5
                
                
                node.zPosition = 5
                
                node.selectedHandlers = { [self] in
                    
                    
                    // ShadeNode and set handlers
                    
                    if lockerTrails.contains(trailStrings[i]){
                        //already Purchased! might be equip function
                        shopEquip.alpha = 1
                        shopEquip.position = node.position

                        print("\(trailStrings[i]) equipped")
                        
                        equippedTrail = trailStrings[i]
                        
                        
                        
                        Global.gameData.selectedTrail = SelectedTrail(rawValue: equippedTrail)!

   
                        
                    } else {
                        // purchasing
                        //check if enough creds
                        if Global.gameData.polyniteCount >= trailPrices[i]
                        {
                            loadPopup(index: i, node: node, type: "trail")
                        }
                        else {
                            Global.gameViewController!.doPopUp(popUpText: "NOT ENOUGH CREDITS")
                            print("not enoug credit")
                        }
       
                    }
                    pushShopStuff()
                    
                }
                
                ///check stuff
                checkForTrailStuff(node: node, string: trailStrings[i])
                scene?.addChild(node)
                scene?.addChild(name)
            }
            
            
            for i in 0..<decalNodes.count {
                
                let name = decalNameTitle[i]
                
           
                name.fontName = "AvenirNext-Bold"
                name.fontColor = UIColor.black
                name.zPosition = 10
                name.fontSize = 80 / 1.5
               
                
     
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
                    name.position.x = node.position.x
                    name.position.y = node.position.y + 170
                } else {
                    node.position.y = frame.midY - 190
                    node.position.x = frame.midX - 300
                    name.position.x = node.position.x
                    name.position.y = node.position.y + 170
                }
                
                node.zPosition = 5
                name.zPosition = 5
                
                node.selectedHandlers = { [self] in
                    
                    if lockerDecals.contains(decalStrings[i]){
                        
                        shopEquip.position = node.position
                        shopEquip.alpha = 1

                    //    DataPusher.PushData(path: "Users/\(UIDevice.current.identifierForVendor!)/equippedDecal", Value: decalStrings[i])
                       

                        equippedDecal = decalStrings[i]
                        Global.gameData.selectedSkin = SelectedSkin(rawValue: equippedDecal)!

                        print("\(decalStrings[i]) equipped")
                                        
                        
                    } else {
                        // purchasing
                        //if enough then
                        if Global.gameData.polyniteCount >= decalPrices[i]
                        {
                            loadPopup(index: i, node: node, type: "decal")
                        }
                        else {
                            Global.gameViewController!.doPopUp(popUpText: "NOT ENOUGH CREDITS")
                            print("not enoug credit")
                        }
                        
                    }
                    pushShopStuff()
                }
                
                checkForDecalStuff(node: node, string: decalStrings[i])
                print("check decal")
                
                scene?.addChild(node)
                scene?.addChild(name)
            //    scene?.addChild(decalNameTitle[i].copy() as! SKNode)
                

            }
            
            
            }
        
        self.run(SKAction.sequence([wait1,action1]))
    
        
        trailsButtonNode = self.childNode(withName: "trailsButtonUnselected") as? MSButtonNode
        trailsButtonNode.selectedHandlers = { [self] in
            shopEquip.alpha = 0
            self.trailsButtonNode.texture = SKTexture(imageNamed: "trailsButtonSelected")
            self.skinsButtonNode.texture = SKTexture(imageNamed: "skinsButtonUnselected")
            self.trailsButtonNode.alpha = 1
            self.shopTab = "trails"
            
            for i in 0..<decalNodes.count {
                decalNodes[i].alpha = 0
                decalNameTitle[i].alpha = 0
                
            }
            
            for i in 0..<trailNodes.count {
                trailNodes[i].alpha = 1
                checkForTrailStuff(node: trailNodes[i], string: trailStrings[i])
                trailNameTitle[i].alpha = 1

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
            shopEquip.alpha = 0
            for i in 0..<decalNodes.count {
                decalNodes[i].alpha = 1
                decalNameTitle[i].alpha = 1
                checkForDecalStuff(node: decalNodes[i], string: decalStrings[i])

            }

            for i in 0..<trailNodes.count {
                trailNodes[i].alpha = 0
                trailNameTitle[i].alpha = 0
            }
            
            
            
        }
        
        skinsButtonNode.selectedHandler = {
            self.skinsButtonNode.alpha = 1
        }
        
        
        trailsButtonNode.position = CGPoint(x: frame.midX + 150 , y: frame.midY + 120 )
        skinsButtonNode.position = CGPoint(x: frame.midX - 150, y: frame.midY + 120)
        
        
        
        

        func loadPopup(index: Int, node: MSButtonNode, type: String) {

            
            
            
            let buyButtonNode: MSButtonNode = MSButtonNode(imageNamed: "buttonBuy")
            
            buyButtonNode.xScale = 0.6
            buyButtonNode.yScale = 0.6
            
           
            buyButtonNode.position = CGPoint(x: frame.midX + 130 , y: buyPopup.position.y - 200)
            buyButtonNode.zPosition = 20
            scene?.addChild(buyButtonNode)
            
            let cancelButtonNode: MSButtonNode = MSButtonNode(imageNamed: "buttonCancel")
            
            cancelButtonNode.xScale = 0.6
            cancelButtonNode.yScale = 0.6
            
           
            cancelButtonNode.position = CGPoint(x: frame.midX - 130 , y: buyPopup.position.y - 200)
            cancelButtonNode.zPosition = 20
            scene?.addChild(cancelButtonNode)
            
            cancelButtonNode.selectedHandlers = {
                self.exitPopup()
                cancelButtonNode.removeFromParent()
                buyButtonNode.removeFromParent()
                cancelButtonNode.alpha = 0
                buyButtonNode.alpha = 0
            }
            
            
            var item = SKSpriteNode()
            var itemName = SKLabelNode()
            var prompt1 = SKLabelNode()
            var prompt2 = SKLabelNode()
            
            buyPopup.alpha = 1
            
            
            
            if type == "decal" {
                
                buyButtonNode.selectedHandlers = { [self] in
                    buyingDecal(i: index, node: node)
                    self.exitPopup()
                    cancelButtonNode.removeFromParent()
                    buyButtonNode.removeFromParent()
                    cancelButtonNode.alpha = 0
                    buyButtonNode.alpha = 0
                    
                }
                
                item = SKSpriteNode(imageNamed: decalStrings[index] + "Purchased")
                itemName = SKLabelNode(text: decalStrings[index])
                prompt1 = SKLabelNode(text: "PURCHASE " + decalStrings[index])
                prompt2 = SKLabelNode(text: " FOR " + String(decalPrices[index]) + " POLYNITE?")
            }
            else if type == "trail" {
                
                buyButtonNode.selectedHandlers = { [self] in
                    buyingTrail(i: index, node: node)
                    self.exitPopup()
                    cancelButtonNode.removeFromParent()
                    buyButtonNode.removeFromParent()
                    cancelButtonNode.alpha = 0
                    buyButtonNode.alpha = 0
                    
                }
                
                item = SKSpriteNode(imageNamed: trailStrings[index] + "Purchased")
                itemName = SKLabelNode(text: trailStrings[index])
                prompt1 = SKLabelNode(text: "PURCHASE " + trailStrings[index])
                prompt2 = SKLabelNode(text: " FOR " + String(trailPrices[index]) + " POLYNITE?")
            }
           
            itemName.position = CGPoint(x: frame.midX, y: buyPopup.position.y + 200)
            itemName.zPosition = 5
            itemName.fontColor = UIColor.black
            itemName.fontSize = 65
            itemName.fontName = "AvenirNext-Bold"
            
            prompt1.position = CGPoint(x: frame.midX, y: buyPopup.position.y - 80)
            prompt1.zPosition = 5
            prompt1.fontColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
            prompt1.fontSize = 50
            prompt1.fontName = "AvenirNext-Bold"
            
            prompt2.position = CGPoint(x: frame.midX, y: buyPopup.position.y - 130)
            prompt2.zPosition = 5
            prompt2.fontColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
            prompt2.fontSize = 50
            prompt2.fontName = "AvenirNext-Bold"
           // item.size = item.texture.size()
                 item.size = CGSize(width: 300, height: 300)
            item.zPosition = 3
            item.position = CGPoint(x: frame.midX, y: buyPopup.position.y + 30)
            
            buyPopup.addChild(itemName)
            buyPopup.addChild(prompt1)
            buyPopup.addChild(prompt2)
            buyPopup.addChild(item)
       //     addChild(itemName)
            
            
        }
        func buyingTrail(i: Int, node: MSButtonNode) {
            print("bought \(trailStrings[i])")
            Global.gameData.spendPolynite(amountToSpend: trailPrices[i])
            polyniteLabel.text = "\(Global.gameData.polyniteCount)"
            
            
            
            shopEquip.alpha = 1
            shopEquip.position = node.position
            
            // prompt buy menu, if bougt then vvv
            
            lockerTrails.append(trailStrings[i])
            
            node.texture = SKTexture(imageNamed: trailStrings[i] + "Purchased")
            print(trailStrings[i] + "Purchased")
            
            equippedTrail = trailStrings[i]
            Global.gameData.selectedTrail = SelectedTrail(rawValue: equippedTrail)!
            
            pushShopStuff()
            exitPopup()
            
        }
        
        
        func buyingDecal(i: Int, node: MSButtonNode) {
            
            print("bought \(decalStrings[i])")
            // subtract polynite according to price
            Global.gameData.spendPolynite(amountToSpend: decalPrices[i])
            
            lockerDecals.append(decalStrings[i])

            polyniteLabel.text = "\(Global.gameData.polyniteCount)"
            
            shopEquip.alpha = 1

            shopEquip.position = node.position
            node.texture = SKTexture(imageNamed: decalStrings[i] + "Purchased")
            equippedDecal = decalStrings[i]

            Global.gameData.selectedSkin = SelectedSkin(rawValue: equippedDecal)!
            
            pushShopStuff()
            exitPopup()
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
            polyniteLabel.position.x = polyniteBox.position.x + 60
        }

        let borderShape = SKShapeNode()
        
        
        let borderwidth = 1200
        let borderheight = 590
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -borderwidth/2, y: -borderheight/2 - 75, width: borderwidth, height: borderheight), cornerRadius: 40).cgPath
        //borderShape.position = CGPoint(x: frame.midX, y: frame.midY)
        borderShape.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1)
        borderShape.strokeColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
        borderShape.lineWidth = 20
        borderShape.name = "border"
        borderShape.zPosition = 1
        
        addChild(borderShape)
        
    }
    
    func checkForTrailStuff(node: MSButtonNode, string: String) {
      //  shopEquip.alpha = 0
        if lockerTrails.contains(string) {
            node.texture = SKTexture(imageNamed: string + "Purchased")
        }
        if equippedTrail == string {
            print("equipping \(equippedTrail)")
            shopEquip.position = node.position
            
            shopEquip.alpha = 1
        }
        
    }
    func exitPopup() {
        buyPopup.removeAllChildren()
 
        buyPopup.alpha = 0
      //  buyButtonNode?.removeFromParent()
        
    }
    
    func checkForDecalStuff(node: MSButtonNode, string: String) {
   //     shopEquip.alpha = 0
        if lockerDecals.contains(string) {
            node.texture = SKTexture(imageNamed: string + "Purchased")
        }
        if equippedDecal == string {
            shopEquip.alpha = 1
            print("equipping \(equippedDecal)")
            shopEquip.position = node.position
          //  print(equippedDecal)
            
        }
        
    }
    
    func pushShopStuff() {
        let shopPayload = ShopPayload(lockerDecals: lockerDecals, lockerTrails: lockerTrails, equippedDecal: equippedDecal, equippedTrail: equippedTrail)
        let data = try! JSONEncoder().encode(shopPayload)
        let json = String(data: data, encoding: .utf8)!
        DataPusher.PushData(path: "Users/\(UIDevice.current.identifierForVendor!)/ShopStuff", Value: json)
        print(json)
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





