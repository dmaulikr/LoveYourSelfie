//
//  UserShareObj.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 20/03/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import Foundation

open class UserShareObj {
    
    var id: Int32?
    var url: String?
    var name: String?
    var userPicture: String?
    var sharedSX: String?
    var sharedDX: String?
    var shareDate: Date?
    var userChoice: String?
    
    internal init(id: Int32, url: String, userPicture: String, shareDate: Date, name: String, sharedDX: String, sharedSX: String, userChoice: String){

        self.id = id
        self.url = url
        self.name = name
        self.userPicture = userPicture
        self.sharedDX = sharedDX
        self.sharedSX = sharedSX
        self.shareDate = shareDate
        self.userChoice = userChoice
    }
    
    internal init () {
    }

}
