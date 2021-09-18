//
//  XPlanerApp.swift
//  Shared
//
//  Created by Esther on 2021/9/9.
//
//

import SwiftUI

@main
struct XPlanerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: XPlanerDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
