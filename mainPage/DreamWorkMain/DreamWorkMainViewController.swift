//
//  DreamWorkMainViewController.swift
//  DreamWork
//
//  Created by Victor on 2019/10/9.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DreamWorkMainViewController: BaseViewController {
    private let backgroundImageView = UIImageView()
    fileprivate let marqueeTableViewCell = MarqueeTableViewCell()
    fileprivate var bannerTableViewCell = BannerTableViewCell()
    fileprivate var activityTableViewCell = ActivityTableViewCell()
    fileprivate var dreamWorkGameCategoryCell = DreamWorkGameCategoryCell()
    private let mainNavigationBar = MainNavigationBar()
    private let navigationBarView = UIView()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.decelerationRate = .fast
        tableView.backgroundColor = .clear
        tableView.bounces = false
        tableView.registerCell(type: BannerTableViewCell.self)
        tableView.registerCell(type: MarqueeTableViewCell.self)
        tableView.registerCell(type: ActivityTableViewCell.self)
        tableView.registerCell(type: DreamWorkGameCategoryCell.self)
        return tableView
    }()
    private var bannerDtos = [BannerDto]()
    var gameTypeDtos = [GameTypeDto]() {
        didSet {
            dreamWorkGameCategoryCell.setGameTypeData(data: gameTypeDtos)
        }
    }
    var shouldFetchGameType: Bool = true
    static let share = DreamWorkMainViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        bindViewModel()
        setupUI()
        bindDreamWorkStyle()
        bindBanner()
        bindMarquee()
        bindCheckInButton()
        bindStyle()
//        fetchBanner()
//        fetchGameType()
        dreamWorkGameCategoryCell.delegate = self
