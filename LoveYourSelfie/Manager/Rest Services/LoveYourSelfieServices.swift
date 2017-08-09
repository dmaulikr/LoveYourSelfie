//
//  LoveYourSelfieServices.swift
//  LoveYourSelfieServices
//
//  Created by Francesco Galasso on 01/03/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

// MARK:  Base Url
let BASE_URL : String = "http://test.loveyourselfie.it"

// MARK:  Api Paths
let LOGIN_PATH : String = "/api/login"
let LOGOUT_PATH : String = "/api/logout"
let SHARE_PATH : String = "/api/share"

// MARK:  Common variables
var __userToken : String = ""
var __authToken : String = "712cbab2683a32fd4711a14ad3003a89"
var __deviceToken : String = ""

class LoveYourSelfieServices: NSObject {
    // MARK:  SERVICES
    
    // MARK:  Authorization Token
    private func getAuthorizationToken() -> String {
        if(__authToken.isEmpty) {
            __authToken = Common.sharedInstance.getAuthToken()
        }
        print("get Auth Token -> \(__authToken)")
        return __authToken
    }
    
    private func setAuthorizationToken(authToken : String) {
        __authToken = authToken
        Common.sharedInstance.saveAuthToken(__authToken)
        
        print("set New Auth Token -> \(__authToken)")
    }
    
    // MARK:  Login Token
    private func getLoginToken() -> String {
        if(__userToken.isEmpty) {
            __userToken = Common.sharedInstance.getLoginToken()
        }
        print("get Login Token -> \(__userToken)")
        return __userToken
    }
    
