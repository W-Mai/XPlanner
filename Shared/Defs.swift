//
//  Defs.swift
//  XPlaner
//
//  Created by Esther on 2021/9/17.
//
import SwiftUI

// 任务状态
enum TaskStatus: String, Codable {
    case finished = "FINISHED",
         original = "ORIGINAL",
         todo = "TODO"
}

// 显示模式
enum DisplayMode: String, Codable {
    case FullSquareMode // 方形样式
    case SimpleProcessBarMode // 线条进度样式
}

// 显示类别
enum DisplayCatagory: String, Codable {
    case All    // 显示所有任务
    case Todos  // 只显示待办事项
}

// 文件结构版本号
struct FileFormatVersion : Codable, Comparable{
    var a, b, c : Int
    
    static func < (lhs: FileFormatVersion, rhs: FileFormatVersion) -> Bool {
        return lhs.a < rhs.a && lhs.b < rhs.b && lhs.c < rhs.c
    }
}

// 任务状态改变记录，记录任务状态改变情况，方便查看每日完成情况
struct TaskStatusChangeRecord : Codable {
    var taskId : UUID
    var changeDate : Date
    var operate : TaskInfo
    
    var extra : String?
}

// 任务详情
struct TaskInfo: Codable, Identifiable {
    var name: String        // 任务名
    var content : String    // 内容
    var status: TaskStatus  // 任务状态
    var createDate : Date   // 创建日期
    
    var id : UUID
    var extra : String?
}

// 项目详情
struct ProjectInfo: Codable, Identifiable {
    var name : String       // 项目名称
    var tasks : [TaskInfo]  // 所包含的任务
    
    var id : UUID
    var extra : String?
}

// 项目组详情
struct ProjectGroupInfo: Codable, Identifiable {
    var name : String               // 项目组名称
    var projects : [ProjectInfo]    // 所包含的项目
    
    var id : UUID
    var extra : String?
}

// 文件信息详情
struct FileInfos : Codable {
    var documentVersion : FileFormatVersion // 文件格式版本
    
    var topic : String                      // 主题
    var createDate: Date                    // 文件创建日期
    var author : String                     // 作者
    var displayMode : DisplayMode           // 显示模式
    var displayCatagory : DisplayCatagory   // 显示类别
    
    var extra : String?
}

// 文件结构
struct PlannerFileStruct: Codable {
    var fileInformations : FileInfos                    // 文件信息
    
    var projectGroups : [ProjectGroupInfo]              // 所包含的项目组
    var taskStatusChanges : [TaskStatusChangeRecord]    // 任务改变状态
}
