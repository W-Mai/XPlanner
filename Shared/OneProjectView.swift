//
//  OneProjectView.swift
//  XPlaner
//
//  Created by Esther on 2021/9/10.
//

import SwiftUI


struct OneTaskView: View {
    var title: String
    var content: String
    var index: Int
    @Binding var isEditingMode: Bool
    
    var status: TaskStatus = .original
    @Binding var seleted: Bool
    
    var body: some View {
        VStack{
            HStack{
                Text("\(index)").font(.footnote)
                    .frame(width: 24, height: 24, alignment: .center)
                    .foregroundColor(.white).background(Color(red: 0.95, green: 0.8, blue: 0.5))
                    .cornerRadius(15)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                VStack(){
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(Color.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                    if status != .original {
                        Text(getSubTitleText()).font(.caption2)
                            .fontWeight(.light)
                            .foregroundColor(Color.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.2)
                        
                    }
                }.frame(maxHeight: 24)
                Spacer()
            }.padding(6.0).background(Color.white).frame(height: 36)
            
            Spacer()
            Text(content)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .padding(8)
                .minimumScaleFactor(0.3)
            Spacer()
        }
        .frame(width: 100, height: 100, alignment: .center)
        .background(Color.orange)
        .cornerRadius(15)
        .shadow(color: Color(hue: 1.0, saturation: 0.0, brightness: 0.718, opacity: status == .finished ? 0 : status == .todo ? 1 : 0.5),
                radius: 6,
                x: 5, y: 5)
        .brightness(status == .finished ? -0.2 : 0)
        .blur(radius: status == .finished ? 2.6 : 0)
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color.accentColor, lineWidth: status == .todo ? 1 : 0)
        )
        .overlay(
            Text(getStatusText())
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(Color.black)
                .lineLimit(1)
                .padding()
                .minimumScaleFactor(0.3)
        )
        .overlay(
            Group{
                if isEditingMode {
                    Image(systemName: "trash.slash").resizable().scaleEffect(0.6).foregroundColor(.white)
                    
                }
            }
        )
        .scaleEffect(seleted ? 0.8 : 1)
        .animation(.easeInOut(duration: 0.2))
        .contextMenu{
            Button(action: {
                
            }, label: {
                Text("删除 \(title) ")
                Image(systemName: "trash")
            })
        }
        .onTapGesture(count: 1) {
            seleted.toggle()
            
        }
        
    }
    
    func getStatusText() -> String {
        switch self.status {
        case .finished:
            return "已完成"
        default:
            return ""
        }
    }
    
    func getSubTitleText() -> String {
        switch self.status {
        case .finished:
            return "✔︎"
        case .todo:
            return "Todo"
        case .original:
            fallthrough
        default:
            return ""
        }
    }
}

struct OneProjectView: View {
    var projectName: String = ""
    var tasks: [String]
    
    @Binding var isEditingMode: Bool
    @Binding var displayMode: DisplayMode
    @Binding var isSelected : Bool
    
    var body: some View {
        VStack(alignment: .leading){
            Section(header:HStack(alignment: .center){
                if isEditingMode {
                    Button(action:{
                        
                    }){
                        // plus.app.fill
                        
                        Image(systemName: "minus.circle.fill").imageScale(.large).foregroundColor(.red)
                        
                    }.padding([.top, .trailing], 10)
                    .padding([.leading], 30)
                }
                
                Text(projectName).font(displayMode == .FullSquareMode ? .title : .title3)
                    .padding([.top, .trailing], 10)
                    .padding([.leading], 30)
                    .contextMenu{
                        Button(action: {
                            
                        }, label: {
                            Text("删除任务 \(projectName) ")
                            Image(systemName: "trash")
                        })
                    }
                
            }
            ){
                switch self.displayMode {
                case .FullSquareMode:
                    ScrollView(.horizontal, showsIndicators:false){
                        ScrollViewReader{proxy in
                            HStack(spacing: 120){
                                ForEach(0..<15, id: \.self){ i in
                                    GeometryReader{geoTask in
                                        OneTaskView(title: "任务\(i) \(UUID())",content:"\(projectName)\(i)", index: i, isEditingMode: $isEditingMode, status: i < 4 ? .finished : i < 6 ? .todo : .original, seleted: $isSelected)
                                            .padding()
                                            .coordinateSpace(name: "task\(i)")
                                            .rotation3DEffect(
                                                isEditingMode ? .zero :
                                                    Angle(degrees: min(
                                                            (Double(geoTask.frame(in: .named("task\(i)")).minX)) /  15,
                                                            45)
                                                    ) , axis: (x: 1, y: 1.0, z: 0))
                                            //                                            .onTapGesture {
                                            //                                                proxy.scrollTo(i+1, anchor: .topLeading)
                                            //                                            }
                                            .animation(.spring(response: 0.8, dampingFraction: 0.3))
                                        //                                    Text("\(Int(geoTask.frame(in: .global).minX))")
                                        
                                    }
                                }.frame(maxWidth: .infinity).frame(height: 140)
                                
                                if isEditingMode {
                                    Button(action: {}, label: {
                                        VStack{
                                            Image(systemName: "plus.square").resizable().foregroundColor(.blue)
                                        }.padding(20)
                                        .frame(width: 80, height: 80, alignment: .center)
                                        .cornerRadius(16)
                                        .shadow(color: Color(hue: 0.8, saturation: 0.0, brightness: 0.718, opacity: 0.5), radius: 6, x: 5, y: 5)
                                    })}
                            }.padding([.trailing], 120)
                        }
                    }
                case .SimpleProcessBarMode:
                    HStack{
                        ProgressView(value: 1)
                            .progressViewStyle(MyProgressStyle(
                                missionsWithStatus:
                                    [TaskInfo].init(repeating: TaskInfo(name: "", content: "" ,status: .finished, createDate: Date()), count: 4) + [TaskInfo].init(repeating: TaskInfo(name: "",content:  "" ,status: .todo, createDate: Date()), count: 3) + [TaskInfo].init(repeating: TaskInfo(name: "",content: "" ,status: .original, createDate: Date()), count: 8)
                            ))
                    }.padding([.horizontal])
                    .padding([.vertical], 5)
                    
                }
                
            }
        }
    }
    func getSometing(){
        
    }
}

struct OneProjectView_Previews: PreviewProvider {
    
    @State static var isEditing = false
    @State static var simpleMode = DisplayMode.SimpleProcessBarMode
    @State static var isSelected = false
    
    static var previews: some View {
        OneProjectView(projectName: "ProjectName", tasks: [String](), isEditingMode: self.$isEditing, displayMode: $simpleMode, isSelected: $isSelected)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            .frame(width: 1000)
        HStack {
            OneTaskView(title: "TaskName",content: "Content", index: 1000, isEditingMode: $isEditing, seleted: $isSelected)
            OneTaskView(title: "TaskName",content: "Content", index: 1000, isEditingMode: $isEditing, status: .finished, seleted: $isSelected)
            OneTaskView(title: "TaskName",content: "✰🤣", index: 1000, isEditingMode: $isEditing, status: .todo, seleted: $isSelected)
        }.previewLayout(.sizeThatFits).padding()
    }
}
