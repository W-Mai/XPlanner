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
import Intents
import WidgetKit

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

func extractData(from data: Data)throws -> PlannerFileStruct? {
    let decoder = JSONDecoder()
    let product: PlannerFileStruct = try decoder.decode(PlannerFileStruct.self, from: data)
    
    return product
}

func serializeData(from data : PlannerFileStruct)throws -> Data {
    let encoder = JSONEncoder()
    let res = try encoder.encode(data)
    
    return res
}

class XPlanerDocument: ReferenceFileDocument, ObservableObject {
    
    static var readableContentTypes: [UTType] { [.xplaner] }
    
    typealias Snapshot = PlannerFileStruct
    
    @Published var plannerData: Snapshot {
        didSet{
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    init() {
        plannerData = Snapshot.init_doc
    }
    
    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let extracted_data = try extractData(from: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        plannerData = extracted_data
    }
    
    init(with file : INFile) throws {
        
        guard let data = try? FileWrapper(url: file.fileURL!),
              let extracted_data = try? extractData(from: data.regularFileContents!)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        plannerData = extracted_data
    }
    
    func snapshot(contentType: UTType) throws -> PlannerFileStruct {
        plannerData
    }
    
    func fileWrapper(snapshot: Snapshot, configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try serializeData(from: snapshot)
        return .init(regularFileWithContents: data)
    }
}
