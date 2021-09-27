//
//  ContentView.swift
//  Shared
//
//  Created by Esther on 2021/9/9.
//
//

import SwiftUI

struct ContentView_Previews: PreviewProvider {
    @State static var document = XPlanerDocument()
    
    static var previews: some View {
        ContentView()
            .environmentObject(document)
            .environmentObject(EnvironmentSettings(simpleMode: false))
    }
}

// MARK: - 总视图

struct ContentView: View {
    @EnvironmentObject var document: XPlanerDocument
    @EnvironmentObject var env_settings : EnvironmentSettings
    @Environment(\.undoManager) var undoManager
    
    @State var scrollProxy : ScrollViewProxy? = nil
    
    var body: some View {
        ZStack{
            ScrollView(.vertical){
                ScrollViewReader() {proxy in
                    // MARK: 总渲染
                    ExtractedMainViewView(
                        data: $document.plannerData
                    ){ prjGrp in
                        // MARK: 项目组渲染
                        ExtractedMainlyContentView(
                            projectGroupName: prjGrp.name,
                            projects: prjGrp.projects
                        ){ prj in
                            // MARK: 项目渲染
                            OneProjectView(
                                projectName: prj.name,
                                tasks: prj.tasks,
                                isEditingMode: $env_settings.isEditingMode,
                                displayMode: env_settings.displayMode,
                                isSelected: $env_settings.isSelected)
                        }
                    }
                    .onAppear(){
                        env_settings.scrollProxy = proxy
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .foregroundColor(.accentColor)
            .animation(.spring(response: 0.3, dampingFraction: 0.5))
            .toolbar { ToolbarItem{
                ExtractedToolBarView(){
                    document.toggleDisplayMode(simple: env_settings.simpleMode, undoManager)}}
            }
            
            ExtractedBottomButtonGroupView()
            ExtractedTopMenuView(
                projectGroups: document.plannerData.projectGroups
            )
        }
    }
}

// MARK: - 分立组件，子视图



// MARK: 🔘底部按钮
struct ExtractedBottomButtonGroupView: View {
    @EnvironmentObject var env_settings : EnvironmentSettings
    
    var body: some View {
        VStack{
            Spacer()
            HStack{
                Spacer()
                Group {
                    Picker("",selection: $env_settings.pickerSelected){
                        Image(systemName: "tray").tag(0)
                        Image(systemName: "calendar").tag(1)
                    }.frame(width: 80, height: 30)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(10)
                .background(Color.white)
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
    @EnvironmentObject var env_settings : EnvironmentSettings
    
    @Binding var data : PlannerFileStruct
    
    var content : (_ item : ProjectGroupInfo) -> Content
    
    var body: some View {
        VStack(alignment: .leading){
            ForEach(data.projectGroups, content: {i in
                content(i).id(i.id)
                
                if(i.id != data.projectGroups.last?.id){
                    Divider().padding([.leading, .trailing])
                }else{
                    HStack{
                        //                        Text("空空如也")
                        EmptyView()
                    }
                }
            })
            
            if env_settings.isEditingMode{
                HStack{
                    Image(systemName: "plus.rectangle").resizable().scaledToFit()
                    
                    Text("添加新项目组").font(.largeTitle)
                        .fontWeight(.bold)
                }.frame(height: 30)
                    .padding()
                    .padding([.bottom], 20)
            }
        }
    }
}

// MARK: 🐯项目组渲染
struct ExtractedMainlyContentView<Content: View>: View {
    @EnvironmentObject var env_settings : EnvironmentSettings
    
    var projectGroupName: String
    
    var projects: [ProjectInfo]
    
    var content : (_ item : ProjectInfo) -> Content
    
    var body: some View {
        Section(header: HStack{
            if env_settings.isEditingMode {
                Button(action:{
                    
                }){// "note.text.badge.plus"
                    
                    Image(systemName: "minus.circle.fill")
                        .imageScale(.large).foregroundColor(.red)
                }.padding([.leading], 10)
            }
            Text(projectGroupName)
                .font(env_settings.displayMode == .FullSquareMode ? .largeTitle : .title2)
                .fontWeight(.bold)
                .padding([.leading, .trailing])
                .background(Color.white)
                .contextMenu{
                    Button(action: {
                        
                    }, label: {
                        Text("删除项目 \(projectGroupName) ")
                        Image(systemName: "trash")
                    })
                }.animation(.easeInOut)
        }.padding([.top], 30)
                
        ){
            ForEach(projects){item in
                content(item)
            }
            if env_settings.isEditingMode{
                HStack{
                    Image(systemName: "plus.rectangle").resizable().scaledToFit()
                    
                    Text("添加新项目").font(.title)
                }.frame(height: 30)
                    .padding()
                    .padding([.leading], 40)
                    .padding([.bottom], 20)
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
        Group{
            VStack{
                HStack(spacing: 10){
                    Spacer()
                    HStack(spacing: 20){
                        if !env_settings.isSelected{
                            if env_settings.displayMode == .FullSquareMode {
                                Button(action: {env_settings.isEditingMode.toggle()}){
                                    Text(env_settings.isEditingMode ? "完成" : "编辑")
                                }
                            }
                        } else {
                            Button(action: {env_settings.isEditingMode.toggle()}){
                                Text("代办")
                            }
                            Button(action: {}){
                                Text("已完成")
                            }
                            Button(action: {}){
                                Text("取消选择")
                            }
                            
                            Divider().frame(height: 20)
                        }
                        
                        Menu("列表"){
                            ForEach(projectGroups){i in
                                Button(action: {
                                    env_settings.scrollProxy?.scrollTo(i.id, anchor: .topLeading)
                                }, label: {
                                    Text(i.name)
                                })
                            }
                            Divider()
                            Button(action:{
                                document.add(undoManager)
                            }){
                                Text("添加")
                                Image(systemName: "plus.app.fill")
                            }
                        }
                    }
                    //                    .frame(width: 100)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding()
                    .shadow(color: Color(red: 0.8, green: 0.8, blue: 0.8), radius: 15, x: 0.0, y: 0.0)
                }
                
                Spacer()
            }
        }.animation(.spring(response: 0.3, dampingFraction: 0.5))
    }
}

// MARK: 🔧工具条
struct ExtractedToolBarView: View {
    @EnvironmentObject var env_settings : EnvironmentSettings
    
    var onChange : () -> Void
    
    var body: some View {
        Toggle(isOn: $env_settings.simpleMode) {
        }.toggleStyle(ImageToggleStyle(onImageName: "list.bullet", offImageName: "rectangle.split.3x3"))
            .onChange(of: env_settings.simpleMode, perform: { value in
                env_settings.simpleMode = env_settings.isEditingMode ? false : env_settings.simpleMode
                env_settings.displayMode = env_settings.simpleMode ? .SimpleProcessBarMode : .FullSquareMode
                onChange()
            })
            .disabled(env_settings.isEditingMode)
    }
}
