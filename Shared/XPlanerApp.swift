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
        let manager = LocalSettingManager(container: persistentContainer)
        manager.writeSettings(appsettings: AppLocalSettings(hideFinishedTasks: false, collectionWaterFlowMode: true))
        let res = manager.readSettings()
        print(res)
    }
    
    var body: some Scene {
        DocumentGroup { XPlanerDocument() } editor: { file in
            ContentView().environmentObject(runtime_config).onAppear(){
                runtime_config.pickerSelected = file.document.plannerData.fileInformations.displayCatagory
                runtime_config.simpleMode = file.document.plannerData.fileInformations.displayMode == .SimpleProcessBarMode
                runtime_config.displayMode = file.document.plannerData.fileInformations.displayMode
                runtime_config.viewHistoryMode = false
            }
        }
    }
}
