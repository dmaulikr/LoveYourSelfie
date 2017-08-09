//
//  Common.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 29/03/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import Foundation

import UIKit
import AVFoundation

import SystemConfiguration

// MARK: Services Notification
let NOTIFICATION_LOGIN_SUCCESS : String = "NOTIFICATION_LOGIN_SUCCESS"
let NOTIFICATION_LOGIN_FAIL : String = "NOTIFICATION_LOGIN_FAIL"

let NOTIFICATION_LOGOUT_SUCCESS : String = "NOTIFICATION_LOGOUT_SUCCESS"
let NOTIFICATION_LOGOUT_FAIL : String = "NOTIFICATION_LOGOUT_FAIL"

let NOTIFICATION_SHARE_SUCCESS : String = "NOTIFICATION_SHARE_SUCCESS"
let NOTIFICATION_SHARE_FAIL : String = "NOTIFICATION_SHARE_FAIL"

let NOTIFICATION_SERVICE_LOGIN_SUCCESS : String = "NOTIFICATION_SERVICE_LOGIN_SUCCESS"
let NOTIFICATION_SERVICE_LOGIN_FAIL : String = "NOTIFICATION_SERVICE_LOGIN_FAIL"

let NOTIFICATION_SERVICE_LOGOUT_SUCCESS : String = "NOTIFICATION_SERVICE_LOGOUT_SUCCESS"
let NOTIFICATION_SERVICE_LOGOUT_FAIL : String = "NOTIFICATION_SERVICE_LOGOUT_FAIL"

let NOTIFICATION_SERVICE_GET_SHARE_LIST_SUCCESS : String = "NOTIFICATION_SERVICE_GET_SHARE_LIST_SUCCESS"
let NOTIFICATION_SERVICE_GET_SHARE_LIST_FAIL : String = "NOTIFICATION_SERVICE_GET_SHARE_LIST_FAIL"

let NOTIFICATION_SERVICE_SHARE_SUCCESS : String = "NOTIFICATION_SERVICE_SHARE_SUCCESS"
let NOTIFICATION_SERVICE_SHARE_FAIL : String = "NOTIFICATION_SERVICE_SHARE_FAIL"

let NOTIFICATION_LOGIN_SERVER_FAIL : String = "NOTIFICATION_LOGIN_SERVER_FAIL"



// MARK: Notifications
let UPDATE_HOME_TABLE : String = "UPDATE_HOME_TABLE"
let SHOW_VIDEO : String = "SHOW_VIDEO"
let WAITING_FOR_VIDEO_ADS : String = "WAITING_FOR_VIDEO_ADS"
let SHARE_COMPLETE_SUCCESS : String = "SHARE_COMPLETE_SUCCESS"
let SHOW_TUTORIAL : String = "NotificationIdentifierTutorial"

// MARK:  JSON Enums
enum JSONError: String, Error {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
}

//Extension:
public extension NSObject{
    public class var nameOfClass: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public var nameOfClass: String{
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}

// MARK:  NSMutableData extension appends
extension NSMutableData {
    
    func appendInt32(_ value : Int32) {
        var val = value.bigEndian
        self.append(&val, length: MemoryLayout.size(ofValue: val))
    }
    
    func appendInt16(_ value : Int16) {
        var val = value.bigEndian
        self.append(&val, length: MemoryLayout.size(ofValue: val))
    }
    
    func appendInt8(_ value : Int8) {
        var val = value
        self.append(&val, length: MemoryLayout.size(ofValue: val))
    }
    
    func appendString(_ value : String) {
        value.withCString {
            self.append($0, length: Int(strlen($0)) + 1)
        }
    }
}

// MARK: UIImage extension
extension UIImage {
    
    var leftHalfSim: UIImage? {
        guard let image = cgImage!.cropping(to: CGRect(origin: CGPoint(x: 0, y: 0),
                                                        size: CGSize(width: size.width/2, height: size.height)))
            else { return nil }
        return UIImage(cgImage: image, scale: 1, orientation: imageOrientation)
    }
    
