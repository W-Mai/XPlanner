//
//  XPlanerApp.swift
//  Shared
//
//  Created by Esther on 2021/9/9.
//
//

import SwiftUI

var runtime_config = EnvironmentSettings(simpleMode: false, displayCategory: .All)

@main
struct XPlanerApp: App {
    var body: some Scene {
        DocumentGroup { XPlanerDocument() } editor: { file in
            ContentView().environmentObject(runtime_config).onAppear(){
                runtime_config.pickerSelected = file.document.plannerData.fileInformations.displayCatagory
                runtime_config.simpleMode = file.document.plannerData.fileInformations.displayMode == .SimpleProcessBarMode
                runtime_config.viewHistoryMode = false
            }
        }
    }
}
