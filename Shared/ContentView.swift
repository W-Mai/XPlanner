//
//  ContentView.swift
//  Shared
//
//  Created by Esther on 2021/9/9.
//
//

import SwiftUI

struct ContentView_Previews: PreviewProvider {
    @State static var data = XPlanerDocument()
    
    static var previews: some View {
        ContentView().environmentObject(data)
    }
}

struct ContentView: View {
    @EnvironmentObject var document: XPlanerDocument
    @Environment(\.undoManager) var undoManager
    
    @State var scrollProxy : ScrollViewProxy? = nil
    @State var isEditingMode = false
    @State var pickerSelected = 0
    @State var simpleMode = false
    @State var isSelected = false
    
    
    var body: some View {
        ZStack{
            ScrollView(.vertical){
                ScrollViewReader() {proxy in
                    ExtractedMainViewView(
                        data: $document.plannerData,
                        isEditingMode: $isEditingMode)
                        .onAppear(){
                            scrollProxy = proxy
                        }
                }
            }
            .frame(maxHeight: .infinity)
            .foregroundColor(.accentColor)
            .animation(.spring(response: 0.3, dampingFraction: 0.5))
            .toolbar {
                ToolbarItem {
                    Toggle(isOn: $simpleMode) {
                    }.toggleStyle(ImageToggleStyle(onImageName: "list.bullet", offImageName: "rectangle.split.3x3"))
                    .onChange(of: simpleMode, perform: { value in
                        simpleMode = isEditingMode ? false : simpleMode
                        document.plannerData.fileInformations.displayMode = simpleMode ? .SimpleProcessBarMode : .FullSquareMode
                    })
                    .onAppear{
                        simpleMode = document.plannerData.fileInformations.displayMode == .SimpleProcessBarMode
                    }
                    .disabled(isEditingMode)

                }
            }
            
            ExtractedBottomButtonGroupView(pickerSelected: $pickerSelected)
            ExtractedTopMenuView(
                scrollProxy: scrollProxy,
                projectGroups: document.plannerData.projectGroups,
                isEditingMode: $isEditingMode,
                displayMode: $document.plannerData.fileInformations.displayMode,
                isSelected: $isSelected
            )
        }
    }
}



struct ExtractedBottomButtonGroupView: View {
    @Binding var pickerSelected: Int
    
    var body: some View {
        VStack{
            Spacer()
            HStack{
                Spacer()
                Group {
                    Picker("",selection: $pickerSelected){
                        Image(systemName: "tray").tag(0)
                        Image(systemName:"calendar").tag(1)
                    }.frame(width: 80, height: 30)
                    
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(10)
                .background(Color.white)
                .cornerRadius(30)
                .padding(10)
                .shadow(color: Color(red: 0.8, green: 0.8, blue: 0.8), radius: 15, x: 0.0, y: 0.0)
                Spacer()
            }
        }
    }
}

struct ExtractedMainViewView: View {
    @Binding var data : PlannerFileStruct
    @Binding var isEditingMode : Bool
    @State var isSelected : Bool = false
    @State var pickerSeleted : Int = 0
    
    var body: some View {
        //            TextEditor(text: $document.text)
        VStack(alignment: .leading){            
            ForEach(data.projectGroups, content: {i in
                ExtractedMainlyContentView(
                    projectGroupName: i.name,
                    projects: i.projects,
                    isEditingMode: $isEditingMode,
                    pickerSelected: $pickerSeleted,
                    displayMode: data.fileInformations.displayMode,
                    isSelected: $isSelected
                ).id(i.id)
                if(i.id != data.projectGroups.last?.id){
                    Divider().padding([.leading, .trailing])
                }else{
                    EmptyView()
                }
            })
            
            if isEditingMode{
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

struct ExtractedMainlyContentView: View {
    var projectGroupName: String
    
    var projects: [ProjectInfo]
    
    @Binding var isEditingMode: Bool
    @Binding var pickerSelected: Int
    var displayMode: DisplayMode
    @Binding var isSelected : Bool
    
    var body: some View {
        Section(header: HStack{
            if isEditingMode {
                Button(action:{
                    
                }){// "note.text.badge.plus"
                    
                    Image(systemName: "minus.circle.fill")
                        .imageScale(.large).foregroundColor(.red)
                }.padding([.leading], 10)
            }
            Text(projectGroupName)
                .font(displayMode == .FullSquareMode ? .largeTitle : .title2)
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
            ForEach(projects){i in
                OneProjectView(
                    projectName: i.name,
                    tasks: i.tasks,
                    isEditingMode: $isEditingMode,
                    displayMode: displayMode,
                    isSelected: $isSelected)
            }
            if isEditingMode{
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

struct ExtractedTopMenuView: View {
    @EnvironmentObject var document : XPlanerDocument
    @Environment(\.undoManager) var undoManager
    
    var scrollProxy: ScrollViewProxy?
    
    var projectGroups : [ProjectGroupInfo]
    @Binding var isEditingMode: Bool
    @Binding var displayMode : DisplayMode
    @Binding var isSelected : Bool
    
    var body: some View {
        Group{
            VStack{
                HStack(spacing: 10){
                    Spacer()
                    HStack(spacing: 20){
                        if !isSelected{
                            if displayMode == .FullSquareMode {
                                Button(action: {isEditingMode.toggle()}){
                                    Text(isEditingMode ? "完成" : "编辑")
                                }
                            }
                        } else {
                            Button(action: {isEditingMode.toggle()}){
                                Text("代办")
                            }
                            Button(action: {isEditingMode.toggle()}){
                                Text("已完成")
                            }
                            Button(action: {isEditingMode.toggle()}){
                                Text("取消选择")
                            }
                            
                            Divider().frame(height: 20)
                        }
                        
                        Menu("列表"){
                            ForEach(projectGroups){i in
                                Button(action: {
                                    scrollProxy?.scrollTo(i.id, anchor: .topLeading)
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
