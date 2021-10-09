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

//struct docuitest1 : View {
//    @State var n = 0
//    @ObservedObject var manager = Manager()
//    @GestureState var isLongPressed = false //用于刷新长按手势的状态
//    @State var isEnded = false
//
//    @State var str = ""
//    @State var str2 = ""
//    @State var status = ""
//
//    var body: some View {
//        let longPressGesture = LongPressGesture(minimumDuration: 1) //初始化一个长按手势，该手势一旦识别到长按的触摸状态，就会调用手势的结束事件。您甚至可以限制长按手势的时间长度
//            .updating($isLongPressed) { value, state, transcation in //通过调用updating方法，监听手势状态的变化
//                print(value, state, transcation)
//                state = value
//
//                str += "1"
//                isEnded = false
//            }
//            .onEnded { (value) in
//                str += "2"
//                isEnded = true
//            }
//            .onChanged { _ in
//                str += "3"
//            }
//
//        return Circle()
//            .fill(Color.orange)
//            .frame(width: 240, height: 240)
//
//            .overlay(
//                List{
//                    Text(str)
//                    Text(str2)
//                    Text(status)
//
//                }
//                    .onChange(of: isLongPressed, perform: { V in
//                        if !isLongPressed {
//                            status = isEnded ? "Loong Pressed" : "Tap Once"
//                        }
//                        str2 += isEnded.description
//                    })
//            )
//
//            .gesture(longPressGesture)
//            .scaleEffect(isLongPressed ? 1.4 : 1)
//
//
//            .animation(.default)
//
//    }
//    //    var body : some View{
//    //        VStack{
//    //            HStack{
//    //                Button(action: {
//    //                    manager.add()
//    //                }, label: {
//    //                    Text("Add").padding()
//    //                })
//    //                VStack{
//    //                    ForEach(manager.data.data, id: \.id){ i in
//    //                        Text("\(i.data) \(i.id)")
//    //                        docuitest(data: i, manager: manager)
//    //                    }
//    //                }
//    //            }
//    //        }
//    //    }
//}

struct GestureView: UIViewRepresentable {
    let callback: () -> Void

    func makeUIView(context: UIViewRepresentableContext<GestureView>) -> UIView {
        let view = UIView(frame: .zero)
        let gesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.action))
        gesture.delegate = context.coordinator
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GestureView>) {}

    class Coordinator: NSObject {
        let callback: () -> Void

        init(callback: @escaping () -> Void) {
            self.callback = callback
        }

        @objc func action(_ sender: UIPanGestureRecognizer) {
            
            if sender.state == .began {
                callback()
            }
            if sender.state == .changed{
                callback()
            }
        }
    }

    func makeCoordinator() -> GestureView.Coordinator {
        Coordinator(callback: callback)
    }
}

extension GestureView.Coordinator: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}


struct docuitest1 : View {
    @State var n = 0
    @ObservedObject var manager = Manager()
    @GestureState var isLongPressed = false //用于刷新长按手势的状态
    @State var isEnded = false
    
    @State var str = ""
    @State var str2 = ""
    @State var status = ""
    
