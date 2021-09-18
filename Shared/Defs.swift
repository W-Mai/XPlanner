//
//  Defs.swift
//  XPlaner
//
//  Created by Esther on 2021/9/17.
//
import SwiftUI

enum TaskStatus: String, Codable {
    case finished = "FINISHED",
         original = "ORIGINAL",
         todo = "TODO"
}

enum DisplayMode: String, Codable {
    case FullSquareMode
    case SimpleProcessBarMode
}

enum DisplayCatagory: String, Codable {
    case All
    case Todos
}

struct FileFormatVersion : Codable, Comparable{
    var a, b, c : Int
    
    static func < (lhs: FileFormatVersion, rhs: FileFormatVersion) -> Bool {
        return lhs.a < rhs.a && lhs.b < rhs.b && lhs.c < rhs.c
    }
}

struct TaskStatusChangeRecord : Codable {
    var taskId : UUID
    var changeDate : Date
    var operate : TaskInfo
    
    var extra : String?
}

struct TaskInfo: Codable {
    var name: String
    var content : String
    var status: TaskStatus
    var createDate : Date
    
    var id : UUID
    var extra : String?
}

struct ProjectInfo: Codable {
    var name : String
    var tasks : [TaskInfo]
    
    var id : UUID
    var extra : String?
}

struct ProjectGroupInfo: Codable {
    var name : String
    var projects : [ProjectInfo]
    
    var id : UUID
    var extra : String?
}

struct FileInfos : Codable {
    var documentVersion : FileFormatVersion
    var createDate: Date
    var author : String
    var displayMode : DisplayMode
    var displayCatagory : DisplayCatagory
    
    var extra : String?
}

struct PlannerFileStruct: Codable {
    var fileInformations : FileInfos
    
    var projectGroups : [ProjectGroupInfo]
    var taskStatusChanges : [TaskStatusChangeRecord]
}
