//
//  MainMenu.swift
//  APBOv2
//
//  Created by 90306670 on 11/18/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import SpriteKit
import UIKit

extension String {
    func emojiToImage() -> UIImage? {
        let dimension = 800
        let size = CGSize(width: dimension, height: dimension)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(dimension))])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

class Shop: SKScene {
    
    /* UI Connections */
    var backButtonNode: MSButtonNode?
    var trailsButtonNode: MSButtonNode!
    var skinsButtonNode: MSButtonNode!

    var shopLightningBoltButtonNode: MSButtonNode!

    //  var shopLightningBoltButtonNode: MSButtonNode!

    
    let polynite = SKSpriteNode(imageNamed: "polynite2")
    let polyniteBox = SKSpriteNode(imageNamed: "polynitebox")
    let polyniteLabel = SKLabelNode(text: "0")
    var currentTab = "skins"
    
    let shopEquip = SKShapeNode()
    let shopEquipLabel = SKSpriteNode(imageNamed: "equippedLabel")
    
    var decalButtons: [MSButtonNode] = []
    var decalShips: [SKSpriteNode] = []
    var decalShipColors: [SKSpriteNode] = []
    var decalBackground: [SKShapeNode] = []
    var decalBackgroundColor: [UIColor] = []
    var decalStrings: [String] = []
    var decalPrices: [Int] = []
    var decalLabel: [SKSpriteNode] = []
    var decalPriceLabel: [SKLabelNode] = []

    var trailButtons: [MSButtonNode] = []
    var trailIcons: [SKSpriteNode] = []
    var trailBackground: [SKShapeNode] = []
    var trailBackgroundColor: [UIColor] = []
    var trailStrings: [String] = []
    var trailPrices: [Int] = []
    var trailLabel: [SKSpriteNode] = []
    var trailPriceLabel: [SKLabelNode] = []
    var trailStringNames:[String] = []

    
    public var lockerDecals: [String] = ["DEFAULTDECAL"]
    public var lockerTrails: [String] = ["trailDefault"]
    public var equippedDecal: String = "DEFAULTDECAL"
    public var equippedTrail: String = "trailDefault"
    
    
    var decalNameTitle: [SKLabelNode] = []
    var trailNameTitle: [SKLabelNode] = []
    
    let buyPopup = SKShapeNode()
    
    var isBuying = false
    
    let backgroundborderwidth = 280
    let backgroundborderheight = 350
    
    var isPopupLoaded = false
    
    // for scrolling shop
    let cameraNode =  SKCameraNode()
    var previousCameraPoint = CGPoint.zero
    let panGesture = UIPanGestureRecognizer()
    var currentHandler = {}
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        //scrolling stuff
        
        panGesture.addTarget(self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGesture)
        
        
        
        addChild(cameraNode)
        camera = cameraNode
        camera?.zPosition = 100
        
        backButtonNode = self.childNode(withName: "backButton") as? MSButtonNode
        backButtonNode?.removeFromParent()
        camera?.addChild(backButtonNode!)
        
        backButtonNode?.zPosition = 2
        
        
        backButtonNode!.selectedHandlers = {
            self.view!.removeGestureRecognizer(self.panGesture)
            //Global.loadScene(s: "MainMenu")
            print("backbutton pressed")
            Global.loadScene(s: "MainMenu")
            
        }
        
        
        
        
        Global.gameData.skView = self.view!
        // EMOJI STUFF
        let emojiImage = "🎂".emojiToImage()
        let emojiTexture = SKTexture(image:emojiImage!)
        
        
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
        
        // setting up shop visual border
        
        let effect = SKEffectNode()
        camera?.addChild(effect)
        
        let effectBackground = SKEffectNode()
        camera?.addChild(effectBackground)
//
//        effect.zPosition = 11

        let backgroundSpace = SKShapeNode()
        
