//
//  ActivityTableViewCell.swift
//  DreamWork
//
//  Created by Victor on 2019/10/15.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class ActivityTableViewCell: UITableViewCell {

    let viewModel = ActivityTableViewCellViewModel()
    private let disposbleBag = DisposeBag()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI()
        setupGuessGameInnerUI()
        setupRedEnvelopeInnerUI()
        setupCartInnerUI()
        bindStyle()
        bindBtn()
        fetchWallet()
        fetchViewModel()
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

        // Configure the view for the selected state
    }
    let redEnvelopeIcon : UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "picRedenvelope")?.withRenderingMode(.alwaysOriginal)
        return imgView
    }()
    let redEnvelopeImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage.init().gradientImage(with: CGRect(x: 0, y: 0, width: 52, height: 52), colors: [#colorLiteral(red: 0.8080132008, green: 0.4029579163, blue: 0.1386047006, alpha: 1),#colorLiteral(red: 0.7755135894, green: 0.773876965, blue: 0.03570868447, alpha: 1)], locations: [0],makes: .vertical)
        imgView.layer.cornerRadius = 10
        imgView.layer.masksToBounds = true
           return imgView
    }()
    let redEnvelopeBGImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage.init().gradientImage(with: CGRect(x: 0, y: 0, width: 52, height: 52), colors: [#colorLiteral(red: 0.9759303927, green: 0.456674993, blue: 0.1027991548, alpha: 1),#colorLiteral(red: 0.9607843137, green: 0.9333333333, blue: 0, alpha: 1)], locations: [0],makes: .vertical)
        imgView.layer.cornerRadius = 10
        imgView.layer.masksToBounds = true
           return imgView
    }()
    let redEnvelopeImvBtn: UIButton = {
        let btn = UIButton()
        return btn
    }()
    let redEnvelopeNumberLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = #colorLiteral(red: 0.1043103561, green: 0.1358509958, blue: 0.1995867193, alpha: 1)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.boldSystemFont(ofSize:  height(17/818))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = "今日剩余4次"
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        return label
    }()
    let redEnvelopeTopLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .left
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.boldSystemFont(ofSize:  height(17/818))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = "领取限时红包"
     return label
    }()
    let redEnvelopeLeftLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .left
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.boldSystemFont(ofSize:  height(15/818))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = "下次时间: "
     return label
    }()
    let redEnvelopeTextLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.boldSystemFont(ofSize:  height(12/818))
//        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    let cartImvBtn: UIButton = {
        let imvBtn = UIButton()
        return imvBtn
    }()
    let cartCoverView: UIButton = {
        let coverBtn = UIButton()
        coverBtn.backgroundColor = UIColor.clear
        return coverBtn
    }()
    let cartPointView : UIView = {
        let view = UIView()
        view.applyCornerRadius(radius: 7.0)
        return view
    }()
    let cartFrontLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize:  height(15/818))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10
        label.text = "梦基金"
        return label
    }()
    let cartPointLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: height(15/818))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10
        label.textAlignment = .center
        label.text = "?"
        return label
    }()
    let cartEndLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize:  height(15/818))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 10
        label.textAlignment = .center
        label.text = "点"
        return label
    }()
    let guessGameImvBtn: UIButton = {
        let imvBtn = UIButton()
        return imvBtn
    }()
    let guessGameTopLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .left
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.boldSystemFont(ofSize:  height(17/818))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = "梦基金游戏竞猜"
     return label
    }()
    let guessGameLeftLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .left
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.boldSystemFont(ofSize:  height(15/818))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = "剩余时间 :"
     return label
    }()
    let guessGameTextLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.font = UIFont.boldSystemFont(ofSize:  height(12/818))
