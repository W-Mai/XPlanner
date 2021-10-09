//
//  Defs.swift
//  XPlaner
//
//  Created by Esther on 2021/9/17.
//
import SwiftUI

// MARK: - 🔢 枚举和常量

let CurrentFileFormatVerison = FileFormatVersion(a: 0, b: 0, c: 1)
let DefalutTaskDuration: TimeInterval = 3600.0

/// 任务状态
enum TaskStatus: String, Codable {
    case finished,
         original,
         todo,
         show
}

/// 显示模式
enum DisplayMode: String, Codable {
    case FullSquareMode         /// 方形样式
    case SimpleProcessBarMode   /// 线条进度样式
}

/// 显示类别
enum DisplayCatagory: String, Codable {
    case All    /// 显示所有任务
    case Todos  /// 只显示待办事项
}

enum SettingBoolString: String, Codable {
    case OK, NOOK
}

// MARK: - 🦀️ 辅助结构

struct TaskIndexPath : Equatable {
    var prjGrpIndex : Int
    var prjIndex : Int
    var tskIndex : Int
}

struct DateDataDayInfo {
    var finishedNumber: Int
    var spentHours: Double
    var date: Date
}

// MARK: - 🏞 环境配置

struct AppLocalSettings {
    var hideFinishedTasks : Bool
    var collectionWaterFlowMode : Bool
}

class EnvironmentSettings: ObservableObject {
    @Published var scrollProxy : ScrollViewProxy? = nil
    @Published var isEditingMode = false
    @Published var pickerSelected = DisplayCatagory.All
    @Published var displayMode : DisplayMode = .FullSquareMode
    @Published var simpleMode = false
    @Published var isSelected = false
    @Published var currentTaskPath : TaskIndexPath? = nil
    @Published var editTaskInfoPresented = false
    @Published var showSettings = false
    @Published var goToFirstTodoTask = false
    @Published var viewHistoryMode = false
    @Published var currentHistoryIndex : Int = 0
    @Published var filtedTasks : PlannerFileStruct = PlannerFileStruct(fileInformations: FileInfos(documentVersion: CurrentFileFormatVerison, topic: "", createDate: Date(), author: "", displayMode: .FullSquareMode, displayCatagory: .All), projectGroups: [ProjectGroupInfo](), taskStatusChanges: [TaskStatusChangeRecord]())
    @Published var localSettings : AppLocalSettings = AppLocalSettings(hideFinishedTasks: false, collectionWaterFlowMode: false)
    
    init(simpleMode : Bool, displayCategory: DisplayCatagory) {
        self.simpleMode = simpleMode
        self.displayMode = simpleMode ? .SimpleProcessBarMode : .FullSquareMode
        self.pickerSelected = displayCategory
    }
}

// MARK: - 🗿 原始数据结构定义

/// 文件结构版本号
struct FileFormatVersion : Codable, Comparable{
    var a, b, c : Int
    
    static func < (lhs: FileFormatVersion, rhs: FileFormatVersion) -> Bool {
        return lhs.a < rhs.a && lhs.b < rhs.b && lhs.c < rhs.c
    }
    
    func str() -> String {
        return "doc-ver: \(a).\(b).\(c)"
    }
}

/// 任务状态改变记录，记录任务状态改变情况，方便查看每日完成情况
struct TaskStatusChangeRecord : Codable {
    var taskId : UUID
    var projectId : UUID
    var groupId : UUID
    var changeDate : Date
    var operate : TaskStatus
    
    var extra : String?
}

/// 任务详情
struct TaskInfo: Codable, Identifiable {
    var name: String        /// 任务名
    var content : String    /// 内容
    var status: TaskStatus  /// 任务状态
    var duration : Double     /// 持续时间
    var createDate : Date   /// 创建日期
    
    var id = UUID()
    var extra : String?
}

/// 项目详情
struct ProjectInfo: Codable, Identifiable {
    var name : String       /// 项目名称
    var tasks : [TaskInfo]  /// 所包含的任务
    
    var id = UUID()
    var extra : String?
}

/// 项目组详情
struct ProjectGroupInfo: Codable, Identifiable {
    var name : String               /// 项目组名称
    var projects : [ProjectInfo]    /// 所包含的项目
    
    var id = UUID()
    var extra : String?
}

/// 文件信息详情
struct FileInfos : Codable {
    var documentVersion : FileFormatVersion /// 文件格式版本
    
    var topic : String                      /// 主题
    var createDate: Date                    /// 文件创建日期
    var author : String                     /// 作者
    var displayMode : DisplayMode           /// 显示模式
    var displayCatagory : DisplayCatagory   /// 显示类别
    
    var extra : String?
}

/// 文件结构
struct PlannerFileStruct: Codable {
    
    var fileInformations : FileInfos                    /// 文件信息
    
    var projectGroups : [ProjectGroupInfo]              /// 所包含的项目组
    var taskStatusChanges : [TaskStatusChangeRecord]    /// 任务改变状态
}


// MARK: - 🆙 可比较支持extension

extension PlannerFileStruct: Equatable{
    static func == (lhs: PlannerFileStruct, rhs: PlannerFileStruct) -> Bool {
        return lhs.fileInformations == rhs.fileInformations &&
            lhs.projectGroups == rhs.projectGroups &&
            lhs.taskStatusChanges == rhs.taskStatusChanges
    }
}

