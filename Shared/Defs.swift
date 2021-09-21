//
//  Defs.swift
//  XPlaner
//
//  Created by Esther on 2021/9/17.
//
import SwiftUI

// MARK: - 原始数据结构定义

/// 任务状态
enum TaskStatus: String, Codable {
    case finished,
         original,
         todo
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

/// 文件结构版本号
struct FileFormatVersion : Codable, Comparable{
    var a, b, c : Int
    
    static func < (lhs: FileFormatVersion, rhs: FileFormatVersion) -> Bool {
        return lhs.a < rhs.a && lhs.b < rhs.b && lhs.c < rhs.c
    }
}

/// 任务状态改变记录，记录任务状态改变情况，方便查看每日完成情况
struct TaskStatusChangeRecord : Codable {
    var taskId : UUID
    var changeDate : Date
    var operate : TaskInfo
    
    var extra : String?
}

/// 任务详情
struct TaskInfo: Codable, Identifiable {
    var name: String        /// 任务名
    var content : String    /// 内容
    var status: TaskStatus  /// 任务状态
    var createDate : Date   /// 创建日期
    
    var id : UUID
    var extra : String?
}

/// 项目详情
struct ProjectInfo: Codable, Identifiable {
    var name : String       /// 项目名称
    var tasks : [TaskInfo]  /// 所包含的任务
    
    var id : UUID
    var extra : String?
}

/// 项目组详情
struct ProjectGroupInfo: Codable, Identifiable {
    var name : String               /// 项目组名称
    var projects : [ProjectInfo]    /// 所包含的项目
    
    var id : UUID
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


// MARK: - 可比较支持extension

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

// MARK: - 文件初始化内容

extension PlannerFileStruct {
    ///  初始化简单数据
    static let init_doc = PlannerFileStruct(
        fileInformations: FileInfos(
            documentVersion: CurrentFileFormatVerison,
            topic: "计划",
            createDate: Date(),
            author: "XPlanner",
            displayMode: .FullSquareMode,
            displayCatagory: .All),
        projectGroups: [ProjectGroupInfo](
            arrayLiteral:ProjectGroupInfo(
                name: "项目组",
                projects: [ProjectInfo](
                    arrayLiteral:ProjectInfo(
                        name: "项目",
                        tasks: [TaskInfo](
                            arrayLiteral:TaskInfo(name: "任务1",content: "任务内容1",status: .finished,createDate: Date(), id: UUID()),
                            TaskInfo(name: "任务2",content: "任务内容2",status: .todo,createDate: Date(), id: UUID()),
                            TaskInfo(name: "任务3",content: "任务内容3",status: .original,createDate: Date(), id: UUID())
                        ),
                        id: UUID())),
                id: UUID())
        ),
        taskStatusChanges: [TaskStatusChangeRecord]()
    )
}
