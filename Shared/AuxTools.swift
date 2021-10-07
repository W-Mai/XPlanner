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
