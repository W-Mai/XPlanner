//
//  AuxTools.swift
//  XPlanner
//
//  Created by Esther on 2021/9/29.
//

import SwiftUI

func MyFeedBack(){
    let ifg = UIImpactFeedbackGenerator()
    ifg.prepare()
    ifg.impactOccurred()
}

extension UIView {
    public func setCornerRadius(cornerRadius:CGFloat, masksToBounds:Bool = true){
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = masksToBounds
    }

    public func setShadow(color:UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),
                          offset:CGSize = CGSize(width: 0, height: 3),
                          radius:CGFloat = 6,
                          opacity:Float = 0.3){
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = opacity
        self.layer.masksToBounds = false
    }
}

func index2date(index: Int) -> Date {
    let date = Date()
    let targetDate = Calendar.current.date(byAdding: Calendar.Component.day, value: -index, to: date)!
    return targetDate
}

func formatDateOnlyYMD(date: Date) -> Date {
    return Calendar.current.dateComponents([.year, .month, .day, .calendar], from: date).date!
}

func formatDateOnlyHMS(date: Date) -> DateComponents {
    return Calendar.current.dateComponents([.hour, .minute, .second], from: date)
}

func xlimit<T>(_ num: T, min a: T, max b: T) -> T where T:Comparable {
    return num < a ? a : num > b ? b : num
}

func OptBinding<T>(_ params: Binding<T?>, _ `default` : T) -> Binding<T> {
    return Binding<T> {
        params.wrappedValue ?? `default`
    } set: { res in
        params.wrappedValue = res
    }
}

func intervalToTimeStr(_ interval: TimeInterval, forFun: Bool) -> String {
    let hour: Int = xlimit(Int(interval / 3600), min: 0, max: 23)
    let minute: Int = xlimit(Int(fmod(interval, 3600) / 60), min: 0, max: 45)
    
    if forFun {
        let funClock = ["🕛", "🕐","🕑","🕒","🕓","🕔","🕕","🕖","🕗","🕘","🕙","🕚"]
        let funMinite = ["0⃣️0⃣️", "1️⃣5⃣️", "3⃣️0⃣️", "4⃣️5⃣️"]
        if minute == 0 {
            return "\(funClock[ hour % 12 ])"
        } else {
            return "\(funClock[ hour % 12 ]) \(funMinite[ Int(minute / 15) ])"
        }
    } else {
        return String(format: "%d h %d min", arguments: [hour, minute])
    }
}
