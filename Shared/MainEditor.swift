//
//  ContentView.swift
//  Shared
//
//  Created by Esther on 2021/9/9.
//
//

import SwiftUI
import CoreData

struct ContentView_Previews: PreviewProvider {
    @State static var document = XPlanerDocument()
    
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
            .environmentObject(document)
            .environmentObject(EnvironmentSettings(simpleMode: false, displayCategory: DisplayCatagory.All))
    }
}

// MARK: - 总视图

struct ContentView: View {
    @EnvironmentObject var document: XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    @Environment(\.undoManager) var undoManager
    
    @State var scrollProxy : ScrollViewProxy? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ZStack{
                    ScrollView(.vertical){
                        ScrollViewReader() {proxy in
                            // MARK: 总渲染
                            ExtractedMainViewView(
                                data: env_settings.viewHistoryMode ? $env_settings.filtedTasks : $document.plannerData
                            ){ prjGrp in
                                // MARK: 项目组渲染
                                ExtractedMainlyContentView(
                                    projectGroup: prjGrp
                                ){ prj in
                                    // MARK: 项目渲染
                                    OneProjectView(
                                        project : prj,
                                        prjGrpId: prjGrp.id,
                                        isEditingMode: $env_settings.isEditingMode,
                                        displayMode: env_settings.displayMode,
                                        isSelected: $env_settings.isSelected)
                                }
                            }
                            .onAppear(){
                                env_settings.scrollProxy = proxy
                            }
                        }
                        
                        VStack{}.frame(height: 100)
                    }
                    .frame(maxHeight: .infinity)
                    .foregroundColor(.accentColor)
                    //            .background(LinearGradient(colors: [.white, .gray], startPoint: .top, endPoint: .bottom))
                    .animation(.easeInOut(duration: 0.2))
                    .toolbar { ToolbarItem{
                        ExtractedToolBarView(){
                            document.toggleDisplayMode(displayMode: env_settings.displayMode, undoManager)}}
                    }
                    
                    
                    ExtractedBottomButtonGroupView()
                        .offset(y: env_settings.simpleMode || env_settings.isEditingMode ? 100 : 0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5))
                }
                .saturation(env_settings.editTaskInfoPresented ? 0.2 : 1)
                .blur(radius: env_settings.editTaskInfoPresented ? 2 : 0)
                .scaleEffect(env_settings.editTaskInfoPresented ? 0.5 : 1)
                .offset(y: env_settings.editTaskInfoPresented ? -screen.height / 4 : 0)
                .rotation3DEffect(Angle(degrees: env_settings.editTaskInfoPresented ? 30 : 0), axis: (-1, 0, 0))
                .animation(.spring(response: 0.2))
                .disabled(env_settings.editTaskInfoPresented)
                
                ExtractedTopMenuView(
                    projectGroups: env_settings.viewHistoryMode ? env_settings.filtedTasks.projectGroups : document.plannerData.projectGroups
                ).offset(x: env_settings.editTaskInfoPresented ? screen.width : 0)
                .animation(.spring(response: 0.2))
                
                ExtractedTaskEditViewView()
                
                if !env_settings.editTaskInfoPresented {
                    ExtractedHistorySwitchView()
                }
            }.sheet(isPresented: $env_settings.showSettings, content: {
                ExtractedSettingsView(undoManager: undoManager)
                    .environmentObject(document)
                    .environmentObject(env_settings)
            })
            
            // TODO: 插入时间调整装置
            
            if env_settings.viewHistoryMode {
                MyDateDataSelector(currentIndex: $env_settings.currentHistoryIndex, datasource: extractDateDataInfos(from: document)).frame(height: 95)
                    .transition(.slide)
                    .animation(.spring(response: 0.3))
                    .onChange(of: env_settings.currentHistoryIndex, perform: { value in
                        env_settings.filtedTasks = filterTasks(pln: document, on: index2date(index: value))
                    })
            }
        }
    }
}

// MARK: - 分立组件，子视图



