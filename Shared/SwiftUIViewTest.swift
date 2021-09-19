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

struct testObsStruct2: Codable, Identifiable {
    var data : String
    
    var id: UUID
}

struct testObsStruct: Codable, Identifiable {
    var data : [testObsStruct2]
    
    var id: UUID
}

class Manager: ObservableObject {
    @Published var data = testObsStruct(data: [], id: UUID())
    
    
    func add() {
        //        objectWillChange.send()
        data.data.append(
            testObsStruct2(data: "\(Int.random(in: 0..<1000))", id: UUID())
        )
    }
    
    func change(id: UUID) {
        let index = data.data.firstIndex(where : {
            $0.id == id
        })
        
        if (index != nil) {
            data.data[index!].data = "Hello World"
        }
    }
}

struct docuitest1 : View {
    @State var n = 0
    @ObservedObject var manager = Manager()
    
    var body : some View{
        VStack{
            HStack{
                Button(action: {
                    manager.add()
                }, label: {
                    Text("Add").padding()
                })
                VStack{
                    ForEach(manager.data.data, id: \.id){ i in
                        Text("\(i.data) \(i.id)")
                        docuitest(data: i, manager: manager)
                    }
                }
            }
        }
    }
}


struct docuitest : View {
     var data : testObsStruct2
    @ObservedObject var manager : Manager
    
    var body : some View{
        VStack{
            Button(action: {
                manager.change(id: data.id)
                
            }, label: {
                Text("\(data.data)")
            })
            
        }
    }
}

struct SwiftUIViewTest_Previews: PreviewProvider {
    static var previews: some View {
        //        SwiftUIViewTest()
        //        ContentView2()
        //        SwiftUIViewTest()
        docuitest1()
            .previewLayout(.sizeThatFits)
    }
}
