//
//  MainViewController.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 28/02/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import SDWebImage

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {
    
    // container view utente loggato
    @IBOutlet weak var loggedInContainer: UIView!
    // tabella post utenti e amici
    @IBOutlet weak var tableView: UITableView!
    
    // container view utente NON loggato
    @IBOutlet weak var loggedOutContainer: UIView!
    // button login
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var beginButton: UIButton!
    @IBOutlet weak var settingButton: UIBarButtonItem!
    
    var myDict: NSDictionary = [:]
    
    var object = [UserShareObj]() // creo array di tipo UserShareObj
    var share = UserShareObj()
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        configureNavigationAppearance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.configureView), name: NSNotification.Name(rawValue: UPDATE_HOME_TABLE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.shareComplete(_:)), name: NSNotification.Name(rawValue: SHARE_COMPLETE_SUCCESS), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.showVideoShare), name: NSNotification.Name(rawValue: SHOW_VIDEO), object: nil)
        
        configureView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.receivedNotificationTutorial(_:)), name:NSNotification.Name(rawValue: SHOW_TUTORIAL), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.logoutSuccess(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_LOGOUT_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.logoutFail(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_LOGOUT_FAIL), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.loginServerError(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_LOGIN_SERVER_FAIL), object: nil)

        self.loginButton.setTitle(NSLocalizedString("fb_login", comment: ""), for: .normal)

    }
    
    func shareComplete(_ notification : Notification) {
    
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: "LoveYourSelfie", message: NSLocalizedString("alert_share_success", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert_close", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        
        DispatchQueue.main.async(execute: {
            //code
            if (/*FBSDKAccessToken.currentAccessToken() != nil && */Common.sharedInstance.isLoggedIn()) {
                
                self.myDict = notification.object as! NSDictionary
                
                self.configureLoggedInView(false)
            } else {
                self.configureLoggedOutView()
            }
        });
    }
    
    // MARK: Configure View
    func configureView() {
        
        if (!Common.sharedInstance.connectedToNetwork()) {
            // se non è connesso alla rete mostra un alert di informazione
            let attributedString = NSAttributedString(string: "ALERT", attributes: [
                NSFontAttributeName : UIFont.systemFont(ofSize: 25),
                NSForegroundColorAttributeName : UIColor.red
                ])
            let alert = UIAlertController(title: "LoveYourSelfie", message: NSLocalizedString("alert_conn", comment: ""),  preferredStyle: .alert)
            alert.setValue(attributedString, forKey: "attributedTitle")
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            // se non c'è rete non facciamo nulla, l'utente non può far niente, le chiamate andranno in error mostrando il relativo messaggio
        }

        
        // isFirstAccess viene messo a true solo dal TutorialViewController
       if (Common.sharedInstance.isFirstAccess()) {
            Common.sharedInstance.setIsFirstAccess(false)
            SwiftLoading().showLoading()
            
            let time: TimeInterval = 2.0
            let delay = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.showCameraControl()
            }
        }
        
        DispatchQueue.main.async(execute: {
            //code
            if (FBSDKAccessToken.current() != nil && Common.sharedInstance.isLoggedIn()) {
                print("stampo currentAccessToken \(FBSDKAccessToken.current())")
                self.configureLoggedInView()
            } else {
                self.configureLoggedOutView()
            }
        });

    }
    
    // MARK: Utente loggato
    func configureLoggedInView() {
        configureLoggedInView(true)
    }
    
    func configureLoggedInView(_ shareList : Bool) {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MainViewController.getShareList), for: UIControlEvents.valueChanged)
        tableView.addSubview(self.refreshControl)
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customCellID")
        
        if (shareList) {
            getShareList()
        } else {
            // self.myDict è stato aggiornato
            reloadShareList()
        }
    }
    
    func getShareList() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.shareListSuccess(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_GET_SHARE_LIST_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.shareListFail(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_GET_SHARE_LIST_FAIL), object: nil)
        DispatchQueue.main.async(execute: {
            LoveYourSelfieServices().shareList()
        });

    }
    
    func shareListSuccess(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_GET_SHARE_LIST_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_GET_SHARE_LIST_FAIL), object: nil)
        
        // success share list
        DispatchQueue.main.async(execute: {
            SwiftLoading().hideLoading()
        });
        
        refreshControl.endRefreshing()
        
        self.myDict = notification.object as! NSDictionary
        
        reloadShareList()
        
    }
    
    func shareListFail(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_GET_SHARE_LIST_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_GET_SHARE_LIST_FAIL), object: nil)
        
        refreshControl.endRefreshing()
        // errore in fase di get share list
        DispatchQueue.main.async(execute: {
            SwiftLoading().hideLoading()
        });
    }
    
    func reloadShareList() {
        self.object = [UserShareObj]()
        if(self.myDict != nil && self.myDict.count > 0) {
            
            let data = self.myDict["data"] as AnyObject?
            let userShares = data?["userShares"] as AnyObject
            let friendShares = data?["friendShares"] as AnyObject
            
            for share in userShares as! [[String: AnyObject]] {
                let id: Int32 = share["id"]!.int32Value
                let userPicture = share["picture"] as! String
                let shareDate = share["shareDate"] as! NSNumber
                let url = share["url"] as! String
                let name = share["name"] as! String
                let sharedSX = share["sx"] as! String
                let sharedDX = share["dx"] as! String
                let choice = share["userChoice"] as! String
                
                let date = Common.sharedInstance.dateFromMilliseconds(shareDate)
                
                // creo oggetto obj
                let obj = UserShareObj(id: id, url: url, userPicture: userPicture, shareDate: date, name: name, sharedDX: sharedDX, sharedSX: sharedSX, userChoice: choice)
                self.object.append(obj)
            }
            
            for share in friendShares as! [[String: AnyObject]] {
                let id: Int32 = share["id"]!.int32Value
                let userPicture = share["picture"] as! String
                let shareDate = share["shareDate"] as! NSNumber
                let url = share["url"] as! String
                let name = share["name"] as! String
                let sharedSX = share["sx"] as! String
                let sharedDX = share["dx"] as! String
                let choice = share["userChoice"] as! String
                
                let date = Common.sharedInstance.dateFromMilliseconds(shareDate)
                
                // creo oggetto obj
                let obj = UserShareObj(id: id, url: url, userPicture: userPicture, shareDate: date, name: name, sharedDX: sharedDX, sharedSX: sharedSX, userChoice: choice)
                self.object.append(obj)
            }
            
            DispatchQueue.main.async(execute: {
                //code
                self.loggedInContainer.isHidden = false
                self.loggedOutContainer.isHidden = true
            });
            
            // ordino l'array dal post più recente
            self.object.sort(by: { $0.shareDate!.compare($1.shareDate! as Date) == ComparisonResult.orderedDescending })
            
            DispatchQueue.main.async(execute: {
                //code
                self.tableView.reloadData()
                
                SwiftLoading().hideLoading()
            });
        }
    }
    
    // MARK: Utente NON loggato
    func configureLoggedOutView() {
        DispatchQueue.main.async(execute: {
            //code
            print("configureLoggedOutView")
            self.loggedInContainer.isHidden = true
            self.loggedOutContainer.isHidden = false
            
            self.myDict = NSDictionary()
            self.object = [UserShareObj]()
            if (Common.sharedInstance.isFirstAccess()) {
                
                SwiftLoading().hideLoading()
            }
        });
        
    }
    
    func showCameraControl() {
        DispatchQueue.main.async(execute: {
            let camera = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewControllerID") as! CameraViewController
            let navigationController = UINavigationController.init(rootViewController: camera)
            self.present(navigationController, animated: true, completion:nil)
            SwiftLoading().hideLoading()
        })
    }
    
    // MARK: Login
    @IBAction func loginCustomAction(_ sender: UIButton) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.loginSuccess(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_LOGIN_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.loginFail(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_LOGIN_FAIL), object: nil)
        
        FacebookManager.sharedInstance.loginInView(self)
    }
    
    func loginSuccess(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_LOGIN_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_LOGIN_FAIL), object: nil)
        // success
        
        DispatchQueue.main.async(execute: {
           self.configureLoggedInView()
        })
    }
    
    func loginFail(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_LOGIN_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_LOGIN_FAIL), object: nil)
        // errore in fase di login
        DispatchQueue.main.async(execute: {
            SwiftLoading().hideLoading()
        });
    }
    
    func loginServerError(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_LOGIN_SERVER_FAIL), object: nil)
        // errore in fase di login da parte del server
        DispatchQueue.main.async(execute: {
            SwiftLoading().hideLoading()
            
            let alert = UIAlertController(title: "LoveYourSelfie", message: NSLocalizedString("alert_login_server_error", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert_close", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        });
    }
    
    // MARK: Logout
    func logoutSuccess(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_LOGOUT_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_LOGOUT_FAIL), object: nil)
        // success
        
        DispatchQueue.main.async(execute: {
            SwiftLoading().hideLoading()
            self.configureLoggedOutView()
        })
    }
    
    func logoutFail(_ notification : Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_LOGOUT_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_LOGOUT_FAIL), object: nil)
        // errore in fase di login
        DispatchQueue.main.async(execute: {
            SwiftLoading().hideLoading()
        });
    }
    
    @IBAction func beginCamera(_ sender: UIButton) {
        DispatchQueue.main.async(execute: {
                        
            let camera = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewControllerID") as! CameraViewController
            
            let navigationController = UINavigationController.init(rootViewController: camera)
            
            self.present(navigationController, animated: true, completion:nil)
        })
    }
    
    
    
    // MARK:  TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("array object \(self.object.count)")
        return self.object.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "customCellID"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CustomCell
        
        let row = indexPath.row
        let share = self.object[row]
        
        cell.titleLabel.text = share.name
        
        cell.descriptionLabel.text = Date().offsetFrom(share.shareDate!)
        
        cell.iconImage.layer.borderWidth = 2.0
        cell.iconImage.layer.masksToBounds = false
        cell.iconImage.layer.borderColor = UIColor.white.cgColor
        cell.iconImage.layer.cornerRadius = cell.iconImage.frame.size.width/2
        cell.iconImage.clipsToBounds = true
        
        var url = URL(string: share.userPicture!)
        // uso il framework SDWebImage
        cell.iconImage.sd_setImage(with: url)
        
        
        url = URL(string: share.sharedSX!)
        // uso il framework SDWebImage
        cell.firstImage.sd_setImage(with: url)
        url = URL(string: share.sharedDX!)
        // uso il framework SDWebImage
        cell.secondImage.sd_setImage(with: url)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        print(row)
        share = object[row]
        
        performSegue(withIdentifier: "fromMain", sender: tableView)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMain" {
            let destination = segue.destination as! DetailsViewController
            
            //devo passare di dati!
            destination.detail = share
        }
    }

    func showTutorial() {
        NavigationManager().showTutorial()
    }
    
    // MARK: NavigationBar Appearance
    func configureNavigationAppearance() {
        
        settingButton.image = UIImage(named: "settings-button")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.enableInteractions(_:)), name: NSNotification.Name(rawValue: "enableInteractions"), object: nil)
        
        let logo = UIImage(named: "navigation-icon")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        self.navigationController!.navigationBar.topItem!.title = "";
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMenu(_ segue: UIStoryboardSegue) {
        print("sono tornato alla mainView")
    }
    
    func receivedNotificationTutorial(_ notification: Notification){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SHOW_TUTORIAL), object: nil)
        DispatchQueue.main.async(execute: {
            NavigationManager().showTutorial()
        })
    }
    
    
    // new entry
    func enableInteractions(_ notification: Notification) {
        print("chiudo il menù setting >> attivo icona ingranaggi")
        settingButton.isEnabled = true
        beginButton.isEnabled = true
        loggedInContainer.isUserInteractionEnabled = true
    }
    
    @IBAction func showSettings(_ sender: UIBarButtonItem) {
        sender.isEnabled = false  // il pulsante settings non è cliccabile
        beginButton.isEnabled = false // il pulsante camera non è cliccabile
        loggedInContainer.isUserInteractionEnabled = false
        SettingsManager.configureAndShowSettingsPopup(self.view)
    }
}