extension FileInfos: Equatable{
    static func == (lhs: FileInfos, rhs: FileInfos) -> Bool {
        return lhs.documentVersion == rhs.documentVersion &&
            lhs.topic == rhs.topic &&
            lhs.createDate == rhs.createDate &&
            lhs.author == rhs.author &&
            lhs.displayMode == rhs.displayMode &&
            lhs.displayCatagory == rhs.displayCatagory &&
            lhs.extra == rhs.extra
    }
}

extension ProjectGroupInfo: Equatable{
    static func == (lhs: ProjectGroupInfo, rhs: ProjectGroupInfo) -> Bool {
        return lhs.name == rhs.name &&
            lhs.projects == rhs.projects &&
            lhs.id == rhs.id &&
            lhs.extra == rhs.extra
    }
}

extension ProjectInfo: Equatable{
    static func == (lhs: ProjectInfo, rhs: ProjectInfo) -> Bool {
        return lhs.name == rhs.name &&
            lhs.tasks == rhs.tasks &&
            lhs.id == rhs.id &&
            lhs.extra == rhs.extra
    }
}

extension TaskInfo: Equatable {
    static func == (lhs: TaskInfo, rhs: TaskInfo) -> Bool {
        return lhs.name == rhs.name &&
            lhs.content == rhs.content &&
            lhs.status == rhs.status &&
            lhs.createDate == rhs.createDate &&
            lhs.duration == rhs.duration &&
            lhs.id == rhs.id &&
            lhs.extra == rhs.extra
    }
}

extension TaskStatusChangeRecord: Equatable{
    static func == (lhs: TaskStatusChangeRecord, rhs: TaskStatusChangeRecord) -> Bool {
        return lhs.taskId == rhs.taskId &&
            lhs.changeDate == rhs.changeDate &&
            lhs.operate == rhs.operate &&
            lhs.extra == rhs.extra
    }
}

extension DateDataDayInfo: Equatable{
    static func == (lhs: DateDataDayInfo, rhs: DateDataDayInfo) -> Bool {
        return lhs.finishedNumber == rhs.finishedNumber &&
            lhs.spentHours == rhs.spentHours &&
            lhs.date == rhs.date
    }
}

extension AppLocalSettings: Equatable {
    static func == (lhs: AppLocalSettings, rhs: AppLocalSettings) -> Bool {
        return lhs.hideFinishedTasks == rhs.hideFinishedTasks &&
            lhs.collectionWaterFlowMode == rhs.collectionWaterFlowMode
    }
}

//MARK: - 🔧功能拓展


//MARK: - 🍮修补拓展
extension TaskInfo {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try! container.decode(type(of: self.name), forKey: .name)
        self.content = try! container.decode(type(of: self.content), forKey: .content)
        self.status = try! container.decode(type(of: self.status), forKey: .status)
        self.createDate = try! container.decode(type(of: self.createDate), forKey: .createDate)
        self.duration = xlimit((try? container.decodeIfPresent(TimeInterval.self, forKey: .duration)) ?? DefalutTaskDuration, min: 0, max: 24 * 3600)
        
        self.id = try! container.decode(type(of: self.id), forKey: .id)
        self.extra = try? container.decode(type(of: self.extra), forKey: .extra)
    }
}



// MARK: - 💆🏼 文件初始化内容

extension PlannerFileStruct {
    ///  初始化简单数据
    static let init_doc = PlannerFileStruct(
        fileInformations: FileInfos(
            documentVersion: CurrentFileFormatVerison,
            topic: L("TEMPLATE.TOPIC"),
            createDate: Date(),
            author: "XPlanner",
            displayMode: .FullSquareMode,
            displayCatagory: .All),
        projectGroups: [ProjectGroupInfo](
            arrayLiteral:ProjectGroupInfo(
                name: L("TEMPLATE.PROJECTGROUP.NAME"),
                projects: [ProjectInfo](
                    arrayLiteral:ProjectInfo(
                        name: L("TEMPLATE.PROJECT.NAME"),
                        tasks: [TaskInfo](
                            arrayLiteral:TaskInfo(name: L("TEMPLATE.TASK.NAME") + "1",content: L("TEMPLATE.TASK.CONTENT") + "1",status: .finished,duration: DefalutTaskDuration, createDate: Date(), id: UUID()),
                            TaskInfo(name: L("TEMPLATE.TASK.NAME") + "2",content: L("TEMPLATE.TASK.CONTENT") + "2",status: .todo,duration: DefalutTaskDuration, createDate: Date(), id: UUID()),
                            TaskInfo(name: L("TEMPLATE.TASK.NAME") + "3",content: L("TEMPLATE.TASK.CONTENT") + "3",status: .original,duration: DefalutTaskDuration, createDate: Date(), id: UUID())
                        ),
                        id: UUID()),
                    ProjectInfo(
                        name: L("TEMPLATE.PROJECT.NAME"),
                        tasks: [TaskInfo](),
                        id: UUID())
                ),
                id: UUID()),
            ProjectGroupInfo(name: L("TEMPLATE.PROJECTGROUP.NAME.NULL"), projects: [ProjectInfo]())
        ),
        taskStatusChanges: [TaskStatusChangeRecord]()
    )
}

func TaskTemplate() -> TaskInfo {
    return TaskInfo(name: L("NEW.TASK.NAME"), content: L("NEW.TASK.CONTENT"), status: .original, duration: DefalutTaskDuration, createDate: Date())
}

func L(_ localStr: String) -> String{
    return NSLocalizedString(localStr, comment: "")
}