// MARK: 🔘底部按钮
struct ExtractedBottomButtonGroupView: View {
    @EnvironmentObject var document : XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        VStack{
            Spacer()
            HStack{
                Spacer()
                Group {
                    Picker("",selection: $env_settings.pickerSelected){
                        Image(systemName: "tray").tag(DisplayCatagory.All)
                        if !env_settings.viewHistoryMode {
                            Image(systemName: "calendar").tag(DisplayCatagory.Todos)
                        }
                    }.frame(width: env_settings.viewHistoryMode ? 40 : 80, height: 30)
                    .onChange(of: env_settings.pickerSelected) { v in
                        document.updateDisplayCategory(to: env_settings.pickerSelected, undoManager)
                    }
                    
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(10)
                .background(Color("BarsBackgroundColor"))
                .cornerRadius(30)
                .padding(10)
                .shadow(color:Color("ShallowShadowColor"), radius: 15, x: 0.0, y: 0.0)
                Spacer()
            }
        }
    }
}

// MARK: 🐲总渲染
struct ExtractedMainViewView<Content: View>: View {
    @EnvironmentObject var document: XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    @Environment(\.undoManager) var undoManager
    
    @Binding var data : PlannerFileStruct
    
    var content : (_ item : ProjectGroupInfo) -> Content
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible())], alignment: .leading, pinnedViews: [.sectionHeaders]){
            if data.projectGroups.count > 0{
                ForEach(data.projectGroups, content: {i in
                    content(i).id(i.id)
                    
                    if(i.id != data.projectGroups.last?.id){
                        Divider().padding([.leading, .trailing])
                    }
                }).frame(maxWidth: .infinity)
            } else {
                VStack{
                    Text("CONTEXT.NOGROUP").frame(maxWidth: .infinity)
                }
            }
            
            if env_settings.isEditingMode{
                Button {
                    document.addGroup(nameIs: L("NEW.PROJECTGROUP.NAME"), undoManager)
                } label: {
                    HStack{
                        Image(systemName: "plus.rectangle").resizable().scaledToFit()
                        
                        Text("MENU.ADDGROUP").font(.title)
                            .fontWeight(.bold)
                    }.frame(height: 30)
                    .padding([.leading, .bottom], 20)
                }
            }
        }
    }
}

// MARK: 🐯项目组渲染
struct ExtractedMainlyContentView<Content: View>: View {
    @EnvironmentObject var document : XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    @Environment(\.undoManager) var undoManager
    
    var projectGroup : ProjectGroupInfo
    
    @State var grpName : String = ""
    
    var content : (_ item : ProjectInfo) -> Content
    
    var body: some View {
        Section(header: HStack{
            if env_settings.isEditingMode {
                Button(action:{
                    document.removeGroup(idIs: projectGroup.id, undoManager)
                }){// "note.text.badge.plus"
                    Image(systemName: "minus.circle.fill")
                        .imageScale(.large).foregroundColor(.red)
                }.padding([.leading], 10)
                
                TextField(grpName, text: $grpName, onCommit : {
                    document.updateGroup(to: grpName, idIs: projectGroup.id, undoManager)
                    self.env_settings.isEditingMode = false
                })
                .foregroundColor(Color.secondary)
                .font(.title)
                .padding([.leading, .trailing])
                .onAppear {
                    grpName = projectGroup.name
                }
            } else {
                Text(projectGroup.name)
                    .font(env_settings.displayMode == .FullSquareMode ? .title : .title2)
                    .fontWeight(.bold)
                    .padding([.leading, .trailing])
                    .padding([.vertical], 10)
                    .background(Color("BarsBackgroundColor").blur(radius: 10))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .contextMenu{
                        Button(action: {
                            document.removeGroup(idIs: projectGroup.id, undoManager)
                        }, label: {
                            Text("MENU.DELGROUP \(projectGroup.name)")
                            Image(systemName: "trash")
                        })
                    }
            }
            Spacer()
        }.padding([.top, .bottom], 1)
        .animation(.none)
        ){
            if projectGroup.projects.count > 0 {
                ForEach(projectGroup.projects){item in
                    content(item).padding([.top], 0)
                }
            } else {
                VStack{
                    Text("CONTEXT.NOPROJECT")
                }
            }
            
            if env_settings.isEditingMode{
                HStack{
                    Button {
                        document.addProject(nameIs: L("NEW.PROJECT.NAME"), for: projectGroup.id, undoManager)
                    } label: {
                        HStack{
                            Image(systemName: "plus.rectangle").resizable().scaledToFit()
                            
                            Text("MENU.ADDPROJECT").font(.title2)
                        }.frame(height: 30)
                        //
                    }
                    .padding([.leading], 40)
                    .padding([.bottom], 20)
                    Spacer()
                }
            }
        }
    }
}

