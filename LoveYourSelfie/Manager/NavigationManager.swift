//
//  NavigationManager.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 19/04/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//


import Foundation
import UIKit

class NavigationManager {
    
    static let sharedInstance = NavigationManager()
    

    //Generate name of the main storyboard file, by default: "Main"
    var kMainStoryboardName: String {
        let info = Bundle.main.infoDictionary!
        
        if let value = info["TPMainStoryboardName"] as? String
        {
            return value
        }else{
            return "Main"
        }
    }
    
    //Main storybord
    func mainStoryboard() -> UIStoryboard
    {
        return storyboard(kMainStoryboardName)
    }
    
    fileprivate func storyboard(_ name: String) -> UIStoryboard
    {
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyboard
    }
    
    // MARK: configure and show home and menu navigation and viewcontrollers
    func configureAndShowHomeNavigation(_ storyboard: UIStoryboard) {
        let nav = storyboard.instantiateViewController(withIdentifier: "NavigationControllerID")
        
        setCurrentRootViewController(nav)
    }
    
    // MARK: configure and show tutorial
    func configureAndShowTutorial(_ storyboard: UIStoryboard) {
        let tutorial = storyboard.instantiateViewController(withIdentifier: "tutorialStoryboardID") as! TutorialViewController
        
        setCurrentRootViewController(tutorial)
    }
    
    func setCurrentRootViewController(_ viewController: UIViewController) {
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    func showTutorial() {
        let storyboard = mainStoryboard()
        let tutorial = storyboard.instantiateViewController(withIdentifier: "tutorialStoryboardID") as! TutorialViewController
        tutorial.isFromHome = true
        let currentCV = currentVC() //MainViewController
        currentCV!.present(tutorial, animated: true, completion: nil)
    }
    
    func currentVC() -> UIViewController? {
        guard let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return nil }
        return navigationController.viewControllers.last
    }

}
