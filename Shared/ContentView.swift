//
//  ContentView.swift
//  Shared
//
//  Created by Esther on 2021/9/9.
//
//

import SwiftUI




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(XPlanerDocument()))
    }
}

struct ContentView: View {
    @Binding var document: XPlanerDocument
    
    let courses: Array<String> = ["数学", "英语", "政治", "专业课", "测试课程"]
    let project = [["直播课", "严选题"],["阅读", "翻译", "完型"], ["徐涛课程"], ["计组", "计网"], []]
    
    @State var isEditingMode = false
    @State var scrollProxy: ScrollViewProxy? = nil
    @State var pickerSelected = 0
    @State var simpleMode = false
    @State var displayMode: DisplayMode = DisplayMode.FullSquareMode
    @State var isSelected = false
    
    var body: some View {
        ZStack{
            ScrollView(.vertical){
                ScrollViewReader() {proxy in
                    //            TextEditor(text: $document.text)
                    
                    VStack(alignment: .leading){
                        ForEach(courses.indices, id: \.self){i in
                            ExtractedMainlyContentView(
                                projectName: courses[i],
                                projectTasks: project[i],
                                isEditingMode: $isEditingMode,
                                pickerSelected: $pickerSelected,
                                displayMode: $displayMode, isSelected: $isSelected
                            )
                            if(i != courses.count - 1){
                                Divider().padding([.leading, .trailing])
                            }
                        }
                        
                        if isEditingMode{
                            HStack{
                                Image(systemName: "plus.rectangle").resizable().scaledToFit()
                                
                                Text("添加新项目").font(.largeTitle)
                                    .fontWeight(.bold)
                            }.frame(height: 30)
                            .padding()
                            .padding([.bottom], 20)
                        }
                    }.onAppear(){
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
                        displayMode = simpleMode ? .SimpleProcessBarMode : .FullSquareMode
                    })
                    .disabled(isEditingMode)
                    
                }
            }
            ExtractedBottomButtonGroupView(pickerSelected: $pickerSelected)
            ExtractedTopMenuView(
                courses: courses,
                scrollProxy: scrollProxy,
                isEditingMode: $isEditingMode,
                displayMode: $displayMode,
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

struct ExtractedMainlyContentView: View {
    var projectName: String
    
    var projectTasks: Array<String>
    
    @Binding var isEditingMode: Bool
    @Binding var pickerSelected: Int
    @Binding var displayMode: DisplayMode
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
            Text(projectName)
                .font(displayMode == .FullSquareMode ? .largeTitle : .title2)
                .fontWeight(.bold)
                .padding([.leading, .trailing])
                .background(Color.white)
                .contextMenu{
                    Button(action: {
                        
                    }, label: {
                        Text("删除项目 \(projectName) ")
                        Image(systemName: "trash")
                    })
                }.animation(.easeInOut)
        }.padding([.top], 30)
        
        ){
            
            ForEach(projectTasks.indices){j in
                OneProjectView(projectName: projectTasks[j], tasks: [String](), isEditingMode: $isEditingMode, displayMode: $displayMode, isSelected: $isSelected)
            }
            if isEditingMode{
                HStack{
                    Image(systemName: "plus.rectangle").resizable().scaledToFit()
                    
                    Text("添加新任务").font(.title)
                }.frame(height: 30)
                .padding()
                .padding([.leading], 40)
                .padding([.bottom], 20)
            }
        }
    }
}

struct ExtractedTopMenuView: View {
    
    var courses: Array<String>
    var scrollProxy: ScrollViewProxy?
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
                            ForEach(courses.indices, id:\.self){i in
                                Button(action: {
                                    scrollProxy?.scrollTo(i, anchor: .topLeading)
                                }, label: {
                                    Text(courses[i])
                                })
                            }
                            Divider()
                            Button(action:{}){
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
