//
//  FacebookManager.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 01/03/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import Foundation
import UIKit

import FBSDKLoginKit


class FacebookManager: NSObject {
    
    static let sharedInstance = FacebookManager()
    
    let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
    var isLoginForShare : Bool = false
    
    // user for login before share
    var currentViewController = UIViewController()
    var currentParams = NSMutableDictionary()
    
    // MARK: Login
    func loginInView(_ viewController : UIViewController) {
        
        currentViewController = viewController

        DispatchQueue.main.async(execute: {
            // Do UI stuff here
            self.fbLoginManager.logIn(withReadPermissions: ["public_profile","email","user_friends"], from:viewController, handler: { (result, error) -> Void in
                if (error == nil){
                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
                    // controlliamo se il set contiene o meno un valore
                    if fbloginresult.grantedPermissions != nil {
                        if(fbloginresult.grantedPermissions.contains("email") && fbloginresult.grantedPermissions.contains("public_profile") && fbloginresult.grantedPermissions.contains("user_friends")) {
                            let tokenUserFacebook = FBSDKAccessToken.current().tokenString //ottengo il fb token
                            self.loginToServer(tokenUserFacebook!)   //chiamata login al server
                        }
                    } else {
                        // error permessi, utente ha rifiutato
                        DispatchQueue.main.async(execute: {
                            let alert = UIAlertController(title: "LoveYourSelf", message: NSLocalizedString("error_auth", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("alert_close", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                            viewController.present(alert, animated: true, completion: nil)
                        })
                    }
                } else {
                    // error
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "LoveYourSelf", message: NSLocalizedString("alert_error", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("alert_close", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                        viewController.present(alert, animated: true, completion: nil)
                    })
                }
            })
        })
    }
    
    fileprivate func loginToServer(_ facebookToken : String) {
        DispatchQueue.main.async(execute: {
            SwiftLoading().showLoading()
        });
        
        // resto in attesa della risposta di login
        NotificationCenter.default.addObserver(self, selector: #selector(FacebookManager.loginResultSuccess(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGIN_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FacebookManager.loginResultFail(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGIN_FAIL), object: nil)
        LoveYourSelfieServices().loginToServer(accessTokenFacebook: facebookToken)
    }
    
    // The @objc attribute makes your Swift API available in Objective-C and the Objective-C runtime.
    @objc func loginResultSuccess(_ notification : Notification) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGIN_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGIN_FAIL), object: nil)
        // success
        if (isLoginForShare) {
            share(currentViewController, params: currentParams)
        } else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_LOGIN_SUCCESS), object: nil)
        }
    }

    @objc func loginResultFail(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGIN_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGIN_FAIL), object: nil)

        // show error
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_LOGIN_FAIL), object: nil)
    }
    
    // MARK: Logout
    func logout() {
        
        fbLoginManager.logOut() // effetta il Logout dell'utente da Facebook
        // resto in attesa della risposta di logout dal server
        NotificationCenter.default.addObserver(self, selector: #selector(FacebookManager.logoutResultSuccess(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGOUT_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FacebookManager.logoutResultFail(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGOUT_FAIL), object: nil)
        
        LoveYourSelfieServices().logoutFromServer()
    }
    
    @objc func logoutResultSuccess(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGOUT_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGOUT_FAIL), object: nil)
        // success
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_LOGOUT_SUCCESS), object: nil)
    }
    
    @objc func logoutResultFail(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGOUT_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGOUT_FAIL), object: nil)
        
        // show error
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_LOGOUT_FAIL), object: nil)
    }

    // MARK: Share 
    func share(_ viewController : UIViewController, params : NSMutableDictionary) {
        
        if (FacebookManager.sharedInstance.checkUserWritePermission()) {
            // ho i permessi di scrittura, procedo con lo share
            
            DispatchQueue.main.async(execute: {
                SwiftLoading().showLoading()
            });
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: SHOW_VIDEO), object: nil)
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(FacebookManager.shareSuccess(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_SHARE_SUCCESS), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(FacebookManager.shareFail(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_SHARE_FAIL), object: nil)
            
            LoveYourSelfieServices().share(param: params)
            
        } else {
            // se non ho i permessi di lettura devo ancora loggarmi
            if (!FacebookManager.sharedInstance.checkUserReadPermission()) {
                
                currentParams = params
                currentViewController = viewController
                isLoginForShare = true
                
                self.loginInView(viewController)
            } else {
                
                // devo richiedere i permessi di scrittura e poi proseguire
                DispatchQueue.main.async(execute: {
                    self.fbLoginManager.logIn(withPublishPermissions: ["publish_actions"], from:viewController, handler: { (result, error) -> Void in
                        if (error == nil){
                            // verifico che effettivamente abbia i permessi di scrittura e riprovo a fare lo share
                            if (FacebookManager.sharedInstance.checkUserWritePermission()) {
                                
                                //let tokenUserFacebook = FBSDKAccessToken.currentAccessToken().tokenString
                                
                                //self.loginToServer(tokenUserFacebook)
                                
                                self.share(viewController, params: params)
                            }
                        } else {
                            DispatchQueue.main.async(execute: {
                                SwiftLoading().hideLoading()
                            });
                        }
                    })
                })
            }
        }
    }
    
    
    @objc func shareSuccess(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_SHARE_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_SHARE_FAIL), object: nil)
        // success
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_SHARE_SUCCESS), object: notification.object)
    }
    
    @objc func shareFail(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_SHARE_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_SHARE_FAIL), object: nil)
        
        // show error
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_SHARE_FAIL), object: nil)
    }
    
    func checkUserReadPermission() -> Bool {
        
        // safely unwrap the optional to prevent crash
        if let loginResult : FBSDKAccessToken = FBSDKAccessToken.current() {
            
            if (FBSDKAccessToken.current() != nil && loginResult.permissions.contains("public_profile")
                && loginResult.permissions.contains("email")
                && loginResult.permissions.contains("user_friends")) {
                    // hofa i permessi in lettura
                    return true
            }
            return false
        }
        return false
    }
    
    func checkUserWritePermission() -> Bool {
        
        // safely unwrap the optional to prevent crash
        if let loginResult : FBSDKAccessToken = FBSDKAccessToken.current() {
            
            if (FBSDKAccessToken.current() != nil && loginResult.permissions.contains("publish_actions")) {
                // ho i permessi in lettura
                return true
            }
            return false
        }
        return false
    }
}
