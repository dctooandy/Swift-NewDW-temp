//
//  CategoryMenu.swift
//  betlead
//
//  Created by Victor on 2019/9/9.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class CategoryMenu: UIView {

    private let dpg = DisposeBag()
    private var gameTypeDtos: [GameTypeDto]?
    private var buttons = [CategoryMenuButton]()
    private var click = PublishSubject<Int>()
    private let menuMask = UIView()
    private var includTags = [Int]()
    func setup(data: [GameTypeDto]) {
        gameTypeDtos = data
        setupMenu()
        bindMenu()
        backgroundColor = Themes.grayLighter
        clipsToBounds = true
    }
    func rxClick() -> Observable<Int> {
        return click.asObserver()
    }
    
    private func bindMenu() {
        
        for btn in buttons {
            btn.rx.tap.subscribeSuccess {[weak self] _ in
                print("menu click :\(btn.tag)")
                self?.click.onNext(btn.tag)
            }.disposed(by: dpg)
        }
    }
    
    func moveMask(tags:[Int]) {
        if buttons.isEmpty { return }
        includTags = tags
        move()
    }
    
    private func move() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.menuMask.frame.origin = CGPoint(x: 0,
                                                       y: strongSelf.buttons[strongSelf.includTags[0]].frame.minY)
        }) { (success) in
            self.setButtonStyle()
        }
    }
    
    private func setButtonStyle() {
        // button style change
        for b in buttons {
            b.isSelected = includTags.contains(b.tag)
        }
    }
    func setupMask() {
        insertSubview(menuMask, at: 0)
        let minY = buttons.first!.frame.minY
        let maxY = buttons[2].frame.maxY
        menuMask.frame = CGRect(x: 0, y: minY, width: frame.width, height: maxY - minY)
        menuMask.addGradientLayer(colors: [Themes.primaryBase.cgColor, Themes.primaryDark.cgColor])
        menuMask.layer.cornerRadius = frame.width / 2
        layer.cornerRadius = frame.width / 2
        menuMask.clipsToBounds = true
        includTags = [0, 1, 2]
        setButtonStyle()
    }
    
    private func setupMenu() {
        guard let types = gameTypeDtos else { return }
        for i in types.enumerated() {
            let title = i.element.gameTypeName_Mobile
//            let icon = i.element.gameTypeBackGroundUnactive ?? ""
            let icon = i.element.gameTypeBackGroundActive ?? ""
            createMenuButton(title: title, icon: icon, tag: i.offset)
        }
    }
    
    private func createMenuButton(title: String, icon: String, tag: Int) {
        let menuButton = CategoryMenuButton(title: title, icon: icon, tag: tag)
        addSubview(menuButton)
        menuButton.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = self else { return }
            make.left.right.equalToSuperview()
            if strongSelf.buttons.isEmpty {
                make.top.equalToSuperview().offset(topOffset(8/812))
            } else {
                make.top.equalTo(strongSelf.buttons.last!.snp.bottom).offset(10)
            }
            
            if strongSelf.gameTypeDtos!.count - 1 == strongSelf.buttons.count {
                make.bottom.equalToSuperview().offset(-topOffset(8/812))
            }
        }
        buttons.append(menuButton)
    }
}

class CategoryMenuButton: UIControl {
    override var isSelected: Bool {
        didSet {
            let color = isSelected ? .white : Themes.grayBase
            label.textColor = color
            imv.tintColor = color
        }
    }
    private let imv: UIImageView = {
        let imv = UIImageView()
        imv.tintColor = Themes.grayBase
        return imv
    }()
    private let label: UILabel = {
        let lb = UILabel()
        lb.font = Fonts.pingFangSCRegular(12)
        lb.textColor = Themes.grayBase
        lb.textAlignment = .center
        lb.numberOfLines = 0
        lb.lineBreakMode = .byCharWrapping
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(title: String, icon: String, tag: Int) {
        super.init(frame: .zero)
        self.tag = tag
        imv.sdLoad(with: URL(string: icon), completed: { [weak self](image) in
           self?.imv.image = image?.withRenderingMode(.alwaysTemplate)
        })
        label.text = title
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(imv)
        addSubview(label)
        imv.snp.makeConstraints { (make) in
            make.size.equalTo(12)
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imv.snp.bottom)
            make.bottom.equalToSuperview().offset(-5)
            make.centerX.width.equalTo(imv)
        }
    }
}
