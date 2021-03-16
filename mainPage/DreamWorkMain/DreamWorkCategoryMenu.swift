//
//  DreamWorkCategoryMenu.swift
//  DreamWork
//
//  Created by Victor on 2019/10/15.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DreamWorkCategoryMenu: UIView {
    private enum Category: Int {
        case sport = 1
        case realPerson = 2
        case ticket = 4
        case chess = 5
        case entertainment = 6
        
        var image: UIImage? {
            switch self {
            case .sport:
                return UIImage(named: "icon-sport")
            case .realPerson:
                return UIImage(named: "icon-realguy")
            case .ticket:
                return UIImage(named: "icon-lottery")
            case .chess:
                return UIImage(named: "icon-chess")
            case .entertainment:
                return UIImage(named: "icon-entertainment")
            }
        }
    }
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let containerView = UIView()
    private var gameTypes:  [GameTypeDto] = []
    private let arrawImageView = UIImageView(image: UIImage(named: "icon-categoryArrow-light"))
    private var categoryViews = [UIButton]()
    private let rxClick = PublishSubject<Int>()
    private let disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(gameTypes:  [GameTypeDto]) {
        super.init(frame: .zero)
        self.gameTypes = gameTypes
    }
    
    func setGameGroupData(data: [GameTypeDto]) {
        self.gameTypes = data
        setupUI()
        setupCategory()
        bindStyle()
    }
    
    private func bindStyle() {
        Themes.dreamWorkMenuArrowImg.bind(to: arrawImageView.rx.image).disposed(by: disposeBag)
        
    }
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(containerView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
       
    }
    private var menuStackView: UIStackView! = UIStackView()
    private func setupCategory() {
        if gameTypes.count == 0 { return }
        categoryViews.forEach({ menuStackView.removeArrangedSubview($0) })
        categoryViews.removeAll()
        menuStackView.removeFromSuperview()
        for i in 0..<gameTypes.count {
            categoryViews.append(createMenuBtn(index: i, id: gameTypes[i].id))
        }
        menuStackView = UIStackView(arrangedSubviews: categoryViews)
        menuStackView.axis = .horizontal
        menuStackView.spacing = 4
        menuStackView.distribution = .fillEqually
        scrollView.addSubview(menuStackView)
        scrollView.delegate = self
        categoryViews.forEach({
            $0.snp.makeConstraints { [weak self](make) in
                guard let weakSelf = self else { return }
                make.size.equalTo(weakSelf.snp.width).multipliedBy(0.2).offset(-3.2)
            }
        })
        menuStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
//            make.width.equalToSuperview()
        }
        addSubview(arrawImageView)
        arrawImageView.snp.makeConstraints { [weak self] (make) in
            guard let weakSelf = self else { return }
            make.width.equalTo(categoryViews[0])
            make.height.equalTo(categoryViews[0]).multipliedBy(1.21)
            make.top.centerX.equalTo(weakSelf.categoryViews[0])
            
        }
    }
    
    private func createMenuBtn(index: Int, id: Int) -> UIButton {
        let b = UIButton()
        b.tag = index
        b.layer.cornerRadius = (Views.screenWidth*0.2 - 3.2) / 4.25
        b.layer.masksToBounds = true
        bindCategoryButton(btn: b)
        let lightImg = gameTypes[index].gameTypeBackGroundActive
//        let darkImg = gameTypes[index].gameTypeBackGroundUnactive
        let darkImg = gameTypes[index].gameTypeBackGroundActive
        Themes.bindDreamWorkStyle(light: lightImg, dark: darkImg).bind(to: b.rx.imageUrl).disposed(by: disposeBag)
        return b
    }
    private func bindCategoryButton(btn: UIButton) {
        btn.rx.tap.subscribeSuccess { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.buttonDidSelected(with: btn.tag)
        }.disposed(by: disposeBag)
    }
    
    private func buttonDidSelected(with tag: Int) {
        rxClick.onNext(tag)
        let btn = categoryViews[tag]
        arrawImageView.snp.remakeConstraints { [weak self] (make) in
            guard let weakSelf = self else { return }
            make.width.equalTo(btn)
            make.height.equalTo(btn).multipliedBy(1.21)
            make.centerX.top.equalTo(btn)
        }
    }
    
    func didClick() -> Observable<Int> {
        return rxClick.asObserver()
    }
}
extension DreamWorkCategoryMenu : UIScrollViewDelegate
{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
}
