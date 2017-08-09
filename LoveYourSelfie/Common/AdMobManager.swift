//
//  SwiftLoading.Swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 07/03/16.
//  Copyright © 2016 Francesco Galasso. All rights reserved.
//

import UIKit

class ADSManager : NSObject, AdColonyAdDelegate {
    
    func showADSVideo() {
        dispatch_async(dispatch_get_main_queue(), {
            
            //let win:UIWindow = UIApplication.sharedApplication().delegate!.window!!
            AdColony.playVideoAdForZone("vzaf193fe06ac8439e98", withDelegate: self)
        })
    }
    func onAdColonyAdStartedInZone(zoneID: String) {

    }
    
    func onAdColonyAdAttemptFinished(shown: Bool, inZone zoneID: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let value = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        });
    }
}
