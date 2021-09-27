//
//  PlannerDataManager.swift
//  XPlanner
//
//  Created by Esther on 2021/9/19.
//

import Foundation
import SwiftUI

extension XPlanerDocument {
    func addGroup(nameIs grpName : String , _ undoManager : UndoManager?) {
        plannerData.projectGroups.append(
            ProjectGroupInfo(
                name: grpName,
                projects: [ProjectInfo]()
            ))
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.plannerData.projectGroups.removeLast()
        })
        
    }
    
    func removeGroup(idIs grpId : UUID, _ undoManager : UndoManager?){
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return }
        
        let old_data = plannerData.projectGroups[index]
        
        plannerData.projectGroups.remove(at: index)
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.plannerData.projectGroups.insert(old_data, at: index)
        })
    }
    
    func addProject(nameIs prjName : String , for grpId : UUID, _ undoManager : UndoManager?) {
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return }
        plannerData.projectGroups[index].projects.append(ProjectInfo(name: prjName, tasks: [TaskInfo]()))
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.plannerData.projectGroups[index].projects.removeLast()
        })
        
    }
    
    func removeProject(idIs prjId : UUID, from grpId : UUID, _ undoManager : UndoManager?){
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return }
        
        guard let indexPrj = plannerData.projectGroups[index].projects.firstIndex (where: { prj in
            prj.id == prjId
        }) else { return }
        
        let old_data = plannerData.projectGroups[index].projects[indexPrj]
        
        plannerData.projectGroups[index].projects.remove(at: indexPrj)
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.plannerData.projectGroups[index].projects.insert(old_data, at: index)
        })
    }
    
    func toggleDisplayMode(simple: Bool ,_ undoManager : UndoManager?){
        plannerData.fileInformations.displayMode = simple ? .SimpleProcessBarMode : .FullSquareMode
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.toggleDisplayMode(simple: !simple, undoManager)
        })
    }
}
