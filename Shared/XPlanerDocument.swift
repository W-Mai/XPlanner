//
//  XPlanerDocument.swift
//  Shared
//
//  Created by Esther on 2021/9/9.
//
//

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
        original_data = PlannerFileStruct(fileInformations: FileInfos(documentVersion: CurrentFileFormatVerison, topic: "计划", createDate: Date(), author: "", displayMode: .FullSquareMode, displayCatagory: .All), projectGroups: [ProjectGroupInfo](), taskStatusChanges: [TaskStatusChangeRecord]())
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
