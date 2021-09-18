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
func extractData(from data: Data)throws -> String {
    let decoder = JSONDecoder()

    let product = try decoder.decode(GroceryProduct.self, from: data)

    return product.name
}
struct XPlanerDocument: FileDocument {
    var text: String
    var original_data: Data
    
    init(text: String="foggy?") {
        self.text = text
        original_data = """
        {
            "name": "hello",
            "points": 12,
            "description": "hahahah"
        }
        """.data(using: .utf8)!
    }
    
    static var readableContentTypes: [UTType] { [.xplaner] }
    

    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            let string = try extractData(from: data)
            text = string
            original_data = data
        }
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = original_data
        return .init(regularFileWithContents: data)
    }
    
}