//        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    func bindStyle() {
        Themes.dreamWorkGuessGameImg.bind(to: guessGameImvBtn.rx.backgroundImage()).disposed(by: disposbleBag)
        Themes.dreamWorkCartImg.bind(to: cartImvBtn.rx.backgroundImage()).disposed(by: disposbleBag)
        Themes.dreamWorkCartBnP.bind(to: cartPointView.rx.backgroundColor).disposed(by: disposbleBag)
    }
    func setupUI() {
        contentView.addSubview(containerView)
        // 紅包
        redEnvelopeImvBtn.addSubview(redEnvelopeBGImageView)
        redEnvelopeImvBtn.addSubview(redEnvelopeImageView)
        redEnvelopeImvBtn.addSubview(redEnvelopeIcon)
        redEnvelopeImvBtn.addSubview(redEnvelopeNumberLabel)
        redEnvelopeImvBtn.addSubview(redEnvelopeTopLabel)
        redEnvelopeImvBtn.addSubview(redEnvelopeLeftLabel)
        redEnvelopeImvBtn.addSubview(redEnvelopeTextLabel)
        // 競猜
        guessGameImvBtn.addSubview(guessGameTopLabel)
        
        let ggStackView = UIStackView(arrangedSubviews: [guessGameLeftLabel, guessGameTextLabel])
        ggStackView.axis = .horizontal
        ggStackView.alignment = .top
        ggStackView.spacing = 5
        ggStackView.distribution = .fillProportionally
        guessGameImvBtn.addSubview(ggStackView)
        
        ggStackView.snp.makeConstraints { (make) in
            make.top.equalTo(guessGameTopLabel.snp.bottom)
            make.leading.equalTo(guessGameTopLabel.snp.leading)
            make.width.equalTo(width(130/414))
            make.height.equalTo(height(20/818))
        }
//        guessGameImvBtn.addSubview(guessGameLeftLabel)
//        guessGameImvBtn.addSubview(guessGameTextLabel)
        // 夢之城
        cartImvBtn.addSubview(cartPointView)
        cartPointView.addSubview(cartFrontLabel)
        cartPointView.addSubview(cartPointLabel)
        cartPointView.addSubview(cartEndLabel)
        cartImvBtn.addSubview(cartCoverView)
        
//        containerView.addSubview(redEnvelopeImvBtn)
//        containerView.addSubview(guessGameImvBtn)
//        containerView.addSubview(cartImvBtn)
        
        let stackView = UIStackView(arrangedSubviews: [redEnvelopeImvBtn, guessGameImvBtn, cartImvBtn])
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        containerView.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(Views.isIPad() ? 25 : 22)
            make.right.equalTo((Views.isIPad() ? -25 : -22))
            
        }
        redEnvelopeImvBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.left.right.equalToSuperview()
            make.height.equalTo(height(56/818))
        }
        guessGameImvBtn.snp.makeConstraints { (make) in
            make.top.equalTo(redEnvelopeImvBtn.snp.bottom).offset(8)
            make.centerX.size.equalTo(redEnvelopeImvBtn)
        }
        cartImvBtn.snp.makeConstraints { (make) in
            make.top.equalTo(guessGameImvBtn.snp.bottom).offset(12)
            make.centerX.width.equalTo(redEnvelopeImvBtn)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(height(48/818))
        }
    }
    func setupCartInnerUI()
    {
        cartCoverView.snp.makeConstraints { (make) in
            make.top.equalTo(cartImvBtn.snp.top)
            make.bottom.equalTo(cartImvBtn.snp.bottom)
            make.leading.equalTo(cartImvBtn.snp.leading)
            make.trailing.equalTo(cartImvBtn.snp.trailing)
        }
        cartPointView.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(height(7/818))
            make.bottom.equalToSuperview().offset(-height(7/818))
            make.leading.equalToSuperview().offset(width(40/414))
            make.width.equalTo((Views.screenWidth/2 - width(46/414)))
        }
        cartFrontLabel.snp.makeConstraints{ (make) in
            make.top.leading.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
            make.width.equalTo(width(55/414))
        }
        cartEndLabel.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
            make.trailing.equalToSuperview().offset(-width(10/414))
            make.width.equalTo(width(15/414))
        }
        cartPointLabel.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
            make.leading.equalTo(cartFrontLabel.snp.trailing)
            make.trailing.equalTo(cartEndLabel.snp.leading)
        }
    }
    func setupGuessGameInnerUI()
    {
        guessGameTopLabel.snp.makeConstraints{ (make) in
            make.centerY.equalToSuperview().offset(-width(15/818))
            make.centerX.equalToSuperview().offset(-width(25/414))
            make.width.equalTo(width(120/414))
            make.height.equalTo(height(20/818))
        }

        guessGameLeftLabel.snp.makeConstraints{ (make) in
//            make.top.equalTo(guessGameTopLabel.snp.bottom)
//            make.leading.equalTo(guessGameTopLabel.snp.leading)
//            make.width.equalTo(width(60/414))
            make.height.equalTo(height(20/818))
        }
        guessGameTextLabel.snp.makeConstraints{ (make) in
//            make.top.equalTo(guessGameTopLabel.snp.bottom)
//            make.leading.equalTo(guessGameLeftLabel.snp.trailing)
            make.width.equalTo(width(70/414))
            make.height.equalTo(height(20/818))
        }
    }
    func setupRedEnvelopeInnerUI()
    {
        redEnvelopeBGImageView.snp.makeConstraints{ (make) in
            make.leading.top.equalToSuperview().offset(2.0)
            make.trailing.bottom.equalToSuperview().offset(-2.0)
        }
        redEnvelopeImageView.snp.makeConstraints{ (make) in
            make.leading.top.equalToSuperview().offset(height(4/818))
            make.trailing.bottom.equalToSuperview().offset(-height(4/818))
        }
        redEnvelopeIcon.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset(-2)
            make.bottom.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(width(22/414))
            make.width.equalTo((height(56/818) * (62/56)))
        }
        redEnvelopeNumberLabel.snp.makeConstraints{ (make) in
            make.top.equalToSuperview().offset((height(56/818) * (10/56)))
            make.bottom.equalToSuperview().offset(-(height(56/818) * (10/56)))
            make.trailing.equalToSuperview().offset(-width(9/414))
            make.width.equalTo((height(56/818) * (108/56)))
            
        }
        redEnvelopeTopLabel.snp.makeConstraints{ (make) in
            make.centerY.equalToSuperview().offset(-width(15/818))
            make.centerX.equalToSuperview().offset(-width(25/414))
            make.width.equalTo(width(120/414))
            make.height.equalTo(height(20/818))
        }
        redEnvelopeLeftLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(redEnvelopeTopLabel.snp.bottom)
            make.leading.equalTo(redEnvelopeTopLabel.snp.leading)
            make.width.equalTo(width(60/414))
            make.height.equalTo(height(20/818))
        }
        redEnvelopeTextLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(redEnvelopeTopLabel.snp.bottom)
            make.leading.equalTo(redEnvelopeLeftLabel.snp.trailing)
            make.width.equalTo(width(70/414))
            make.height.equalTo(height(20/818))
        }
    }
    func bindBtn()
    {
        redEnvelopeImvBtn.rx.tap.subscribeSuccess { _ in
            DispatchQueue.main.async
                {
                    Beans.matomoServer.track(
                    eventWithCategory: MCategory.HomeLink.rawValue,
                    action: MAction.Click.rawValue ,
                    name: "红利")
                    guard let url = DWURLForPage.share.redEnvelope,
                        UserStatus.share.isLogin else
                    {
                        UIApplication.topViewController()?.present(LoginAlert(), animated: true)
                        return
                    }
                    UIApplication.topViewController()?.present(BetLeadWebViewController(url), animated: true)
                    
                    
                }
        }.disposed(by: disposbleBag)
        guessGameImvBtn.rx.tap.subscribeSuccess { _ in
            DispatchQueue.main.async
                {
                    Beans.matomoServer.track(
                    eventWithCategory: MCategory.HomeLink.rawValue,
                    action: MAction.Click.rawValue ,
                    name: "竞猜")
                guard let url = DWURLForPage.share.guessGame,
                    UserStatus.share.isLogin  else
                    {
                        UIApplication.topViewController()?.present(LoginAlert(), animated: true)
                        return
                    }
                UIApplication.topViewController()?.present(BetLeadWebViewController(url), animated: true)
            }
        }.disposed(by: disposbleBag)
        cartCoverView.rx.tap.subscribeSuccess { _ in
            DispatchQueue.main.async
                {
                    Beans.matomoServer.track(
                    eventWithCategory: MCategory.HomeLink.rawValue,
                    action: MAction.Click.rawValue ,
                    name: "梦之城")
                guard let url = DWURLForPage.share.cart,
                    UserStatus.share.isLogin  else
                    {
                        UIApplication.topViewController()?.present(LoginAlert(), animated: true)
                        return
                    }
                UIApplication.topViewController()?.present(BetLeadWebViewController(url), animated: true)
            }
        }.disposed(by: disposbleBag)
    }
    func fetchWallet() {
           WalletDto.rxShare.subscribeSuccess {[weak self] (walletDto) in
                guard let weakSelf = self ,
                      let walletDto = walletDto
                      else {
                        self!.cartPointLabel.text = "?"
                        return }
            weakSelf.cartPointLabel.text = UserStatus.share.isLogin ? String(walletDto.point).numberFormatterOnlyStyle(.decimal):"?"
           }.disposed(by: disposbleBag)
    }
    func fetchViewModel()
    {
        viewModel.reTimeString.subscribeSuccess {[weak self] (timeString) in
            guard let weakSelf = self else { return }
//            Log.v("剩餘時間 : \(timeString)")
            DispatchQueue.main.async {
                weakSelf.redEnvelopeTextLabel.text = timeString
            }
        }.disposed(by: disposbleBag)
        
        viewModel.reTimeTitleString.subscribeSuccess {[weak self] (timeTitleString) in
            guard let weakSelf = self else { return }
            weakSelf.redEnvelopeLeftLabel.text = timeTitleString
                }.disposed(by: disposbleBag)
        
        viewModel.reCountString.subscribeSuccess {[weak self] (countString) in
            guard let weakSelf = self else { return }
//            Log.v("剩餘次數 : \(countString)")
            weakSelf.redEnvelopeNumberLabel.text = countString
        }.disposed(by: disposbleBag)
        viewModel.ggTimeTitleString.subscribeSuccess{ [weak self] (titleString) in
            guard let weakSelf = self else { return }
            weakSelf.guessGameLeftLabel.text = titleString
        }.disposed(by: disposbleBag)
        viewModel.ggTimeString.subscribeSuccess {[weak self] (countString) in
            guard let weakSelf = self else { return }
//            Log.v("剩餘時間 : \(ggTimeString)")
            DispatchQueue.main.async {
                if countString == ""
                {
                    weakSelf.guessGameTextLabel.isHidden = true
                }else
                {
                    weakSelf.guessGameTextLabel.isHidden = false
                    weakSelf.guessGameTextLabel.text = countString
                }
            }
        }.disposed(by: disposbleBag)
    }
}
