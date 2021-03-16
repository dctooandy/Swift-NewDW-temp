//
//  AdsCollectionView.swift
//  PreBetLead
//
//  Created by vanness wu on 2019/5/13.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class BannerCarouselView :UIView {
    
    @IBOutlet weak var pageControl: UIPageControl!
    private let disposeBag = DisposeBag()
    private let onClick = PublishSubject<(String, Int , String , BannerPlayGameDto)>()
    private let emptyUrl = "https://gss0.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/zhidao/pic/item/c9fcc3cec3fdfc03b7614cfed93f8794a4c2265e.jpg"
    private var bannerDtos = [BannerDto]() {
        didSet {
            pageControl.numberOfPages = bannerDtos.count > 1 ? bannerDtos.count : 1
            addTimer()
            reloadData()
        }
    }
    //(Views.screenWidth - 16*2) * 0.55
    static let height:CGFloat = Views.isIPad() ?  Views.screenHeight * 0.3 : Views.screenWidth * 0.48
    @IBOutlet weak var bannerCollectionView:UICollectionView!
    private let itemSizeWidth = Views.screenWidth
    private let pageView = PageView()
    static func loadViewFromNib(bannerDtos:[BannerDto]) -> BannerCarouselView {
        let view = BannerCarouselView.loadNib()
        view.bannerDtos = bannerDtos
        return view
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyCornerRadius(radius: 10)
        clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAdsCollectionView()
        //setupPageView()
        bindPageController()
        backgroundColor = .clear
        bannerCollectionView.backgroundColor = .clear
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func rxClick() -> Observable<(String, Int , String, BannerPlayGameDto)> {
        return onClick.asObserver()
    }
    func reloadData(){
        bannerCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setDefault()
        }
    }
    
    func setData(bannerDtos:[BannerDto]) {
        self.bannerDtos = bannerDtos
       // pageView.setupPage(dataCount: bannerDtos.count)
    }
    func setDefault() {
        DispatchQueue.main.async { [weak self] in
            self?.bannerCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: false)
        }
        
    }
    private var dispose:Disposable?
    
    private func bindPageController(){
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = Themes.secondaryYellow
        flowLayout.rxCurrentPage.distinctUntilChanged().subscribe(onNext: {[weak self] index in
            guard let weakSelf = self else { return }
            if index == 0 {
//                weakSelf.pageView.selected(index: weakSelf.bannerDtos.count - 1)
                weakSelf.pageControl.currentPage = weakSelf.bannerDtos.count - 1
            } else if index == weakSelf.bannerDtos.count + 1 {
//                weakSelf.pageView.selected(index: 0)
                 weakSelf.pageControl.currentPage = 0
            } else {
//                weakSelf.pageView.selected(index: index - 1)
                weakSelf.pageControl.currentPage = index - 1
            }
        }).disposed(by: disposeBag)
    }
    private func addTimer(period:TimeInterval = 7) {
        dispose?.dispose()
        dispose = Observable<Int>.timer(0, period: period, scheduler: MainScheduler.instance).map({[weak self] _ -> Int in
            guard let weakSelf = self else { return 0}
            return weakSelf.flowLayout.rxCurrentPage.value
        }).skip(1).subscribe(onNext: {[weak self] currentpage in
            guard let weakSelf = self else { return }
            weakSelf.bannerCollectionView.scrollToItem(at: IndexPath(row: (currentpage + 1) % (weakSelf.bannerDtos.count + 2), section: 0), at: .centeredHorizontally, animated: true)
        })
    }
    
    private lazy var flowLayout:BetLeadCarouseFlowLayout = {
        let flowLayout = BetLeadCarouseFlowLayout(delegate: self, offset:  8)
        flowLayout.sideItemAlpha = 0.9
        flowLayout.sideItemScale = 0.8
        flowLayout.itemSize = CGSize(width: self.itemSizeWidth - 2*width(18/414), height: BannerCarouselView.height)
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }()
    private func setupAdsCollectionView(){
        bannerCollectionView.collectionViewLayout = flowLayout
        bannerCollectionView.registerXibCell(type: BannerCollectionViewCell.self)
        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        bannerCollectionView.showsHorizontalScrollIndicator = false
    }
    private func setupPageView() {
        addSubview(pageView)
        pageView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-4)
            make.centerX.equalToSuperview()
        }
    }
}

