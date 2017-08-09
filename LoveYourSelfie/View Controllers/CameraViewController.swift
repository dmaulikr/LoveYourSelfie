//
//  ViewController.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 26/02/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//


import UIKit
import AVFoundation
import FBSDKLoginKit
import GoogleMobileAds

class CameraViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate,GADInterstitialDelegate {
    
    @IBOutlet weak var scrollViewContainer: UIScrollView!
    
    // camera view container
    @IBOutlet weak var cameraViewContainer: UIView!
    // camera view
    @IBOutlet weak var cameraPreviewView: UIView!
    // linee guida foto utente
    @IBOutlet weak var lineMirrored: UIView!
    @IBOutlet weak var leftEyesLine: UIImageView!
    @IBOutlet weak var rightEyesLine: UIImageView!
    // scatta la foto
    @IBOutlet weak var takeButton: UIButton!
    
    // captured image view container
    @IBOutlet weak var capturedImageViewContainter: UIView!
    // immagine appena scattata
    @IBOutlet weak var capturedImage: UIImageView!
    
    // prosegui button
    @IBOutlet weak var elaborateButton: UIButton!
    
    // elaborated images view container
    @IBOutlet weak var elaboratedImageViewContainer: UIView!
    // la scroll contiene le immagini da condividere
    @IBOutlet weak var imagesCollection: UICollectionView!
    weak var pageControl: UIPageControl!
    
    
    // elaborated images view container
    @IBOutlet weak var shareViewContainer: UIView!
    // la scroll contiene le immagini da condividere
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var leftImageStarred: UIImageView!
    @IBOutlet weak var rightImageStarred: UIImageView!
    
    // share button
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var lblElaborate: UILabel!
    @IBOutlet weak var lblShare: UILabel!
    
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var containerImageViewLeftMirrored = UIView()
    var containerImageViewRightMirrored = UIView()
    let emptyStarImage = UIImage(named: "emptyStar") as UIImage?
    let filledStarImage = UIImage(named: "filledStar") as UIImage?
    
    var finalMergedImageLeft: UIImage!
    var finalMergedImageRight: UIImage!
    
    var preferenzaUtentePic: String!
    
    var flagLeft = Bool()
    var flagRight = Bool()
    
    var camera = Bool()
    
    let cellClassName : String = "CollectionCell"
    
    var baseOffset : CGFloat = 0
    var offsetStep : CGFloat = 0
    
    var images : NSMutableArray = []
    
    var isSimulator : Bool = false
    
    var interstitial: GADInterstitial!
    
    var notificationObjectResponse : Any!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        elaborateButton.layer.cornerRadius = elaborateButton.frame.size.height/2
        elaborateButton.layer.masksToBounds = true
        
