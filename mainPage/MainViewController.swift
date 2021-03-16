//
//  ViewController.swift
//  PreBetLead
//
//  Created by vanness wu on 2019/5/13.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import UPCarouselFlowLayout
import SnapKit
import RxCocoa
import RxSwift
import UserNotifications
import SafariServices
import SDWebImage
class MainViewController: BaseViewController {
   
    @IBOutlet weak var contentView:UIView!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var scrollViweTop: NSLayoutConstraint!
    @IBOutlet weak var contentViewWidth:NSLayoutConstraint!
    private let bgImageView:UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "main-bg")
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    private let navigationBarView = UIView()
    private var bannerDtos = [BannerDto]()
    private var gameTypeDtos = [GameTypeDto]() {
        didSet {
            tableView.reloadData()
            setMenuData()
        }
    }
    fileprivate var bannerTableViewCell = BannerTableViewCell()
    fileprivate let marqueeTableViewCell = MarqueeTableViewCell()
    private let signupLoginBtnView = SignupLoginButtonView()
    private lazy var walletAmountView = WalletAmountView()
    private var categoryMenu: CategoryMenu? = nil
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.decelerationRate = .fast
        tableView.registerCell(type: BannerTableViewCell.self)
        tableView.registerCell(type: MarqueeTableViewCell.self)
        tableView.registerCell(type: CategoryTableViewCell.self)
        return tableView
    }()
    var shouldFetchGameType: Bool = true
    
    // MARK: - life cycle
    init() {
        super.init()
        fetchCommonData()
        fetchBanner()
        fetchGameType()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fetchCommonData()
        fetchBanner()
        fetchGameType()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarView()
        bindWalletAmountView()
        setupTableView()
        setupSignupLoginBtnView()
        bindSignupLoginViewStatus()
        bindBanner()
        bindMarquee()
        contentView.backgroundColor = Themes.primeBackground
        view.backgroundColor = Themes.primeBackground
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindGameWalletData()
        updateSignupLoginViewStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNotificationAuth()
        if !shouldFetchGameType { return }
        fetchGameType()
        setMenuData()
        updateBanner()
        shouldFetchGameType = false
    }
    
    
    //MARK: - ui
    private func setupNavigationBarView() {
        contentView.addSubview(navigationBarView)
        navigationBarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Views.statusBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(Views.navigationBarHeight + 10)
        }
        
        let logo = UIImageView(image: UIImage(named: "icon-logo_home"))
        navigationBarView.addSubview(logo)
        logo.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(36)
            make.width.equalTo(94)
        }
        navigationBarView.addSubview(walletAmountView)
        walletAmountView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
        let bottomLine = UIView()
        bottomLine.backgroundColor = Themes.grayBase
        navigationBarView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setupSignupLoginBtnView() {
        navigationBarView.addSubview(signupLoginBtnView)
        signupLoginBtnView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftRightOffset(12/812))
            make.centerY.equalToSuperview()
        }
    }
    
    func setupTableView() {
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBarView.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func setupMenu() {
        contentView.addSubview(categoryMenu!)
        categoryMenu!.snp.makeConstraints { (make) in
            make.top.equalTo(Views.statusBarHeight)
            make.left.equalToSuperview()
        }
    }
    
    private var menuOriginY: CGFloat = 0
    private var tmpOffsetY: CGFloat = 0 // for menu mask view
    func setMenuData() {
        if gameTypeDtos.isEmpty { return }
        if categoryMenu == nil {
            categoryMenu = CategoryMenu()
            contentView.addSubview(categoryMenu!)
            bindMenu()
            categoryMenu?.setup(data: gameTypeDtos)
        }
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        
        // update menu y position
        let top = (cell?.frame.origin.y ?? Views.navigationBarHeight) + tableView.frame.origin.y
        categoryMenu?.snp.updateConstraints { (make) in
            make.top.equalTo(top)
        }
        categoryMenu?.setupMask()
        menuOriginY = top
    }
    
    func updateBanner() {
        if bannerDtos.isEmpty { return }
        bannerTableViewCell.setData(data: bannerDtos)
    }
    
    // MARK: - bind
    func bindBanner() {
        bannerTableViewCell.bannerDidSelected()
            .subscribeSuccess { [weak self] (linkMethodType) in
            guard let strongSelf = self else { return }
            let urlString = linkMethodType.0
            let method = linkMethodType.1
            if urlString == "" {
                print("banner url is empty la!")
                return
            }
            strongSelf.showBannerAd(urlString: urlString, method: method)
        }.disposed(by: disposeBag)
    }
    
    func bindMenu() {
        categoryMenu?.rxClick()
            .subscribeSuccess { (tag) in
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath(row: tag + 2, section: 0), at: .top, animated: true)
                }
            }.disposed(by: disposeBag)
    }
    func bindMarquee() {
        marqueeTableViewCell.rx.selectedMarquee
            .subscribeSuccess { [weak self] (newDto) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    NewsDetailBottomSheet(marqueeDto: newDto).start(viewController: strongSelf)
                }
        }.disposed(by: disposeBag)
    }
    
    private func bindSignupLoginViewStatus() {
        signupLoginBtnView.rxClick().subscribeSuccess { (isLogin) in
            DispatchQueue.main.async() {
                UIApplication.shared.keyWindow?.rootViewController =  LoginSignupViewController.share.isLogin(isLogin)
            }
        }.disposed(by: disposeBag)
    }
    
    private func updateSignupLoginViewStatus() {
        signupLoginBtnView.isHidden = UserStatus.share.isLogin
    }
    
    private func bindGameWalletData() {
        if !UserStatus.share.isLogin {
            walletAmountView.snp.remakeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-10)
                make.height.equalTo(20)
                make.width.equalTo(0)
            }
            return
        }
        walletAmountView.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
        
        WalletDto.rxShare.subscribeSuccess { [weak self] (dto) in
            guard let amount = dto?.amount else { return }
            self?.walletAmountView.setAmount(amount)
        }.disposed(by: disposeBag)
    }
    
    private func bindWalletAmountView() {
        walletAmountView.rx.click
            .subscribeSuccess { (_) in
                print("wallet amount click")
                DeepLinkManager.share.handleDeeplink(navigation: .memberShowWallet)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - fetch data
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
    
    private func fetchCommonData(){
        Beans.bankCodeServer.getBankList().subscribeSuccess { (bankDtos) in
            Beans.banks = bankDtos
            }.disposed(by: disposeBag)
    }
    
    private func  requestNotificationAuth() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (status, error) in
            if (!status || error != nil)  && UserStatus.share.isLogin{
                Beans.memberServer.updateNotice(parameters: ["deposit_broadcast" : 0 ,
                                                             "withdraw_broadcast" : 0 ,
                                                             "promotion_broadcast" : 0])
                    .subscribeSuccess({ (noticeDto) in
                        print(noticeDto)
                    }).disposed(by: self.disposeBag)
            }
        }
        
    }
    private func fetchBanner(){
        Beans.bannerServer.frontendBanner()
            .subscribeSuccess {[weak self] (bannerDtos, paginiationDto) in
                guard let weakSelf = self else { return }
                weakSelf.bannerDtos = bannerDtos
                weakSelf.bannerTableViewCell.setData(data: bannerDtos)
            }.disposed(by: disposeBag)
    }
    
    func showMaintainAlert(){
        UIApplication.topViewController()?.showAlert(title: "贴心小提示", message: "游戏维护中，请稍后再进入")
    }
    
    private var tmpY: CGFloat = 0 // for menu position
    func updateMenu(_ contentOffsetY: CGFloat) {
        let diff = contentOffsetY - tmpY
        tmpY = contentOffsetY
        var topOffset = categoryMenu!.frame.minY - diff
        if topOffset <= navigationBarView.frame.maxY { return }
        if diff < 0 {
            if menuOriginY - contentOffsetY - navigationBarView.frame.maxY < 0 { return }
            topOffset = menuOriginY - contentOffsetY
        }
        categoryMenu?.snp.updateConstraints { (make) in
            make.top.equalTo(topOffset)
        }
        categoryMenu?.layoutIfNeeded()
    }
}

