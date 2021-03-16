//
//  CategoryView.swift
//  PreBetLead
//
//  Created by vanness wu on 2019/5/13.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum Category:Int, CaseIterable {
    case sport = 0,human,gaming,lottery,chess,video,fishing
    
    var title:String {
        switch self {
        case .sport:
            return "体育"
        case .human:
            return "真人"
        case .gaming:
            return "电竞"
        case .lottery:
            return "彩票"
        case .chess:
            return "棋牌"
        case .video:
            return "电子"
        case .fishing:
            return "捕鱼"
        }
    }
    var icon:UIImage? {
        switch self {
        case .sport:
            return UIImage(named: "coins")
        case .human:
            return UIImage(named: "coins")
        case .lottery:
            return UIImage(named: "coins")
        case .gaming:
            return UIImage(named: "coins")
        case .chess:
            return UIImage(named: "coins")
        case .fishing:
            return UIImage(named: "coins")
        case .video:
            return UIImage(named: "coins")
        }
    }
    var url:String {
        switch self {
        case .sport:
            return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFzmgyVbZd1gOdMa1H2sDhDR82HfQbTB7desMJ90eUlYAsLjpdzg"
        case .human:
            return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3v5h6Edx0iIa7BODwWcDRpaUvDQKgqdbCd2B5AtitKQ_iriwnXw"
        case .lottery:
            return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkCZrlKK-_b3SAWBcTQ_zYIktT4JPf5KlVgisgnqiwGZ30JWol"
        case .gaming:
            return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSmfI9vNh2yYZpzln8VbaPuJuWDPsAn68L8ydGBI3Yaso8aZb5u"
        case .chess:
            return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKi-Q3ecvNt0gZoRUYDQUmSdyDx3gBxF7hWYG15gPgWxUo0YC_dw"
        case .fishing:
            return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPKwKwxNJTwvG0RC75jhJ5KIqmnT0CjeHu7HVmYWE__WXDhCpH"
        case .video:
            return "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQoivBbvVahPHVoTlw-MRrvnNs_d1W16BwD_v0yLMknm9fmg0iK"
        }
    }
}

protocol CategoryViewDelegate:class {
    func onClick(gameGroupDtos:[GameGroupDto],id:Int, index:Int)
}

class CategoryView:UIView {
    
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var menuContentView:UIView!
    @IBOutlet weak var menuMaskView: UIView!
    
    private var menuViews = [CategoryMenuView]()
    private let disposeBag = DisposeBag()
    let rxSelectedIndex = PublishSubject<Int>()
    private let lineSapcing:CGFloat = 10
    private var gameTypeDtos = [GameTypeDto]()
    weak var delegate:CategoryViewDelegate?
    private var isDragging = false
    private let gameEntranceDtos = [GameEntranceDto(title: "AG真人", image: "1" , icon: "ag-entrance"),GameEntranceDto(title: "AG假人", image: "2", icon:"ibo-entrance" ),GameEntranceDto(title: "AG真假人", image: "3", icon:"og-entrance"),GameEntranceDto(title: "AG陰陽人", image: "4", icon:"ibo-entrance") ]
    private var pageHeight:CGFloat {
        return self.collectionView.frame.height + self.lineSapcing
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        setupMenuView()
        setupCollectionView()
        bindSelectedIndex()
        bindCollectionView()
        collectionView.backgroundColor = .clear
        rxSelectedIndex.onNext(0)
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        menuMaskView.roundCorner(corners: [.topRight,.bottomRight], radius: 16)
    }
    
    class func loadViewFromNib() -> CategoryView {
        let view = CategoryView.loadNib()
        return view
    }
    
    func setData(gameTypeDtos:[GameTypeDto]){
        self.gameTypeDtos = gameTypeDtos
        collectionView.reloadData()
    }
    
    private func setupCollectionView(){
        collectionView.registerCell(type: GameEntranceCell.self)
        collectionView.registerCell(type: EmptyCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.1)
    }
    
    private func bindSelectedIndex(){
        rxSelectedIndex.scan( [ 0,0 ] ) { seed, newValue in
            return [ seed[1], newValue ]
            }
            .map { array -> (Int,Int) in
                return (array[0], array[1])
            }
            .subscribe(onNext: {[weak self] (lastIndex,currentIndex) in
                guard let weakSelf = self else {return}
                weakSelf.setMenuSelected(tag: currentIndex)
                if currentIndex != lastIndex {
                    weakSelf.setMenuUnSelected(tag: lastIndex)
                }
                if !weakSelf.isDragging {
                    weakSelf.collectionView.setContentOffset(CGPoint(x: 0, y: CGFloat(currentIndex) * (weakSelf.pageHeight)), animated: true)
                }
                
            }).disposed(by: disposeBag)
    }
    
