//
//  SplashScreenViewController.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 21/02/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import Foundation
import UIKit

class SplashScreenViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Common.sharedInstance.setIsFirstAccess(false)
        self.activityIndicator.startAnimating()
        
        let triggerTime = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: triggerTime, execute: { () -> Void in

            // se l'utente ha già visto il tutorial vado al main
            if(Common.sharedInstance.getLookedTutorial()) {

                // richiama main
                self.activityIndicator.stopAnimating()
                let storyBoard = NavigationManager().mainStoryboard()
                NavigationManager().configureAndShowHomeNavigation(storyBoard)
            } else {

                // richiama il tutorial
                self.activityIndicator.stopAnimating()
                NavigationManager().configureAndShowTutorial(self.storyboard!)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