    private func setLoginToken(loginToken : String) {
        __userToken = loginToken
        Common.sharedInstance.saveLoginToken(__userToken)
        print("set New Login Token -> \(__userToken)")
    }

    
    // MARK: Service Login
    func loginToServer(accessTokenFacebook: String) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url: NSURL = NSURL(string: "\(BASE_URL)\(LOGIN_PATH)")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.getAuthorizationToken(), forHTTPHeaderField: "authToken")
        request.addValue(accessTokenFacebook, forHTTPHeaderField: "facebookToken")
        
        if (!Common.sharedInstance.getDeviceToken().isEmpty) {
            __deviceToken = Common.sharedInstance.getDeviceToken()
            request.addValue(__deviceToken as String, forHTTPHeaderField: "deviceToken")
            // parametro riconoscimento device per il server
            request.addValue("IOS", forHTTPHeaderField: "devicePlatform")
        }
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in do {
            
            if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                print("server OK")
                
                guard let dat = data else {
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: dat, options: []) as? NSDictionary else {
                    throw JSONError.ConversionFailed
                }
                
                if(error == nil) {
                    // SUCCESS
                    let data = json.object(forKey: "data") as! NSDictionary?
                    
                    if data != nil {
                        let token = data?.object(forKey: "userToken") as! NSString
                        // salvo localmente lo userToken
                        self.setLoginToken(loginToken: token as String)
                        Common.sharedInstance.setIsLogged(true)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGIN_SUCCESS), object: nil)
                    } else {
                        // FAIL
                        Common.sharedInstance.setIsLogged(false)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGIN_FAIL), object: nil)
                    }
                } else {
                    // FAIL
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_LOGIN_FAIL), object: nil)
                    Common.sharedInstance.setIsLogged(false)
                }
                
            } else  if let response = response as? HTTPURLResponse , 500...509 ~= response.statusCode{
                print(response.statusCode)
                print("Server Error")
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_LOGIN_SERVER_FAIL), object: nil)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

        } catch let error as JSONError {
            print(error.rawValue)
        } catch {
            print(error)
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.resume()
    }
    
    // MARK: Service Logout
    func logoutFromServer(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url: NSURL = NSURL(string: "\(BASE_URL)\(LOGOUT_PATH)")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        
        request.httpMethod = "GET"
        request.addValue(self.getAuthorizationToken() as String, forHTTPHeaderField: "authToken")

        request.addValue(self.getLoginToken(), forHTTPHeaderField: "userToken")
        
        if (!Common.sharedInstance.getDeviceToken().isEmpty) {
            __deviceToken = Common.sharedInstance.getDeviceToken()
            request.addValue(__deviceToken as String, forHTTPHeaderField: "deviceToken")
        }
        
        URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in do {
                
                guard let dat = data else {
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: dat, options: []) as? [String: Any] else {
                    throw JSONError.ConversionFailed
                }
                
                if(error == nil) {
                    // SUCCESS
//                    let data = json.object(forKey: "data") as! NSDictionary?
                    if let data = json["result"] as? String {
                        print("data -> \(data)")
                        self.setLoginToken(loginToken: "")
                        Common.sharedInstance.resetAllValues()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_LOGOUT_SUCCESS), object: nil)
                    } else { // data = nil
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_LOGOUT_FAIL), object: nil)
                    }
                } else {
                    // FAIL
                    // DOBBIAMO GESTIRLO?
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_LOGOUT_FAIL), object: nil)
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.resume()

    }
    
    // MARK: Service Share - POST
    func share(param: NSMutableDictionary?) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url: NSURL = NSURL(string: "\(BASE_URL)\(SHARE_PATH)")!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        let headers = [
            "content-type" : "multipart/form-data; boundary=\(boundary)",
            "authToken" : self.getAuthorizationToken(),
            "userToken" : self.getLoginToken(),
        ]
        request.allHTTPHeaderFields = headers
      
        let image_data_sx = UIImageJPEGRepresentation(param?.object(forKey: "sx") as! UIImage, 0.5)
        let image_data_dx = UIImageJPEGRepresentation(param?.object(forKey: "dx") as! UIImage, 0.5)
        
        let body = NSMutableData()
        
        let user_choise = param!.object(forKey: "userChoice") as! String
        let fname_sx = "sx.jpg"
        let fname_dx = "dx.jpg"
        
        let mimetype_sx = "image/jpeg"
        let mimetype_dx = "image/jpeg"
        
        // user choise
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        print("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"userChoice\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        print("Content-Disposition: form-data; name=\"userChoice\"\r\n\r\n")
        body.append("\(user_choise)\r\n".data(using: String.Encoding.utf8)!)
        print("\(user_choise)\r\n")
        
        // image1
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        print("--\(boundary)\r\n")
        body.append("Content-Disposition:form-data; name=\"sx\"; filename=\"\(fname_sx)\"\r\n".data(using: String.Encoding.utf8)!)
        print("Content-Disposition:form-data; name=\"sx\"; filename=\"\(fname_sx)\"\r\n")
        body.append("Content-Type: \(mimetype_sx)\r\n\r\n".data(using: String.Encoding.utf8)!)
        print("Content-Type: \(mimetype_sx)\r\n\r\n")
        body.append(image_data_sx!)
        print("data image")
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        print("\r\n")
        
        // image2
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        print("--\(boundary)\r\n")
        body.append("Content-Disposition:form-data; name=\"dx\"; filename=\"\(fname_dx)\"\r\n".data(using: String.Encoding.utf8)!)
        print("Content-Disposition:form-data; name=\"dx\"; filename=\"\(fname_sx)\"\r\n")
        body.append("Content-Type: \(mimetype_dx)\r\n\r\n".data(using: String.Encoding.utf8)!)
        print("Content-Type: \(mimetype_sx)\r\n\r\n")
        body.append(image_data_dx!)
        print("data image")
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        print("\r\n")

        
        //chiusura
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        print("--\(boundary)--\r\n")
        
        request.httpBody = body as Data
        
        URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try JSONSerialization.jsonObject(with: dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                

                DispatchQueue.main.async(execute: {
                    SwiftLoading().hideLoading()
                });
                
                print("stampo il json share")
                print(json)
                if(error == nil) {
                    // SUCCESS
                    
                    let data = json.object(forKey: "data") as! NSDictionary?
                    // print(data)
                    if data != nil {
                       NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_SHARE_SUCCESS), object: json)
                    } else {
                        // FAIL
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_SHARE_FAIL), object: nil)
                        print("data == nil")
                    }
                    
                } else {
                    // FAIL
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_SHARE_FAIL), object: nil)
                    print("ERROR")
                }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.resume()
    }
    
    // MARK: Service Share List - GET
    func shareList(){
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let url: NSURL = NSURL(string: "\(BASE_URL)\(SHARE_PATH)")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        
        request.httpMethod = "GET"

        let headers = [
            "authToken": self.getAuthorizationToken() as String,
            "userToken": self.getLoginToken() as String,
        ]
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in do {
                
                guard let dat = data else { throw JSONError.NoData }
//                guard let json = try JSONSerialization.jsonObject(with: dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                guard let json = try JSONSerialization.jsonObject(with: dat, options: []) as? [String: AnyObject] else {
                    throw JSONError.ConversionFailed
                }
                
                if(error == nil) {
                    // SUCCESS
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_GET_SHARE_LIST_SUCCESS), object: json)
                    
                } else {
                    // FAIL
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SERVICE_GET_SHARE_LIST_FAIL), object: nil)
                }
                
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.resume()
    }
    
    // MARK:  Boundary
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }

}
