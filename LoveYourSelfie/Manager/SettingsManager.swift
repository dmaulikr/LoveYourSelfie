//
//  SettingsManager.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 16/04/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import Foundation
import UIKit

class SettingsManager  {
    
    static func configureAndShowSettingsPopup(_ view : UIView) {
        
        let rect : CGSize
        rect = CGSize(width: 270, height: 274)
        
        let settingsPopup : Settings = Settings.init(frame: CGRect(origin: CGPoint.zero, size: rect))
        
        DispatchQueue.main.async(execute: {
            
            view.addSubview(settingsPopup)
            settingsPopup.center = view.center
        })
    }

    static func removeSettingsPopup(_ view : Settings) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "enableInteractions"), object: nil)
        DispatchQueue.main.async(execute: {
            UIView.animate(withDuration: 0.5, animations: {
                view.alpha = 0
            }, completion: { (true) in
                view.removeFromSuperview()
            }) 
        })
    }

}
