//
//  OneProjectView.swift
//  XPlaner
//
//  Created by Esther on 2021/9/10.
//

import SwiftUI


struct OneTaskView: View {
    var task : TaskInfo
    var index : Int
    @Binding var isEditingMode: Bool
    @Binding var seleted: Bool
    
    var action : ((_ : Bool) -> Void)? = nil
    
    let shadowOpacityMap : [TaskStatus : Double] = [
        .finished : 0,
        .todo : 1,
        .original : 0.5
    ]
    
    let lineWidthMap : [TaskStatus : Double] = [
        .finished : 0,
        .todo : 3,
        .original : 0.5
    ]
    
    var body: some View {
        VStack(){
            HStack{
                Text("\(index)")
                    .minimumScaleFactor(0.2)
                    .font(.footnote)
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24, alignment: .center)
                    .background(Color(red: 0.95, green: 0.8, blue: 0.5))
                    .clipShape(Circle())
                VStack(){
                    Text(task.name)
                        .font(.subheadline)
                        .foregroundColor(Color.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                    if task.status != .original {
                        Text(getSubTitleText()).font(.caption2)
                            .fontWeight(.light)
                            .foregroundColor(Color.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.2)
                    }
                }.frame(maxWidth: .infinity, maxHeight: 24)
            }.padding(6.0).background(Color.white)
            
            VStack(alignment: .center) {
                Text(task.content)
                    .font(.title2)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(6)
                    .minimumScaleFactor(0.4)
            }
        }
        .frame(width: 100, height: 100, alignment: .top)
        .background(Color.orange)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        //        .shadow(color: Color("ShallowShadowColor").opacity(shadowOpacityMap[status]!),
        //                radius: 6,
        //                x: 5, y: 5)
        .brightness(task.status == .finished ? -0.2 : 0)
        .blur(radius: task.status == .finished ? 10 : 0)
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(Color.accentColor, lineWidth: lineWidthMap[task.status]!)
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
                Text("删除 \(task.name) ")
                Image(systemName: "trash")
            })
        }
        .onTapGesture(count: 1) {
            action?(self.seleted)
        }
        
    }
    
    func getStatusText() -> String {
        switch self.task.status {
        case .finished:
            return "已完成"
        default:
            return ""
        }
    }
    
    func getSubTitleText() -> String {
        switch self.task.status {
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
    @EnvironmentObject var document : XPlanerDocument
    @Environment(\.undoManager) var undoManager
    
    var project : ProjectInfo
    var prjGrpId : UUID
    
    @Binding var isEditingMode: Bool
    var displayMode: DisplayMode
    @Binding var isSelected : Bool
    
    var body: some View {
        VStack(alignment: .leading){
            Section(header:HStack(alignment: .center){
                if isEditingMode {
                    Button(action:{
                        document.removeProject(idIs: project.id, from: prjGrpId, undoManager)
                    }){
                        // plus.app.fill
                        Image(systemName: "minus.circle.fill").imageScale(.large).foregroundColor(.red)
                    }.padding([.top, .trailing], 10)
                        .padding([.leading], 30)
                }
                
                Text(project.name)
                    .font(displayMode == .FullSquareMode ? .title : .title3)
                    .padding([.top, .trailing], 10)
                    .padding([.leading], 30)
                    .contextMenu{
                        Button(action: {
                            document.removeProject(idIs: project.id, from: prjGrpId, undoManager)
                        }, label: {
                            Text("删除任务 \(project.name) ")
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
                                ForEach(project.tasks.indices){ i in
                                    GeometryReader{geoTask in
                                        OneTaskView(
                                            task: project.tasks[i],
                                            index: i,
                                            isEditingMode: $isEditingMode,
                                            seleted: $isSelected,
                                            
                                            action: { selected in
                                                
                                            }
                                        )
                                            .padding()
                                            .coordinateSpace(name: "task\(i)")
                                            .rotation3DEffect(
                                                isEditingMode ? .zero :
                                                    Angle(degrees: min(
                                                        (Double(geoTask.frame(in: .named("task\(i)")).minX)) /  15,
                                                        45)
                                                         ) , axis: (x:-0.1, y: -0.3, z: 0))
                                        //                                            .onTapGesture {
                                        //                                                proxy.scrollTo(i+1, anchor: .topLeading)
                                        //                                            }
                                            .animation(.spring(response: 0.8, dampingFraction: 0.3))
                                        //                                    Text("\(Int(geoTask.frame(in: .global).minX))")
                                        
                                    }
                                }.frame(maxWidth: .infinity).frame(height: 140)
                                
                                if isEditingMode {
                                    Button(action: {
                                        
                                    }, label: {
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
                                missionsWithStatus: project.tasks
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
    @State static var simpleMode = DisplayMode.FullSquareMode
    @State static var isSelected = false
    @State static var project = ProjectInfo(
        name: "ProjectName",
        tasks: [TaskInfo](
            arrayLiteral:
                TaskInfo(name: "任务1",content: "任务内容1",status: .finished,createDate: Date(), id: UUID()),
            TaskInfo(name: "任务2",content: "任务内容2",status: .todo,createDate: Date(), id: UUID()),
            TaskInfo(name: "任务3",content: "任务内容3",status: .original,createDate: Date(), id: UUID())
        ))
    
    @State static var status1 = TaskStatus.finished
    @State static var status2 = TaskStatus.todo
    @State static var status3 = TaskStatus.original
    
    static var previews: some View {
        OneProjectView(project: project, prjGrpId: UUID(), isEditingMode: self.$isEditing, displayMode: simpleMode, isSelected: $isSelected)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            .frame(width: 1000)
        HStack {
            OneTaskView(task: TaskInfo(name: "TaskName", content: "Content", status: status1, createDate: Date()), index: 1000, isEditingMode: $isEditing, seleted: $isSelected)
            OneTaskView(task: TaskInfo(name: "TaskName", content: "LongContent1231231231231231231231231231", status: status2, createDate: Date()), index: 1, isEditingMode: $isEditing, seleted: $isSelected)
            OneTaskView(task: TaskInfo(name: "TaskName", content: "✰🤣", status: status3, createDate: Date()), index: 100000, isEditingMode: $isEditing, seleted: $isSelected)
            
            
        }.previewLayout(.sizeThatFits).padding()
    }
}
