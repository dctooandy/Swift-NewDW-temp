//
//  MarqueeTableViewCell.swift
//  betlead
//
//  Created by Victor on 2019/9/6.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class MarqueeTableViewCell: UITableViewCell {
    private let dpg = DisposeBag()
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    private lazy var megaphoneImageView:UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage(named: "icon-megaphone")?.withRenderingMode(.alwaysTemplate)
        imv.tintColor = .black
        imv.contentMode = .scaleAspectFit
        return imv
    }()
    fileprivate var marqueeView: MarqueeView = MarqueeView()
    let dailySignView: UIView = {
        let view = UIView(color: Themes.secondaryOrange)
        view.layer.cornerRadius = width(20/414)/2
        view.layer.borderWidth = 1
        view.layer.borderColor = Themes.secondaryYellow.cgColor
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setup()
        setBorder()
        setupDailySign()
        bindStyle()
    }
    private func bindStyle() {
        Themes.dreamWorkBlackAndWhite.bind(to: containerView.rx.borderColor).disposed(by: dpg)
        Themes.dreamWorkMegaphoneImg.bind(to: megaphoneImageView.rx.image).disposed(by: dpg)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setBorder() {
        containerView.applyBorder(color: .black, borderWidth: 1)
        containerView.applyCornerRadius(radius: width(20/414)/2)
    }
    private func setup() {
        contentView.addSubview(containerView)
        containerView.addSubview(marqueeView)
        containerView.addSubview(megaphoneImageView)
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-5)
            
        }
        megaphoneImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(15)
            make.size.equalTo(width(20/414))
        }
        
        marqueeView.snp.makeConstraints { (make) in
            make.top.bottom.height.equalTo(megaphoneImageView)
            make.left.equalTo(megaphoneImageView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-22)
        }
        
        
    }
    
    func setupDailySign() {
        contentView.addSubview(dailySignView)
        dailySignView.snp.makeConstraints { (make) in
            make.top.bottom.height.equalTo(containerView)
            make.left.equalTo(containerView.snp.right).offset(8)
            make.right.equalToSuperview().offset(-22)
        }
        let imv = UIImageView(image: UIImage(named: "icon-promotionAuto")?.withRenderingMode(.alwaysTemplate))
        imv.tintColor = .white
        dailySignView.addSubview(imv)
        imv.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(7)
            make.size.equalTo(width(12/414))
            make.centerY.equalToSuperview()
        }
        let titleLb = UILabel(title: "每日签到", textColor: .white)
        titleLb.font = Fonts.pingFangTCSemibold(12)
        titleLb.sizeToFit()
        dailySignView.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.left.equalTo(imv.snp.right).offset(3)
            make.centerY.equalTo(imv)
            make.right.equalToSuperview().offset(-7)
            
        }
    }
}

extension Reactive where Base: MarqueeTableViewCell {
    var selectedMarquee: Observable<MarqueeDto> {
        return base.marqueeView.rx.selectedMarquee
    }
    var selectedCheckInBtn: Observable<String?> {
        return base.dailySignView.rx.click.map({
            return DWURLForPage.share.checkIn})
    }
}
