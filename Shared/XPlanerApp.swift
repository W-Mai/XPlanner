//
//  XPlanerApp.swift
//  Shared
//
//  Created by Esther on 2021/9/9.
//
//

import SwiftUI
import CoreData

var runtime_config = EnvironmentSettings(simpleMode: false, displayCategory: .All)
var localSettingsManager : LocalSettingManager!

@main
struct XPlanerApp: App {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocalSettingModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    init() {
        localSettingsManager = LocalSettingManager(container: persistentContainer)
    }
    
    var body: some Scene {
        DocumentGroup { XPlanerDocument() } editor: { file in
            ContentView()
                .environmentObject(runtime_config)
                .environmentObject(localSettingsManager)
                .onAppear(){
                    runtime_config.pickerSelected = file.document.plannerData.fileInformations.displayCategory
                    runtime_config.simpleMode = file.document.plannerData.fileInformations.displayMode == .SimpleProcessBarMode
                    runtime_config.displayMode = file.document.plannerData.fileInformations.displayMode
                    
                    let res = localSettingsManager.readSettings()
                    
                    runtime_config.localSettings = res
                    runtime_config.viewHistoryMode = false
                }
        }
    }
}
