//
//  OneProjectView.swift
//  XPlaner
//
//  Created by Esther on 2021/9/10.
//

import SwiftUI

struct OneProjectView_Previews: PreviewProvider {
    
    @State static var isEditing = false
    @State static var simpleMode = DisplayMode.FullSquareMode
    @State static var isSelected = false
    @State static var project = ProjectInfo(
        name: "ProjectName",
        tasks: [TaskInfo](
            arrayLiteral:
                TaskInfo(name: "任务1", content: "任务内容1", status: .finished, duration: DefalutTaskDuration, createDate: Date(), id: UUID()),
            TaskInfo(name: "任务2", content: "任务内容2", status: .todo, duration: DefalutTaskDuration, createDate: Date(), id: UUID()),
            TaskInfo(name: "任务2", content: "任务内容2", status: .todo, duration: DefalutTaskDuration, createDate: Date(), id: UUID()),
            TaskInfo(name: "任务2", content: "任务内容2", status: .todo, duration: DefalutTaskDuration, createDate: Date(), id: UUID()),
            TaskInfo(name: "任务2", content: "任务内容2", status: .todo, duration: DefalutTaskDuration, createDate: Date(), id: UUID()),
            TaskInfo(name: "任务2", content: "任务内容2", status: .todo, duration: DefalutTaskDuration, createDate: Date(), id: UUID()),
            TaskInfo(name: "任务3", content: "任务内容3", status: .original, duration: DefalutTaskDuration, createDate: Date(), id: UUID())
        ))
    
    @State static var status1 = TaskStatus.finished
    @State static var status2 = TaskStatus.todo
    @State static var status3 = TaskStatus.original
    
    static var previews: some View {
        OneProjectView(project: project, prjGrpId: UUID(), isEditingMode: self.$isEditing, displayMode: simpleMode, isSelected: $isSelected)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            .frame(width: 1000)
        
            .environmentObject(EnvironmentSettings(simpleMode: false, displayCategory: (DisplayCatagory.All)))
        HStack {
            OneTaskView(task: TaskInfo(name: "TaskName", content: "Content", status: status1, duration: DefalutTaskDuration, createDate: Date()), index: 1000, isEditingMode: $isEditing, seleted: $isSelected)
            OneTaskView(task: TaskInfo(name: "TaskName", content: "LongContent1231231231231231231231231231", status: status2, duration: DefalutTaskDuration, createDate: Date()), index: 1, isEditingMode: $isEditing, seleted: $isSelected)
            OneTaskView(task: TaskInfo(name: "TaskName", content: "✰🤣", status: status3, duration: DefalutTaskDuration, createDate: Date()), index: 100000, isEditingMode: $isEditing, seleted: $isSelected)
            OneTaskView(task: TaskInfo(name: "TaskName", content: "✰🤣", status: status3, duration: DefalutTaskDuration, createDate: Date()), index: 100000, isEditingMode: $isEditing, seleted: .constant(true))
            
            
        }.previewLayout(.sizeThatFits).padding()
    }
}



struct OneTaskView: View {
    var task: TaskInfo
    var index: Int
    @Binding var isEditingMode: Bool
    @Binding var seleted: Bool
    
    var action: ((_: Bool) -> Void)? = nil
    var longAction : (() -> Void)? = nil
    
    @GestureState var isDetectingLongPress = false
    @State var completedLongPress = false
    @State var currentState = false
    
    let shadowOpacityMap: [TaskStatus: Double] = [
        .finished: 0,
        .todo: 1,
        .original: 0,
        .show: 1
    ]
    
    let lineWidthMap: [TaskStatus: Double] = [
        .finished: 0,
        .todo: 3,
        .original: 0,
        .show: 2
    ]
    
