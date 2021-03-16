//
//  NewsBottomSheet.swift
//  betlead
//
//  Created by vanness wu on 2019/6/10.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit
import WebKit
class NewsDetailBottomSheet:BaseBottomSheet {
    
    private let newsTitleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = Themes.primaryBase
        label.numberOfLines = 2
        return label
    }()
    
    private let timeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = Themes.grayDarker
        return label
    }()
    
    private lazy var contentWebView: DreamWorkWebView = {
        let wk = DreamWorkWebView()
        wk.backgroundColor = .clear
        wk.wkWebView.backgroundColor = .clear
        wk.wkWebView.scrollView.backgroundColor = .clear
        wk.wkWebView.isOpaque = false
        return wk
    }()
    
    init(marqueeDto:MarqueeDto) {
        super.init()
        bindSubmitBtn()
        titleLabel.text = "公告内容"
        submitBtn.setTitle("查看全部公告", for: .normal)
        newsTitleLabel.text = marqueeDto.newsTitle
        timeLabel.text = marqueeDto.newsCreatedAt
        let renderContent = JSStyleRender.share.renderFitContentCss(content:marqueeDto.newsContent)
        contentWebView.loadHtml(renderContent)//.loadHTMLString(renderContent, baseURL: nil)
        bindStyle()
    }
    
    init(newsDto:NewsDto) {
        super.init()
        bindSubmitBtn()
        titleLabel.text = "公告内容"
        submitBtn.setTitle("查看全部公告", for: .normal)
        newsTitleLabel.text = newsDto.newsTitle
        timeLabel.text = newsDto.newsCreatedAt
        let renderContent = JSStyleRender.share.renderFitContentCss(content:newsDto.newsContent)
        contentWebView.loadHtml(renderContent)
        bindStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(_ parameters: Any? = nil) {
        super.init()
    }
    
    private func bindStyle() {
        Themes.dreamWorkWhiteAndDarkBase.bind(to: defaultContainer.rx.backgroundColor).disposed(by: disposeBag)
        Themes.dreamWorkBlackAndWhite.bind(to: titleLabel.rx.textColor).disposed(by: disposeBag)
        Themes.dreamWorkContentTextColor.bind(to: timeLabel.rx.textColor).disposed(by: disposeBag)
//        contentWebView
    }
    
    override func setupViews() {
        super.setupViews()
        bindServiceBtn()
        defaultContainer.addSubview(newsTitleLabel)
        defaultContainer.addSubview(timeLabel)
        defaultContainer.addSubview(contentWebView)
        
        newsTitleLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(separator.snp.bottom).offset(28)
            maker.leading.equalToSuperview().offset(24)
            maker.trailing.equalToSuperview().offset(-24)
            maker.height.equalTo(60)
        }
        timeLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(newsTitleLabel.snp.bottom).offset(16)
            maker.leading.trailing.equalTo(newsTitleLabel)
            maker.height.equalTo(24)
        }
        contentWebView.snp.makeConstraints { (maker) in
            maker.top.equalTo(timeLabel.snp.bottom).offset(8)
            maker.leading.trailing.equalTo(newsTitleLabel)
            maker.bottom.equalTo(submitBtn.snp.top).offset(-8)
        }
    }
    
    private func bindSubmitBtn(){
        submitBtn.rx.tap.subscribeSuccess {[weak self] (_) in
            guard let weakSelf = self else {return}
            weakSelf.dismissVC(nextSheet: NewsBottomSheet())
        }.disposed(by: disposeBag)
    }
    private func bindServiceBtn() {
        serviceBtn.rx.tap.subscribeSuccess {
            print("game wallet service btn pressed.")
            LiveChatService.share.betLeadServicePresent()
            }.disposed(by: disposeBag)
    }
}
