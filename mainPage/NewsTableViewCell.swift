//
//  NewsTableViewCell.swift
//  betlead
//
//  Created by vanness wu on 2019/6/10.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
class NewsTableViewCell:UITableViewCell{
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var contentLabel:UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        bindStyle()
    }
    
    func configureCell(newsDto:NewsDto){
        titleLabel.text = newsDto.newsTitle
        contentLabel.text = newsDto.newsContent.stripHTML()
    }
    private let disposeBag = DisposeBag()
    func bindStyle() {
        Themes.dreamWorkContentTextColor.bind(to: contentLabel.rx.textColor).disposed(by: disposeBag)
    }
}