    var body: some View {
        VStack() {
            HStack {
                VStack() {
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
        .frame(width: 80, height: 80, alignment: .top)
        .background(Color.orange)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        
        .drawingGroup()
        
        .brightness(task.status == .finished ? -0.2 : 0)
        //        .blur(radius: task.status == .finished ? 10 : 0)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(LinearGradient(gradient: Gradient(colors: [Color("FavoriteColor5").opacity(0.3), Color("FavoriteColor6")]), startPoint: .leading, endPoint: .bottom), lineWidth: CGFloat(lineWidthMap[task.status]!))
        )
        .overlay(
            HStack{
                VStack{
                    ZStack{
                        Color(red: 0.95, green: 0.8, blue: 0.5)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        Text( String(format: "%.1fh", task.duration / 3600) )
                            .fontWeight(.semibold)
                            .font(.footnote)
                            .minimumScaleFactor(0.2)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .padding(2)
                    }
                    .hueRotation(Angle(degrees: 10 * task.duration / 3600))
                    .rotationEffect(.degrees(-10))
                    .frame(width: 24, height: 16, alignment: .center)
                    Spacer()
                }
                Spacer()
            }.offset(x: -4, y: -6)
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
        
        .animation(.easeInOut(duration: 0.2))
        
        .scaleEffect(currentState ? 0.9 : 1)
        .animation(.easeInOut(duration: 0.5))
        .rotation3DEffect(Angle(degrees: task.status == .todo ? 10 : 0), axis: (1 , 0, 0))
        .offset(y: task.status == .todo ? -5 : 0)
//        .brightness(task.status == .todo ? -0.1 : 0)
        
        .overlay(
            Group {
                if isEditingMode {
                    Image(systemName: "trash.slash").resizable().scaleEffect(0.6).foregroundColor(.white)
                }
            }
        )
        
        .drawingGroup()
        .animation(.easeInOut(duration: 0.2))
        .onTapGesture {
            action?(seleted)
        }.onLongPressGesture(minimumDuration: 0.1, pressing: { v in
            currentState = v
        }, perform: {
            MyFeedBack()
            longAction?()
        })
    }
    
    func getStatusText() -> String {
        switch self.task.status {
        case .finished:
            return L("TASK.COMPONENT.STATUS.FINISHED")
        case .show:
            return String(format: "%.1f h", task.duration / 3600)
        default:
            return ""
        }
    }
    
    func getSubTitleText() -> String {
        switch self.task.status {
        case .finished:
            return L("TASK.COMPONENT.STATUS.SUBTITLE.FINISHED")
        case .todo:
            return L("TASK.COMPONENT.STATUS.SUBTITLE.TODO")
        case .show:
            return task.extra! + " " + L("TASK.COMPONENT.STATUS.SUBTITLE.FINISHED")
        case .original:
            fallthrough
        default:
            return L("TASK.COMPONENT.STATUS.SUBTITLE.ORIGINAL")
        }
    }
}

struct OneProjectView: View {
    @EnvironmentObject var document: XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    @Environment(\.undoManager) var undoManager
    
    var project: ProjectInfo
    var prjGrpId: UUID
    
    @State var prjName = ""
    
    @Binding var isEditingMode: Bool
    var displayMode: DisplayMode
    @Binding var isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, content: {
            Section(header: HStack(alignment: .center) {
                if isEditingMode {
                    Button(action: {
                        document.removeProject(idIs: project.id, from: prjGrpId, undoManager)
                    }) {
                        // plus.app.fill
                        Image(systemName: "minus.circle.fill").imageScale(.large).foregroundColor(.red)
                    }//.padding([.top, .trailing], 10)
                    .padding([.leading], 30)
                    
                    TextField(prjName, text: $prjName, onCommit : {
                        document.updateProject(to: prjName, idIs: project.id, from: prjGrpId, undoManager)
                        self.env_settings.isEditingMode = false
                    })
                        .foregroundColor(Color.secondary)
                        .font(.title2)
                        .padding([.leading, .trailing])
                        .onAppear {
                            prjName = project.name
                        }
                } else {
                    Text(project.name)
                        .font(displayMode == .FullSquareMode ? .title2 : .title3)
                        .padding([.leading], 30)
                        .contextMenu {
                            Button(action: {
                                document.removeProject(idIs: project.id, from: prjGrpId, undoManager)
                            }, label: {
                                Text("MENU.DELPROJECT \(project.name)")
                                Image(systemName: "trash")
                            })
                        }
                }
            }
            ) {
                ProjectDifferentModeView(project: project, prjGrpId: prjGrpId)
            }
        })
    }
    
    func getSometing() {
        
    }
}


struct ProjectDifferentModeView: View {
    var project: ProjectInfo
    var prjGrpId: UUID
    