//        viewModel.doCombineAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMainNavBar()
        checkTimer()
        bannerTableViewCell.setBannerToDefault()
    }
    
    func bindStyle() {
        Themes.dreamWorkBgImage.bind(to: backgroundImageView.rx.image).disposed(by: disposeBag)
    }
    
    func setupUI(){
        
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        view.addSubview(mainNavigationBar)
        mainNavigationBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Views.statusBarHeight)
            make.left.equalToSuperview().offset(22)
            make.right.equalToSuperview().offset(-22)
        }
        setupTableView()
    }
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(mainNavigationBar.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    // MARK: - bind
    func bindMarquee() {
        marqueeTableViewCell.rx.selectedMarquee
            .subscribeSuccess { [weak self] (newDto) in
                guard let weakSelf = self else { return }
                DispatchQueue.main.async {
                    if newDto.newsTitle != "暂无公告资料"
                    {
                        Beans.matomoServer.track(
                            eventWithCategory: MCategory.Announcement.rawValue,
                            action: MAction.Click.rawValue ,
                            name: newDto.newsTitle)
                        NewsDetailBottomSheet(marqueeDto: newDto).start(viewController: weakSelf)                        
                    }
                }
        }.disposed(by: disposeBag)
    }
    func bindCheckInButton()
    {
        marqueeTableViewCell.rx.selectedCheckInBtn
                 .subscribeSuccess { [weak self] (urlString) in
                    DispatchQueue.main.async {
                    guard let weakSelf = self ,UserStatus.share.isLogin else{
                        self!.present(LoginAlert(), animated: true, completion: nil)
                        return}
                        Beans.matomoServer.track(
                        eventWithCategory: MCategory.HomeLink.rawValue,
                        action: MAction.Click.rawValue ,
                        name: "每日签到")
                        weakSelf.present(BetLeadWebViewController(urlString), animated: true)
                    }
             }.disposed(by: disposeBag)
        
    }
    func bindBanner() {
        bannerTableViewCell.bannerDidSelected()
            .subscribeSuccess { [weak self] (linkMethodType) in
                guard let strongSelf = self else { return }
                let urlString = linkMethodType.0
                let method = linkMethodType.1
                let title = linkMethodType.2
                let dto = linkMethodType.3
                Beans.matomoServer.track(
                    eventWithCategory: MCategory.Banner.rawValue,
                    action: MAction.Click.rawValue,
                    name: title )
                if urlString == "" {
                    print("banner url is empty la!")
                    return
                }
                strongSelf.showBannerAd(urlString: urlString, method: method , dto:dto)
        }.disposed(by: disposeBag)
    }
    
    func showBannerAd(urlString: String, method: Int , dto : BannerPlayGameDto) {
        print("link method: \(method), url: \(urlString)")
//        if method == 1 { // pop web view
//            let webBottomSheet = WebViewBottomSheet()
//            webBottomSheet.urlString = urlString
//            webBottomSheet.start(viewController: self)
//        } else if method == 2 { // open safari
//            guard let url = URL(string: urlString) else { return }
//            UIApplication.shared.open(url)
//        }

        if method == 3 { // pop view
            
            DeepLinkManager.share.parserUrlFromBroeser(URL(string: urlString + "?id=\(dto.gameGroupId ?? 0)&id2=\(dto.gameId ?? 0)"))
        }else
        {
            DeepLinkManager.share.parserUrlFromBroeser(URL(string: urlString))
        }
    }
    
    private func updateMainNavBar() {
        mainNavigationBar.isLogin(UserStatus.share.isLogin)
    }
    
    // MARK: fetch data
    func bindViewModel()
    {
        BaseAPIViewModel.share.homeBannerDtos
            .subscribeSuccess { [weak self] (bannerDtos) in
                Log.v("request api homeBannerDtos")
                guard let weakSelf = self else { return }
                weakSelf.bannerDtos = bannerDtos
                weakSelf.bannerTableViewCell.setData(data: bannerDtos)
                
        }.disposed(by: disposeBag)
        BaseAPIViewModel.share.homeGameTypeDtos
            .subscribeSuccess { [weak self] (gameTypeDtos) in
                Log.v("request api homeGameTypeDtos")
                guard let weakSelf = self else { return }
                for i in gameTypeDtos {
                    i.gameGroups.data.forEach({$0.fetchGameIcon()})
                }
                weakSelf.gameTypeDtos = gameTypeDtos
        }.disposed(by: disposeBag)
    }
    func fetchBanner(){
        Beans.bannerServer.frontendBanner()
            .subscribeSuccess {[weak self] (bannerDtos, paginiationDto) in
                guard let weakSelf = self else { return }
                weakSelf.bannerDtos = bannerDtos
                weakSelf.bannerTableViewCell.setData(data: bannerDtos)
        }.disposed(by: disposeBag)
    }
    
    private func fetchGameType() {
        Beans.gameServer.getGameType()
            .subscribeSuccess {[weak self] (gameTypeDtos) in
                guard let weakSelf = self else { return }
                for i in gameTypeDtos {
                    i.gameGroups.data.forEach({$0.fetchGameIcon()})
                }
                weakSelf.gameTypeDtos = gameTypeDtos
        }.disposed(by: disposeBag)
    }
    func checkTimer()
    {
        checkRedEnvelopeCount()
        checkGuessGameTime()
    }
    func checkGuessGameTime()
    {
        activityTableViewCell.viewModel.checkGuessGameTime()
    }
    func checkRedEnvelopeCount()
    {
        activityTableViewCell.viewModel.checkRedEnvelopeCount()
    }
    func invalidateActivityTableViewCellTimer()
    {
        activityTableViewCell.viewModel.stopRETimer()
        activityTableViewCell.viewModel.stopGGTimer()
    }
}


// MARK: - TableView Delegate Datasource
extension DreamWorkMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return marqueeTableViewCell // news cell
        case 1: return bannerTableViewCell // banner cell
        case 2: return dreamWorkGameCategoryCell // game category cell
        case 3: return activityTableViewCell //activity cell
        default: return UITableViewCell()
        }
    }
    func showMaintainAlert(){
        UIApplication.topViewController()?.showAlert(title: "贴心小提示", message: "游戏维护中，请稍后再进入")
    }
}

extension DreamWorkMainViewController: DreamWorkGameCategoryCellDelegate, Gamingable {
    func gameDidClick(gameGroupDtos: [GameGroupDto], id: Int, index: Int) {
        guard let selectedGameGroup = gameGroupDtos.filter({ $0.id == id }).first,
            selectedGameGroup.isAvailable
            else {return}
        if selectedGameGroup.gameGroupStatus ?? 1 == 2 {
            showMaintainAlert()
        } else {
            if selectedGameGroup.isEnterGameList {
                let gamelistGroup = gameGroupDtos//.filter{ $0.isEnterGameList}
                let newVC = GameViewController(isNavBarTransparent: true, gameGroupDtos: gamelistGroup, groupId: id)
                newVC.view.backgroundColor = .white
                navigationController?.pushViewController(newVC, animated: true)
            } else {
                enterGame(game_group_id: id, game_id: 0)
            }
        }
    }
}
