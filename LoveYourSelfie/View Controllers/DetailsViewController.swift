//
//  DetailsViewController.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 06/05/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import UIKit
import SDWebImage
import CoreData

class DetailsViewController: UIViewController {

    var detail = UserShareObj()
    
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var img1: UIImageView!
    @IBOutlet var img2: UIImageView!
    @IBOutlet var h1: UIImageView!
    @IBOutlet var h2: UIImageView!
    @IBOutlet var viewScroll: UIScrollView!
    @IBOutlet var preferenza1: RatingView!
    @IBOutlet var preferenza2: RatingView!
    
    let colorTop = UIColor.white.cgColor
    let colorBottom = UIColor.lightGray.cgColor
    var gradientLayer: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationAppearance()

        // Do any additional setup after loading the view.
        h1.alpha = 0
        h2.alpha = 0
        
        nameLbl.text = detail.name
        
        let url1 = URL(string: detail.sharedDX!)
        let url2 = URL(string: detail.sharedSX!)
        
        img1.sd_setImage(with: url1)
        img2.sd_setImage(with: url2)
        
        let myColor : UIColor = UIColor( red: 255, green: 0, blue:255, alpha: 1.0 )
        
        img1.layer.cornerRadius = 25
        img1.layer.masksToBounds = true;
        img2.layer.cornerRadius = 25
        img2.layer.masksToBounds = true;
        
        if(detail.userChoice == "dx"){
            img1.layer.borderWidth = 5
            img1.layer.borderColor = myColor.cgColor
            h1.alpha = 1
        } else {
            img2.layer.borderWidth = 5
            img2.layer.borderColor = myColor.cgColor
            h2.alpha = 1
        }
        
        let search = String(describing: detail.id)
        loadRating(search)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configureNavigationAppearance() {
        
        let button: UIButton = UIButton.init(type: (UIButtonType.system))
        button.setTitle(NSLocalizedString("btn_back", comment: ""), for: UIControlState())
        button.tintColor = UIColor.magenta
        //add function for button
        button.addTarget(self, action: #selector(DetailsViewController.backToMain(_:)), for: UIControlEvents.touchUpInside)
        //set frame
        button.contentMode = UIViewContentMode.left
        button.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        navigationItem.leftBarButtonItem = barButton
        
        let logo = UIImage(named: "navigation-icon")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        self.navigationController!.navigationBar.topItem!.title = "";
    }

    func backToMain(_ sender: UIBarButtonItem) {
        
        let id = String(describing: detail.id)
        let voto1 = String(preferenza2.rating)
        let voto2 = String(preferenza1.rating)

        
        let dati = [id, voto1, voto2]
        let nomi : [String] = ["id", "value1", "value2"]
        
        CoreDataUtilities.sharedInstance.saveToDB(dati, entityName: "Preferenza", key: nomi)
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }

    
    func loadRating(_ toSearch: String) {
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Preferenza")
        
        
        //var toSearch : String = self.textFieldIndirizzo.text!
        // Add Predicate
        let predicate = NSPredicate(format: "id = %@", toSearch)
        fetchRequest.predicate = predicate
        
        do {
            let records = try managedContext!.fetch(fetchRequest) as! [NSManagedObject]
            
            if(records.isEmpty){
                print("nessun dato presente nel DB")
            } else {
                print("dato presente nel DB")
                for record in records {
                    _ = record.value(forKey: "id")! as! String
                    let value1 = (record.value(forKey: "value1")! as AnyObject).floatValue
                    let value2 = (record.value(forKey: "value2")! as AnyObject).floatValue
                    
                    preferenza2.rating = value1!
                    preferenza1.rating = value2!
                }
                
            }
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        //CAGradientLayer
        // https://www.appcoda.com/cagradientlayer/
        createGradientLayer()
    }
    
    private func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [colorTop, colorBottom]
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
