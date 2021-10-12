//
//  BindingCollection.swift
//  XPlanner
//
//  Created by W-Mai on 2021/9/22.
//

import SwiftUI

/// A helper that converts a binding to a collection of elements into a collection of bindings to the individual elements.
struct BindingCollection<Base: MutableCollection & RandomAccessCollection>: RandomAccessCollection {
    let base: Binding<Base>

    typealias Element = Binding<Base.Element>
    typealias Index = Base.Index

    var startIndex: Index {
        base.wrappedValue.startIndex
    }

    var endIndex: Index {
        base.wrappedValue.endIndex
    }

    subscript(position: Base.Index) -> Binding<Base.Element> {
        Binding(get: {
            base.wrappedValue[position]
        }, set: {
            var result = base.wrappedValue
            result[position] = $0
            base.wrappedValue = result
        })
    }

    func index(before index: Base.Index) -> Base.Index {
        base.wrappedValue.index(before: index)
    }
    func index(after index: Base.Index) -> Base.Index {
        base.wrappedValue.index(after: index)
    }
}
