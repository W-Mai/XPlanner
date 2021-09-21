//
//  MyAnimations.swift
//  XPlaner
//
//  Created by Esther on 2021/9/15.
//

import SwiftUI

struct Bounce: AnimatableModifier {
    let animCount: Int
    var animValue: CGFloat
    var amplitude: CGFloat = 10  // 振幅
    
    init(animCount: Int) {
        self.animCount = animCount
        self.animValue = CGFloat(animCount)
    }
    
    var animatableData: CGFloat {
        get { animValue }
        set { animValue = newValue }
    }
    
    func body(content: Content) -> some View {
        let offset: CGFloat = -abs(sin(animValue * .pi * 2) * amplitude)
        return content.offset(y: offset)
    }
}

//
//struct BindingCollection<Base: MutableCollection & RandomAccessCollection>: RandomAccessCollection {
//    
//    typealias Element = Binding<Base>
//    typealias Index = Base.Index
//    
//    let base : Element
//    
//    subscript(position: Index) -> Element {
//        _read {
//            <#code#>
//        }
//    }
//    
//    var startIndex: Index
//    
//    var endIndex: Index
//    
//    func index(before i: Index) -> Index {
//        <#code#>
//    }
//    
//   
//    func index(before i: Index) -> Index {
//        <#code#>
//    }
//    
//   
//    
//}