    var rightHalfSim: UIImage? {
        guard let image = cgImage!.cropping(to: CGRect(origin: CGPoint(x: CGFloat(Int(size.width)-Int((size.width/2))), y: 0),
                size: CGSize(width: CGFloat(Int(size.width)-Int((size.width/2))), height: size.height)))
            else { return nil }
        return UIImage(cgImage:
            image, scale: 1, orientation: imageOrientation)
    }
    
    var rightHalf: UIImage? { // da rincontrollare tutti i nomi -> questa in realtà è la parte SINISTRA!
        guard let image = cgImage!.cropping(to: CGRect(origin: CGPoint(x: 0, y: 0),
                                                        size: CGSize(width: size.height, height: size.width/2)))
            else { return nil }
        return UIImage(cgImage: image, scale: 1, orientation: imageOrientation)
    }
    
    var leftHalf: UIImage? {
        guard let image = cgImage!.cropping(to: CGRect(origin: CGPoint(x: 0,  y: CGFloat(Int(size.width)-Int(size.width/2))),
                                                        size: CGSize(width: size.height, height: CGFloat(Int(size.width) - Int(size.width/2)))))
            else { return nil }
        return UIImage(cgImage:
            image, scale: 1, orientation: imageOrientation)
    }
    
    /*
    * source : http://stackoverflow.com/questions/29137488/how-do-i-resize-the-uiimage-to-reduce-upload-image-size
    */
    func resize(_ scale:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width*scale, height: size.height*scale)))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    /*
    * source : http://stackoverflow.com/questions/28517866/how-to-set-the-alpha-of-a-uiimage-in-swift-programmatically
    */
    func alpha(_ value:CGFloat)->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        let ctx = UIGraphicsGetCurrentContext();
        let area = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height);
        
        ctx!.scaleBy(x: 1, y: -1);
        ctx!.translateBy(x: 0, y: -area.size.height);
        ctx!.setBlendMode(CGBlendMode.multiply);
        ctx!.setAlpha(value);
        ctx!.draw(self.cgImage!, in: area);
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
}


// MARK: NSDate extension
extension Date {
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
        
        if yearsFrom(date)   > 1 { return "\(yearsFrom(date))\(NSLocalizedString("anni_passati", comment: ""))" }
        if yearsFrom(date)   == 1 { return "\(yearsFrom(date))\(NSLocalizedString("anno_passato", comment: ""))" }
        if monthsFrom(date)  > 1 { return "\(monthsFrom(date))\(NSLocalizedString("mesi_passati", comment: ""))" }
        if monthsFrom(date)  == 1 { return "\(monthsFrom(date))\(NSLocalizedString("mese_passato", comment: ""))" }
        if weeksFrom(date)   > 1 { return "\(weeksFrom(date))\(NSLocalizedString("settimane_passati", comment: ""))" }
        if weeksFrom(date)   == 1 { return "\(weeksFrom(date))\(NSLocalizedString("settimana_passata", comment: ""))" }
        if daysFrom(date)    > 1 { return "\(daysFrom(date))\(NSLocalizedString("giorni_passati", comment: ""))" }
        if daysFrom(date)    == 1 { return "\(daysFrom(date))\(NSLocalizedString("giorno_passato", comment: ""))" }
        if hoursFrom(date)   > 1 { return "\(hoursFrom(date))\(NSLocalizedString("ore_passate", comment: ""))" }
        if hoursFrom(date)   == 1 { return "\(hoursFrom(date))\(NSLocalizedString("ora_passata", comment: ""))" }
        if minutesFrom(date) > 1 { return "\(minutesFrom(date))\(NSLocalizedString("minuti_passati", comment: ""))" }
        if minutesFrom(date) == 1 { return "\(minutesFrom(date))\(NSLocalizedString("minuto_passato", comment: ""))" }
        if secondsFrom(date) > 1 { return "\(secondsFrom(date))\(NSLocalizedString("secondi_passati", comment: ""))" }
        return ""
    }
}


// MARK: UIColor extension
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


// MARK:  Empty or Nil string
//protocol OptionalString {}
//extension String : OptionalString {}

extension String {
    var isNilOrEmpty: Bool {
        return ((self) ).isEmpty
    }
}

