//
//  GameSearchingViewController.swift
//  betlead
//
//  Created by vanness wu on 2019/6/24.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit
import Toaster
import RxCocoa
import RxSwift
class GameSearchingViewController:GameBaseViewController {
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var backgroundImv: UIImageView!
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var topBgView:UIView!
    @IBOutlet weak var topBgImv: UIImageView!
    @IBOutlet weak var collectionView:UICollectionView!
    private var gameDtos = [GameDto]()
    private var filterGameDtos = [GameDto]()
    private var subject = PublishSubject<String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //topBgView.backgroundColor = Themes.grayDark
        setupSearchBar()
        setupCollectionView()
        bindStyle()
    }
    
    
    private func bindStyle() {
        Themes.dreamWorkNavigationBg.bind(to: topBgImv.rx.image).disposed(by: disposeBag)
        Themes.dreamWorkBgImage.bind(to: backgroundImv.rx.image).disposed(by: disposeBag)
        Themes.dreamWorkGrayDarkAndGrayLight.bind(to: resultTitleLabel.rx.textColor).disposed(by: disposeBag)
    }
    
    static func loadViewFromNib(groupId:String) -> GameSearchingViewController{
        let newVC = GameSearchingViewController.loadNib()
        newVC.groupId = groupId
        newVC.bindSearchBar()
        return newVC
    }
    private var dispose:Disposable?
    private func bindSearchBar(){
        guard let groupId = groupId else {return}
        dispose?.dispose()
        dispose = subject.asObserver().debounce(0.6, scheduler: MainScheduler.instance).flatMap({ text -> Single<[GameDto]> in
            return  Beans.gameServer.getNewGameList(game_group_id: groupId , keyword: text)
        })
            .subscribeSuccess {[weak self] (gameDtos) in
                guard let weakSelf = self else { return }
                weakSelf.filterGameDtos = gameDtos
                weakSelf.collectionView.reloadData()
        }
    }
    
    private func setupSearchBar(){
        searchBar.backgroundColor = .clear
        searchBar.setTextFieldColor(color: .white)
        searchBar.setTextFieldTextColor(color: Themes.grayDarker)
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.delegate = self
    }
    
    private func setupCollectionView(){
        let flowLayout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = flowLayout
        flowLayout.itemSize = CGSize(width: (Views.screenWidth - 24*2 - 16)/2, height: 132)
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 24, bottom: 0, right: 24)
        collectionView.registerXibCell(type: GameCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
    }
    
    override func fetchGameList(){
        guard let groupId = groupId else {return}
        Beans.gameServer.fetchGameList(gameType: .newest, game_group_id: groupId).subscribeSuccess { [weak self](gameDtos) in
            guard let weakSelf = self else { return }
            weakSelf.gameDtos = gameDtos
            weakSelf.filterGameDtos = gameDtos
            weakSelf.collectionView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    
}

extension GameSearchingViewController:UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        subject.onNext(searchText)
    }
}

extension GameSearchingViewController: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,Gamingable {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterGameDtos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: GameCell.self, indexPath: indexPath)
        let dto = filterGameDtos[indexPath.row]
        cell.configureCell(gameDto: dto)
        cell.rxLike().subscribeSuccess {[weak self] (_) in
            self?.handleLike(dto: dto)
            }.disposed(by: disposeBag)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let groupId = groupId ,
            let groupIdInt = Int(groupId)
            else {return}
        let dto = filterGameDtos[indexPath.row]
        enterGame(game_group_id: groupIdInt, game_id: dto.id)
    }
    
    
}
