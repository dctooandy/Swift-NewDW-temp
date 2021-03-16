//
//  ActivityTableViewCellViewModel.swift
//  DreamWork
//
//  Created by Andy Chen on 2019/11/20.
//  Copyright © 2019 vanness wu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ActivityTableViewCellViewModel:BaseViewModel{
    var bonusCountDtos:[BonusCountDto] = []
    var guessBetDtos:[GuessBetDto] = []
    var reCountString = BehaviorSubject<String>(value: "今日剩余0次")
    var reTimeTitleString = BehaviorSubject<String>(value: "下次时间")
    var reTimeString = BehaviorSubject<String>(value: "00:00:00")
    var ggTimeTitleString = BehaviorSubject<String>(value: "剩余时间")
    var ggTimeString = BehaviorSubject<String>(value: "")
    var timer: Timer?
    var betTimer: Timer?
    static var titleChangeflag = false
    static let share = ActivityTableViewCellViewModel()
    override init() {
        super.init()
        checkTimerForModelView()
    }
    func checkTimerForModelView()
    {
        checkRedEnvelopeCount()
//        checkGuessGameTime()
    }
    func checkGuessGameTime()
    {
            Beans.pointServer.getDWGuessBetData().subscribeSuccess{ [weak self] (dtos) in
                guard let strongSelf = self ,dtos.count > 0 else {
                    self!.renewGGCountText("今日竞猜已结束，明日请早〜")
                    self!.ggTimeString.onNext("")
                    return }
//封印 如果Coming這隻API回傳不只一場賽事,則時間需要先處理
//                let formatter = DateFormatter()
//                formatter.dateFormat = "YYYY/MM/dd HH:mm"
//                var components = DateComponents()
//                components.setValue(-1, for: .hour)
//                let timeArray = dtos.filter(
//                {
//                    Calendar.current.date(byAdding: components, to: (formatter.date(from: ($0.date )))!)!.compare(Date()) == .orderedDescending  }).map({ return $0.date
//                    })
                self!.renewGGCountText("下次时间")
                strongSelf.startGuessBetCountDown(dateString: dtos.first!.date)
                
            }.disposed(by: disposeBag)
     
    }
    func checkRedEnvelopeCount()
    {
        if UserStatus.share.isLogin == true
        {
            Beans.pointServer.getDWBonusCount().subscribe(onSuccess: { [weak self] (dtos) in
                guard let strongSelf = self else { return }
                strongSelf.bonusCountDtos = dtos
                let bonusDto = strongSelf.bonusCountDtos.first
                strongSelf.renewRECountText(bonusDto)
                strongSelf.startToCountDown()
            }) { (error) in
                self.renewRECountText(nil)
                self.startToCountDown()
                ErrorHandler.show(error: error)
            }.disposed(by: disposeBag)
        }else
        {
            renewRECountText(nil)
            startToCountDown()
        }
    }
    func renewGGCountText(_ testString:String)
    {
        ggTimeTitleString.onNext("\(testString)")
    }
    func renewRECountText(_ bonusDto:BonusCountDto?)
    {
        reCountString.onNext("今日剩余\(bonusDto?.count ?? 0)次")
        Log.v("\n今日剩餘搶紅包次數: \(bonusDto?.count ?? 0) ")
    }
    func stopRETimer()
    {
        timer?.invalidate()
        timer = nil
    }
    func stopGGTimer()
    {
        betTimer?.invalidate()
        betTimer = nil
    }
    func startGuessBetCountDown(dateString dString : String) {
        stopGGTimer()
//        guard  else {return}
        // 競猜結束時間為比賽開始時間前一個小時
        let timeComponents = DateHelper.share.getNextGuessBetTime(dString)
        if timeComponents == nil ||
            (timeComponents?.hour)! < 0 ||
            (timeComponents?.minute)! < 0 ||
            (timeComponents?.second)! < 0
        {
            checkGuessGameTime()
            return
        }
        var totalSecond = 0
        let hourInt = (timeComponents?.hour)!*60*60
        let minInt = (timeComponents?.minute)!*60
        let secInt = timeComponents?.second
        totalSecond = hourInt+minInt+secInt!
        
        var betCountInt = totalSecond

        betTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            guard let strongSelf = self else { return }
            betCountInt -= 1
            DispatchQueue.main.async {

//                let theHour = betCountInt > 3600 ? betCountInt/(60*60) : 0
//                let theMin = (betCountInt - theHour*60*60) > 60 ? (betCountInt - theHour*60*60)/(60) : 0
//                let theSec = (betCountInt - theHour*60*60 - theMin*60)

                strongSelf.ggTimeString.onNext(strongSelf.intTransString(betCountInt))

                if betCountInt <= 0 {
                    timer.invalidate()
                    strongSelf.checkGuessGameTime()
                }
            }
        }
        betTimer?.fire()
    }
    func startToCountDown() {
        stopRETimer()
        guard let timeIntArray = DateHelper.share.getNextRETime() else {return}
        var countInt = timeIntArray.first!
        let isFever = Bool(truncating: timeIntArray.last! as NSNumber)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            guard let strongSelf = self else { return }
            countInt -= 1
            DispatchQueue.main.async {

                strongSelf.reTimeString.onNext(strongSelf.intTransString(countInt ,with: isFever))
                strongSelf.reTimeTitleString.onNext(isFever ? "剩余时间: " : "下次时间: ")

                if countInt == 0 {
                    timer.invalidate()
                    strongSelf.checkRedEnvelopeCount()
                }
            }
        }
        timer?.fire()
        }
    func intTransString(_ seconds:Int ,with fever:Bool = false) -> String
        {
            var hours = 0
            var mins = 0
            var secs = seconds
            if seconds >= 60 {
                mins = Int(seconds / 60)
                secs = seconds - (mins * 60)
            }
            if mins >= 60
            {
                hours = Int(mins / 60)
                mins = mins - (hours * 60)
            }
            
            let theHourString = (hours == 0 ? "00":(hours < 10 ? "0\(hours)":"\(hours)"))
            let theMinString = (mins == 0 ? "00":(mins < 10 ? "0\(mins)":"\(mins)"))
            let theSecString = (secs == 0 ? "00":(secs < 10 ? "0\(secs)":"\(secs)"))
    //        Log.v("Test : \(theHourString):\(theMinString):\(theSecString)")
            // faver time 需要顯示秒數
//            return fever ? "\(theHourString):\(theMinString)" : "\(theHourString):\(theMinString):\(theSecString)"
            return "\(theHourString):\(theMinString):\(theSecString)"
        }
}