    var body: some View {
        VStack {
            Text(status)
            ScrollView(.horizontal) {
                    HStack {
                        ForEach(0 ..< 15) { item in
                            RoundedRectangle(cornerRadius: 25.0)
                                .frame(width: 125, height: 200)
                                .padding(.horizontal)
//                                .overlay(
//                                    GestureView(callback: { status += "Long" })
//                                )
                                .onTapGesture {
                                    status += "Tap"
                                }
                                .onLongPressGesture(minimumDuration: 0.2, pressing: { v in
                                    status += "l"
                                }, perform: {
                                    status += "k"
                                })
                        }
                    }
            }
        }
        }
//    var body: some View {
//        let longPressGesture = TapGesture()
//            .updating($isLongPressed) { value, state, transcation in //通过调用updating方法，监听手势状态的变化
//                print(value, state, transcation)
////                state = sta
//
//                str += "1"
//                isEnded = false
//            }
//            .onEnded({ _ in
//                status += "Tap"
//            })
//
//            .simultaneously(with:
//
//                                LongPressGesture(minimumDuration: 0.4, maximumDistance: 0.2)
//                    .updating($isLongPressed, body: { val, sta, trans in
//                        sta = val
//                    })
//                    .onEnded({ _ in
//                        status += "LongPress"
//                    })
//            )
//
//        return ScrollView{
//            Circle()
//                .fill(Color.orange)
//                .frame(width: 240, height: 240)
//
//                .overlay(
//                    List{
//                        Text(str)
//                        Text(str2)
//                        Text(status)
//                    }
//                )
//
////                .gesture(longPressGesture)
////                .onLongPressGesture(minimumDuration: 1, pressing: { v in
////                    isEnded = v
////                }, perform: {
////                    status = "LongPress"
////                    isEnded = false
////                })
//                .overlay(GestureView(callback: {
//                    isEnded = true
//                }))
//                .scaleEffect(isEnded ? 1.4 : 1)
//
//
//                .animation(.default)
//        }


    }
    //    var body : some View{
    //        VStack{
    //            HStack{
    //                Button(action: {
    //                    manager.add()
    //                }, label: {
    //                    Text("Add").padding()
    //                })
    //                VStack{
    //                    ForEach(manager.data.data, id: \.id){ i in
    //                        Text("\(i.data) \(i.id)")
    //                        docuitest(data: i, manager: manager)
    //                    }
    //                }
    //            }
    //        }
    //    }
//}

struct docuitest : View {
    var data : testObsStruct2
    @ObservedObject var manager : Manager
    
    var body : some View{
        VStack{
            Section(header: HStack{
                Color.black
                
            }){
                Color.blue
            }
            
            Button(action: {
                manager.change(id: data.id)
                
            }, label: {
                Text("\(data.data)")
            })
            
        }
    }
}

struct MyStruct: Codable, Identifiable {
    var duration: TimeInterval
    
    var id = UUID()
}

struct newTest : View {
    let text = (1...30).map{"Hello\($0)"}
    //以最小宽度160斤可能在一行放入grid
    let columns = [GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top), GridItem(.flexible(), alignment: .top)]
    
    @State var show = true
    @State var task = MyStruct(duration: 3600)
    @State var task1 = TaskInfo(name: "", content: "", status: .finished, duration: 3600, createDate: Date())
    @State var time = TimeInterval(3600)
    
    var body: some View {
        ZStack{
        HStack{
            Button(action: {show = true}, label: {
                Text("Button")
            })
        }
            if(show){
                VStack{
                    Button(action: {
                        task.duration += 1000
                        task1.duration -= 100
                        print(task.duration)
                    }, label: {
                        Text("\(task.duration)")
                        Text("\(task1.duration)")
                    })
//                    MyCountDownPicker(val: $time)
                }
                .padding()
//                .frame(width: 100, height: 30, alignment: .center)
                .background(Color.white)
                
//                .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            }
        }
        
        
//        ScrollView{
//            Section(header: Text("最小160")){
//                LazyVGrid(columns: [GridItem(.flexible(), alignment: .top)], spacing: 20, pinnedViews: [.sectionHeaders]){
//                    ForEach(text, id: \.self){ item in
//                        Section(header:
//                                    Text("fuck\(item)")
//                        ) {
//                            LazyVGrid(columns: columns, spacing: 20, pinnedViews: [.sectionHeaders]){
//                                ForEach(0..<2){i in
//                                    Section(header:
//                                                VStack{
//                                                    Text("okkkk\(i)")
//                                                }.padding([.top], 30)
//                                    ) {
//                                        ForEach(0..<5){j in
//                                            Text(item)
//                                                .frame(width: CGFloat.random(in: 20..<100), height: CGFloat.random(in: 20..<100))
//                                                .foregroundColor(.white)
//                                                .background(Color.blue)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    
}

struct SwiftUIViewTest_Previews: PreviewProvider {
    static var previews: some View {
        //        SwiftUIViewTest()
        //        ContentView2()
        //        SwiftUIViewTest()
        //        docuitest1()
        newTest()
//            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
