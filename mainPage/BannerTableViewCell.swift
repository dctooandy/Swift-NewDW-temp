//
//  BannerTableViewCell.swift
//  betlead
//
//  Created by Victor on 2019/9/6.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift

protocol BannerTableViewCellDelegate {
    func clickBanner(urlString: String, method: Int)
}

class BannerTableViewCell: UITableViewCell {
    private let dpg = DisposeBag()
    lazy var delegate: BannerTableViewCellDelegate? = nil
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setup()
        bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bannerCarouselView = BannerCarouselView.loadNib()
    
    func setup() {
        contentView.addSubview(bannerCarouselView)
        backgroundColor = .clear
        bannerCarouselView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(12)
            maker.left.equalToSuperview().offset(width(18/414))
            maker.right.equalToSuperview().offset(-width(18/414))
            maker.bottom.equalToSuperview().offset(-12)
            maker.height.equalTo(BannerCarouselView.height)
        }
    }
    private let pdg = DisposeBag()
    func bind() {
        bannerCarouselView.rxClick().subscribeSuccess { [weak self] (link) in
            self?.delegate?.clickBanner(urlString: link.0, method: link.1)
        }.disposed(by: dpg)
    }
    
    func bannerDidSelected() -> Observable<(String, Int , String, BannerPlayGameDto)> {
        return bannerCarouselView.rxClick()
    }
    
    func setData(data: [BannerDto]) {
        DispatchQueue.main.async {[weak self] in
            self?.bannerCarouselView.setData(bannerDtos: data)
        }
    }
    
    func setBannerToDefault() {
        bannerCarouselView.setDefault()
    }
}
