//
//  XPlanerApp.swift
//  Shared
//
//  Created by Esther on 2021/9/9.
//
//

import SwiftUI

let CurrentFileFormatVerison = FileFormatVersion(a: 0, b: 0, c: 1)

@main
struct XPlanerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: XPlanerDocument()) { file in
            ContentView(document: file.document)
        }
    }
}
