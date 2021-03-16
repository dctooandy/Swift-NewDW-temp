//
//  WalletAmountView.swift
//  betlead
//
//  Created by Victor on 2019/8/29.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletAmountView: UIView {
    private let disposeBag = DisposeBag()
    private lazy var walletImageView:UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "coins")?.withRenderingMode(.alwaysTemplate)
        img.tintColor = Themes.primaryBase
        return img
    }()
    
    private lazy var walletLabel:UILabel = {
        let lb = UILabel()
        lb.text = "Y$$$$$$$$$.$$"
        lb.font = Fonts.pingFangTCSemibold(12)
        lb.textColor = .black
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setup()
        bindStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindStyle() {
        walletImageView.image = walletImageView.image?.withRenderingMode(.alwaysTemplate)
        Themes.dreamWorkPrimaryBaseAndYellow.bind(to: walletLabel.rx.textColor).disposed(by: disposeBag)
        Themes.dreamWorkPrimaryBaseAndYellow.bind(to: walletImageView.rx.tintColor).disposed(by: disposeBag)
    }
    
    private func setup() {
        addSubview(walletImageView)
        addSubview(walletLabel)
        walletImageView.snp.makeConstraints { (make) in
            make.size.equalTo(self.snp.height)
            make.top.left.bottom.equalToSuperview()
        }
        
        walletLabel.snp.makeConstraints { (make) in
            make.left.equalTo(walletImageView.snp.right).offset(2)
            make.top.bottom.right.equalToSuperview()
        }
    }
    
    func setAmount(_ amount: String) {
        walletLabel.text = amount
    }
    

}
