import Foundation
import GoogleMobileAds

public class AdHandler {
    // Trach the ads preloaded
    private var appOpen: GADAppOpenAd?
    private var interstitialImage: GADInterstitialAdBeta?
    private var interstitialGeneral: GADInterstitialAdBeta?
    private var interstitialVideo: GADInterstitialAdBeta?
    private var rewardedInterstitial: GADRewardedInterstitialAd?
    private var rewarded: GADRewardedAdBeta?
    
    // Track the AD IDs for each ad type
    private var bannerID: String?
    private var appOpenID: String?
    private var interstitialImageID: String?
    private var interstitialVideoID: String?
    private var interstitialGeneralID: String?
    private var rewardedInterstitialID: String?
    private var rewardedID: String?
    
    //========================= *** SUPER IMPORTANT ***
    private var inTestMode = true
    //========================= *** MUST BE ENABLED FOR TESTING ***
    
    private var isReady = false
    private weak var controller: GameViewController?
    
    func setup(){
        
        if inTestMode{
            bannerID = "ca-app-pub-3940256099942544/2934735716"
            appOpenID = "ca-app-pub-3940256099942544/5662855259"
            interstitialImageID = "ca-app-pub-3940256099942544/4411468910"
            interstitialVideoID = "ca-app-pub-3940256099942544/5135589807"
            rewardedInterstitialID = "ca-app-pub-3940256099942544/6978759866"
            rewardedID = "ca-app-pub-3940256099942544/1712485313"
            interstitialGeneralID = "ca-app-pub-3940256099942544/4411468910"
        } else {
            bannerID = "ca-app-pub-8214314705526801/1873169855"
            appOpenID = "ca-app-pub-8214314705526801/3440745853"
            interstitialImageID = "ca-app-pub-8214314705526801/5620843174"
            interstitialVideoID = "ca-app-pub-8214314705526801/5429271484"
            
            // Rewarded videos need to have specific values to enter into adMob
            rewardedInterstitialID = ""
            rewardedID = ""
        }
        
        GADMobileAds.sharedInstance().start(completionHandler: {_ in
            self.controller = Global.gameViewController
            self.isReady = true
            
            GADAppOpenAd.load(withAdUnitID: self.appOpenID!, request: GADRequest(), orientation: UIInterfaceOrientation.landscapeRight, completionHandler: { [self] ad, error in
                appOpen = ad
            })
            
            GADRewardedAdBeta.load(withAdUnitID: self.rewardedID!, request: GADRequest(), completionHandler: { [self] ad, error in
                rewarded = ad
            })
            
            GADInterstitialAdBeta.load(withAdUnitID: self.interstitialVideoID!, request: GADRequest(), completionHandler: { [self] ad, error in
                interstitialVideo = ad
            })
            
            GADInterstitialAdBeta.load(withAdUnitID: self.interstitialImageID!, request: GADRequest(), completionHandler: { [self] ad, error in
                interstitialImage = ad
            })
            
            GADInterstitialAdBeta.load(withAdUnitID: self.interstitialGeneralID!, request: GADRequest(), completionHandler: { [self] ad, error in
                interstitialGeneral = ad
            })
            
        })
    }
    
    func presentInterstitialGeneral(){
        if !isReady{
            fatalError("Why would you do that. Thats just a bad idea.")
        }
        interstitialGeneral!.present(fromRootViewController: controller!)
        GADInterstitialAdBeta.load(withAdUnitID: interstitialGeneralID!, request: GADRequest(), completionHandler: { [self] ad, error in
            interstitialGeneral = ad
        })
    }
    
    func presentInterstitialImage(){
        if !isReady{
            fatalError("Why would you do that. Thats just a bad idea.")
        }
        interstitialImage!.present(fromRootViewController: controller!)
        GADInterstitialAdBeta.load(withAdUnitID: interstitialGeneralID!, request: GADRequest(), completionHandler: { [self] ad, error in
            interstitialImage = ad
        })
    }
    
    func presentInterstitialVideo(){
        if !isReady{
            fatalError("Why would you do that. Thats just a bad idea.")
        }
        interstitialVideo!.present(fromRootViewController: controller!)
        GADInterstitialAdBeta.load(withAdUnitID: interstitialGeneralID!, request: GADRequest(), completionHandler: { [self] ad, error in
            interstitialVideo = ad
        })
    }
    
    func presentRewardedForRevive(){
        if !isReady{
            fatalError("Why would you do that. Thats just a bad idea.")
        }
        rewarded!.present(fromRootViewController: controller!, userDidEarnRewardHandler: {
            print("should load endless again")
            Global.loadSceneSolo(s: "GameScene")
        })
        GADRewardedAdBeta.load(withAdUnitID: rewardedID!, request: GADRequest(), completionHandler: { [self] ad, error in
            rewarded = ad
        })
    }
    
    func presentAppOpen(){
        if !isReady{
            fatalError("Why would you do that. Thats just a bad idea.")
        }
        appOpen!.present(fromRootViewController: controller!)
        GADAppOpenAd.load(withAdUnitID: appOpenID!, request: GADRequest(), orientation: UIInterfaceOrientation.landscapeRight, completionHandler: { [self] ad, error in
            appOpen = ad
        })
    }
    
    public func retrieveBannerID() -> String {
        if isReady{
            return bannerID!
        }
        fatalError("pepe")
    }
    
}