extension BannerCarouselView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section:Int) -> Int {
        if bannerDtos.count < 2 {
            return 3
        }
        return bannerDtos.count + 2
    }
    
    func collectionView(_ collectionView:UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: BannerCollectionViewCell.self, indexPath: indexPath)
        cell.configureCell(url: getUrl(indexPath: indexPath))
        cell.tag = indexPath.row
        return cell
    }
    
    func getUrl(indexPath:IndexPath) -> String {
        var url = ""
        if bannerDtos.count == 0 {
            url = emptyUrl
        } else if bannerDtos.count == 1 {
            url = bannerDtos[0].bannerImageMobile
        } else {
            if indexPath.row == 0 {
                url = bannerDtos.last?.bannerImageMobile ?? ""
            } else if indexPath.row == bannerDtos.count + 1 {
                url = bannerDtos.first?.bannerImageMobile ?? ""
            } else {
                url =  bannerDtos[indexPath.row - 1].bannerImageMobile
            }
        }
        return url
    }
    
    func getBannerLinkMethodType(indexPath: IndexPath) -> (url: String, type: Int , title:String , dto : BannerPlayGameDto) {
        var type = 0
        var url = ""
        var title = ""
        var theDto = BannerPlayGameDto()
        if bannerDtos.count == 0 {
        } else if bannerDtos.count == 1 {
            type = bannerDtos[0].bannerLinkMethod.value
            url = bannerDtos[0].bannerLinkMobile ?? ""
            title = bannerDtos[0].bannerTitle
            theDto = bannerDtos[0].bannerLinkMethod.value == 3 ? bannerDtos[0].bannerPlayGame! : BannerPlayGameDto()
        } else {
            if indexPath.row == 0 {
                type = bannerDtos.last?.bannerLinkMethod.value ?? 0
                url = bannerDtos.last?.bannerLinkMobile ?? ""
                title = bannerDtos.last?.bannerTitle ?? ""
                theDto = bannerDtos.last?.bannerLinkMethod.value == 3 ? (bannerDtos.last?.bannerPlayGame!)! : BannerPlayGameDto()
            } else if indexPath.row == bannerDtos.count + 1 {
                type = bannerDtos.first?.bannerLinkMethod.value ?? 0
                url = bannerDtos.first?.bannerLinkMobile ?? ""
                title = bannerDtos.first?.bannerTitle ?? ""
                theDto = bannerDtos.first?.bannerLinkMethod.value == 3 ? (bannerDtos.first?.bannerPlayGame!)! : BannerPlayGameDto()
            } else {
                type = bannerDtos[indexPath.row - 1].bannerLinkMethod.value
                url = bannerDtos[indexPath.row - 1].bannerLinkMobile ?? ""
                title = bannerDtos[indexPath.row - 1].bannerTitle
                theDto = bannerDtos[indexPath.row - 1].bannerLinkMethod.value == 3 ? bannerDtos[indexPath.row - 1].bannerPlayGame! : BannerPlayGameDto()
            }
        }
        return (url, type , title , theDto)
    }
    
    func collectionView(_ collectionView:UICollectionView, didSelectItemAt indexPath:IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        let link = getBannerLinkMethodType(indexPath: indexPath)
        onClick.onNext(link)
        select(index: indexPath.row)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView:UIScrollView) {
        handlePageIndex(scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handlePageIndex(scrollView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        addTimer()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dispose?.dispose()
    }
    private func handlePageIndex(_ scrollView:UIScrollView){
        guard let flowLayout = bannerCollectionView.collectionViewLayout as? BetLeadCarouseFlowLayout else {
            return
        }
        flowLayout.scrollViewDidEndDecelerating(scrollView)
        if flowLayout.rxCurrentPage.value == 0 {
            bannerCollectionView.scrollToItem(at: IndexPath(row: bannerDtos.count, section: 0), at: .centeredHorizontally, animated: false)
            flowLayout.rxCurrentPage.accept(bannerDtos.count)
        } else if flowLayout.rxCurrentPage.value == bannerDtos.count + 1 {
            bannerCollectionView.scrollToItem(at: IndexPath(row: 1, section: 0)    , at: .centeredHorizontally, animated: false)
            flowLayout.rxCurrentPage.accept(1)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        flowLayout.scrollViewDidScroll(scrollView)
    }
    
}

extension BannerCarouselView: BetLeadCarouselFlowLayoutDelegate {
    func select(index: Int) {
        
    }
}

