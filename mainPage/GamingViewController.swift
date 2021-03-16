//
//  GamingViewController.swift
//  betlead
//
//  Created by vanness wu on 2019/7/16.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import WebKit

fileprivate class LeakAvoider: NSObject, WKScriptMessageHandler {
    
    weak var delegate: WKScriptMessageHandler?
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

class GamingViewController: BaseViewController {
    var progressView:UIProgressView = UIProgressView()
    private lazy var contentWebView :WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        for method in Method.allCases {
            configuration.userContentController.add(LeakAvoider(delegate: self), name: method.rawValue)
        }
//        let source: String = "var meta = document.createElement('meta');" + "meta.name = 'viewport';" + "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" + "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);";
//        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//        configuration.userContentController.addUserScript(script)
        let webview = WKWebView(frame: self.view.frame, configuration: configuration)
        webview.navigationDelegate = self
        if UIDevice().userInterfaceIdiom == .phone
        {
            webview.customUserAgent = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.20 (KHTML, like Gecko) Mobile/7B298g"
        }else
        {
            webview.customUserAgent = "Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.10"
        }
        webview.addObserver(self, forKeyPath:"estimatedProgress", options: NSKeyValueObservingOptions.new, context:nil)
        return webview
    }()
    
    private let url:URL
    private let cancelBtn: AssistiveTouch = {
        let btn = AssistiveTouch()
        return btn
    }()
    
    init(url:URL) {
        self.url = url
        super.init()
    }
    
    deinit {
        print("gaming vc deinit.")
        contentWebView.configuration.userContentController.removeAllUserScripts()
        contentWebView.removeObserver(self, forKeyPath:"estimatedProgress")
        contentWebView.navigationDelegate = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupViews()
        bindBtn()
        setDeviceOrientation(.portrait)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        cancelBtn.updateOrigin(width: size.width, height: size.height)
        switch UIDevice.current.orientation{
        case .portrait:
            contentWebView.snp.updateConstraints { (maker) in
                maker.edges.equalTo(UIEdgeInsets(top: Views.statusBarHeight, left: 0, bottom: 0, right: 0))
            }
        case .landscapeRight:
            contentWebView.snp.updateConstraints { (maker) in
                maker.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
        case .landscapeLeft:
            contentWebView.snp.updateConstraints { (maker) in
                maker.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
        default:
            break
        }
        
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LoadingViewController.show()
        contentWebView.load(URLRequest(url: url))
    }
    
    func setDeviceOrientation(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
    
    private func setupViews(){
        view.addSubview(contentWebView)
        view.addSubview(cancelBtn)
        contentWebView.snp.makeConstraints { (maker) in
            
            maker.edges.equalTo(UIEdgeInsets(top: Views.statusBarHeight, left: 0, bottom: 0, right: 0))
        }
//        cancelBtn.snp.makeConstraints { (maker) in
//            maker.bottom.equalToSuperview().multipliedBy(0.8)
//            //.offset( Views.isIPhoneWithNotch() ? -(Views.tabBarHeight + 40) : -40)
//            maker.trailing.equalTo(-20)
//            maker.size.equalTo(CGSize(width: 52, height: 52))
//        }
        
        contentWebView.addSubview(progressView)
        
        progressView.snp.makeConstraints { (make)in
            make.width.equalToSuperview()
            make.height.equalTo(3)
            make.top.equalToSuperview()
        }
        progressView.tintColor = UIColor.red
        progressView.isHidden = true
    }
    
    private func bindBtn(){
        cancelBtn.mainButtonClick.subscribeSuccess { [weak self] _ in
             guard let self = self else { return }
            Beans.gameServer.retrieveAllGameMoney().subscribeSuccess { (isScuuess) in
                if isScuuess {
                    _ = LoadingViewController.action(mode: .success, title: "錢包收回成功")
                    WalletDto.update()
                } else {
                    _ = LoadingViewController.action(mode: .fail, title: "未知原因失敗")
                }
                }.disposed(by: self.disposeBag)
            self.dismiss(animated: true, completion: nil)
            self.setDeviceOrientation(.portrait)
//            AssistiveTouch.share.isHidden = true
        }.disposed(by: disposeBag)
    }
    
    override func observeValue(forKeyPath keyPath:String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        // 載入進度
        if keyPath == "estimatedProgress" {
            let newprogress = (change?[.newKey]!as! NSNumber).floatValue
            let oldprogress = (change?[.oldKey] as? NSNumber)?.floatValue ?? 0.0
            //已經盡量不要讓進度條倒著走...有時候goback會出現這種情況
            if newprogress < oldprogress {
                return
            }
            if newprogress == 1 {
                progressView.isHidden = true
                progressView.setProgress(0, animated:false)
            }
            else {
                progressView.isHidden = false
                progressView.setProgress(newprogress, animated:true)
            }
        }
    }
}
extension GamingViewController: WKNavigationDelegate{
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        _ = LoadingViewController.dismiss()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        _ = LoadingViewController.dismiss()
        progressView.isHidden = true
        progressView.setProgress(0, animated:false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        _ = LoadingViewController.dismiss()
        progressView.isHidden = true
        progressView.setProgress(0, animated:false)
    }
}
extension GamingViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        Beans.gameServer.retrieveAllGameMoney().subscribeSuccess { (isScuuess) in
            if isScuuess {
                _ = LoadingViewController.action(mode: .success, title: "錢包收回成功")
                WalletDto.update()
            } else {
                _ = LoadingViewController.action(mode: .fail, title: "未知原因失敗")
            }
            }.disposed(by: disposeBag)
        guard let method = Method(rawValue: message.name) else { return }
        switch method {
        case .app_service:
            LiveChatService.share.betLeadServicePresent()
        case .app_deposit:
            DeepLinkManager.share.handleDeeplink(navigation: .walletDeposit)
        case .app_mypage:
            DeepLinkManager.share.handleDeeplink(navigation: .member)
        default: break
        }
    }
}
