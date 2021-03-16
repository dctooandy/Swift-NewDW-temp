//
//  HotGamePopup.swift
//  betlead
//
//  Created by vanness wu on 2019/5/31.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit

class HotGamePopup: PopupBottomSheet {
    override func setupViews() {
        super.setupViews()
        view.addSubview(defaultContainer)
        defaultContainer.snp.makeConstraints { (maker) in
            maker.centerY.centerX.equalToSuperview()
            maker.size.equalTo(CGSize(width: 300, height: 400))
        }
    }
}
