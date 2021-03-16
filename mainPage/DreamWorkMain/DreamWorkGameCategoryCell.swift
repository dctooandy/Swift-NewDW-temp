//
//  DreamWorkGameCategoryCell.swift
//  DreamWork
//
//  Created by Victor on 2019/10/15.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
protocol DreamWorkGameCategoryCellDelegate {
    func gameDidClick(gameGroupDtos:[GameGroupDto] , id:Int , index:Int)
}

class DreamWorkGameCategoryCell: UITableViewCell {
    lazy var delegate: DreamWorkGameCategoryCellDelegate? = nil
    private let disposeBag = DisposeBag()
    private let shadowView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.clipsToBounds = false
        return v
    }()
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.clipsToBounds = true
        return v
    }()
    private let bgView = UIView()
    private let categoryMenu = DreamWorkCategoryMenu(gameTypes: [])
    private var gameTypes = [GameTypeDto]()
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let cv =  UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cv.registerCell(type: GameCollectionViewCell.self)
        return cv
    }()
    
    private var selectedIndex = 0 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                Beans.matomoServer.track(eventWithCategory: MCategory.GameClass.rawValue, action: MAction.Click.rawValue ,name: weakSelf.gameTypes[weakSelf.selectedIndex].gameTypeName_Mobile)
                weakSelf.collectionView.alpha = 0
                weakSelf.collectionView.transform = CGAffineTransform(translationX: -weakSelf.collectionView.bounds.width, y: 0)
                
                UIView.animate(withDuration: 0.3) {
                    // 執行動畫效果
                    // 將透明度改回 1，並取消所有的變形效果，回到原樣及位置。
                    weakSelf.collectionView.alpha = 1
                    weakSelf.collectionView.transform = CGAffineTransform.identity
                }
                weakSelf.collectionView.reloadData()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
        bindMenu()
        bindStyle()
    }
    
    func bindStyle() {
        Themes.dreamWorkCategoryShadowColor.bind(to: shadowView.layer.rx.shadowColor).disposed(by: disposeBag)
        Themes.dreamWorkCategoryBgColor.bind(to: bgView.rx.backgroundColor).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private lazy var collectionViewBg: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.09356039017, green: 0.1345116198, blue: 0.2056360245, alpha: 1)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    func setupUI() {
        backgroundColor = .clear
        contentView.addSubview(shadowView)
        shadowView.addSubview(bgView)
        shadowView.addSubview(containerView)
        containerView.addSubview(collectionViewBg)
        containerView.addSubview(collectionView)
        containerView.addSubview(categoryMenu)
        
        shadowView.applyShadow(color: .black, radius: 12, alpha: 0.3)
        shadowView.snp.makeConstraints { (make) in
            make.left.equalTo(22)
            make.right.equalTo(-22)
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
        }
        
        bgView.backgroundColor = .white
        bgView.applyCornerRadius(radius: 12)
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(10)
            make.right.bottom.equalTo(-10)
        }
        
        categoryMenu.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(containerView.snp.width).multipliedBy(0.2).offset(-3.2)
        }
        
        collectionViewBg.snp.makeConstraints { (make) in
            make.top.equalTo(categoryMenu.snp.bottom).offset(8)
            make.left.right.equalTo(categoryMenu)
            make.height.equalTo(height(144/812))
            make.bottom.equalToSuperview()
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(collectionViewBg)
        }
    }
    
    func setGameTypeData(data: [GameTypeDto]) {
        self.gameTypes = data
        categoryMenu.setGameGroupData(data: data)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1 , execute:
            {
                self.selectedIndex = 0
        })
    }
    
    func bindMenu() {
        categoryMenu.didClick().subscribeSuccess { [weak self] (index) in
            guard let weakSelf = self else { return }
            weakSelf.selectedIndex = index
        }.disposed(by: disposeBag)
    }
}

extension DreamWorkGameCategoryCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if gameTypes.count == 0 { return 0 }
        return gameTypes[selectedIndex].gameGroups.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueCell(type: GameCollectionViewCell.self, indexPath: indexPath)
        cell.setData(gameTypes[selectedIndex].gameGroups.data[indexPath.row])
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let baseHeight = height(124/812)

        let dto = gameTypes[selectedIndex].gameGroups.data[indexPath.item]
        guard let icon = dto.icon else {
            switch selectedIndex {
            case 0: // 體育
                return CGSize(width: baseHeight * 1.56, height: baseHeight)
            default:
                return CGSize(width: baseHeight * 0.96, height: baseHeight)
            }
        }
        
        return CGSize(width: baseHeight * (icon.size.width/icon.size.height), height: baseHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("dream work selected index: \(indexPath.item)")
        let groupData = gameTypes[selectedIndex].gameGroups.data
        let id = groupData[indexPath.item].id
        Beans.matomoServer.track(
            eventWithCategory: MCategory.EnterGame.rawValue,
            action: MAction.Click.rawValue ,
            name: groupData[indexPath.item].gameGroupName)
        delegate?.gameDidClick(gameGroupDtos: groupData, id: id, index: indexPath.item)
    }
    
    
}
