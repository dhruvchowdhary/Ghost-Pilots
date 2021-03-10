//
//  OnlineMenu.swift
//  APBOv2
//
//  Created by 90306670 on 11/24/20.
//  Copyright © 2020 Dhruv Chowdhary. All rights reserved.
//

import Foundation
import SpriteKit
import StoreKit
import UIKit
import Firebase
import FirebaseCore
import FirebaseDatabase


class OnlineMenu: SKScene, UITextFieldDelegate {
    var backButtonNode: MSButtonNode!
    var hostButtonNode: MSButtonNode!
    var joinButtonNode: MSButtonNode!
    var enterButtonNode: MSButtonNode!
    var emptyButton = SKSpriteNode(imageNamed: "emptyButton")
    
    var useCount = UserDefaults.standard.integer(forKey: "useCount")
  //  var username = UserDefaults.standard.string(forKey: "username")
    
    var usernameBox: UITextField!
    var codeBox: UITextField!
    var activeTextField: UITextField!
    var ref: DatabaseReference!

    override func didMove(to view: SKView) {
        usernameBox = UITextField(frame: CGRect(x: view.bounds.width/2 - 95, y: view.bounds.height/2 - 130, width: 190, height: 60))
        usernameBox.attributedPlaceholder = NSAttributedString(string: "Enter Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        usernameBox.font = UIFont.init(name: "AvenirNext-Bold", size: 23)
        
        codeBox = UITextField(frame: CGRect(x: view.bounds.width/2 - 65, y: view.bounds.height/2 + 50, width: 130, height: 50))
        codeBox.attributedPlaceholder = NSAttributedString(string: "Enter Code", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        codeBox.font = UIFont.init(name: "AvenirNext-Bold", size: 16)
        codeBox.keyboardType = .numberPad
        codeBox.alpha = 0
        
        createTextBox(textBox: usernameBox)
        createTextBox(textBox: codeBox)

        ref = Database.database().reference()
        ref.child("systemID/\(UIDevice.current.identifierForVendor!.uuidString)").observeSingleEvent(of: .value){ snapshot in
            if snapshot.exists() {
                self.usernameBox.text = snapshot.value as? String
                Global.playerData.username = snapshot.value as! String
            }
        }
        
        
        self.setupHideKeyboardOnTap()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        useCount += 1 //Increment the useCount
        UserDefaults.standard.set(useCount, forKey: "useCount")
        if useCount == 1 {
            loadTutorial()
        } else {
            if useCount == 6 {
                SKStoreReviewController.requestReview() //Request the review.
            }
            /* Setup your scene here */
            if let particles = SKEmitterNode(fileNamed: "Starfield") {
                particles.position = CGPoint(x: frame.midX, y: frame.midY)
                //      particles.advanceSimulationTime(60)
                particles.zPosition = -1
                addChild(particles)
            }
            self.sceneShake(shakeCount: 4, intensity: CGVector(dx: 2, dy: 2), shakeDuration: 0.1)
            self.run(SKAction.playSoundFileNamed("menuThumpnew", waitForCompletion: false))
            
            /* Set UI connections */
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
            
            hostButtonNode = self.childNode(withName: "hostButton") as? MSButtonNode
            hostButtonNode.selectedHandlers = {
                if self.usernameBox.text!.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.usernameBox.shake()
                    self.usernameBox.text?.removeAll()
                    self.hostButtonNode.alpha = 1
                } else {
                    self.loadHostMenu()
                }
            }
            
            joinButtonNode = self.childNode(withName: "joinButton") as? MSButtonNode
            emptyButton = self.childNode(withName: "emptyButton") as! SKSpriteNode
            enterButtonNode = self.childNode(withName: "enterButton") as? MSButtonNode
            joinButtonNode.selectedHandlers = {
                self.joinButtonNode.alpha = 0
                self.emptyButton.alpha = 1
                self.enterButtonNode.alpha = 1
                self.codeBox.alpha = 1
            }
            
            enterButtonNode.selectedHandlers = {
                if self.usernameBox.text!.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.usernameBox.shake()
                    self.usernameBox.text?.removeAll()
                    self.enterButtonNode.alpha = 1
                } else if self.codeBox.text!.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.codeBox.shake()
                    self.enterButtonNode.alpha = 1
                } else {
                    self.ref.child("Games/\(self.codeBox.text!)").observeSingleEvent(of: .value){ snapshot in
                        if snapshot.exists() {
                            DataPusher.PushData(path: "Games/\(self.codeBox.text!)/PlayerList/\(self.usernameBox.text!)", Value: "PePeNotGone")
                            Global.gameData.gameID = Int(self.codeBox.text!)!
                            Global.gameData.isHost = false
                            self.loadLobbyMenu()
                        } else {
                            print(self.codeBox.text!)
                            self.codeBox.shake()
                            self.enterButtonNode.alpha = 1
                        }
                    }
                }
            }
            
            setPositions()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if activeTextField == codeBox {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view?.frame.origin.y == 0 {
                    self.view?.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if activeTextField == usernameBox {
            if self.usernameBox.text!.trimmingCharacters(in: .whitespaces).isEmpty {
                self.usernameBox.shake()
                self.usernameBox.text?.removeAll()
            }
        }
        if self.view?.frame.origin.y != 0 {
            self.view?.frame.origin.y = 0
        }
        Global.playerData.username = usernameBox.text!
        print(Global.playerData.username)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength = 0
        if activeTextField == usernameBox {
            maxLength = 10
        } else {
            maxLength = 5
        }
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    // Assign the newly active text field to your activeTextField variable
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func KickedFromGame() {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hides the keyboard
        textField.resignFirstResponder()
        
        // if is codeBox
        if activeTextField == codeBox {
            if self.usernameBox.text == "" {
                self.usernameBox.shake()
            } else {
                // do whatever is in the else of enterButtonNode.selectedHandlers
            }
        }
        return true
    }
    
    func createTextBox(textBox: UITextField) {
        view?.addSubview(textBox)
        textBox.delegate = self
        
        textBox.borderStyle = UITextField.BorderStyle.roundedRect
        textBox.layer.borderColor = UIColor.white.cgColor
        textBox.layer.borderWidth = 3.0
        textBox.layer.cornerRadius = 10
        
        textBox.textColor = SKColor.white
        textBox.textAlignment = .center
        textBox.backgroundColor = SKColor.clear
        textBox.autocorrectionType = UITextAutocorrectionType.no
        
        textBox.clearButtonMode = UITextField.ViewMode.whileEditing
        self.view!.addSubview(textBox)
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
    
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view!.addGestureRecognizer(self.endEditingRecognizer())
        //       self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view!.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
    
    func setPositions() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            usernameBox.frame = CGRect(x: view!.bounds.width/2 - 160, y: view!.bounds.height/2 - 195, width: 320, height: 101.052632)
            usernameBox.font = UIFont.init(name: "AvenirNext-Bold", size: 38.7368)
            
            codeBox.frame = CGRect(x: view!.bounds.width/2 - 100, y: view!.bounds.height/2 + 85, width: 200, height: 70)
            codeBox.font = UIFont.init(name: "AvenirNext-Bold", size: 28)
        } else if UIScreen.main.bounds.width > 779 {
            //iphone X+
            usernameBox.frame = CGRect(x: view!.bounds.width/2 - 140, y: view!.bounds.height/2 - 165, width: 280, height: 88.947368)
            usernameBox.font = UIFont.init(name: "AvenirNext-Bold", size: 38)
            if UIScreen.main.bounds.width > 813 {
                //iphone XR and others
                codeBox.frame = CGRect(x: view!.bounds.width/2 - 80, y: view!.bounds.height/2 + 65, width: 160, height: 65)
            } else {
                //iphone X
                codeBox.frame = CGRect(x: view!.bounds.width/2 - 80, y: view!.bounds.height/2 + 80, width: 160, height: 58)
                codeBox.frame = CGRect(x: view!.bounds.width/2 - 80, y: view!.bounds.height/2 + 58.5, width: 160, height: 58)

            }
            codeBox.font = UIFont.init(name: "AvenirNext-Bold", size: 23)
        } else if UIScreen.main.bounds.width > 567 {
            //iphone 8+
            usernameBox.frame = CGRect(x: view!.bounds.width/2 - 120, y: view!.bounds.height/2 - 150, width: 240, height: 75.78947)
            usernameBox.font = UIFont.init(name: "AvenirNext-Bold", size: 33)
            
            codeBox.frame = CGRect(x: view!.bounds.width/2 - 75, y: view!.bounds.height/2 + 58, width: 150, height: 60)
            codeBox.font = UIFont.init(name: "AvenirNext-Bold", size: 20)
        } else {
            // < iphone 8
            
        }
    }
    
    func loadTutorial() {
        usernameBox.removeFromSuperview()
        codeBox.removeFromSuperview()
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = Tutorial(fileNamed:"Tutorial") else {
            print("Could not make Tutorial, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func loadMainMenu() {
        DataPusher.PushData(path: "systemID/\(UIDevice.current.identifierForVendor!.uuidString)", Value: usernameBox.text!)
        usernameBox.removeFromSuperview()
        codeBox.removeFromSuperview()
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
    
    func loadHostMenu() {
        DataPusher.PushData(path: "systemID/\(UIDevice.current.identifierForVendor!.uuidString)", Value: usernameBox.text!)
        usernameBox.removeFromSuperview()
        codeBox.removeFromSuperview()
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Menu scene */
        guard let scene = SKScene(fileNamed:"HostMenu") else {
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
    
    func loadLobbyMenu() {
        DataPusher.PushData(path: "systemID/\(UIDevice.current.identifierForVendor!.uuidString)", Value: usernameBox.text!)
        usernameBox.removeFromSuperview()
        codeBox.removeFromSuperview()
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView? else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Menu scene */
        guard let scene = SKScene(fileNamed:"LobbyMenu") else {
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

extension UITextField {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - 4.0, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 4.0, y: self.center.y)
        layer.add(animation, forKey: "position")
    }
}
