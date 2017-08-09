//
//  TutorialViewController.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 21/02/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageTutorial: UIImageView!
    @IBOutlet weak var titleTutorial: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var topView: UIVisualEffectView!
    @IBOutlet weak var bottomView: UIVisualEffectView!
    var isFromHome: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * 3, height: self.scrollView.frame.height)
        self.pageControl.currentPage = 0
        self.labelDescription.textColor = UIColor.gray
        self.startButton.alpha = 0.0
        self.imageTutorial.image = UIImage(named: "Tutorial1")
        self.titleTutorial.text = NSLocalizedString("tut1_title", comment: "")
        self.labelDescription.text = NSLocalizedString("tut1_description", comment: "")
        
        UIManager.applyShadow(startButton, cornerRadius: 14.5, shadowColor: .black, shadowOffsetWidth: 2.0, shadowOffsetHeight: 2.0, shadowOpacity: 0.6, shadowRadius: 0.0)
    }
    
    override func viewDidLayoutSubviews() {
        UIManager.drawShadow(topView, shadowColor: .black, shadowOffsetWidth: 0, shadowOffsetHeight: 2, shadowOpacity: 0.5)
        UIManager.drawShadow(bottomView, shadowColor: .black, shadowOffsetWidth: 0.0, shadowOffsetHeight: 0.0, shadowOpacity: 0.5)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        
        // Change the text accordingly
        if Int(currentPage) == 0 {
            self.labelDescription.text = NSLocalizedString("tut1_description", comment: "")
            self.imageTutorial.image = UIImage(named: "Tutorial1")
            self.titleTutorial.text = NSLocalizedString("tut1_title", comment: "")
            self.startButton.alpha = 0.0
        }else if Int(currentPage) == 1{
            self.labelDescription.text = NSLocalizedString("tut2_description", comment: "")
            self.imageTutorial.image = UIImage(named: "Tutorial2")
            self.titleTutorial.text = NSLocalizedString("tut2_title", comment: "")
            self.startButton.alpha = 0.0
        }else{
            // mostro il pulsante nell'ultima slide con un'animazione a dissolvenza
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.labelDescription.text = NSLocalizedString("tut3_description", comment: "")
                self.imageTutorial.image = UIImage(named: "Tutorial3")
                self.titleTutorial.text = NSLocalizedString("tut3_title", comment: "")
                self.startButton.alpha = 1.0
                self.startButton.setTitle(NSLocalizedString("btn_text", comment: ""), for: .normal)
            })
        }
    }

    @IBAction func onClick(_ sender: AnyObject) {
        Common.sharedInstance.setLookedTutorial(true)
        // metto isFirstAccess a true così nel MainViewController mostro la Fotocamera una sola volta
        if(!isFromHome) {
            Common.sharedInstance.setIsFirstAccess(true)
            let nav = self.storyboard?.instantiateViewController(withIdentifier: "NavigationControllerID")
            UIApplication.shared.keyWindow?.rootViewController = nav
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