        shareButton.addTarget(self, action: #selector(CameraViewController.share), for: UIControlEvents.touchUpInside)
        shareButton.layer.cornerRadius = shareButton.frame.size.height/2
        shareButton.layer.masksToBounds = true
        
        // swift3
        // scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 700)
        
        self.scrollViewContainer.contentSize = CGSize(width: UIScreen.main.bounds.width*4, height: self.scrollViewContainer.frame.size.height)
        print("scrollView width: \(self.elaboratedImageViewContainer.frame.size.width*4)")
        print("device width: \(UIScreen.main.bounds.width)")
        self.scrollViewContainer.contentOffset = CGPoint(x: 0, y: self.scrollViewContainer.contentOffset.y)
        
        interstitial = AdMobManager.configureInterstitialView(self, bannerUnit: ADMOB_UNIT_INTERSTITIAL_ID)
        interstitial.delegate = self
        
        loadCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (previewLayer != nil) { //per app finale
            previewLayer!.frame = cameraPreviewView.bounds
        } else {
            //test per simulator
            let image = UIImage(named: "simulator_face")
            capturedImage.image = image
            isSimulator = true
        }
        configureNavigationAppearance()
        
        lblShare.text = NSLocalizedString("share_lbl", comment: "")
        lblElaborate.text = NSLocalizedString("elaborate_lbl", comment: "")
        shareButton.setTitle(NSLocalizedString("share_btn", comment: ""), for: .normal)
        elaborateButton.setTitle(NSLocalizedString("elaborate_btn", comment: ""), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Load Camera
    func loadCamera() {
        changeLeftBarButtonSelectorClose()
        
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()
        
        // camera loading code
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        var captureDevice:AVCaptureDevice! = nil
        // var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (camera == false) {
            let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            for device in videoDevices!{
                let device = device as! AVCaptureDevice
                if device.position == AVCaptureDevicePosition.front {
                    captureDevice = device
                    break
                }
            }
        } else {
            let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            for device in videoDevices!{
                let device = device as! AVCaptureDevice
                if device.position == AVCaptureDevicePosition.back {
                    captureDevice = device
                    break
                }
            }
        }
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill//AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewLayer!.frame = cameraPreviewView.frame
                cameraPreviewView.layer.addSublayer(previewLayer!)
                
                cameraPreviewView.bringSubview(toFront: lineMirrored)
                cameraPreviewView.bringSubview(toFront: leftEyesLine)
                cameraPreviewView.bringSubview(toFront: rightEyesLine)
                
                captureSession!.startRunning()
            }
        }
    }
    
    // MARK: Take Photo
    // Camera Container View
    @IBAction func didPressTakePhoto(_ sender: UIButton) {
        if (previewLayer != nil) {
            // no simulator
            if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
                videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
                stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                    if (sampleBuffer != nil) {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        let dataProvider = CGDataProvider(data: imageData as! CFData)
                        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                        
                        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                        self.capturedImage.image = image
                        
                        self.changeLeftBarButtonSelectorToRetake()
                        
                        DispatchQueue.main.async(execute: {
                            
                            // animazione scroll laterale
                            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
                                let bounds = UIScreen.main.bounds
                                let x = bounds.width
                                self.scrollViewContainer.contentOffset = CGPoint(x: x, y: self.scrollViewContainer.contentOffset.y)
                                
                            }, completion: nil)
                        })
                        
                    }
                })
            }
        } else {
            // simulator
            DispatchQueue.main.async(execute: {
                
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
                    let bounds = UIScreen.main.bounds
                    let x = bounds.width
                    self.scrollViewContainer.contentOffset = CGPoint(x: x, y: self.scrollViewContainer.contentOffset.y)
                    
                }, completion: nil)
            })
        }
        
    }
    
    // MARK: Elaborate Photo
    @IBAction func elaborateClicked(_ sender: UIButton) {
        
        // right sarebbe la parte di destra -> Mr Hyde
        
        if(isSimulator){    //SIMULATOR
            let imageRight = self.capturedImage.image?.rightHalfSim
            let imageRightMirrored = UIImage(cgImage: imageRight!.cgImage!, scale: 1.0, orientation: .upMirrored)
            finalMergedImageRight = getMergedImage(imageRightMirrored, image2: imageRight!)
            
            let imageLeft = self.capturedImage.image?.leftHalfSim
            let imageLeftMirrored = UIImage(cgImage: imageLeft!.cgImage!, scale: 1.0, orientation: .upMirrored)
            finalMergedImageLeft = getMergedImage(imageLeft!, image2: imageLeftMirrored)
        } else {    //DEVICE
            let imageRight = self.capturedImage.image?.rightHalf
            let imageRightMirrored = UIImage(cgImage: imageRight!.cgImage!, scale: 1.0, orientation: .leftMirrored)
            finalMergedImageRight = getMergedImage(imageRightMirrored, image2: imageRight!)
            
            let imageLeft = self.capturedImage.image?.leftHalf
            let imageLeftMirrored = UIImage(cgImage: imageLeft!.cgImage!, scale: 1.0, orientation: .leftMirrored)
            finalMergedImageLeft = getMergedImage(imageLeft!, image2: imageLeftMirrored)
        }
        
        let widthPreviewView = capturedImage.frame.width//cameraPreviewView.bounds);
        let heightPreviewView = capturedImage.frame.height//cameraPreviewView.bounds);
        
        let imageViewLeftMirrored = UIImageView(frame: CGRect(x: 0, y: 0, width: widthPreviewView, height: heightPreviewView));
        imageViewLeftMirrored.image = finalMergedImageLeft;
        let imageViewRightMirrored = UIImageView(frame: CGRect(x: widthPreviewView, y: 0, width: widthPreviewView, height: heightPreviewView));
        imageViewRightMirrored.image = finalMergedImageRight;
        
        imageViewRightMirrored.contentMode = UIViewContentMode.scaleToFill
        imageViewLeftMirrored.contentMode = UIViewContentMode.scaleToFill
        
        // resize dell'immagine per velocizzare l'uploading
        finalMergedImageLeft = finalMergedImageLeft.resize(0.3)
        finalMergedImageRight = finalMergedImageRight.resize(0.3)
        
        
        // configuro la collection
        imagesCollection.register(UINib(nibName: cellClassName, bundle: nil), forCellWithReuseIdentifier: cellClassName)
        imagesCollection.decelerationRate = UIScrollViewDecelerationRateFast
        
        baseOffset = imagesCollection.contentOffset.x
        
        let layout : UICollectionViewFlowLayout = imagesCollection.collectionViewLayout as! UICollectionViewFlowLayout
        
        let stepUnit : CGFloat = layout.itemSize.width + layout.minimumLineSpacing
        offsetStep = stepUnit * CGFloat(floorf(Float(imagesCollection.bounds.width / stepUnit)))
        
        images = []
        
        images.add(finalMergedImageLeft)
        images.add(finalMergedImageRight)
        
        imagesCollection.reloadData()
        
        DispatchQueue.main.async(execute: {
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
                
                self.scrollViewContainer.contentOffset = CGPoint(x: 640, y: self.scrollViewContainer.contentOffset.y)
                
            }, completion: nil)
        })
    }
    
    func getMergedImage(_ image1: UIImage, image2: UIImage) -> UIImage {
        
        let size = CGSize(width: image1.size.width + image2.size.width, height: image1.size.height)
        
        UIGraphicsBeginImageContext(size)
        
        image1.draw(in: CGRect(x: 0,y: 0,width: image1.size.width, height: size.height))
        image2.draw(in: CGRect(x: image1.size.width,y: 0,width: image1.size.width, height: size.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClassName, for: indexPath) as! CollectionCell
        
        cell.generatedImage.image = images[indexPath.row] as? UIImage
        
        if (indexPath.row == 0) {
            // left
            cell.titleLabel.text = "Dr Jeckyll"
        } else {
            // right
            cell.titleLabel.text = "Mr Hyde"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        starredAction(indexPath.row+1)
        
        imagesCollection.reloadData()
        
        showShare()
    }
    
    /*
     Funzione che gestisce la pressione del tasto della figura di sinistra. Se è già presente una preferenza che non sia quella di sinistra ma viene premuto il pulsante SX, compare un alert che chiede all'utente se vuol procedere al cambio di preferenza o meno. Altrimenti, se non è presente nessuna preferenza, viene impostata quella di SX; se già esiste e corrisponde a quella di SX viene rimossa: l'utente quindi potrà scegliere quella che preferisce
     
     Funzione che gestisce la pressione del tasto della figura di destra. Se è già presente una preferenza che non sia quella di destra ma viene premuto il pulsante DX, compare un alert che chiede all'utente se vuol procedere al cambio di preferenza o meno. Altrimenti, se non è presente nessuna preferenza, viene impostata quella di Dx; se già esiste e corrisponde a quella di Dx viene rimossa: l'utente quindi potrà scegliere quella che preferisce
     */
    func starredAction(_ index : Int) {
        if (index == 1) {
            // left image
            if (!flagLeft) {
                // se non è stato premuto il pulsante di sinistra
                if(flagRight) {
                    // se è già stato premuto il pulsante di destra
                    self.flagRight = !self.flagRight // metto in stato false button dx
                    self.flagLeft = !self.flagLeft // metto stato true button sx
                    self.choosedPreferred()
                    
                    self.imagesCollection.reloadData()
                } else {
                    flagLeft = true
                    
                    choosedPreferred()
                }
            } else {
                flagLeft = false
                
                choosedPreferred()
            }
        } else {
            // right image
            if (!flagRight) {
                if( flagLeft) {
                    self.flagRight = !self.flagRight // metto in stato true button dx
                    self.flagLeft = !self.flagLeft // metto in stato false button sx
                    self.choosedPreferred()
                    
                    self.imagesCollection.reloadData()
                } else {
                    flagRight = true
                    
                    choosedPreferred()
                }
            } else {
                flagRight = false
                choosedPreferred()
            }
        }
    }
    
    /*
     Funzione che mi permette di settare il parametro preferenzaUtentePic usato per il servizio di share del
     server. I primi 2 if corrispondono al cambiamento di selezione tra le 2 immagini (rispettivamente rappresentano uno il passaggio da una preferenza da img dx a img sx, l'altro rappresenta il cambio di preferenza da img sx a img dx); gli altri corrispondono alle scelte singole (selezionando e deselezionando il pulsante a forma di stella)
     */
    func choosedPreferred(){
        if (!flagRight && flagLeft){
            preferenzaUtentePic = "sx"
        }
        else if (flagRight && !flagLeft){
            preferenzaUtentePic = "dx"
        }
        else if(flagRight){
            preferenzaUtentePic = "dx"
        }
        else if(!flagRight){
            preferenzaUtentePic = ""
        }
        else if (flagLeft){
            preferenzaUtentePic = "sx"
        }
        else if (!flagLeft){
            preferenzaUtentePic = ""
        }
    }
    
    func showShare() {
        changeLeftBarButtonSelectorToRetake()
        
        leftImage.image = finalMergedImageLeft
        rightImage.image = finalMergedImageRight
        
        if (preferenzaUtentePic == "dx") {
            leftImageStarred.isHidden = true
            rightImageStarred.isHidden = false
        } else {
            leftImageStarred.isHidden = false
            rightImageStarred.isHidden = true
        }
        
        DispatchQueue.main.async(execute: {
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
                
                self.scrollViewContainer.contentOffset = CGPoint(x: 960, y: self.scrollViewContainer.contentOffset.y)
                
            }, completion: nil)
        })
    }
    
    // MARK: Share Pics
    func share() {
        
        print("cliccato share")
        // "\(preferenzaUtentePic as String)" >> non devo passare un optional
        let arrayObjects: NSMutableArray = ["\(preferenzaUtentePic as String)", images[0], images[1]]
        let arrayValues: NSMutableArray = ["userChoice", "sx", "dx"]
        let myDictionary = NSMutableDictionary(objects: arrayObjects as [AnyObject], forKeys: arrayValues as NSCopying as! [NSCopying])
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.shareSuccess(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SHARE_SUCCESS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.shareFail(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SHARE_FAIL), object: nil)
        
        FacebookManager.sharedInstance.share(self, params: myDictionary)
        
        DispatchQueue.global(qos: .userInteractive).async {
            // Background Thread
            FacebookManager.sharedInstance.share(self, params: myDictionary)
            SwiftLoading().showLoading()

            DispatchQueue.main.async {
                // Main UI Thread
                if (!self.interstitial.isReady || self.interstitial.hasBeenUsed) {
                    self.interstitial = AdMobManager.configureInterstitialView(self, bannerUnit: ADMOB_UNIT_INTERSTITIAL_ID)
                    self.interstitial.delegate = self
                }
                
                AdMobManager.loadInterstitialView(self.interstitial, rootViewController: self)
            }
        }
    }
    
    func shareSuccess(_ notification : Notification) {
        
//        notificationObjectResponse = notification.object
//        
//        if (!self.interstitial.isReady || self.interstitial.hasBeenUsed) {
//            self.interstitial = AdMobManager.configureInterstitialView(self, bannerUnit: ADMOB_UNIT_INTERSTITIAL_ID)
//            self.interstitial.delegate = self
//        }
//        
//        AdMobManager.loadInterstitialView(self.interstitial, rootViewController: self)
        
        SwiftLoading().hideLoading()
        NotificationCenter.default.post(name: Notification.Name(rawValue: SHARE_COMPLETE_SUCCESS), object: notification)
    }
    
    func shareFail(_ notification : Notification) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SHARE_SUCCESS), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SHARE_FAIL), object: nil)
        
        DispatchQueue.main.async(execute: {
            let alert = UIAlertController(title: "LoveYourSelf", message: NSLocalizedString("alert_error", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert_close", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            SwiftLoading().hideLoading()
        })
    }
    
    // MARK: Pop Controller
    func popMe(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: UPDATE_HOME_TABLE), object: nil)
        })
    }
    
    // MARK: Left BarButton Selector RetakePhoto
    func changeLeftBarButtonSelectorToRetake() {
        let button = UIButton.init(type: (UIButtonType.custom))
        //set image for button
        button.setImage(UIImage(named: "take-photo"), for: UIControlState())
        //add function for button
        button.addTarget(self, action: #selector(CameraViewController.retakePhoto), for: UIControlEvents.touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 30)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        navigationItem.leftBarButtonItem = barButton
    }
    
    func retakePhoto() {
        DispatchQueue.main.async(execute: {
            //            var closeButton : Bool = false
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveLinear], animations: {
                
                if(self.scrollViewContainer.contentOffset.x > 320) {
                    self.scrollViewContainer.contentOffset = CGPoint(x: 0, y: self.scrollViewContainer.contentOffset.y)
                    //                    closeButton = true
                    self.changeLeftBarButtonSelectorClose()
                }
            }, completion: nil)
        })
        
        loadCamera()
    }
    
    // MARK: Left BarButton Selector Cose
    func changeLeftBarButtonSelectorClose() {
        
        // Il rightButton farà sia il popMe che il reTakePhoto, cambiamo Selector a runtime
        let button = UIButton.init(type: (UIButtonType.custom))
        //set image for button
        button.setImage(UIImage(named: "close-button"), for: UIControlState())
        //add function for button
        button.addTarget(self, action: #selector(CameraViewController.popMe(_:)), for: UIControlEvents.touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        navigationItem.leftBarButtonItem = barButton
    }
    
    // MARK: NavigationBar Appearance
    func configureNavigationAppearance() {
        
        changeLeftBarButtonSelectorClose()
        
        let logo = UIImage(named: "navigation-icon")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        self.navigationController!.navigationBar.topItem!.title = "";
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = AdMobManager.configureInterstitialView(self, bannerUnit: ADMOB_UNIT_INTERSTITIAL_ID)
        interstitial.delegate = self
        
//        self.dismiss(animated: false, completion: {
//            
//            SwiftLoading().hideLoading()
//            NotificationCenter.default.post(name: Notification.Name(rawValue: SHARE_COMPLETE_SUCCESS), object: self.notificationObjectResponse as! NSDictionary)
//        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