        let backgroundwidth = 2000
        let backgroundheight = 2000
        backgroundSpace.path = UIBezierPath(roundedRect: CGRect(x: -backgroundwidth/2, y: -backgroundheight/2, width: backgroundwidth, height: backgroundheight), cornerRadius: 40).cgPath
        backgroundSpace.position = CGPoint(x: frame.midX, y: frame.midY - 100 )
        backgroundSpace.fillColor = UIColor.black
        backgroundSpace.zPosition = -420
        
        effectBackground.addChild(backgroundSpace)
        
        
        let backgroundholewidth = 1200
        let backgroundholeheight = 500
        let backgroundHole = SKShapeNode()
     
        backgroundHole.path = UIBezierPath(roundedRect: CGRect(x: -backgroundholewidth/2, y: -backgroundholeheight/2, width: backgroundholewidth, height: backgroundholeheight), cornerRadius: 40).cgPath
        backgroundHole.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundHole.fillColor = UIColor.white
        backgroundHole.alpha = 0.001
        backgroundHole.blendMode = .replace
        backgroundSpace.addChild(backgroundHole)
        
        
        
        let borderShape = SKShapeNode()

        let borderwidth = 1200
        let borderheight = 500
        
        borderShape.path = UIBezierPath(roundedRect: CGRect(x: -borderwidth/2, y: -borderheight/2, width: borderwidth, height: borderheight), cornerRadius: 40).cgPath
        borderShape.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        borderShape.fillColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1)
        borderShape.strokeColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
        borderShape.lineWidth = 14
        borderShape.name = "border"
        borderShape.zPosition = -100
        
        
        effect.addChild(borderShape)
        


        let holewidth = 900
        let holeheight = 400
        let rectangleHole = SKShapeNode()
        rectangleHole.name = "rectanglehole"
        rectangleHole.path = UIBezierPath(roundedRect: CGRect(x: -holewidth/2, y: -holeheight/2, width: holewidth, height: holeheight), cornerRadius: 0).cgPath
        rectangleHole.position = CGPoint(x: frame.midX + 115, y: frame.midY)
        rectangleHole.fillColor = UIColor.white
            rectangleHole.alpha = 0.001
        rectangleHole.blendMode = .replace
        borderShape.addChild(rectangleHole)
        
        

        let rectangleFill = SKShapeNode()
        rectangleFill.name = "rectangleFill"
        rectangleFill.path = UIBezierPath(roundedRect: CGRect(x: -holewidth/2, y: -holeheight/2, width: holewidth, height: holeheight), cornerRadius: 0).cgPath
        rectangleFill.position = CGPoint(x: rectangleHole.position.x, y: borderShape.position.y)
        rectangleFill.fillColor = UIColor.white
        rectangleFill.strokeColor = UIColor.white
        rectangleFill.lineWidth = 10
        rectangleFill.zPosition = -200
        camera?.addChild(rectangleFill)
        
        
       
        
        let tabShape = SKShapeNode()

        let tabwidth = 254
        let tabheight = 500 - 14
        
        tabShape.path = UIBezierPath(roundedRect: CGRect(x: -tabwidth/2, y: -tabheight/2, width: tabwidth, height: tabheight), cornerRadius: 40).cgPath
        tabShape.position = CGPoint(x: frame.midX - 470, y: frame.midY - 100)
        tabShape.fillColor = UIColor(red: 14/255, green: 23/255, blue: 160/255, alpha:1)
        tabShape.strokeColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
        tabShape.lineWidth = 14
        borderShape.zPosition = -99
        camera?.addChild(tabShape)
        // dark blu UIColor(red: 14/255, green: 23/255, blue: 57/255, alpha:1)
        
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
        camera?.addChild(buyPopup)
        
        
        shopEquip.alpha = 0
        shopEquip.path = UIBezierPath(roundedRect: CGRect(x: -backgroundborderwidth/2, y: -backgroundborderheight/2, width: backgroundborderwidth, height: backgroundborderheight), cornerRadius: 40).cgPath
        
        shopEquip.fillColor = UIColor.clear
        shopEquip.strokeColor = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha:1)
        shopEquip.lineWidth = 14
        addChild(shopEquip)
        
        shopEquip.zPosition = 6
        
        shopEquipLabel.alpha = 0
        addChild(shopEquipLabel)
        shopEquipLabel.zPosition = 6
        shopEquipLabel.xScale = 0.3
        shopEquipLabel.yScale = 0.3
        
        Global.gameData.skView = self.view!
        Global.gameData.addPolyniteCount(delta: 100)
        
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.targetNode = effectBackground
          //  particles.position = CGPoint(x: frame.midX, y: frame.midY)
            //      particles.advanceSimulationTime(60)
            particles.zPosition = -400
          //  effectBackground.addChild(particles)
        }
        
        
        let shopDisplay = SKSpriteNode(imageNamed: "shopDisplay")
        shopDisplay.position = CGPoint(x: frame.midX, y: frame.midY + 280)
        shopDisplay.xScale = 0.25
        shopDisplay.yScale = 0.25
        camera?.addChild(shopDisplay)
        
        shopDisplay.zPosition = 2
  
        polyniteLabel.text = "\(Global.gameData.polyniteCount)"
        polyniteLabel.position = CGPoint(x: shopDisplay.position.x , y: shopDisplay.position.y - 50)
        polyniteLabel.fontName = "AvenirNext-Bold"
        polyniteLabel.fontColor = UIColor.black
        polyniteLabel.zPosition = 10
        polyniteLabel.fontSize = 80 / 1.5
        camera?.addChild(polyniteLabel)
        
        
        decalShips =
            [
                SKSpriteNode(imageNamed: "decalDefault"), SKSpriteNode(imageNamed: "decalTiger"), SKSpriteNode(imageNamed: "decalSwirl")
            ]
        decalShipColors =// could select a randomized color each tine enter shop
            [
                SKSpriteNode(imageNamed: "decalShipWhite"), SKSpriteNode(imageNamed: "decalShipWhite"), SKSpriteNode(imageNamed: "decalShipWhite")
            ]
        decalButtons =
            [
                MSButtonNode(color: UIColor.clear, size: CGSize(width: backgroundborderwidth, height: backgroundborderheight)), MSButtonNode(color: UIColor.clear, size: CGSize(width: backgroundborderwidth, height: backgroundborderheight)), MSButtonNode(color: UIColor.clear, size: CGSize(width: backgroundborderwidth, height: backgroundborderheight))
            ]
        
        decalBackground =
            [
                SKShapeNode(), SKShapeNode(), SKShapeNode()
            ]

        decalBackgroundColor =
            [
               UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha:1), UIColor(red: 195/255, green: 212/255, blue: 255/255, alpha:1), UIColor(red: 195/255, green: 212/255, blue: 255/255, alpha:1)
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
        decalLabel =
            [
                SKSpriteNode(imageNamed: "priceLabel"), SKSpriteNode(imageNamed: "priceLabel"), SKSpriteNode(imageNamed: "priceLabel")
            ]
        decalPriceLabel =
            [
                SKLabelNode(text: "0"), SKLabelNode(text: "0"), SKLabelNode(text: "0")
            ]

        
        
        trailIcons =
            [
                SKSpriteNode(imageNamed: "trailDefault"), SKSpriteNode(imageNamed: "trailLightning"), SKSpriteNode(imageNamed: "trailHeart")
            ]
        trailButtons =
            [
                MSButtonNode(color: UIColor.clear, size: CGSize(width: backgroundborderwidth, height: backgroundborderheight)), MSButtonNode(color: UIColor.clear, size: CGSize(width: backgroundborderwidth, height: backgroundborderheight)), MSButtonNode(color: UIColor.clear, size: CGSize(width: backgroundborderwidth, height: backgroundborderheight))
            ]
        
        trailBackground =
            [
                SKShapeNode(), SKShapeNode(), SKShapeNode()
            ]

        trailBackgroundColor =
            [
               UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha:1), UIColor(red: 191/255, green: 236/255, blue: 163/255, alpha:1), UIColor(red: 191/255, green: 236/255, blue: 163/255, alpha:1)
            ]
        
        
        trailStrings =
            [
                "trailDefault", "trailLightning", "trailHeart"
            ]
        
        trailStringNames =
            [
                "DEFAULT", "BOLT", "HEART"
            ]
        
        trailPrices =
            [
                0, 200, 200
            ]
        trailNameTitle =
            [
                SKLabelNode(text: "DEFAULT"), SKLabelNode(text: "BOLT"), SKLabelNode(text: "HEART")
            ]
        trailLabel =
            [
                SKSpriteNode(imageNamed: "priceLabel"), SKSpriteNode(imageNamed: "priceLabel"), SKSpriteNode(imageNamed: "priceLabel")
            ]
        trailPriceLabel =
            [
                SKLabelNode(text: "0"), SKLabelNode(text: "0"), SKLabelNode(text: "0")
            ]
        
        
        
        let wait1 = SKAction.wait(forDuration:0.2)
        let action1 = SKAction.run { [self] in
            
            for i in 0..<decalShips.count {
                
                let decalShip = decalShips[i]
                
                let shipSize = CGSize(width: (decalShip.texture?.size().width)! / 4, height: (decalShip.texture?.size().height)! / 4)
                decalShip.size = shipSize
                
                let decalShipColor = decalShipColors[i] // could randomize
                decalShipColor.size = shipSize
                
                let itemBackground = decalBackground[i]
                
                itemBackground.path = UIBezierPath(roundedRect: CGRect(x: -backgroundborderwidth/2, y: -backgroundborderheight/2, width: backgroundborderwidth, height: backgroundborderheight), cornerRadius: 40).cgPath
                
                itemBackground.fillColor = decalBackgroundColor[i]
                itemBackground.strokeColor = UIColor.clear
                itemBackground.lineWidth = 20
                itemBackground.name = "itemBackground"
                itemBackground.alpha = 1
                
                
                let name = decalNameTitle[i]
                name.fontName = "AvenirNext-Bold"
                name.fontColor = UIColor.black
                name.zPosition = 10
                name.fontSize = 80 / 1.5
               
                let label = decalLabel[i]
                label.xScale = 0.3
                label.yScale = 0.3
                label.name = "label"
                
                let priceLabel = decalPriceLabel[i]
                priceLabel.text = String(decalPrices[i])
                priceLabel.fontName = "AvenirNext-Bold"
                priceLabel.fontColor = UIColor.black
                priceLabel.zPosition = 7
                priceLabel.fontSize = 55
                priceLabel.name = "priceLabel"
                
                let node = decalButtons[i]
                node.isUserInteractionEnabled = true
                node.state = .MSButtonStopAlphaChanges
                node.alpha = 1
                // Scale the node here
//                node.xScale = 0.3
//                node.yScale = 0.3
                
                // Position node
                if i != 0 {
                    decalShip.position.x = decalShips[i-1].position.x + 300
                    decalShip.position.y = decalShips[i-1].position.y
                    
                } else {
                    decalShip.position.y = borderShape.position.y
                    decalShip.position.x = borderShape.position.x - 300 + 120
                }
                node.position = decalShip.position
                name.position.x = decalShip.position.x
                name.position.y = decalShip.position.y + 100
                label.position.x = decalShip.position.x
                label.position.y = decalShip.position.y - 120
                priceLabel.position.x = label.position.x + 30
                priceLabel.position.y = label.position.y - 20
                
                
                decalShipColor.position = decalShip.position
                itemBackground.position = decalShip.position
                
                decalShip.zPosition = 7
                decalShipColor.zPosition = 6
                node.zPosition = 10
                name.zPosition = 5
                label.zPosition = 5
                
               
                itemBackground.zPosition = 4
                
                node.selectedHandlers = { [self] in
                    
                    if lockerDecals.contains(decalStrings[i]){
                        
                        showShopEquip(node: node)
                        equippedDecal = decalStrings[i]
                        Global.gameData.selectedSkin = SelectedSkin(rawValue: equippedDecal)!

                        print("\(decalStrings[i]) equipped")
                                        
                        
                    } else {
                        // purchasing
                        //if enough then
                        if Global.gameData.polyniteCount >= decalPrices[i]
                        {
                            if isPopupLoaded == false {
                            loadPopup(index: i, node: node, type: "decal")
                            }
                        }
                        else {
                            Global.gameViewController!.doPopUp(popUpText: "NOT ENOUGH CREDITS")
                            print("not enoug credit")
                        }
                        
                    }
                    pushShopStuff()
                }
                
                
                checkForDecalStuff(index: i, decalShip: decalShip, node: node, string: decalStrings[i])
                
                scene?.addChild(decalShip)
                scene?.addChild(decalShipColor)
                scene?.addChild(node)
                scene?.addChild(name)
                scene?.addChild(itemBackground)
                if i != 0 {
                    scene?.addChild(label)
                    scene?.addChild(priceLabel)
                }
            //    scene?.addChild(decalNameTitle[i].copy() as! SKNode)
                

            }
            
            for i in 0..<trailIcons.count {
                
                let trailIcon = trailIcons[i]
                
                let trailIconSize = CGSize(width: (trailIcon.texture?.size().width)! / 4, height: (trailIcon.texture?.size().height)! / 4)
                trailIcon.size = trailIconSize
                
                
                trailIcon.alpha = 0
        
                
                let itemBackground = trailBackground[i]
                
                itemBackground.path = UIBezierPath(roundedRect: CGRect(x: -backgroundborderwidth/2, y: -backgroundborderheight/2, width: backgroundborderwidth, height: backgroundborderheight), cornerRadius: 40).cgPath
                
                itemBackground.fillColor = trailBackgroundColor[i]
                itemBackground.strokeColor = UIColor.clear
                itemBackground.lineWidth = 20
                itemBackground.name = "itemBackground"
                itemBackground.alpha = 0
                
                
                let name = trailNameTitle[i]
                name.fontName = "AvenirNext-Bold"
                name.fontColor = UIColor.black
                name.zPosition = 10
                name.fontSize = 80 / 1.5
                name.alpha = 0
               
                let label = trailLabel[i]
                label.xScale = 0.3
                label.yScale = 0.3
                label.name = "label"
                label.alpha = 0
                
                let priceLabel = trailPriceLabel[i]
                priceLabel.text = String(trailPrices[i])
                priceLabel.fontName = "AvenirNext-Bold"
                priceLabel.fontColor = UIColor.black
                priceLabel.zPosition = 7
                priceLabel.fontSize = 55
                priceLabel.name = "priceLabel"
                priceLabel.alpha = 0
                
                let node = trailButtons[i]
                node.isUserInteractionEnabled = true
                node.state = .MSButtonStopAlphaChanges
                node.alpha = 0
                // Scale the node here
//                node.xScale = 0.3
//                node.yScale = 0.3
                
                // Position node
                if i != 0 {
                    trailIcon.position.x = trailIcons[i-1].position.x + 300
                    trailIcon.position.y = trailIcons[i-1].position.y
                    
                } else {
                    trailIcon.position.y = borderShape.position.y
                    trailIcon.position.x = borderShape.position.x - 300 + 120
                }
                node.position = trailIcon.position
                name.position.x = trailIcon.position.x
                name.position.y = trailIcon.position.y + 100
                label.position.x = trailIcon.position.x
                label.position.y = trailIcon.position.y - 120
                priceLabel.position.x = label.position.x + 30
                priceLabel.position.y = label.position.y - 20
                
                itemBackground.position = trailIcon.position
                
                trailIcon.zPosition = 7
                node.zPosition = 10
                name.zPosition = 5
                label.zPosition = 5
                
               
                itemBackground.zPosition = 4
                
                node.selectedHandlers = { [self] in
                    
                    if lockerTrails.contains(trailStrings[i]){
                        
                        showShopEquip(node: node)
                        equippedTrail = trailStrings[i]
                        Global.gameData.selectedTrail = SelectedTrail(rawValue: equippedTrail)!

                        print("\(trailStrings[i]) equipped")
                                        
                        
                    } else {
                        // purchasing
                        //if enough then
                        if Global.gameData.polyniteCount >= trailPrices[i]
                        {
                            if isPopupLoaded == false {
                            loadPopup(index: i, node: node, type: "trail")
                            }
                        }
                        else {
                            Global.gameViewController!.doPopUp(popUpText: "NOT ENOUGH CREDITS")
                            print("not enoug credit")
                        }
                        
                    }
                    pushShopStuff()
                }
                
                
                checkForTrailStuff(index: i, trailIcon: trailIcon, node: node, string: trailStrings[i])
                
                scene?.addChild(trailIcon)
                scene?.addChild(node)
                scene?.addChild(name)
                scene?.addChild(itemBackground)
                if i != 0 {
                    scene?.addChild(label)
                    scene?.addChild(priceLabel)
                }
            //    scene?.addChild(decalNameTitle[i].copy() as! SKNode)
                

            }
            
        }
          
            

        
        self.run(SKAction.sequence([wait1,action1]))
        
       // checkForDecalStuff(decalShip: decalShips[0], string: "DEFAULTDECAL")
        
        trailsButtonNode = self.childNode(withName: "trailsButtonSelected") as? MSButtonNode
        trailsButtonNode.selectedHandlers = { [self] in
            hideShopEquip()
            self.trailsButtonNode.texture = SKTexture(imageNamed: "trailsButtonUnselected")
            self.skinsButtonNode.texture = SKTexture(imageNamed: "skinsButtonSelected")
            self.trailsButtonNode.alpha = 1
            self.currentTab = "trails"
            
            
            hideDecalStuff()
            showTrailStuff()
        }
        
        trailsButtonNode.selectedHandler = {
            self.trailsButtonNode.alpha = 1
        }
        
        skinsButtonNode = self.childNode(withName: "skinsButtonUnselected") as? MSButtonNode
        skinsButtonNode.selectedHandlers = { [self] in
            self.trailsButtonNode.texture = SKTexture(imageNamed: "trailsButtonSelected")
            self.skinsButtonNode.texture = SKTexture(imageNamed: "skinsButtonUnselected")
            self.skinsButtonNode.alpha = 1
            self.currentTab = "skins"
            hideShopEquip()
            showDecalStuff()
            hideTrailStuff()
        }
        
        skinsButtonNode.selectedHandler = {
            self.skinsButtonNode.alpha = 1
        }
        
        trailsButtonNode.xScale = 0.8
        trailsButtonNode.yScale = 0.8
        skinsButtonNode.xScale = 0.8
        skinsButtonNode.yScale = 0.8
        trailsButtonNode.position = CGPoint(x: frame.midX - 469 , y: borderShape.position.y - 60)
        skinsButtonNode.position = CGPoint(x: trailsButtonNode.position.x, y: borderShape.position.y + 60)
        skinsButtonNode.zPosition = 100
        trailsButtonNode.zPosition = 100
        
        trailsButtonNode?.removeFromParent()
        camera?.addChild(trailsButtonNode!)
        skinsButtonNode?.removeFromParent()
        camera?.addChild(skinsButtonNode!)
        
        
        func hideDecalStuff() {
            for i in 0..<decalShips.count {
                decalButtons[i].alpha = 0
                decalShips[i].alpha = 0
                decalShipColors[i].alpha = 0
                decalNameTitle[i].alpha = 0
                decalBackground[i].alpha = 0
                decalLabel[i].alpha = 0
                decalPriceLabel[i].alpha = 0
                
                
                
            }
        }
        
        func showDecalStuff() {
            for i in 0..<decalShips.count {
                decalButtons[i].alpha = 1
                decalShips[i].alpha = 1
                decalShipColors[i].alpha = 1
                decalNameTitle[i].alpha = 1
                decalBackground[i].alpha = 1
                decalLabel[i].alpha = 1
                decalPriceLabel[i].alpha = 1
                checkForDecalStuff(index: i, decalShip: decalShips[i], node: decalButtons[i], string: decalStrings[i])
               

            }
        }
        
        func hideTrailStuff() {
            for i in 0..<trailIcons.count {
                trailButtons[i].alpha = 0
                trailIcons[i].alpha = 0
                trailNameTitle[i].alpha = 0
                trailBackground[i].alpha = 0
                trailLabel[i].alpha = 0
                trailPriceLabel[i].alpha = 0
                
            }
        }
        
        func showTrailStuff() {
            for i in 0..<trailIcons.count {
                trailButtons[i].alpha = 1
                trailIcons[i].alpha = 1
                trailNameTitle[i].alpha = 1
                trailBackground[i].alpha = 1
                trailLabel[i].alpha = 1
                trailPriceLabel[i].alpha = 1
                checkForTrailStuff(index: i, trailIcon: trailIcons[i], node: trailButtons[i], string: trailStrings[i])
               

            }
        }
        

        func loadPopup(index: Int, node: MSButtonNode, type: String) {

            
            
            
            let buyButtonNode: MSButtonNode = MSButtonNode(imageNamed: "buttonBuy")
            
            buyButtonNode.xScale = 0.6
            buyButtonNode.yScale = 0.6
            
           
            buyButtonNode.position = CGPoint(x: frame.midX + 130 , y: buyPopup.position.y - 210)
            buyButtonNode.zPosition = 20
            camera?.addChild(buyButtonNode)
            
            let cancelButtonNode: MSButtonNode = MSButtonNode(imageNamed: "buttonCancel")
            
            cancelButtonNode.xScale = 0.6
            cancelButtonNode.yScale = 0.6
            
           
            cancelButtonNode.position = CGPoint(x: frame.midX - 130 , y: buyPopup.position.y - 210)
            cancelButtonNode.zPosition = 20
            camera?.addChild(cancelButtonNode)
            
            cancelButtonNode.selectedHandlers = {
                self.exitPopup()
                cancelButtonNode.removeFromParent()
                buyButtonNode.removeFromParent()
                cancelButtonNode.alpha = 0
                buyButtonNode.alpha = 0
                
            }
            
            
            var item = SKSpriteNode()
            var itemColor = SKSpriteNode()
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
                
                item = decalShips[index].copy() as! SKSpriteNode
                itemColor = decalShipColors[index].copy() as! SKSpriteNode
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
                
                item = trailIcons[index].copy() as! SKSpriteNode

                itemName = SKLabelNode(text: trailStringNames[index])
                prompt1 = SKLabelNode(text: "PURCHASE " + trailStringNames[index])
                prompt2 = SKLabelNode(text: " FOR " + String(trailPrices[index]) + " POLYNITE?")
            }
           
            itemName.position = CGPoint(x: frame.midX, y: buyPopup.position.y + 185)
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
           
            
            item.xScale = 1
            item.yScale = 1
            item.zPosition = 4
            item.position = CGPoint(x: frame.midX, y: buyPopup.position.y + 70)
            
            itemColor.xScale = 1
            itemColor.yScale = 1
            itemColor.zPosition = 3
            itemColor.position = CGPoint(x: frame.midX, y: buyPopup.position.y + 70)
            
            
            
            buyPopup.addChild(itemName)
            buyPopup.addChild(prompt1)
            buyPopup.addChild(prompt2)
            buyPopup.addChild(item)
            buyPopup.addChild(itemColor)
       //     addChild(itemName)
            
            isPopupLoaded = true
            
        }
        
        
        func buyingTrail(i: Int, node: MSButtonNode) {
            
            print("bought \(trailStrings[i])")
            // subtract polynite according to price
            Global.gameData.spendPolynite(amountToSpend: trailPrices[i])
            
            lockerTrails.append(trailStrings[i])

            polyniteLabel.text = "\(Global.gameData.polyniteCount)"
            
            showShopEquip(node: node)
            trailLabel[i].texture = SKTexture(imageNamed: "purchasedLabel")
            trailPriceLabel[i].removeFromParent()
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
            
            showShopEquip(node: node)
            decalLabel[i].texture = SKTexture(imageNamed: "purchasedLabel")
            decalPriceLabel[i].removeFromParent()
            equippedDecal = decalStrings[i]

            Global.gameData.selectedSkin = SelectedSkin(rawValue: equippedDecal)!
            
            pushShopStuff()
            exitPopup()
        }
        
        // adjusting for devices
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIScreen.main.bounds.width < 779 {
                backButtonNode!.position.x = -600
                backButtonNode!.position.y =  300
            }
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            
        } else if UIScreen.main.bounds.width > 779 {
            
        } else {
            polyniteBox.position.x = frame.midX + 600
            polynite.position.x = polyniteBox.position.x - 80
            polyniteLabel.position.x = polyniteBox.position.x + 60
        }

 
        
    }
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        // The camera has a weak reference, so test it
        guard let camera = self.camera else {
            return
        }
        
        //  let zoomInActionipad = SKAction.scale(to: 1.7, duration: 0.01)
        
        //  camera.run(zoomInActionipad)
        
        // If the movement just began, save the first camera position
        if sender.state == .began {
            previousCameraPoint = camera.position
            currentHandler()
            currentHandler = {}
        }
        // Perform the translation
        let translation = sender.translation(in: self.view)
        
        var newPosition = CGPoint(
            x: previousCameraPoint.x + translation.x * -2,
            y: previousCameraPoint.y
        )
        if newPosition.x < 0 { newPosition.x = 0}
        var rightLimit = CGFloat(0)
        if currentTab == "skins" {
            rightLimit = CGFloat(((decalShips.count - 3) * 300))
        }
        else if currentTab == "trails" {
            rightLimit = CGFloat((trailIcons.count - 3) * 300)
        }
        
        if newPosition.x > rightLimit { newPosition.x = CGFloat(rightLimit)}
        
        camera.position = newPosition
        
        
    }

    
   
    func exitPopup() {
        buyPopup.removeAllChildren()
        isPopupLoaded = false
        buyPopup.alpha = 0
      //  buyButtonNode?.removeFromParent()
        
    }
    func showShopEquip(node: MSButtonNode) {
        shopEquip.position = node.position
        shopEquip.alpha = 1
        
        shopEquipLabel.position.x = node.position.x
        shopEquipLabel.position.y = node.position.y - 120 // this val must match in the for loops
        shopEquipLabel.alpha = 1
    }
    
    func hideShopEquip() {
        shopEquip.alpha = 0
        shopEquipLabel.alpha = 0
    }
    func checkForDecalStuff(index: Int, decalShip: SKSpriteNode, node: MSButtonNode, string: String) {
        if currentTab == "skins" {
            //     shopEquip.alpha = 0
            
            //code to show show purchased
            if lockerDecals.contains(string) {
                print("locker contains \(string)")
                decalLabel[index].texture = SKTexture(imageNamed: "purchasedLabel")
                decalPriceLabel[index].alpha = 0
            }
            if equippedDecal == string {
                shopEquip.alpha = 1
                print("equipping \(equippedDecal)")
                showShopEquip(node: node)
                //  print(equippedDecal)
            }
        }
        
    }
    
    func checkForTrailStuff(index: Int, trailIcon: SKSpriteNode, node: MSButtonNode, string: String) {
        if currentTab == "trails" {
            //     shopEquip.alpha = 0
            
            //code to show show purchased
            if lockerTrails.contains(string) {
                print("locker contains \(string)")
                trailLabel[index].texture = SKTexture(imageNamed: "purchasedLabel")
                trailPriceLabel[index].alpha = 0
            }
            if equippedTrail == string {
                shopEquip.alpha = 1
                print("equipping \(equippedTrail)")
                showShopEquip(node: node)
            }
        }
        
    }
    
    func pushShopStuff() {
        let shopPayload = ShopPayload(lockerDecals: lockerDecals, lockerTrails: lockerTrails, equippedDecal: equippedDecal, equippedTrail: equippedTrail)
        let data = try! JSONEncoder().encode(shopPayload)
        let json = String(data: data, encoding: .utf8)!
        DataPusher.PushData(path: "Users/\(UIDevice.current.identifierForVendor!)/ShopStuff", Value: json)
       print("shop data: ")
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





