//
//  CatgoryTableViewCell.swift
//  betlead
//
//  Created by Victor on 2019/9/6.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
import SDWebImage
protocol CategoryTableViewCellDelegate {
    func categoryCellDidClick(gameGroupDtos:[GameGroupDto] , id:Int , index:Int)
}
class CategoryTableViewCell: UITableViewCell {
    lazy var delegate: CategoryTableViewCellDelegate? = nil
    private let leadingLine: UIView = {
        let v = UIView()
        v.backgroundColor = Themes.primaryBase
        return v
    }()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 20
        let cv =  UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.registerCell(type: GameCollectionViewCell.self)
        return cv
    }()
    
    private var type: Int = 0
    private var gameTypeDto: GameTypeDto? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setup()
    }
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
   
    func setGameGroupData(data: GameTypeDto) {
        gameTypeDto = data
        type = data.id
        collectionView.reloadData()
    }
    
    
    private func setup() {
        
        contentView.addSubview(leadingLine)
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)
        leadingLine.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(50)
            make.width.equalTo(3)
            make.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(leadingLine.snp_right).offset(10)
            make.centerY.equalTo(leadingLine)
            make.height.equalTo(20)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(leadingLine.snp_bottom).offset(10)
            make.left.equalTo(leadingLine)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview()
            make.height.equalTo(height(146/812))
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension CategoryTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameTypeDto?.gameGroups.data.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: GameCollectionViewCell.self, indexPath: indexPath)
        let data = gameTypeDto?.gameGroups.data[indexPath.item]
        cell.setData(data)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let baseHeight = height(146/812)
        guard let dto = gameTypeDto?.gameGroups.data[indexPath.item] else { return .zero }
        guard let icon = dto.icon else {
            switch type {
            case 1:
                return CGSize(width: baseHeight * 1.56, height: baseHeight)
            default:
                return CGSize(width: baseHeight * 0.96, height: baseHeight)
            }
        }
        return CGSize(width: baseHeight * icon.size.width/icon.size.height, height: baseHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dto = gameTypeDto else { return }
        let groupData = dto.gameGroups.data
        let id = groupData[indexPath.item].id
        delegate?.categoryCellDidClick(gameGroupDtos: groupData, id: id, index: indexPath.item)
    }
    
    
}
