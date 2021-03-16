//
//  MySafariVC.swift
//  betlead
//
//  Created by vanness wu on 2019/7/16.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import SafariServices


class MySafariVC:SFSafariViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.frame = view.frame.offsetBy(dx: 0, dy: 40)
    }
}