// MARK: 🌲顶部菜单
struct ExtractedTopMenuView: View {
    @EnvironmentObject var document : XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    @Environment(\.undoManager) var undoManager
    
    var projectGroups : [ProjectGroupInfo]
    
    var body: some View {
        VStack(alignment: .trailing){
            HStack(alignment: .bottom, spacing: 10){
                Spacer()
                HStack(spacing: 20){
                    if env_settings.displayMode == .FullSquareMode && env_settings.pickerSelected == .All && !env_settings.viewHistoryMode {
                        Button(action: {env_settings.isEditingMode.toggle()}){
                            Text(env_settings.isEditingMode ? "BUTTON.DONE" : "BUTTON.EDIT")
                        }
                    }
                    VStack{
                        Menu {
                            ForEach(projectGroups){i in
                                Button(action: {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                        env_settings.scrollProxy?.scrollTo(i.id, anchor: .top)
                                    }
                                }, label: {
                                    Text(i.name)
                                })
                            }
                            Divider()
                            if !env_settings.viewHistoryMode {
                                Button(action:{
                                    document.addGroup(nameIs: L("NEW.PROJECTGROUP.NAME"), undoManager)
                                }){
                                    Text("MENU.ADDGROUP")
                                    Image(systemName: "plus.app.fill")
                                }
                            }
                        } label: {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 20, weight: .bold))
                        }.frame(maxWidth: 30)
                        .menuStyle(BorderlessButtonMenuStyle())
                    }
                }
                .padding()
                .background(Color("BarsBackgroundColor"))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding()
                .shadow(color: Color("ShallowShadowColor"), radius: 15, x: 0.0, y: 0.0)
                
            }
            Spacer()
        }.frame(maxWidth: .infinity)
    }
}

// MARK: 🔧工具条
struct ExtractedToolBarView: View {
    @EnvironmentObject var document : XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    @Environment(\.undoManager) var undoManager
    
    var onClick : () -> Void
    
    var body: some View {
        if !env_settings.viewHistoryMode {
            HStack{
                HStack{
                    Button(action: {
                        env_settings.showSettings = true
                    }, label: {
                        Image(systemName: "gear")
                    })} .padding(5)
                    .background(Color("BarsBackgroundColor")).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                HStack{
                    if undoManager?.canUndo ?? false {
                        Button(action: {
                            undoManager?.undo()
                        }){
                            Image(systemName: "arrow.uturn.backward.circle")
                        }
                    }
                    if undoManager?.canRedo ?? false {
                        Button(action: {
                            undoManager?.redo()
                        }){
                            Image(systemName: "arrow.uturn.forward.circle")
                        }
                    }
                }
                .padding(5)
                .background(Color("BarsBackgroundColor")).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                Spacer()
                if !env_settings.simpleMode {
                    HStack{
                        Button(action: {
                            env_settings.goToFirstTodoTask.toggle()
                        }){
                            Image(systemName: "rays")
                        }
                    }.padding(5)
                    .background(Color("BarsBackgroundColor")).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                Toggle(isOn: $env_settings.simpleMode) {
                }.toggleStyle(ImageToggleStyle(onImageName: "list.bullet", offImageName: "rectangle.split.3x3"){
                    env_settings.simpleMode = env_settings.isEditingMode ? false : env_settings.simpleMode
                    env_settings.displayMode = env_settings.simpleMode ? .SimpleProcessBarMode : .FullSquareMode
                    onClick()
                }
                )
                .onChange(of: document.plannerData.fileInformations.displayMode, perform: { value in
                    env_settings.simpleMode = value == .SimpleProcessBarMode
                    env_settings.simpleMode = env_settings.isEditingMode ? false : env_settings.simpleMode
                    env_settings.displayMode = env_settings.simpleMode ? .SimpleProcessBarMode : .FullSquareMode
                })
                .disabled(env_settings.isEditingMode)
            }
        }
    }
}

// MARK: - 📑编辑弹窗
struct ExtractedTaskEditViewView: View {
    @EnvironmentObject var document: XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    @Environment(\.undoManager) var undoManager
    
