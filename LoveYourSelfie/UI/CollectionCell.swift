//
//  CollectionCell.swift
//  LoveYourSelfie
//
//  Created by Francesco Galasso on 20/03/17.
//  Copyright © 2017 Francesco Galasso. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var generatedImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    
    let colorTop = UIColor.white.cgColor
    let colorBottom = UIColor.lightGray.cgColor
    
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        let gl: CAGradientLayer = CAGradientLayer()

        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
        
        gl.frame = titleView.bounds
        
        titleView.layer.insertSublayer(gl, at: 0)
    }
}
