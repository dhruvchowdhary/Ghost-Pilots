import Firebase
import SpriteKit

class LobbyMenu: SKScene {
    var backButtonNode: MSButtonNode!
    var startButtonNode: MSButtonNode!
    
    var codeLabel = SKLabelNode(text: "00000")
    var playercountLabel = SKLabelNode(text: "1/∞")
    var playerLabel = SKNode()
    var playerLabelParent = SKNode()
    var user1 = SKLabelNode(text: "user1")
    var randInt = 0
    
    var modeImageButtonNode: MSButtonNode!
    let modeArray = ["ffa", "astroball", "infection"]
    var i = 0
    
    var mapImageButtonNode: MSButtonNode!
    var mapArray = ["OnlineCubis", "OnlineTrisen", "OnlineHex"]
    var j = 0
    
    var colorButtonNode: MSButtonNode!
    var colorIndex = 0
    var kickButtonNode: MSButtonNode!
    var list: [String] = []
    
    let intToColor: Dictionary = [
        0: "player",
        1: "apboBlue",
        2: "apboBlack",
        3: "apboGreen",
        4: "apboOrange",
        5: "apboPink",
        6: "apboPurple",
        7: "apboWhite",
        8: "apboYellow",
    ]
    let intToColorInfection: Dictionary = [
        0: "apboGreen",
        1: "apboWhite",
    ]
    
    
    override func didMove(to view: SKView) {
        Global.gameData.gameState = GameStates.LobbyMenu
        
        MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/PlayerList").observeSingleEvent(of: .value) { snapshot in
            var playerList: [String] = []
            for child in snapshot.children {
                let e = child as! DataSnapshot
                if e.value as! String == "PePeNotGone"{
                    playerList.append(e.key)
                }
            }
            self.setPlayerList(playerList: playerList)
        }
        
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
            Global.gameData.ResetGameData(toLobby: false)
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
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/Status", Value: "Game")
            //====================================
        }
        if Global.gameData.isHost {
            startButtonNode.alpha = 1
        }

        codeLabel.position = CGPoint(x: frame.midX, y: frame.midY - 340)
        startButtonNode.position.y = codeLabel.position.y + startButtonNode.size.height/4
        codeLabel.text = String(Global.gameData.gameID)
        setupLabel(label: codeLabel)
        
        playercountLabel.position = CGPoint(x: -480, y: frame.midY - 340)
        setupLabel(label: playercountLabel)
        
        user1.position = CGPoint(x: frame.midX - 150, y: frame.midY)
        user1.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        setupLabel(label: user1)
        user1.fontSize = 90
        

        colorButtonNode = self.childNode(withName: "redPlayer") as? MSButtonNode
        kickButtonNode = self.childNode(withName: "kickButton") as? MSButtonNode
        
        if Global.gameData.mode == modeArray[0] {
            i = 0
        } else if Global.gameData.mode == modeArray[1] {
            i = 1
        } else {
            i = 2
        }
        modeImageButtonNode = self.childNode(withName: "modeImage") as? MSButtonNode
        self.modeImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.mode)
        if Global.gameData.isHost {
            modeImageButtonNode.selectedHandlers = {
                if self.i == self.modeArray.endIndex - 1 {
                    self.i = 0
                } else {
                    self.i = self.i+1
                }
                self.modeImageButtonNode.alpha = 1
                Global.gameData.mode = self.modeArray[self.i]
                Global.gameData.ModeChange()
                self.modeImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.mode)
            }
        } else {
            modeImageButtonNode.selectedHandler = {
                self.modeImageButtonNode.alpha = 1
            }
        }
        
        if Global.gameData.map == mapArray[0] {
            j = 0
        } else if Global.gameData.map == mapArray[1] {
            j = 1
        } else {
            j = 2
        }
        mapImageButtonNode = self.childNode(withName: "mapImage") as? MSButtonNode
        self.mapImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.map)
        if Global.gameData.isHost {
            mapImageButtonNode.selectedHandlers = {
                if self.j == self.mapArray.endIndex - 1 {
                    self.j = 0
                } else {
                    self.j = self.j+1
                }
                self.mapImageButtonNode.alpha = 1
                Global.gameData.map = self.mapArray[self.j]
                Global.gameData.MapChange()
                self.mapImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.map)
            }
        } else {
            mapImageButtonNode.selectedHandler = {
                self.mapImageButtonNode.alpha = 1
            }
        }
        
        user1.name = "user1"
        colorButtonNode.name = "colorButtonNode"
        kickButtonNode.name = "kickButtonNode"
        user1.removeFromParent()
        colorButtonNode.removeFromParent()
        kickButtonNode.removeFromParent()
        
        playerLabel.addChild(user1)
        playerLabel.addChild(colorButtonNode)
        if Global.gameData.isHost {
            playerLabel.addChild(kickButtonNode)
        }
        addChild(playerLabelParent)
        
        Global.multiplayerHandler.listenForGuestChanges()
        Global.multiplayerHandler.ListenForGameStatus()
        Global.multiplayerHandler.ListenForMapChanges()
        Global.multiplayerHandler.ListenForModeChanges()
   //     Global.multiplayerHandler.ListenForColorChanges()
    }
    
    
    func setPlayerList(playerList: [String]) {
        list = playerList
        playerLabelParent.removeAllChildren()
        print(playerList)
        for player in playerList {
            let newuser = playerLabel.copy() as! SKNode
            let userLabel = newuser.childNode(withName: "user1") as! SKLabelNode
            userLabel.text = player
            let index = playerList.firstIndex(of: player)!
            
            if Global.gameData.isHost {
                let userKick = newuser.childNode(withName: "kickButtonNode") as! MSButtonNode
                userKick.selectedHandlers = {
                    //kick em
                }
            }
            let userColor = newuser.childNode(withName: "colorButtonNode") as! MSButtonNode
            if player == Global.playerData.username {
                setUpColors(userColor: userColor, isPlayer: true, index: index)
            } else {
                setUpColors(userColor: userColor, isPlayer: false, index: index)
            }
            
            
            newuser.position.x = frame.midX - 120
            newuser.position.y += CGFloat(200 - index*100)
            playerLabelParent.addChild(newuser)
            playercountLabel.text = "\(playerList.count)/∞"
        }
    }
    
    func StartGame(){
        if list.count > 1 {
            randInt = Global.gameData.gameID % (list.count)
        }
        for s in self.list {
            var spaceship: SpaceshipBase
            if s == Global.playerData.username {
                switch Global.gameData.mode {
                case "infection":
                    if list.firstIndex(of: s) == randInt {
                        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/InfectedList/\(Global.playerData.username)", Value: "true")
                        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerColor/\(Global.playerData.username)", Value: "apboGreen")
                        spaceship = LocalSpaceship(imageTexture: intToColorInfection[0]!)
                    } else {
                        DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerColor/\(Global.playerData.username)", Value: "apboWhite")
                        spaceship = LocalSpaceship(imageTexture: intToColorInfection[1]!)
                    }
                case "ffa":
                    spaceship = LocalSpaceship(imageTexture: intToColor[colorIndex]!)
                case "astroball":
                    spaceship = LocalSpaceship(imageTexture: intToColor[colorIndex]!)
                default:
                    spaceship = LocalSpaceship(imageTexture: intToColor[colorIndex]!)
                }
                Global.gameData.playerShip = spaceship as? LocalSpaceship
            } else {
                print("not me: \(list.firstIndex(of: s))")
                switch Global.gameData.mode {
                case "infection":
                    if list.firstIndex(of: s) == randInt {
                        spaceship = RemoteSpaceship(playerID: s, imageTexture: intToColorInfection[0]!)
                    } else {
                        spaceship = RemoteSpaceship(playerID: s, imageTexture: intToColorInfection[1]!)
                    }
                case "ffa":
                    spaceship = RemoteSpaceship(playerID: s, imageTexture: intToColor[list.firstIndex(of: s)! % 9]!)
                case "astroball":
                    spaceship = RemoteSpaceship(playerID: s, imageTexture: intToColor[list.firstIndex(of: s)! % 2]!)
                default:
                    spaceship = RemoteSpaceship(playerID: s, imageTexture: intToColor[list.firstIndex(of: s)! % 9]!)
                }
            }
            Global.gameData.shipsToUpdate.append(spaceship)
        }
        
        switch Global.gameData.mode {
        case "ffa":
            Global.gameData.gameState = GameStates.FFA
            Global.loadScene(s: "GameSceneBase")
        case "astroball":
            Global.gameData.gameState = GameStates.AstroBall
            Global.loadScene(s: "AstroBall")
        case "infection":
            Global.gameData.gameState = GameStates.Infection
            Global.loadScene(s: "Infection")
        default:
            Global.gameData.gameState = GameStates.FFA
            Global.loadScene(s: "GameSceneBase")
        }
    }
    
    func setupLabel(label: SKLabelNode) {
        label.zPosition = 2
        label.fontColor = UIColor.white
        label.fontSize = 120
        label.fontName = "AvenirNext-Bold"
        addChild(label)
    }
    
    func setUpColors(userColor: MSButtonNode, isPlayer: Bool, index: Int){
        switch Global.gameData.mode {
        case "infection":
            userColor.alpha = 0
        case "ffa":
            userColor.texture = SKTexture(imageNamed: intToColor[index % 9]!)
            colorIndex = index
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerColor/\(Global.playerData.username)", Value: self.intToColor[self.colorIndex]!)
            if isPlayer {
                userColor.selectedHandlers = {
                    if self.colorIndex == 8 {
                        self.colorIndex = 0
                    } else {
                        self.colorIndex = self.colorIndex + 1
                    }
                    userColor.texture = SKTexture(imageNamed: self.intToColor[self.colorIndex]!)
                    DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerColor/\(Global.playerData.username)", Value: self.intToColor[self.colorIndex]!)
                    userColor.alpha = 1
                }
            } else {
                userColor.selectedHandler = {
                    userColor.alpha = 1
                }
            }
        case "astroball":
            userColor.texture = SKTexture(imageNamed: intToColor[index % 2]!)
            colorIndex = index
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerColor/\(Global.playerData.username)", Value: self.intToColor[self.colorIndex]!)
            if isPlayer {
                userColor.selectedHandlers = {
                    if self.colorIndex == 1 {
                        self.colorIndex = 0
                    } else {
                        self.colorIndex = 1
                    }
                    userColor.texture = SKTexture(imageNamed: self.intToColor[self.colorIndex]!)
                    DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerColor/\(Global.playerData.username)", Value: self.intToColor[self.colorIndex]!)
                    userColor.alpha = 1
                }
            } else {
                userColor.selectedHandler = {
                    userColor.alpha = 1
                }
            }
        default:
            userColor.texture = SKTexture(imageNamed: intToColor[index % 9]!)
            colorIndex = index
            DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerColor/\(Global.playerData.username)", Value: self.intToColor[self.colorIndex]!)
            userColor.selectedHandlers = {
                if self.colorIndex == 8 {
                    self.colorIndex = 0
                } else {
                    self.colorIndex = self.colorIndex + 1
                }
                userColor.texture = SKTexture(imageNamed: self.intToColor[self.colorIndex]!)
                DataPusher.PushData(path: "Games/\(Global.gameData.gameID)/PlayerColor/\(Global.playerData.username)", Value: self.intToColor[self.colorIndex]!)
                userColor.alpha = 1
            }
        }
    }
    
    func pullMap(){
        print("pulled map")
        MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Map").observeSingleEvent(of: .value) {
            snapshot in
            if (snapshot.exists()) {
                Global.gameData.map = snapshot.value as! String
                self.mapImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.map)
                self.mapImageButtonNode.alpha = 1
            }
        }
    }
    
    func pullMode(){
        print("pulled mode")
        MultiplayerHandler.ref.child("Games/\(Global.gameData.gameID)/Mode").observeSingleEvent(of: .value) {
            snapshot in
            if (snapshot.exists()) {
                Global.gameData.mode = snapshot.value as! String
                self.modeImageButtonNode.texture = SKTexture(imageNamed: Global.gameData.mode)
                self.modeImageButtonNode.alpha = 1
            }
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

}


