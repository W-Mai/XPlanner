//
//  XPlanerDocument.swift
//  Shared
//
//  Created by Esther on 2021/9/9.
//
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct GroceryProduct: Codable {
    var name: String
    var points: Int
    var description: String?
}

extension UTType {
    static var xplaner: UTType {
        UTType(exportedAs: "com.xclz-studio.xplaner", conformingTo: .data)
    }
}

func extractData(from data: Data)throws -> PlannerFileStruct {
    let decoder = JSONDecoder()
    let product: PlannerFileStruct = try decoder.decode(PlannerFileStruct.self, from: data)
    
    return product
}

func serializeData(from data : PlannerFileStruct)throws -> Data {
    let encoder = JSONEncoder()
    let res = try encoder.encode(data)
    
    return res
}

struct XPlanerDocument: FileDocument {
    var original_data: PlannerFileStruct
    
    init() {
        let author = NSFullUserName()
        
        original_data = PlannerFileStruct(
            fileInformations: FileInfos(documentVersion: CurrentFileFormatVerison,
                                        topic: "计划",
                                        createDate: Date(),
                                        author: author,
                                        displayMode: .FullSquareMode,
                                        displayCatagory: .All),
            projectGroups: [ProjectGroupInfo](arrayLiteral:
                                                ProjectGroupInfo(
                                                    name: "项目组",
                                                    projects: [ProjectInfo](
                                                        arrayLiteral:
                                                            ProjectInfo(
                                                                name: "项目",
                                                                tasks: [TaskInfo](arrayLiteral:
                                                                                    TaskInfo(name: "任务1",content: "任务内容1",status: .finished,createDate: Date(), id: UUID()),
                                                                                  TaskInfo(name: "任务2",content: "任务内容2",status: .todo,createDate: Date(), id: UUID()),
                                                                                  TaskInfo(name: "任务3",content: "任务内容3",status: .original,createDate: Date(), id: UUID())
                                                                ),
                                                                id: UUID())),
                                                    id: UUID()),
                                              ProjectGroupInfo(
                                                  name: "项目组2",
                                                  projects: [ProjectInfo](
                                                      arrayLiteral:
                                                          ProjectInfo(
                                                              name: "项目",
                                                              tasks: [TaskInfo](arrayLiteral:
                                                                                  TaskInfo(name: "任务1",content: "任务内容1",status: .finished,createDate: Date(), id: UUID()),
                                                                                TaskInfo(name: "任务2",content: "任务内容2",status: .todo,createDate: Date(), id: UUID()),
                                                                                TaskInfo(name: "任务3",content: "任务内容3",status: .original,createDate: Date(), id: UUID())
                                                              ),
                                                              id: UUID())),
                                                  id: UUID())),
            taskStatusChanges: [TaskStatusChangeRecord]()
        )
    }
    
    static var readableContentTypes: [UTType] { [.xplaner] }
    
    
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            let string = try extractData(from: data)
            original_data = string
        }
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try serializeData(from: original_data)
        return .init(regularFileWithContents: data)
    }
    
}
