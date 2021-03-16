//
//  GameCardView.swift
//  betlead
//
//  Created by vanness wu on 2019/5/24.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import SnapKit
class GameCardView:UIView {
    
    @IBOutlet weak var collectionView:UICollectionView!
    private var gameCardDtos = [GameCardDto]()
    private let onClick = PublishSubject<GameCardDto>()
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAdsCollectionView()
        backgroundColor = .clear
        collectionView.backgroundColor = .clear
    }
    
    private lazy var flowLayout:BetLeadCarouseFlowLayout = {
        let flowLayout = BetLeadCarouseFlowLayout(delegate: self, offset:  8)
        flowLayout.sideItemAlpha = 1
        flowLayout.sideItemScale = 1
        flowLayout.itemSize = CGSize(width: 208, height: 82)
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }()
    
    private func setupAdsCollectionView(){
        collectionView.collectionViewLayout = flowLayout
        collectionView.registerXibCell(type: GameCardCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
    }
    func setData(_ gameCardDtos:[GameCardDto]){
        self.gameCardDtos = gameCardDtos
        reloadData()
    }
    
    func reloadData(){
        collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0) , at: .centeredHorizontally, animated: false)
        }
    }
    
    func rxClick() -> Observable<GameCardDto> {
        return onClick.asObserver()
    }
}

extension GameCardView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if gameCardDtos.count < 2 {
            return 3
        }
        return gameCardDtos.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: GameCardCollectionViewCell.self, indexPath: indexPath)
        cell.configureCell(gameCardDto: getDto(indexPath: indexPath))
        return cell
    }
    func collectionView(_ collectionView:UICollectionView, didSelectItemAt indexPath:IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        onClick.onNext(getDto(indexPath: indexPath))
        select(index: indexPath.row)
    }
    
    func getDto(indexPath:IndexPath) -> GameCardDto {
        if gameCardDtos.count == 0 {
            return GameCardDto()
        } else if gameCardDtos.count == 1 {
            return gameCardDtos[0]
        } else {
            if indexPath.row == 0 {
                return gameCardDtos.last ??  GameCardDto()
            } else if indexPath.row == gameCardDtos.count + 1 {
               return gameCardDtos.first ?? GameCardDto()
            } else {
                return  gameCardDtos[indexPath.row - 1]
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView:UIScrollView) {
        handlePageIndex(scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handlePageIndex(scrollView)
    }
 
    private func handlePageIndex(_ scrollView:UIScrollView){
        guard let flowLayout = collectionView.collectionViewLayout as? BetLeadCarouseFlowLayout else {
            return
        }
        flowLayout.scrollViewDidEndDecelerating(scrollView)
        if flowLayout.rxCurrentPage.value == 0 {
            collectionView.scrollToItem(at: IndexPath(row: gameCardDtos.count, section: 0)    , at: .centeredHorizontally, animated: false)
            flowLayout.rxCurrentPage.accept(gameCardDtos.count)
        } else if flowLayout.rxCurrentPage.value == gameCardDtos.count + 1 {
            collectionView.scrollToItem(at: IndexPath(row: 1, section: 0)    , at: .centeredHorizontally, animated: false)
            flowLayout.rxCurrentPage.accept(1)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        flowLayout.scrollViewDidScroll(scrollView)
    }
    
    
}
extension GameCardView: BetLeadCarouselFlowLayoutDelegate {
    func select(index: Int) {
    }
}
