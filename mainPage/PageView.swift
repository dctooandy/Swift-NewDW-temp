//
//  PageView.swift
//  betlead
//
//  Created by Victor on 2019/9/11.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit

class PageView: UIView {

    private var pages: [PageLabel] = []
    private let bottomLine: UIView = {
        let v = UIView()
        v.backgroundColor = Themes.primaryBase
        return v
    }()
    
    func setupPage(dataCount: Int) {
        if dataCount == 0 { return }
        pages.forEach({$0.removeFromSuperview()})
        bottomLine.removeFromSuperview()
        pages.removeAll()
        for i in 1...dataCount {
            let label = PageLabel()
            label.tag = i - 1
            label.text = String(format: "%02d", i)
            label.font =  UIFont.systemFont(ofSize: 12, weight: .heavy)
            label.textAlignment = .center
            addSubview(label)
            label.snp.makeConstraints { [weak self] (make) in
                guard let strongSelf = self else { return }
                if strongSelf.pages.isEmpty {
                    make.left.equalToSuperview()
                } else {
                    make.left.equalTo(strongSelf.pages.last!.snp.right).offset(2)
                }
                make.top.equalToSuperview()
                if i == dataCount {
                    make.right.equalToSuperview()
                }
                make.width.equalTo(18)
                make.height.equalTo(17)
            }
            pages.append(label)
        }
        pages[0].isSelected = true
        setBottomLine()
    }
    
    private func setBottomLine() {
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.top.equalTo(pages[0].snp.bottom)
            make.centerX.equalTo(pages[0])
            make.width.equalTo(pages[0])
            make.height.equalTo(3)
            make.bottom.equalToSuperview()
        }
    }
    
    func selected(index: Int) {
        if index < 0 { return }
        pages.forEach({ $0.isSelected = $0.tag == index })
        bottomLine.snp.remakeConstraints { (make) in
            make.top.equalTo(pages[index].snp.bottom)
            make.centerX.equalTo(pages[index])
            make.width.equalTo(pages[index])
            make.height.equalTo(3)
            make.bottom.equalToSuperview()
        }
    }
}


class PageLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = Themes.grayDark
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isSelected: Bool = false {
        didSet {
            changeTitleColor()
        }
    }
    
    private var selectedColor: UIColor = Themes.grayDarkest
    private var defaultColor: UIColor = Themes.grayDark
    
    func setTitleColor(color: UIColor, forSelect: Bool) {
        if forSelect {
            selectedColor = color
        } else {
            defaultColor = Themes.grayDark
        }
    }
    
    private func changeTitleColor() {
        if isSelected {
            textColor = selectedColor
        } else {
            textColor = defaultColor
        }
    }
    
    
}
