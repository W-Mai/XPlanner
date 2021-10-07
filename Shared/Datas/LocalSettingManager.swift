//
//  LocalSettingManager.swift
//  XPlanner
//
//  Created by Esther on 2021/10/7.
//

import Foundation
import CoreData

class LocalSettingManager: NSObject {
    var container : NSPersistentContainer!
    
    init(container : NSPersistentContainer) {
        self.container = container
    }
    
    func readSettings() -> AppLocalSettings {
        var result = AppLocalSettings(hideFinishedTasks: false, collectionWaterFlowMode: false)
        
        let context = container.viewContext
        let fetch1 = AppSettings.fetchRequest() as NSFetchRequest<AppSettings>
        let fetch2 = AppSettings.fetchRequest() as NSFetchRequest<AppSettings>
        
        fetch1.predicate = NSPredicate(format: "name == %@", "hideFinishedTasks")
        fetch2.predicate = NSPredicate(format: "name == %@", "collectionWaterFlowMode")
        guard let hideFinishedTasksRes = try? context.fetch(fetch1),
              let collectionWaterFlowModeRes = try? context.fetch(fetch2)
        else {
            return result
        }
        
        if hideFinishedTasksRes.count == 0 || collectionWaterFlowModeRes.count == 0 {
            let hideFinishedTasks = AppSettings(context: context)
            hideFinishedTasks.name = "hideFinishedTasks"
            hideFinishedTasks.status = SettingBoolString.NOOK.rawValue
            
            let collectionWaterFlowMode = AppSettings(context: context)
            collectionWaterFlowMode.name = "collectionWaterFlowMode"
            collectionWaterFlowMode.status = SettingBoolString.NOOK.rawValue
            try? context.save()
            
            return result
        }
        print(collectionWaterFlowModeRes, hideFinishedTasksRes)
        
        result.collectionWaterFlowMode = SettingBoolString(rawValue: collectionWaterFlowModeRes[0].status ?? "") == .OK
        result.hideFinishedTasks =  SettingBoolString(rawValue: hideFinishedTasksRes[0].status ?? "") == .OK
        
        return result
    }
    
    func writeSettings(appsettings : AppLocalSettings) {
        clear()

        let context = container.viewContext
        
        let hideFinishedTasks = AppSettings(context: context)
        hideFinishedTasks.name = "hideFinishedTasks"
        hideFinishedTasks.status = appsettings.hideFinishedTasks ? SettingBoolString.OK.rawValue : SettingBoolString.NOOK.rawValue
        
        let collectionWaterFlowMode = AppSettings(context: context)
        collectionWaterFlowMode.name = "collectionWaterFlowMode"
        collectionWaterFlowMode.status = appsettings.collectionWaterFlowMode ? SettingBoolString.OK.rawValue : SettingBoolString.NOOK.rawValue
        try? context.save()
    }
    
    func clear(){
        let context = container.viewContext
        
        let request = AppSettings.fetchRequest() as NSFetchRequest<AppSettings>
        guard let res = try? context.fetch(request)
        else { return }
        
        for item in res {
            context.delete(item)
        }
        
        try? context.save()
    }
}
