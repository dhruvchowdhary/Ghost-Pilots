import Firebase
import SpriteKit

class LobbyMenu: SKScene {
    var backButtonNode: MSButtonNode!
    var startButtonNode: MSButtonNode!
    
    var codeLabel = SKLabelNode(text: "00000")
    var playerLabel = SKNode()
    var playerLabelParent = SKNode()
    var user1 = SKLabelNode(text: "user1")
    var colorButtonNode: MSButtonNode!
    var kickButtonNode: MSButtonNode!
    var list: [String] = []
    
    override func didMove(to view: SKView) {
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
            // if host give host to someone else || if no one destroy lobby/code || if not host just leave
            self.loadOnlineMenu()
        }
        if UIDevice.current.userInterfaceIdiom != .pad {
            if UIScreen.main.bounds.width < 779 {
                backButtonNode.position.x = -600
                backButtonNode.position.y =  300
            }
        }
        
        startButtonNode = self.childNode(withName: "startButton") as? MSButtonNode
        startButtonNode.selectedHandlers = {
            for s in self.list {
                var spaceship: SpaceshipBase
                if s == Global.playerData.username {
                    spaceship = LocalSpaceship()
                    Global.gameData.playerShip = spaceship as! LocalSpaceship
                } else {
                    spaceship = RemoteSpaceship(playerID: s)
                }
                Global.gameData.shipsToUpdate.append(spaceship)
            }
            Global.loadScene(s: "GameSceneBase")
        }
        if Global.gameData.isHost {
            startButtonNode.alpha = 1
        }

        codeLabel.position = CGPoint(x: frame.midX, y: frame.midY - 340)
        codeLabel.text = String(Global.gameData.gameID)
        setupLabel(label: codeLabel)
        
       // user1.text =
        user1.position = CGPoint(x: frame.midX - 300, y: frame.midY)
        user1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        setupLabel(label: user1)
        
        colorButtonNode = self.childNode(withName: "redPlayer") as? MSButtonNode
        colorButtonNode.position = CGPoint(x: user1.position.x - 230, y: user1.position.y + 50)
        colorButtonNode.selectedHandlers = {
            // go down a list checking if color is in use by another player and if not change it to that
            self.colorButtonNode.texture = SKTexture(imageNamed: "apboBlue")
            // change player's image in firebase
            
            self.colorButtonNode.alpha = 1
        }
        
        kickButtonNode = self.childNode(withName: "kickButton") as? MSButtonNode
        
        user1.name = "user1"
        user1.removeFromParent()
        colorButtonNode.removeFromParent()
        kickButtonNode.removeFromParent()
        playerLabel.addChild(user1)
        addChild(playerLabelParent)
   //     playerLabel.addChild(colorButtonNode)
    //    playerLabel.addChild(kickButtonNode)
        
   //     pullGuestList()
        Global.multiplayerHandler.listenForGuestChanges()
    }
    
    
    func setPlayerList(playerList: [String]) {
        list = playerList
        playerLabelParent.removeAllChildren()
        print(playerList)
        for player in playerList {
            let newuser = playerLabel.copy() as! SKNode
            let userLabel = newuser.childNode(withName: "user1") as! SKLabelNode
            userLabel.text = player
            let i = playerList.firstIndex(of: player)!
            newuser.position.x = frame.midX
            newuser.position.y -= CGFloat(i*100)
            playerLabelParent.addChild(newuser)
        }
    }
    
    func setupLabel(label: SKLabelNode) {
        label.zPosition = 2
        label.fontColor = UIColor.white
        label.fontSize = 120
        label.fontName = "AvenirNext-Bold"
        addChild(label)
    }
    
    func pullGuestList(){
        var playerList: [String] = []
        MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Players").observeSingleEvent(of: .value) { snapshot in
            if (snapshot.exists()){
                for child in snapshot.children {
                    let e = child as! DataSnapshot
                    playerList.append(e.key)
                }
            }
        }
        print(playerList)
        setPlayerList(playerList: playerList)
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
    
    func loadOnlineMenu() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Menu scene */
        guard let scene = SKScene(fileNamed:"OnlineMenu") else {
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


