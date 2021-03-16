//
//  SignupLoginButtonView.swift
//  betlead
//
//  Created by Victor on 2019/9/10.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
class SignupLoginButtonView: UIView {

    private let dpg = DisposeBag()
    private let signupBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("注册", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.textColor = UIColor.black
        btn.layer.cornerRadius = width(30/414)/2
        btn.layer.borderColor = UIColor.black.cgColor
        btn.layer.borderWidth = 1.0
        btn.clipsToBounds = true
        btn.titleLabel?.font = Fonts.pingFangTCSemibold(12)
        return btn
    }()
    private let loginBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("登录", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = width(30/414)/2
        btn.clipsToBounds = true
        btn.titleLabel?.font = Fonts.pingFangTCSemibold(12)
        return btn
    }()
    private let onClick = PublishSubject<Bool>()
    override func draw(_ rect: CGRect) {
        loginBtn.addGradientLayer(colors: [UIColor(red: 57, green: 109, blue: 238).cgColor, UIColor(red: 101, green: 0, blue: 255).cgColor], direction: .toRight)
    }
    init() {
        super.init(frame: .zero)
        setup()
        bind()
        bindStyle()
    }
    
    private func bind() {
        loginBtn.rx.tap.subscribeSuccess { [weak self] _ in
            self?.onClick.onNext(true)
        }.disposed(by: dpg)
        signupBtn.rx.tap.subscribeSuccess { [weak self] _ in
            self?.onClick.onNext(false)
        }.disposed(by: dpg)
        
             
    }
    
    private func bindStyle() {
        Themes.dreamWorkBlackAndWhite.bind(to: signupBtn.titleLabel!.rx.textColor).disposed(by: dpg)
        Themes.dreamWorkBlackAndWhite.bind(to: signupBtn.rx.textColor).disposed(by: dpg)
        Themes.dreamWorkBlackAndWhite.bind(to: signupBtn.rx.borderColor).disposed(by: dpg)
    }
    
    private func setup() {
        addSubview(loginBtn)
        addSubview(signupBtn)
        signupBtn.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalTo(width(64/414))
            make.height.equalTo(width(30/414))
        }
        
        loginBtn.snp.makeConstraints { (make) in
            make.left.equalTo(signupBtn.snp_right).offset(10)
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(width(64/414))
            make.height.equalTo(width(30/414))
        }
    }
    
    func rxClick() -> Observable<Bool> {
        return onClick.asObserver()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

