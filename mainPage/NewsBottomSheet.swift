//
//  NewsBottomSheet.swift
//  betlead
//
//  Created by vanness wu on 2019/6/10.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
class NewsBottomSheet:BaseBottomSheet {
    
    private var newsDtos = [NewsDto]()
    
    private lazy var newsTableView:UITableView  = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.registerXibCell(type: NewsTableViewCell.self)
        return tableView
    }()
    required init(_ parameters: Any? = nil) {
        super.init()
        titleLabel.text = "最新公告"
        fetchNews()
        bindStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func bindStyle() {
        Themes.dreamWorkWhiteAndDarkBase.bind(to: defaultContainer.rx.backgroundColor).disposed(by: disposeBag)
        Themes.dreamWorkBlackAndWhite.bind(to: titleLabel.rx.textColor).disposed(by: disposeBag)
    }
    private func fetchNews(){
        Beans.newsServer.frontendNews(page: 1, per_page: 999).subscribeSuccess {[weak self] (dtos,pagingDto) in
            guard let weakSelf = self else { return}
            if dtos.count > 0
            {
                weakSelf.newsDtos = dtos
            }else
            {
                weakSelf.newsDtos = [NewsDto()]
            }
            weakSelf.newsTableView.reloadData()
        }.disposed(by: disposeBag)
    }
    
    override func setupViews() {
        super.setupViews()
        defaultContainer.addSubview(newsTableView)
        newsTableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(separator.snp.bottom)
            maker.bottom.leading.trailing.equalToSuperview()
        }
        submitBtn.isHidden = true
    }
    
    
}


extension NewsBottomSheet:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsDtos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: NewsTableViewCell.self, indexPath: indexPath)
        cell.configureCell(newsDto: newsDtos[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presentingVC = presentingViewController else {return}
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                NewsDetailBottomSheet(newsDto: self.newsDtos[indexPath.row]).start(viewController: presentingVC)
            }
        }
    }
    
}
