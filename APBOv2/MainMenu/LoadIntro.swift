import GoogleMobileAds
import SpriteKit

class LoadIntro: SKScene {
    let intropilot = SKSpriteNode(imageNamed: "intropilot")
    
    override func didMove(to view: SKView) {
        
        Global.adHandler.setup()
        /* Setup your scene here */
        Global.gameData.skView = self.view!
        
        intropilot.position = CGPoint(x: frame.midX, y: frame.midY)
        intropilot.size =  CGSize(width: 250.6667, height: 247.3333)
        addChild(intropilot)
        let fadeOut = SKAction.fadeOut(withDuration: 2.5)
        intropilot.run(fadeOut)
        
        let wait1 = SKAction.wait(forDuration: 2.5)
        let action1 = SKAction.run {
            Global.loadScene(s: "MainMenu")
        }
        self.run(SKAction.sequence([wait1,action1]))
        MultiplayerHandler.ref.child("Users/\(UIDevice.current.identifierForVendor!)/Polynite").observeSingleEvent(of: .value) {
            snapshot in
            if (snapshot.exists()) {
                Global.gameData.polyniteCount = Int(snapshot.value as! String)!
            } else {
                DataPusher.PushData(path: "Users/\(UIDevice.current.identifierForVendor!)/Polynite", Value: "0")
            }
        }
        
        let shopRef = MultiplayerHandler.ref.child("Users/\(UIDevice.current.identifierForVendor!)/ShopStuff")
       
            shopRef.observeSingleEvent(of:.value, with: { [self] (Snapshot) in
            if !Snapshot.exists(){
                return
            }
            
            let snapVal = Snapshot.value as! String
            let jsonData = snapVal.data(using: .utf8)
            let payload = try! JSONDecoder().decode(ShopPayload.self, from: jsonData!)
            
            if payload.equippedTrail != "trailDefault" {
                print("equipped trail is \(payload.equippedTrail)")
                Global.gameData.selectedTrail = SelectedTrail(rawValue: payload.equippedTrail)!
            }
            else {
                print("equipped trail is none")
                Global.gameData.selectedTrail = SelectedTrail(rawValue: "trailDefault")!
            }
            
            if payload.equippedDecal != "default" {
                print("equipped skin is \(payload.equippedDecal)")
                Global.gameData.selectedSkin  = SelectedSkin(rawValue: payload.equippedDecal)!
            }
            else {
                print("equipped skin is none")
                Global.gameData.selectedSkin  = SelectedSkin(rawValue: "none")!
            }
        })
        
        
        
        
    }
}