    private func bindCollectionView(){
        collectionView.rx.contentOffset.map({$0.y}).map({[weak self] offset -> Int in
            guard let weakSelf = self else {return 0}
            return Int(ceil((offset - weakSelf.pageHeight/2 )/weakSelf.pageHeight))
        }).distinctUntilChanged()
            .subscribe(onNext: {[weak self] (index) in
                guard let weakSelf = self else {return}
                if weakSelf.isDragging {
                    weakSelf.rxSelectedIndex.onNext(index)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindTurnView(){
        
        
    }
    
    private func setupMenuView(){
        let menuContenHeight: CGFloat = height(334/812)
        let lineSpaceing: CGFloat = height(12/812)
        let viewHeight: CGFloat = (menuContenHeight - (height(14/812) * 8)) / 7
        let menuWidth: CGFloat = Views.isIPad() ? 74 : width(60/375)
        for (index,category) in Category.allCases.enumerated() {
            let menuView = CategoryMenuView.loadViewFromNib(category: category)
            menuContentView.addSubview(menuView)
            menuView.tag = index
            let tap = UITapGestureRecognizer()
            tap.rx.event.map({[weak self] tap in
                guard let weakSelf = self else {return 0}
                weakSelf.isDragging = false
                return tap.view?.tag ?? 0
            }).bind(to: rxSelectedIndex).disposed(by: disposeBag)
            menuView.addGestureRecognizer(tap)
            menuView.snp.makeConstraints { [weak self] (maker) in
                guard let strongSelf = self else { return }
                if strongSelf.menuViews.isEmpty {
                    maker.top.equalToSuperview().offset(lineSpaceing)
                } else {
                    maker.top.equalTo(strongSelf.menuViews.last!.snp.bottom).offset(lineSpaceing)
                }
                maker.leading.equalToSuperview()
                maker.height.equalTo(viewHeight)
                maker.width.equalTo(menuWidth)
                if index == Category.allCases.count - 1 {
                    maker.bottom.equalToSuperview().offset(-lineSpaceing)
                }
            }
            menuViews.append(menuView)
        }
        
        menuContentView.snp.remakeConstraints { (maker) in
            maker.top.equalToSuperview().offset(topOffset(16/812))
            maker.leading.equalToSuperview()
            maker.width.equalTo(width(74/375))
            maker.bottom.equalToSuperview().offset(-topOffset(16/912)).priority(.low)
        }
    }
    
    private func setMenuSelected(tag:Int){
        menuViews[tag].sethighlight(true)
        
    }
    private func setMenuUnSelected(tag:Int){
        menuViews[tag].sethighlight(false)
    }
}

extension CategoryView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let category = Category(rawValue: indexPath.row),
            indexPath.row < gameTypeDtos.count
            else {
                let cell = collectionView.dequeueCell(type: EmptyCollectionViewCell.self, indexPath: indexPath)
                return cell 
        }
        let cell = collectionView.dequeueCell(type: GameEntranceCell.self, indexPath: indexPath)
        cell.delegate = self
        cell.setEntrance(gameTypeDto: gameTypeDtos[indexPath.row],index:indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSapcing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDragging = false
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentOffset:Float = Float(scrollView.contentOffset.y)
        let targetOffset:Float = Float(targetContentOffset.pointee.y)
        let onePageHeight = Float(pageHeight)
        var newTargetOffset:Float = 0
        if targetOffset > currentOffset {
            newTargetOffset = ceilf(targetOffset / onePageHeight) * onePageHeight
        } else if (targetOffset == currentOffset) {
            newTargetOffset = roundf(targetOffset / onePageHeight) * onePageHeight
        } else {
            newTargetOffset = floorf(targetOffset / onePageHeight) * onePageHeight
        }
        if newTargetOffset < 0 {
            newTargetOffset = 0
        } else if (newTargetOffset > Float(scrollView.contentSize.height)) {
            newTargetOffset = Float(Float(scrollView.contentSize.height))
        }
        
        targetContentOffset.pointee.y = CGFloat(newTargetOffset)
    }
}

extension CategoryView:GameEntranceCellDelegate {
    func enterGame(index:Int , id:Int) {
        delegate?.onClick(gameGroupDtos: gameTypeDtos[index].gameGroups.data, id: id , index:index)
    }
    
    
}
