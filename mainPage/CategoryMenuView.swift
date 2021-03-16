//
//  CategoryMenuView.swift
//  PreBetLead
//
//  Created by vanness wu on 2019/5/13.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit

class CategoryMenuView:UIView {
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var bgView:UIImageView!
    private var category:Category? {
        didSet {
            guard let category = category else { return }
            titleLabel.text = category.title
            titleLabel.textColor = .white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = Fonts.pingFangTCMedium(Views.isIPhoneWithNotch() ? 18 : 16)
    }
    
    class func loadViewFromNib(category:Category) -> CategoryMenuView {
        let view = CategoryMenuView.loadNib()
        view.category = category
        view.backgroundColor = .clear
        
        return view
    }
    
    func sethighlight(_ ishighlight:Bool){
        
        UIView.animate(withDuration: 0.25) {
            self.bgView.image = ishighlight ? UIImage(named: "menu-btn-blue") : nil
            if ishighlight {
                self.titleLabel.transform.tx = 5
            } else {
                self.titleLabel.transform = CGAffineTransform.identity
            }
        }
    }
    
}
