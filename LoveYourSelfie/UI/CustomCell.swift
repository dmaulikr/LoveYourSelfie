//
//  CustomCell.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 20/03/16.
//  Copyright © 2016 Francesco Galasso. All rights reserved.
//

import UIKit

extension UILabel {
    
    var localizedText: String {
        set (key) {
            text = NSLocalizedString(key, comment: "")
        }
        get {
            return text!
        }
    }
}

class CustomCell: UITableViewCell{
    
    
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleDescriptionGradient: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let colorTop = UIColor.white.cgColor
    let colorBottom = UIColor.lightGray.cgColor
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        let gl: CAGradientLayer = CAGradientLayer()
        
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
        
        gl.frame = titleDescriptionGradient.bounds
        
        titleDescriptionGradient.layer.insertSublayer(gl, at: 0)
        
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