    @EnvironmentObject var document: XPlanerDocument
    @EnvironmentObject var env_settings: EnvironmentSettings
    @Environment(\.undoManager) var undoManager
    
    @State var varas = true
    
    var body: some View {
        switch env_settings.displayMode{
        case .FullSquareMode :
            let projects = project.tasks.filter({ ele in
                let standard_condition = env_settings.pickerSelected == .Todos ? ele.status == .todo : true
                if env_settings.localSettings.hideFinishedTasks {
                    return ele.status == .finished ? false : standard_condition
                }
                return standard_condition
            })
            ScrollViewReader { proxy in
                ScrollView(env_settings.localSettings.collectionWaterFlowMode ? .vertical : .horizontal, showsIndicators: false) {
                    LazyVGrid(columns: env_settings.localSettings.collectionWaterFlowMode ? [GridItem(.adaptive(minimum: 80))]
                                : Array(repeating: GridItem(.flexible(minimum: 90)), count: projects.count + 1)
                    ) {
                        ForEach(projects) { tsk in
                            OneTaskView(
                                task: tsk,
                                index: project.tasks.firstIndex(of: tsk)! + 1,
                                isEditingMode: $env_settings.isEditingMode,
                                seleted: $env_settings.isSelected,
                                
                                action: { selected in
                                    if env_settings.isEditingMode {
                                        document.removeTask(idIs: tsk.id, from: project.id, in: prjGrpId, undoManager)
                                    }
                                    document.updateTaskStatus(tskStatus: StatusNextMapper[tsk.status]!, idIs: tsk.id, from: project.id, in: prjGrpId, undoManager)
                                },
                                longAction : {
                                    env_settings.currentTaskPath = document.indexOfTask(idIs: tsk.id, from: project.id, in: prjGrpId)
                                    env_settings.editTaskInfoPresented = true
                                }
                            )
                            .padding()
                            .shadow(color: Color("ShallowShadowColor"), radius: 10, x: 2, y: 2)
                            .drawingGroup()
                            .animation(.spring(response: 0.3, dampingFraction: 0.7))
                            .disabled(env_settings.viewHistoryMode)
                            .id(tsk.id)
                        }
                        if env_settings.isEditingMode {
                            Button(action: {
                                let lst_tsk = document.getLastAddedTask(from: project.id, in: prjGrpId)
                                
                                guard let new_tsk = document.addTask(nameIs: lst_tsk.name, contentIs: lst_tsk.content, duration: lst_tsk.duration, for: project.id, in: prjGrpId, undoManager)
                                else { return }
                                
                                env_settings.currentTaskPath = document.indexOfTask(idIs: new_tsk.id, from: project.id, in: prjGrpId)
                                env_settings.editTaskInfoPresented = true
                                
                                proxy.scrollTo(lst_tsk.id, anchor: .trailing)
                            }, label: {
                                VStack {
                                    Image(systemName: "plus.square").resizable().foregroundColor(Color("AccentColor"))
                                }.padding(20)
                                .frame(width: 80, height: 80, alignment: .center)
                                .cornerRadius(16)
                                .shadow(color: Color(hue: 0.8, saturation: 0.0, brightness: 0.718, opacity: 0.5), radius: 6, x: 5, y: 5)
                            })
                        }
                    }
                    .padding([.leading, .trailing], env_settings.localSettings.collectionWaterFlowMode ? 30 : 0)
                    .onChange(of: env_settings.goToFirstTodoTask) { v in
                        let lst_tsk = document.getFirstTask(where:{ tsk in
                            tsk.status == .todo
                        }, from: project.id, in: prjGrpId)
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            proxy.scrollTo(lst_tsk.id, anchor: .topLeading)
                        }
                    }
                }
            }
            
        case .SimpleProcessBarMode:
            HStack {
                ProgressView(value: 1)
                    .progressViewStyle(MyProgressStyle(
                        missionsWithStatus: project.tasks
                    ))
            }.padding([.horizontal])
                .padding([.vertical], 5)
        }
        
    }
}

var StatusNextMapper : [TaskStatus : TaskStatus] = [
    .finished : .finished,
    .original : .todo,
    .todo : .finished
]

