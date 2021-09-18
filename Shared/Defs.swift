//
//  Defs.swift
//  XPlaner
//
//  Created by Esther on 2021/9/17.
//

enum TaskStatus: String, Codable {
    case finished = "FINISHED",
         original = "ORIGINAL",
         todo = "TODO"
}

enum DisplayMode {
    case FullSquareMode
    case SimpleProcessBarMode
}

struct TaskInfo: Codable {
    var name: String
    var status: TaskStatus
}
