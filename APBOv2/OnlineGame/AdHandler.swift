import Foundation
import GoogleMobileAds
import SystemConfiguration

public class AdHandler {
    // Trach the ads preloaded
    private var appOpen: GADAppOpenAd?
    private var interstitialImage: GADInterstitialAdBeta?
    private var interstitialGeneral: GADInterstitialAdBeta?
    private var interstitialVideo: GADInterstitialAdBeta?
    private var rewardedInterstitial: GADRewardedInterstitialAd?
    public var rewarded: GADRewardedAdBeta?
    public var rewardedRevive: GADRewardedAdBeta?
    
    // Track the AD IDs for each ad type
    private var bannerID: String?
    private var appOpenID: String?
    private var interstitialImageID: String?
    private var interstitialVideoID: String?
    private var interstitialGeneralID: String?
    private var rewardedInterstitialID: String?
    public var rewardedID: String?
    public var rewardedReviveID: String?
    
    var isReviveLoaded = false
    
    private let handler = {
        Global.gameData.isReviveReady = true
    }
    
    //========================= *** SUPER IMPORTANT ***
    private var inTestMode = false
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
            rewardedReviveID = "ca-app-pub-3940256099942544/1712485313"
            
        } else {
            bannerID = "ca-app-pub-8214314705526801/1873169855"
            appOpenID = "ca-app-pub-8214314705526801/3440745853"
            interstitialGeneralID = "ca-app-pub-8214314705526801/5429271484"
            interstitialImageID = "ca-app-pub-8214314705526801/5620843174"
            interstitialVideoID = "ca-app-pub-8214314705526801/5429271484"
            rewardedReviveID = "ca-app-pub-8214314705526801/5645480637"
            
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
            self.loadRewardedForRevive()
//            GADRewardedAdBeta.load(withAdUnitID: self.rewardedReviveID!, request: GADRequest(), completionHandler: { [self] ad, error in
//                if error == nil{
//                    rewardedRevive = ad
//                    rewardedRevive?.fullScreenContentDelegate = controller
//                    isReviveLoaded = true
//                }
//            })
            
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
            if isConnectedToNetwork(){
                setup()
            } else {
                return
            }
        }
        interstitialGeneral!.present(fromRootViewController: controller!)
        GADInterstitialAdBeta.load(withAdUnitID: interstitialGeneralID!, request: GADRequest(), completionHandler: { [self] ad, error in
            interstitialGeneral = ad
        })
    }
    
    func presentInterstitialImage(){
        if !isReady{
            return
        }
        interstitialImage?.present(fromRootViewController: controller!)
        GADInterstitialAdBeta.load(withAdUnitID: interstitialGeneralID!, request: GADRequest(), completionHandler: { [self] ad, error in
            interstitialImage = ad
        })
    }
    
    func presentInterstitialVideo(){
        if !isReady{
            if isConnectedToNetwork(){
                setup()
            } else {
                return
            }
        }
        interstitialVideo!.present(fromRootViewController: controller!)
        GADInterstitialAdBeta.load(withAdUnitID: interstitialGeneralID!, request: GADRequest(), completionHandler: { [self] ad, error in
            interstitialVideo = ad
        })
    }
    
    func presentRewardedForRevive() -> Bool{
        
        if (rewardedRevive == nil){
            // try loading on the fly
            loadPlayRevive()
            return false
        }
        
        rewardedRevive?.present(fromRootViewController: controller!, userDidEarnRewardHandler: handler)
        loadRewardedForRevive()
        return true
    }
    
    public func loadRewardedForRevive(){
        GADRewardedAdBeta.load(withAdUnitID: self.rewardedReviveID!, request: GADRequest(), completionHandler: { [self] ad, error in
            rewardedRevive = ad
            rewardedRevive?.fullScreenContentDelegate = controller
            isReviveLoaded = true
            if error != nil {
                print("===================")
                print("===================")
                print("===================")
                print(error)
                print("===================")
                print("===================")
                print("===================")
                return
            }
        })
    }
    
    public func loadPlayRevive(){
        GADRewardedAdBeta.load(withAdUnitID: self.rewardedReviveID!, request: GADRequest(), completionHandler: { [self] ad, error in
            rewardedRevive = ad
            rewardedRevive?.fullScreenContentDelegate = controller
            isReviveLoaded = true
            if error != nil {
                print("===================")
                print("===================")
                print("===================")
                print(error)
                print("===================")
                print("===================")
                print("===================")
                return
            }
        })
    }
    
    func presentAppOpen(){
        if !isReady{
            if isConnectedToNetwork(){
                setup()
            } else {
                return
            }
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
    
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
 
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
 
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}
