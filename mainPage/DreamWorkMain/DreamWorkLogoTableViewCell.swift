//
//  DreamWorkLogoTableViewCell.swift
//  DreamWork
//
//  Created by Victor on 2019/10/16.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
class DreamWorkLogoTableViewCell: UITableViewCell {
    private let navigationBarView = UIView()
    private lazy var walletAmountView = WalletAmountView()
    private let loginBtnView = SignupLoginButtonView()
    private let topLogo = UIImageView()
    private let disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
        addTopLogoClick()
        bindGameWalletData()
        bindWalletAmountView()
        bindLoginButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(navigationBarView)
        navigationBarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(Views.navigationBarHeight + 10)
        }
        Themes.dreamWorkLogoImage.bind(to: topLogo.rx.image).disposed(by: disposeBag)

        navigationBarView.addSubview(topLogo)
        topLogo.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(36)
            make.width.equalTo(94)
        }
        navigationBarView.addSubview(walletAmountView)
        walletAmountView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
        
        navigationBarView.addSubview(loginBtnView)
        loginBtnView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftRightOffset(12/812))
            make.centerY.equalToSuperview()
        }
    }
    
    func addTopLogoClick() {
        topLogo.rx.click.subscribeSuccess {
            DreamWorkStyle.share.acceptStyle(DreamWorkStyle.share.interFaceStyle.value == .dark ? .light : .dark)
        }.disposed(by: disposeBag)
    }
    
    func isLogin(_ isLogin: Bool) {
        loginBtnView.isHidden = isLogin
        walletAmountView.isHidden = !isLogin
    }
    
    private func bindLoginButton() {
        loginBtnView.rxClick().subscribeSuccess { (isLogin) in
            DispatchQueue.main.async() {
                UIApplication.shared.keyWindow?.rootViewController =  LoginSignupViewController.share.isLogin(isLogin)
            }
        }.disposed(by: disposeBag)
    }
    
    private func bindGameWalletData() {
        WalletDto.rxShare.subscribeSuccess { [weak self] (dto) in
            guard let amount = dto?.amount else { return }
            self?.walletAmountView.setAmount(amount)
        }.disposed(by: disposeBag)
    }
    private func bindWalletAmountView() {
        walletAmountView.rx.click
            .subscribeSuccess { (_) in
                DeepLinkManager.share.handleDeeplink(navigation: .memberShowWallet)
            }.disposed(by: disposeBag)
    }
    
    
}
