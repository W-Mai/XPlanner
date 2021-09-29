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
        DocumentGroup { XPlanerDocument() } editor: { file in
            ContentView().environmentObject(EnvironmentSettings(simpleMode: file.document.plannerData.fileInformations.displayMode == .SimpleProcessBarMode, displayCategory: file.document.plannerData.fileInformations.displayCatagory))
        }
    }
}
