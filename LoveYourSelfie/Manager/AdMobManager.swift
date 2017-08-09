//
//  AdMobManager.Swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 07/06/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import Foundation

import GoogleMobileAds

// for real app on store
//let ADMOB_APPLICATION_ID = "ca-app-pub-2434873727650847~6941786617"
//let ADMOB_UNIT_INTERSTITIAL_ID = "ca-app-pub-2434873727650847/3997565013"

// Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
let ADMOB_APPLICATION_ID = "ca-app-pub-3940256099942544~1458002511"
let ADMOB_UNIT_INTERSTITIAL_ID = "ca-app-pub-3940256099942544/4411468910"

class AdMobManager: NSObject {
    
    static let sharedInstance = AdMobManager()
    
    static func initAdMob() {
        
        GADMobileAds.configure(withApplicationID: ADMOB_APPLICATION_ID)
    }
    
    static func configureInterstitialView(_ rootViewController : UIViewController, bannerUnit : String)  -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: bannerUnit)
        
        let request = GADRequest()
        
        // per i test
//        request.testDevices = ["D4BC735B-4502-4B35-BCBD-DC196371C8D2", kGADSimulatorID]
        interstitial.load(request)
        
        return interstitial
    }
    
    static func loadInterstitialView(_ interstitial : GADInterstitial, rootViewController : UIViewController) {
    
        DispatchQueue.main.async(execute: {
            interstitial.present(fromRootViewController: rootViewController)
        })
    }
}
