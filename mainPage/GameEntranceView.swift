//
//  GameEntranceView.swift
//  PreBetLead
//
//  Created by vanness wu on 2019/5/20.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import SDWebImage
class GameEntranceView:UIView {
    private let imageView = UIImageView()
    private let companyIcon = UIImageView(image: UIImage(named: "game-entrance"))
    private let companyIconBottomOffset:CGFloat =  Views.isIPhoneWithNotch() ? 40 : 30
    private let companyIconHeight:CGFloat = 20
    var gameGroupDto:GameGroupDto?
    init(){
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(){
        imageView.contentMode = .scaleAspectFit
        companyIcon.contentMode = .scaleAspectFit
        companyIcon.alpha = 0.0
        addSubview(imageView)
        addSubview(companyIcon)
        imageView.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.width.equalTo(self.frame.width)
            maker.height.equalTo(self.frame.height)
//            maker.edges.equalToSuperview()//.equalTo(UIEdgeInsets.zero)
        }
        companyIcon.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.size.equalTo(CGSize(width: 60, height: 20))
            maker.bottom.equalTo(-companyIconBottomOffset)
        }
    }
    
    func configureView(dto:GameGroupDto) {
        self.gameGroupDto = dto
        imageView.sdLoad(with: URL(string: dto.gameVi_Before) )
        
        self.companyIcon.sdLoad(with: URL(string: dto.gameLogo_Mobile) ,completed: { [weak self] _ in
            self?.companyIcon.setImageTintColor(UIColor.white.withAlphaComponent(0.4))
        })
        let img = UIImageView()
        img.sdLoad(with: URL(string: dto.gameVi_After))
    }
    
    func animateIcon(progress:CGFloat , distance:CGSize) {
        companyIcon.transform =  CGAffineTransform(translationX: distance.width * progress,
                                                   y: (distance.height + companyIconBottomOffset + companyIconHeight/2 ) * progress)
        
    }
    func resizeImageView(isBlack:Bool) {
        let baseHeight = frame.height
        let baseWidth = frame.width
        let scale: CGFloat = 1.5
        imageView.snp.updateConstraints { (maker) in
            if isBlack {
                maker.width.equalTo(baseWidth * scale)
                maker.height.equalTo(baseWidth * scale)
            } else {
                maker.width.equalTo(baseWidth)
                maker.height.equalTo(baseHeight)
            }
        }
    }
    
    func setImage(isBlack:Bool) {
        guard let dto = gameGroupDto else {return}
        if isBlack {
            imageView.sdLoad(with: URL(string: dto.gameVi_After) )
        } else {
            imageView.sdLoad(with: URL(string: dto.gameVi_Before) )
        }
    }
    
    func calculateState(radians:CGFloat ,distance:CGSize){
        let isBehindHalf = -sin(radians) < 0.5
        let progress = isBehindHalf ? 0 : (-sin(radians) - 0.5)*2
        setImage(isBlack: isBehindHalf)
        resizeImageView(isBlack: isBehindHalf)
        animateIcon(progress: progress, distance:  distance)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        let alphaInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: alphaInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        self.layer.render(in: context!)
        
        let floatAlpha = CGFloat(pixel[3])
        return floatAlpha > 0
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        return  super.hitTest(point, with: event)
    }
}
