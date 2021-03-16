//
//  BetLeadCarouseFlowLayout.swift
//  PreBetLead
//
//  Created by vanness wu on 2019/5/13.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UPCarouselFlowLayout
import UIKit
import RxCocoa
import RxSwift

protocol BetLeadCarouselFlowLayoutDelegate: NSObjectProtocol {
    func select(index:Int)
}

class BetLeadCarouseFlowLayout:UPCarouselFlowLayout , UIScrollViewDelegate{
    public var offest:CGFloat = 0
    public var rxCurrentPage = BehaviorRelay(value:0)
    fileprivate weak var delegate:BetLeadCarouselFlowLayoutDelegate?
    
    required init?(coder aDecoder:NSCoder) {
        fatalError("This class doesn't support NSCoding.")
    }
    
    override public init() {
        super.init()
    }
    
    public init(delegate:BetLeadCarouselFlowLayoutDelegate, offset:CGFloat) {
        super.init()
        self.delegate = delegate
        self.offest = offset
        self.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: offset)
    }
    private lazy var basePageOffset = itemSize.width + offest - (1 - self.sideItemScale)*itemSize.width/2
    func scrollViewDidEndDecelerating(_ scrollView:UIScrollView) {
            let page = Int(round(scrollView.contentOffset.x / basePageOffset))
            delegate?.select(index: page)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / basePageOffset))
        rxCurrentPage.accept(page)
    }
    
    fileprivate var pageSize:CGSize {
        let layout = self
        var pageSize = layout.itemSize
        pageSize.width += layout.minimumLineSpacing
        return pageSize
    }

}
