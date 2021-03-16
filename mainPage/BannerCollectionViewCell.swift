//
//  AdsCollectionViewCell.swift
//  PreBetLead
//
//  Created by vanness wu on 2019/5/13.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit


class BannerCollectionViewCell:UICollectionViewCell{
    
    @IBOutlet weak var adsImageView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyCornerRadius()
    }
    
    func configureCell(url:String) {
        adsImageView.sdLoad(with: URL(string:url))
    }
    
}
