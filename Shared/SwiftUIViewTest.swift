//
//  SwiftUIViewTest.swift
//  XPlaner
//
//  Created by Esther on 2021/9/14.
//

import SwiftUI

struct SwiftUIViewTest: View {
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                Button("Jump to #50") {
                    proxy.scrollTo(5, anchor: .top)
                }
                
                List(0..<100, id: \.self) { i in
                    Text("Example \(i)")
//                        .id(i)
                }
            }
        }
    }
}

// ForEach(0..<50000, id: \.self)

struct ContentView2: View {
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyHStack {
                    ForEach(0..<50, id: \.self) { i in
                        Button("Jump to \(i+5)") {
                            proxy.scrollTo(i+5)
                        }
//                        Text("Example \(i)")
//                            .id(i)
                    }
                }
            }
        }
    }
    
    
    
}

class Manager: ObservableObject {
    @Published var data = [1 ,2 ,3]
    
    
    func add() {
        objectWillChange.send()
        data.append(Int.random(in: 0..<1000))
    }
}

struct docuitest : View {
    @State var n = 0
    @ObservedObject var manager = Manager()
    
    var body : some View{
        VStack{
            Button(action: {
                manager.add()
            }, label: {
                Text("Add").padding()
            })
            
            ForEach(manager.data.indices, id: \.self){i in
                Text("\(manager.data[i])")
            }
        }
    }
}

struct SwiftUIViewTest_Previews: PreviewProvider {
    static var previews: some View {
//        SwiftUIViewTest()
//        ContentView2()
//        SwiftUIViewTest()
        docuitest()
            .previewLayout(.sizeThatFits)
    }
}
