//
//  GameEntranceCell.swift
//  PreBetLead
//
//  Created by vanness wu on 2019/5/21.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
protocol GameEntranceCellDelegate:class {
    func enterGame(index:Int , id:Int)
}

class GameEntranceCell:UICollectionViewCell {
   
    enum Direction {
        case right
        case left
    }
    private let disposeBag = DisposeBag()
    private let transformLayer = CATransformLayer()
    private var currentAngel:CGFloat  = 0
    private var currentOffset:CGFloat = 0
    private var index = 0
    private let transFormeLayerWidth:CGFloat = 300
    private let transFormeLayerHeight:CGFloat = 300
    private var direction = Direction.left
    weak var delegate:GameEntranceCellDelegate?
    private var gameGroupDtos = [GameGroupDto]()
    private var selectedGameEntranceDto:GameGroupDto? {
        didSet {
            //            gameBtn.setTitle(selectedGameEntranceDto?.title, for: .normal)
        }
    }
    private var baseAngle:CGFloat {
        if gameGroupDtos.count == 2 {
             return CGFloat(240)
        }
        return CGFloat(270)
    }
    private var segmentGameCard:CGFloat {
        let c = gameGroupDtos.count == 0 ? 1 : gameGroupDtos.count
        return CGFloat(360/c)
    }
    private var gameViews = [GameEntranceView]()
    private let backgroundImageView = UIImageView()
    private lazy var nextBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "chevron-right-blue"), for: .normal)
        btn.addTarget(self, action: #selector(nextGame), for: .touchUpInside)
        return btn
    }()
    private lazy var previousBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "chevron-left-blue"), for: .normal)
        btn.addTarget(self, action: #selector(previousGame), for: .touchUpInside)
        return btn
    }()
    private lazy var gameBtn:UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.setBackgroundImage(UIImage(named: "gameBtn-bg") , for: .normal)
        btn.addTarget(self, action: #selector(enterGame), for: .touchUpInside)
        return btn
    }()
    private let placeholderIcon:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.tintColor = .white
        img.applyShadow(color: .white)
        return img
    }()
    private let gameTitle:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.applyShadow(color:.white)
        return label
    }()
    
    private let rxTurn = PublishSubject<(CGFloat,CGFloat)>()
    private let leftGap:CGFloat = 74
    private var animateSize = CGSize.zero
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setupViews()
        setupTransFormLayer()
        setupPanGesture()
        setupBtn()
    }
    func setEntrance(gameTypeDto:GameTypeDto ,index:Int) {
        self.index = index
        gameViews.forEach({$0.removeFromSuperview()})
        gameViews = []
        currentAngel = 0
        currentOffset = 0
        let gameGroups = gameTypeDto.gameGroups.data
        let isHideSideBtn = gameGroups.count == 1
        nextBtn.isHidden = isHideSideBtn
        previousBtn.isHidden = isHideSideBtn
        self.gameGroupDtos = gameGroups
        for (index,gameGroupDto) in gameGroupDtos.enumerated() {
            addGameCard(dto: gameGroupDto, tag: index)
        }
        selectedGameEntranceDto = gameGroups.first
        turnCarousel()
        bindRxTurn()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
    }
    private func setupPanGesture(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self
        contentView.addGestureRecognizer(pan)
    }
    
    private func setupBtn(){
        contentView.addSubview(nextBtn)
        contentView.addSubview(previousBtn)
        contentView.addSubview(gameBtn)
        contentView.addSubview(placeholderIcon)
        contentView.addSubview(gameTitle)
        
        previousBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.leading.equalTo(74 + 18)
            maker.size.equalTo(CGSize(width: 15, height: 24) )
        }
        
        nextBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.trailing.equalTo(-18)
            maker.size.equalTo(CGSize(width: 15, height: 24) )
        }
        
        gameBtn.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview().offset(leftGap/2)
            maker.size.equalTo(CGSize(width: 140, height: 36))
            maker.bottom.equalTo(-10)
        }
        placeholderIcon.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(gameBtn)
            maker.size.equalTo(CGSize(width: 60, height: 20))
            maker.centerX.equalTo(gameBtn)