    @GestureState var draging : Bool = false
    @State var dragOffset : CGSize = .zero
    @State var willCloseFlag = false
    @State var tmpTask : TaskInfo = TaskTemplate()

    @State var showTimePicker : Bool = false
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.01).frame(maxWidth: .infinity, maxHeight: .infinity).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    env_settings.editTaskInfoPresented = false
                }
            VStack{
                VStack{
                    VStack(spacing: 20) {
                        MyTextFiled(title: L("EDITTASK.TITLE"), text: $tmpTask.name, tilt: Color("FavoriteColor7"))
                            .shadow(color: Color.gray.opacity(0.3), radius: dragOffset.height / 30 * 10, x: dragOffset.width, y: dragOffset.height)
                        MyTextFiled(title: L("EDITTASK.CONTENT"), text: $tmpTask.content, tilt: Color("FavoriteColor7"))
                            .shadow(color: Color.gray.opacity(0.3), radius: dragOffset.height / 30 * 10, x: dragOffset.width, y: dragOffset.height)
                        Picker(selection: $tmpTask.status, label: EmptyView()) {
                            Text("TASK.STATUS.ORIGINAL").tag(TaskStatus.original)
                            Text("TASK.STATUS.TODO").tag(TaskStatus.todo)
                            Text("TASK.STATUS.FINISHED").tag(TaskStatus.finished)
                        }.pickerStyle(SegmentedPickerStyle())
                        HStack{
                            Text("Duration is")
                            Spacer()
                            Button(action: {showTimePicker = true}, label: {
                                Text(intervalToTimeStr(tmpTask.duration, forFun: true))
                            })
                        }.padding(5)
                        .padding([.horizontal], 10)
                        .foregroundColor(Color("FavoriteColor7"))
                        .background(Color("BarsBackgroundColor").opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }.padding([.vertical], 40)
                    .padding(.horizontal, 30)
                }
                .background(LinearGradient(gradient: Gradient(colors: [Color("FavoriteColor7"), Color("FavoriteColor3")]), startPoint: .topLeading, endPoint: .bottomTrailing).brightness(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                .shadow(color: Color.gray.opacity(0.3), radius: dragOffset.height / 30 * 10, x: dragOffset.width, y: dragOffset.height)
                
                VStack{
                    Button(action: {
                        env_settings.editTaskInfoPresented = false
                    }){
                        Text("EDITTASK.CANCEL")
                    }
                }.padding()
            }
            .frame(width: 256)
            .padding([.top, .leading, .trailing], 16)
            .background(Color("BarsBackgroundColor"))
            .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))
            .shadow(color: Color("ShallowShadowColor").opacity(0.6), radius: 25, x: -20, y: -20)
            .shadow(color: Color("ShallowShadowColor").opacity(0.6), radius: 25, x: (1 - dragOffset.height / 30) * 20, y: (dragOffset.height / 30 + 1) * 20)
            
            .offset(x: dragOffset.width * 2, y: dragOffset.height * 2)
            .rotation3DEffect(Angle(degrees: Double(dragOffset.height) / 2), axis: (-1, 0, 0))
            .brightness(-Double(dragOffset.height) / 200)
            
            .opacity(env_settings.editTaskInfoPresented ? 1 : 0)
            .scaleEffect(env_settings.editTaskInfoPresented ? 1 : 0.2)
            
            .onChange(of: env_settings.editTaskInfoPresented, perform: { V in
                let indexes = env_settings.currentTaskPath
                let task = indexes != nil ? document.plannerData.projectGroups[indexes!.prjGrpIndex].projects[indexes!.prjIndex].tasks[indexes!.tskIndex] : TaskTemplate()
                
                if env_settings.editTaskInfoPresented {
                    tmpTask = task
                }
            })
            .gesture(
                DragGesture()
                    .onChanged { state in
                        let pos = state.translation
                        dragOffset = CGSize(width: pos.width / 50, height: pos.height > 0 ? pos.height / 10: 0)
                        
                        if pos.height > 200 {
                            if !willCloseFlag {
                                MyFeedBack()
                            }
                            self.willCloseFlag = true
                        } else { self.willCloseFlag = false }
                    }
                    .onEnded{ state in
                        dragOffset = .zero
                        
                        guard self.willCloseFlag else { return }
                        
                        document.updateTaskInfo(tsk: tmpTask, for: env_settings.currentTaskPath!, undoManager)
                        
                        self.willCloseFlag = false;
                        env_settings.editTaskInfoPresented = false
                    }
            )
            .blur(radius: showTimePicker ? 10 : 0)
            
            if showTimePicker{
                ZStack {
                    Color.black.opacity(0.1).onTapGesture {
                        showTimePicker = false
                    }
                    VStack{
                        MyCountDownPicker(val: $tmpTask.duration)
                    }.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }.opacity(env_settings.editTaskInfoPresented ? 1 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7))
        .edgesIgnoringSafeArea(.all)
        
    }
}

