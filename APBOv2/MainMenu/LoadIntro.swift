import GoogleMobileAds
import SpriteKit

class LoadIntro: SKScene {
    let intropilot = SKSpriteNode(imageNamed: "intropilot")
    
    override func didMove(to view: SKView) {
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
        
        GADMobileAds.sharedInstance().start(completionHandler: {_ in
            let request = GADRequest()
            GADInterstitialAdBeta.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910", request: request, completionHandler: { [self] ad, error in
                Global.gameData.interstitial = ad
            })
        })
    }
}