//            maker.leading.equalTo(gameBtn).offset(26)
        }
        gameTitle.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(gameBtn)
            maker.trailing.equalTo(gameBtn).offset(-20)
        }
        
    }
    
    private func setupTransFormLayer(){
        transformLayer.frame = contentView.bounds
        contentView.layer.addSublayer(transformLayer)
    }
    
    @objc private func enterGame(){
        guard let selectedDto = selectedGameEntranceDto 
            else {return}
        delegate?.enterGame(index:index, id:selectedDto.id)
    }
    private let transformsY:CGFloat = 50 * Views.getScaleByHeight(scale: .iphoneX)
    private let imageSize = CGSize(width: 168 * Views.getScaleByHeight(scale: .iphoneX) , height: 304 * Views.getScaleByHeight(scale: .iphoneX))
    
    private func addGameCard(dto:GameGroupDto , tag:Int){
        
        let gameView = GameEntranceView()
        layoutIfNeeded()
        let yPostition = gameBtn.frame.origin.y - imageSize.height - gameBtn.frame.height - (Views.isIPhoneWithNotch() ? 10 : -10)
        let xOffSet = gameGroupDtos.count == 2 ? Views.getScaleByHeight(scale: .iphoneX) * 50 : 0
        gameView.frame = CGRect(x: (Views.screenWidth + leftGap)/2 - imageSize.width/2 + xOffSet, y: yPostition + Views.getScaleByHeight(scale: .iphoneX) * 50, width: imageSize.width, height: imageSize.height)
        gameView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        gameView.configureView(dto: dto)
        gameView.layer.masksToBounds = true
        gameView.tag = tag
        let tap = UITapGestureRecognizer(target: self, action: #selector(didSelectGame))
        gameView.addGestureRecognizer(tap)
        contentView.addSubview(gameView)
        gameViews.append(gameView)
        if animateSize == CGSize.zero {
            animateSize = CGSize(width: gameView.center.x - placeholderIcon.center.x, height: placeholderIcon.center.y - gameView.center.y - imageSize.height/2)
        }
    }
    
    private func turnCarousel(isAnimated:Bool = false , secondAnimate:Bool = false ,isNext:Bool = false) {
        var angleOffset = currentAngel
        for gameView in gameViews {
            var transform = CATransform3DIdentity
            transform.m34 = -1/500
            
            let radians = degressToRadians(deg: angleOffset)
            let xOffset: CGFloat = gameGroupDtos.count == 2 ? 0 : 40
            transform = CATransform3DTranslate(transform, cos(radians)*(imageSize.width/2 + xOffset), -sin(radians) * 0, -sin(radians)*100 - 110)
            if isAnimated {
                if gameGroupDtos.count == 2 && secondAnimate {
                    var halfTransform = CATransform3DIdentity
                    let halfRadians = degressToRadians(deg: angleOffset + (isNext ? 90 : -90))
                    halfTransform = CATransform3DTranslate(halfTransform, cos(halfRadians)*200/2, -sin(halfRadians)*0.1*Views.screenHeight/2, -sin(halfRadians)*100 )
                    UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: .calculationModeCubic, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                            gameView.layer.transform = halfTransform
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                            gameView.layer.transform = transform
                        })
                    }, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                        gameView.layer.transform = transform
                    })
                }
            } else {
                
                gameView.layer.transform = transform
            }
            let iconRadians = degressToRadians(deg: angleOffset, deviation: gameViews.count == 2 ? 30 : 0)
            gameView.calculateState(radians:radians ,distance: animateSize)
            animateIcon(tag: gameView.tag, radians: iconRadians)
            angleOffset += segmentGameCard
        }
        setSelectedIndex()
    }
    
    private func animateIcon(tag:Int,radians:CGFloat){
        let isStartAnimate = -sin(radians) > 0.8
        if isStartAnimate {
            var progress = isStartAnimate ? (-sin(radians) - 0.8)*5 : 0
            progress = progress < 0.5 ? 0 : progress
            placeholderIcon.sdLoad(with: URL(string: selectedGameEntranceDto?.gameLogo_Mobile ?? "") ,completed: {[weak self] _ in
                self?.placeholderIcon.setImageTintColor(.white)
            })
            placeholderIcon.transform = CGAffineTransform(translationX: 0, y: 28 * (progress - 1))
            placeholderIcon.alpha = progress
        }
    }
    
    private func setSelectedIndex(){
        if gameGroupDtos.count == 0 { return }
        let intIndex = Int(round(currentAngel/segmentGameCard))%gameGroupDtos.count
        let selectedIndex = (intIndex > 0 ? gameGroupDtos.count  - intIndex : -intIndex)
        selectedGameEntranceDto = gameGroupDtos[selectedIndex]
        contentView.bringSubviewToFront(gameViews[selectedIndex])
    }
    
    @objc func didSelectGame(gesture:UIGestureRecognizer){
        guard let tag = gesture.view?.tag  else {return}
        var lastSelectedIndex = 0
        if let dto = selectedGameEntranceDto {
            lastSelectedIndex = gameGroupDtos.indexOfObject(object: dto)
            if tag == lastSelectedIndex{
                delegate?.enterGame(index:index, id:dto.id)
                return
            }
        }
        var angleOffset = CGFloat(lastSelectedIndex - tag)*segmentGameCard
        if abs(angleOffset) > 180 {
            angleOffset =  angleOffset + (angleOffset > 0 ? -360 : 360)
        }
        performTurning(startAngle: currentAngel, endAngle: currentAngel + angleOffset)
    }
    
    private func performTurning(startAngle:CGFloat , endAngle:CGFloat){
        let divide:CGFloat = startAngle > endAngle ? -3 : 3
        var count:Double = 0
        for angle in stride(from: startAngle, through: endAngle, by: divide) {
            DispatchQueue.main.asyncAfter(deadline: .now() + count * 0.005) {
                self.currentAngel = angle
                self.turnCarousel(isAnimated: false)
            }
            count += 1
        }
    }
    
    @objc func handlePan(gesture:UIPanGestureRecognizer){
        let xOffset = gesture.translation(in: contentView).x
        let xDiff = xOffset - currentOffset
        if xDiff > 0 {
            direction = .right
        }
        if xDiff < 0 {
            direction = .left
        }
       
        switch  gesture.state {
        case .began:
            currentOffset = 0
            currentOffset += xDiff
            currentAngel += xDiff/Views.screenWidth*360
            turnCarousel()
        case .changed:
            currentOffset += xDiff
            currentAngel += xDiff/Views.screenWidth*360
            turnCarousel()
        case .ended, .cancelled:
            currentOffset = 0
            let index = floor(currentAngel/segmentGameCard) + (direction == .right ? 1 : 0)
            performTurning(startAngle: currentAngel, endAngle: index * segmentGameCard)
        default:
            break
        }
    }
    @objc func nextGame() {
        rxTurn.onNext((currentAngel,currentAngel - segmentGameCard))
    }
    @objc func previousGame() {
        rxTurn.onNext((currentAngel,currentAngel + segmentGameCard))
    }
    private func bindRxTurn(){
        rxTurn.throttle(0.5,latest: false, scheduler: MainScheduler.instance).subscribeSuccess { (startAngle,endAngle) in
            self.performTurning(startAngle: startAngle, endAngle: endAngle)
            }.disposed(by: disposeBag)
    }
    
    
    func degressToRadians(deg:CGFloat, deviation: CGFloat = 0 ) -> CGFloat {
        return (deg + baseAngle + deviation)/180 * CGFloat.pi
    }
}

extension GameEntranceCell:UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer:UIGestureRecognizer) -> Bool {
        if gameGroupDtos.count == 1 { return false }
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: contentView)
            return abs(velocity.x) > abs(velocity.y)
        }
        return true
    }
}

