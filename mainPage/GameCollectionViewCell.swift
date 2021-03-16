//
//  GameCollectionViewCell.swift
//  betlead
//
//  Created by Victor on 2019/9/6.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import SDWebImage
class GameCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imv = UIImageView()
//        imv.image = UIImage(named: "agTest")
        imv.contentMode = .scaleAspectFit
        return imv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalToSuperview()//.offset(10)
        }
    }
    private var data: GameGroupDto?
    func setData(_ data: GameGroupDto?) {
        guard let d = data else { return }
        guard let icon = d.icon else {
            imageView.sdLoad(with: URL(string: d.gameVi_Before))
            return
        }
        imageView.image = icon
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