//MARK: - 📅底部历史记录按钮

struct ExtractedHistorySwitchView: View {
    @EnvironmentObject var document : XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    
    @State var setting_backup = EnvironmentSettings(simpleMode: false, displayCategory: .All)
    
    var body: some View {
        VStack{
            Spacer()
            HStack {
                Spacer()
                VStack{
                    Button(action: {
                        env_settings.viewHistoryMode.toggle()
                        env_settings.isEditingMode = false
                        
                        if env_settings.viewHistoryMode {
                            setting_backup.displayMode = env_settings.displayMode
                            setting_backup.simpleMode = env_settings.simpleMode
                            setting_backup.pickerSelected = env_settings.pickerSelected
                            
                            env_settings.filtedTasks = filterTasks(pln: document, on: index2date(index: 0))
                            
                            env_settings.displayMode = .FullSquareMode
                            env_settings.simpleMode = false
                            env_settings.pickerSelected = .All
                        } else {
                            env_settings.displayMode = setting_backup.displayMode
                            env_settings.simpleMode = setting_backup.simpleMode
                            env_settings.pickerSelected = setting_backup.pickerSelected
                        }
                    }, label: {
                        Image(systemName: "clock.arrow.circlepath")
                    })
                }.padding(5)
                .frame(width: 30, height: 30, alignment: .center)
                .background(Path { path in
                    let w = 30, h = 30
                    let tr = min(min(15, h/2), w/2)
                    let tl = min(min(15, h/2), w/2)
                    let bl = min(min(0, h/2), w/2)
                    let br = min(min(0, h/2), w/2)
                    
                    path.move(to: CGPoint(x: w / Int(2.0), y: 0))
                    path.addLine(to: CGPoint(x: w - tr, y: 0))
                    path.addArc(center: CGPoint(x: w - tr, y: tr), radius: CGFloat(tr), startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                    path.addLine(to: CGPoint(x: w, y: h - br))
                    path.addArc(center: CGPoint(x: w - br, y: h - br), radius: CGFloat(br), startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                    path.addLine(to: CGPoint(x: bl, y: h))
                    path.addArc(center: CGPoint(x: bl, y: h - bl), radius: CGFloat(bl), startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                    path.addLine(to: CGPoint(x: 0, y: tl))
                    path.addArc(center: CGPoint(x: tl, y: tl), radius: CGFloat(tl), startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
                    
                }.fill(Color("BarsBackgroundColor")))
                .shadow(color: Color("ShallowShadowColor"), radius: 10, x: 0, y: 0)
            }.padding(.trailing, 10)
        }
    }
}

//MARK: - ⚙️设置页面

struct ExtractedSettingsView: View {
    @EnvironmentObject var document : XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    @EnvironmentObject var localSettingManager : LocalSettingManager
    var undoManager : UndoManager?
    
    @State var showAlert: Bool = false
    
    @State var backInfo: FileInfos = FileInfos(documentVersion: CurrentFileFormatVerison, topic: "", createDate: Date(), author: "", displayMode: .FullSquareMode, displayCatagory: .All)
    @State var backLocalSettings : AppLocalSettings = AppLocalSettings(hideFinishedTasks: false, collectionWaterFlowMode: false)
    
    var body: some View {
        NavigationView{
            VStack{
                Form{
                    Section(header: Text("文档设置")) {
                        HStack{
                            Text(Image(systemName: "square.and.pencil")).frame(width: 30)
                            Text("主题")
                            TextField("主题", text: $backInfo.topic)
                                .multilineTextAlignment(.center)
                        }
                        HStack{
                            Text(Image(systemName: "person.fill.questionmark")).frame(width: 30)
                            Text("作者")
                            TextField("作者", text: $backInfo.author)
                                .multilineTextAlignment(.center)
                        }
                        HStack{
                            Text(Image(systemName: "calendar")).frame(width: 30)
                            Text("创建日期")
                            DatePicker("", selection: $backInfo.createDate)
                                .datePickerStyle(CompactDatePickerStyle())
                                .disabled(true)
                        }
                        HStack{
                            Text(Image(systemName: "display")).frame(width: 30)
                            Text("显示模式")
                            HStack{
                                Image(systemName: backInfo.displayMode == .SimpleProcessBarMode ? "list.bullet" :  "rectangle.split.3x3")
                                Text(backInfo.displayMode == .SimpleProcessBarMode ? "简约线条" : "完整模式")
                            }.frame(maxWidth: .infinity)
                            .padding(5).background(Color("BarsBackgroundColor"))
                            .cornerRadius(10)
                        }
                        HStack{
                            Text(Image(systemName: "tray.full")).frame(width: 30)
                            Text("显示类别")
                            HStack{
                                Image(systemName: backInfo.displayCatagory == .All ? "tray" :  "calendar")
                                Text(backInfo.displayCatagory == .All ? "所有任务" : "今日任务")
                            }.frame(maxWidth: .infinity)
                            .padding(5).background(Color("BarsBackgroundColor"))
                            .cornerRadius(10)
                        }
                        HStack{
                            Text(Image(systemName: "number")).frame(width: 30)
                            Text("文档版本")
                            HStack{
                                Text("\(backInfo.documentVersion.str())")
                                    .foregroundColor(.secondary)
                            }.frame(maxWidth: .infinity)
                        }
                    }
                    
                    Section(header: Text("备注")) {
                        TextEditor(text: OptBinding($backInfo.extra, "")).frame(height: 200)
                    }
                    
                    Section(header: Text("系统设置")) {
                        HStack{
                            Image(systemName: "eye.slash").frame(width: 30)
                            Toggle(isOn: $backLocalSettings.hideFinishedTasks, label: {
                                Text("隐藏已完成任务")
                            })
                        }
                        HStack{
                            Image(systemName: "square.grid.3x1.below.line.grid.1x2").frame(width: 30)
                            Toggle(isOn: $backLocalSettings.collectionWaterFlowMode, label: {
                                Text("瀑布流布局")
                            })
                        }
                    }
                    Section(header: Text("关于")) {
                        let info = Bundle.main.infoDictionary!
                        let name = info["CFBundleDisplayName"] as! String
                        let version = "Verison \(info["CFBundleShortVersionString"]!) build \(info["CFBundleVersion"]!)"
                        VStack(alignment: .center, spacing: 20){
                            Image("AppIcon-UsedForShowing").resizable().frame(width: 100, height: 100, alignment: .center)
                            Text("\(name)")
                            Text(version)
                            HStack{
                                Image(systemName: "42.square")
                                Text("作者")
                                Text("W-Mai").foregroundColor(.secondary)
                            }
                            HStack{
                                Image(systemName: "house")
                                Text("工作室")
                                Text("XCLZ STUDIO").foregroundColor(.secondary)
                            }
                        }.frame(maxWidth: .infinity)
                    }.padding()
                }
            }
            .navigationTitle("设置")
            .navigationBarItems(trailing: Button(action: {
                showAlert = true
            }, label: {Text("🔘")}))
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("(๑•̀ㅂ•́)و✧") , dismissButton: .cancel(Text("Yeahヽ(✿ﾟ▽ﾟ)ノ")))
            })
        }.onAppear(perform: {
            backInfo = document.plannerData.fileInformations
            backLocalSettings = env_settings.localSettings
        })
        .onDisappear(perform: {
            if backInfo != document.plannerData.fileInformations {
                undoManager?.beginUndoGrouping()
                document.updateTopic(backInfo.topic, undoManager)
                document.updateAuthor(backInfo.author, undoManager)
                document.updateFileExtra(backInfo.extra, undoManager)
                undoManager?.endUndoGrouping()
            }
            
            if env_settings.localSettings != backLocalSettings {
                env_settings.localSettings = backLocalSettings
                localSettingsManager.writeSettings(appsettings: backLocalSettings)
            }
        })
    }
}


//MARK: - ☹️一些全局常量

let screen = UIScreen.main.bounds


