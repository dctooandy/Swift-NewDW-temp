//
//  MainNavigationBar.swift
//  DreamWork
//
//  Created by Victor on 2019/10/18.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainNavigationBar: UIView {
    let lightImg = "https://2.bp.blogspot.com/-hle2DnjMLXQ/V0P4wAkUb-I/AAAAAAAACb8/oxEL6n_34KgNJwlK5Frqh4mI8OH_o8DVgCLcB/s640/TWICE-HIGHCUT03.gif"
    let darkImg = "http://www.teepr.com/wp-content/uploads/2017/05/source.gif"
    private let navigationBarView = UIView()
    private lazy var walletAmountView = WalletAmountView()
    private let loginBtnView = SignupLoginButtonView()
    private let topLogo = UIImageView()
    private let dwDelegateADButton :UIButton = {
        let btn = UIButton()
//        btn.setTitle("登录", for: .normal)
//        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = width(30/414)/2
        btn.clipsToBounds = true
//        btn.titleLabel?.font = Fonts.pingFangTCSemibold(12)
        return btn
    }()
    private let disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI()
        addTopLogoClick()
        bindGameWalletData()
        bindWalletAmountView()
        bindLoginButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func bindStyle() {
        
    }

    func setupUI() {
        addSubview(navigationBarView)
        navigationBarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(width(Views.navigationBarHeight/414) + 10)
        }
        Themes.dreamWorkLogoImage.bind(to: topLogo.rx.image).disposed(by: disposeBag)
//        Themes.bindDreamWorkStyle(light: lightImg, dark: darkImg).bind(to: dwDelegateADButton.rx.imageUrl).disposed(by: disposeBag)
//        dwDelegateADButton.imageView?.contentMode = .scaleAspectFill
        
        navigationBarView.addSubview(topLogo)
        topLogo.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(width(36/414))
            make.width.equalTo(width(94/414))
        }
         #if DREAMWORKPRO
        // production
//            #elseif DREAMWORKSTAGE
//            #elseif DREAMWORKDEV
//            #elseif DREAMWORKTWO
        #else
        // test
        // stage
        // 封印我婆子瑜按鈕
//        navigationBarView.addSubview(dwDelegateADButton)
//        dwDelegateADButton.snp.makeConstraints{ (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalTo(topLogo.snp.right).offset(10)
//            make.height.equalTo(width(36/414))
//            make.width.equalTo(width(94/414))
//        }

        #endif
        navigationBarView.addSubview(walletAmountView)
        walletAmountView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(width(20/414))
        }
        
        navigationBarView.addSubview(loginBtnView)
        loginBtnView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftRightOffset(12/812))
            make.centerY.equalToSuperview()
        }
    }
    
    func addTopLogoClick() {
        topLogo.rx.click.subscribeSuccess { // 切換style
            #if DREAMWORKPRO
            // production
//            #elseif DREAMWORKSTAGE
//            #elseif DREAMWORKDEV
//            #elseif DREAMWORKTWO
            #else
            // test
            // stage
            Beans.matomoServer.track(eventWithCategory: MCategory.Header.rawValue,
                                     action: MAction.Click.rawValue,
                                     name: "Logo")
            DreamWorkStyle.share.acceptStyle(.light)
            #endif
        }.disposed(by: disposeBag)
        
//        dwDelegateADButton.rx.click.subscribeSuccess{
//            let url = DWURLForPage.share.agency
//            UIApplication.topViewController()?.present(BetLeadWebViewController(url), animated: true)
//        }.disposed(by: disposeBag)
    }
    
    func isLogin(_ isLogin: Bool) {
        loginBtnView.isHidden = isLogin
        walletAmountView.isHidden = !isLogin
//        dwDelegateADButton.isHidden = !isLogin
    }
    
    private func bindLoginButton() {
        loginBtnView.rxClick().subscribeSuccess { (isLogin) in
            DispatchQueue.main.async() {
                Beans.matomoServer.track(eventWithCategory: MCategory.Header.rawValue,
                action: MAction.Click.rawValue,
                name: (isLogin ? "登录":"注册"))
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
                Beans.matomoServer.track(eventWithCategory: MCategory.Header.rawValue,
                action: MAction.Click.rawValue,
                name: "钱包")
                DeepLinkManager.share.handleDeeplink(navigation: .memberShowWallet)
            }.disposed(by: disposeBag)
    }
}