// MARK: Dates
public func timeFromDate(_ pastDate : Date) -> String {
    return Date().offsetFrom(pastDate)
}


// MARK:  Common
private let userDefaults = UserDefaults.standard

private let _loginToken : String = "loginToken"
private let _authToken : String = "authToken"
private let _deviceToken : String = "deviceToken"
private let _facebookToken : String = "facebookToken"
private let _isLogged : String = "isLogged"
private let _isFirstAccess : String = "isFirstAccess"
private let _lookedTutorial : String = "lookedTutorial"

class Common: NSObject {
    
    static let sharedInstance = Common()
    
    // MARK:  Login Token
    func saveLoginToken(_ loginToken : String) {
        userDefaults.set(loginToken, forKey: _loginToken)
        userDefaults.synchronize()
    }
    
    func getLoginToken() -> String {
        return userDefaults.object(forKey: _loginToken) as? String ?? ""
    }
    
    // MARK:  Auth Token
    func saveAuthToken(_ authToken : String) {
        userDefaults.set(authToken, forKey: _authToken)
        userDefaults.synchronize()
    }
    
    func getAuthToken() -> String {
        return userDefaults.object(forKey: _authToken) as? String ?? ""
    }
    
    // MARK:  Device Token
    func saveDeviceToken(_ deviceToken : Data) {
        userDefaults.set(self.convertTokenToDeviceID(deviceToken), forKey: _deviceToken)
        userDefaults.synchronize()
    }
    
    fileprivate func convertTokenToDeviceID(_ deviceToken : Data) -> String {
        var deviceTokenString = String(format: "%@", deviceToken as CVarArg)
        deviceTokenString = deviceTokenString.replacingOccurrences(of: "<", with: "")
        deviceTokenString = deviceTokenString.replacingOccurrences(of: ">", with: "")
        deviceTokenString = deviceTokenString.replacingOccurrences(of: " ", with: "")
        
        return deviceTokenString
    }
    
    func getDeviceToken() -> String {
        return userDefaults.object(forKey: _deviceToken) as? String ?? ""
    }
    
    // MARK:  Facebook Token
    func saveFacebookToken(_ facebookToken : String) {
        userDefaults.set(facebookToken, forKey: _facebookToken)
        userDefaults.synchronize()
    }
    
    func getFacebookToken() -> String {
        return userDefaults.object(forKey: _facebookToken) as? String ?? ""
    }
    
    // MARK: Logged In
    func setIsLogged(_ isLogged : Bool) {
        userDefaults.set(isLogged, forKey: _isLogged)
        userDefaults.synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return userDefaults.bool(forKey: _isLogged) as Bool
    }
    
    // MARK: First Access
    func setIsFirstAccess(_ isLogged : Bool) {
        userDefaults.set(isLogged, forKey: _isFirstAccess)
        userDefaults.synchronize()
    }
    
    func isFirstAccess() -> Bool {
        return userDefaults.bool(forKey: _isFirstAccess) as Bool
    }
    
    // MARK: Tutorial Viewed
    func setLookedTutorial(_ lookedTutorial : Bool) {
        userDefaults.set(lookedTutorial, forKey: _lookedTutorial)
        userDefaults.synchronize()
    }
    
    func getLookedTutorial() -> Bool {
        return userDefaults.bool(forKey: _lookedTutorial) as Bool
    }

    // MARK: Reset All Saved Values
    func resetAllValues() {
        userDefaults.removeObject(forKey: _authToken)
        userDefaults.removeObject(forKey: _loginToken)
        // NON RIMUOVERE IL DEVICETOKEN, IN CASO DI LOGOUT NON VIENE RECUPERATO
        //userDefaults.removeObjectForKey(_deviceToken)
        userDefaults.removeObject(forKey: _facebookToken)
        userDefaults.removeObject(forKey: _isLogged)
//        userDefaults.removeObject(forKey: _lookedTutorial)
    }
    
    // MARK: Utility
    
    
    /*
    * source : http://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647
    */
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func dateFromMilliseconds(_ ms: NSNumber) -> Date {
        return Date(timeIntervalSince1970:Double(ms) / 1000.0)
    }
}