extension MainViewController:UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer:UIGestureRecognizer) -> Bool {
        print(gestureRecognizer)
        return true
    }
}

// MARK: - tableView delegate & dataSource
extension MainViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + gameTypeDtos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: return bannerTableViewCell // banner cell
        case 1: return marqueeTableViewCell // news cell
        default:
            //games
            let categoryCell = tableView.dequeueCell(type: CategoryTableViewCell.self, indexPath: indexPath)
            categoryCell.tag = indexPath.row
            categoryCell.delegate = self
            categoryCell.setTitle(gameTypeDtos[indexPath.row - 2].gameTypeName_Mobile)
            if gameTypeDtos.count > 0 {
                categoryCell.setGameGroupData(data: gameTypeDtos[indexPath.row - 2])
            }
            return categoryCell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateMenu(scrollView.contentOffset.y)
        caculateSelectedCell(scrollView)
    }
   
    // 計算顯示在畫面上的遊戲分類去移動menu的mask view
    func caculateSelectedCell(_ scrollView: UIScrollView) {
        tmpOffsetY = scrollView.contentOffset.y
        var cells = tableView.visibleCells.filter({$0.tag > 0})
        if cells.isEmpty { return }
        if cells.count <= 3 {//顯示在畫面上小於三個時
            var tags = cells.map({$0.tag - 2})
            if tags.count < 3 {
                for i in tags.count - 1..<2 {
                   let next = tags[i]
                    tags.append(next + 1)
                }
            }
            categoryMenu?.moveMask(tags: tags)
            return
        }
        if cells.count == 5 { // 5個分類都顯示在畫面上時
            var tags = cells.map({$0.tag - 2})
            tags.removeFirst()
            tags.removeLast()
            categoryMenu?.moveMask(tags: tags)
            return
        }
        // 檢查前後兩個cell顯示在畫面上的面積
        let removeCellIndex = getVisibleLessCellIndex(cells: cells)
        cells.remove(at: removeCellIndex)
        var tags = cells.map({$0.tag - 2})
        if tags.count > 3 {
            if (scrollView.contentOffset.y - tmpOffsetY) >= 0 { // scroll to top
                tags.removeFirst()
            } else {
                tags.removeLast()
            }
        }
        categoryMenu?.moveMask(tags: tags)
    }
    
    func getVisibleLessCellIndex(cells: [UITableViewCell]) -> Int {
        // 檢查前後兩個cell顯示在畫面上的面積
        let tableViewMaxY = tableView.contentOffset.y + tableView.frame.height
        var tmpCell: (Int, CGFloat)? = nil // index and height
        let firstCell = cells.first!
        let visibleHeight = firstCell.frame.height - (tableView.contentOffset.y - firstCell.frame.minY)
        tmpCell = (0, visibleHeight)
        if tmpCell != nil {
            let lastCell = cells.last!
            let visibleHeight = tableViewMaxY - lastCell.frame.minY
            if visibleHeight < tmpCell!.1 {
                tmpCell = (cells.count - 1, visibleHeight)
            }
        }
        return tmpCell!.0
    }
    
    func showBannerAd(urlString: String, method: Int) {
        print("link method: \(method), url: \(urlString)")
        if method == 1 { // pop web view
            let webBottomSheet = WebViewBottomSheet()
            webBottomSheet.urlString = urlString
            webBottomSheet.start(viewController: self)
        } else if method == 2 { // open safari
            guard let url = URL(string: urlString) else { return }
            UIApplication.shared.open(url)
        }
    }
}

extension MainViewController: CategoryTableViewCellDelegate, Gamingable {
    func categoryCellDidClick(gameGroupDtos: [GameGroupDto], id: Int, index: Int) {
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
