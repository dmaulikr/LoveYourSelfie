//
//  UIManager.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 17/06/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import Foundation
import UIKit

class UIManager {
    
    static func applyBorder(_ item : UIView, borderWidth : CGFloat, color : UIColor, cornerRadius : CGFloat, tintColorString: String) {
        item.layer.borderWidth = borderWidth
        item.layer.masksToBounds = false
        item.layer.borderColor = color.cgColor
        item.layer.cornerRadius = cornerRadius
        item.clipsToBounds = true
        if(tintColorString != ""){item.tintColor = UIColor(hexString: tintColorString)}

        //button.layer.shouldRasterize = true
    }

    static func applyShadow(_ item : UIButton, cornerRadius: CGFloat, shadowColor : UIColor, shadowOffsetWidth : CGFloat, shadowOffsetHeight: CGFloat, shadowOpacity: Float, shadowRadius: CGFloat) {
        
        item.layer.masksToBounds = false
        item.layer.cornerRadius = cornerRadius   //startButton.frame.size.height/2
        item.layer.shadowColor = shadowColor.cgColor
        item.layer.shadowOffset = CGSize(width: shadowOffsetWidth ,height: shadowOffsetHeight)
        item.layer.shadowOpacity = shadowOpacity
        item.layer.shadowRadius = shadowRadius
    }
    
    static func drawShadow(_ item : UIView, shadowColor : UIColor, shadowOffsetWidth : CGFloat, shadowOffsetHeight: CGFloat, shadowOpacity: Float) {

        let shadowPath = UIBezierPath(rect: item.bounds)
        item.layer.masksToBounds = false
        item.layer.shadowColor = shadowColor.cgColor
        item.layer.shadowOffset = CGSize(width: shadowOffsetWidth ,height: shadowOffsetHeight)
        item.layer.shadowOpacity = shadowOpacity
        item.layer.shadowPath = shadowPath.cgPath
    }
}
