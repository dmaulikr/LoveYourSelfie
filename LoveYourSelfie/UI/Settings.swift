//
//  Settings.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 16/04/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import UIKit

@IBDesignable class Settings: UIView{

    @IBOutlet var viewTop: UIView!
    @IBOutlet var viewBottom: UIView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var background: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet var btnTutorial: UIButton!
    @IBOutlet var btnLanguage: UIButton!
    @IBOutlet var btnLogout: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }

    fileprivate func nibSetup() {
        backgroundColor = .clear
        
        view = loadViewFromNib()
        view.frame = bounds
        UIManager.applyBorder(view!, borderWidth: 1.0, color: UIColor.lightGray, cornerRadius: 10, tintColorString: "")
        viewBottom.backgroundColor = .white
        UIManager.applyBorder(viewBottom!, borderWidth: 1.0, color: UIColor.lightGray, cornerRadius: 10, tintColorString: "")
        UIManager.applyBorder(btnTutorial, borderWidth: 1.0, color: UIColor.lightGray, cornerRadius: 10, tintColorString: "#ED0089")
        UIManager.applyBorder(btnLogout, borderWidth: 1.0, color: UIColor.lightGray, cornerRadius: 10, tintColorString: "#ED0089")
        
        let userToken = Common().getLoginToken()
        if(userToken.isNilOrEmpty) {
            print("userToken vuoto")
            btnLogout.isEnabled = false
        } else {
            btnLogout.isEnabled = true
        }
        addSubview(view)
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }

    @IBAction func closeAction(_ sender: UIButton) {
        SettingsManager.removeSettingsPopup(self)
    }
    
    @IBAction func actionTutorial(_ sender: UIButton) {
        SettingsManager.removeSettingsPopup(self)
        NotificationCenter.default.post(name: Notification.Name(rawValue: SHOW_TUTORIAL), object: nil)
    }
    
    @IBAction func actionLogout(_ sender: UIButton) {
        SettingsManager.removeSettingsPopup(self)
        FacebookManager.sharedInstance.logout()
    }
    
    
}
