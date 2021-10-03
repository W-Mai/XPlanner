//
//  PlannerDataManager.swift
//  XPlanner
//
//  Created by Esther on 2021/9/19.
//

import Foundation
import SwiftUI

extension XPlanerDocument {
    func replaceTheWholeFile(with file : [ProjectGroupInfo], _ undoManager : UndoManager?){
        let old = plannerData.projectGroups
        
        plannerData.projectGroups = file
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.replaceTheWholeFile(with: old, undoManager)
        })
    }
    
    func addGroup(nameIs grpName : String , _ undoManager : UndoManager?) {
        let res = ProjectGroupInfo(
            name: grpName,
            projects: [ProjectInfo]()
        )
        plannerData.projectGroups.append(res)
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.removeGroup(idIs: res.id, undoManager)
        })
    }
    
    func removeGroup(idIs grpId : UUID, _ undoManager : UndoManager?){
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return }
        
        let old_data = plannerData.projectGroups
        print(old_data.count)
        plannerData.projectGroups.remove(at: index)
        print(old_data.count)
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.replaceTheWholeFile(with: old_data, undoManager)
        })
    }
    
    func updateGroup(to name : String, idIs grpId : UUID, _ undoManager : UndoManager?){
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return }
        
        let old_data = plannerData.projectGroups[index].name
        
        plannerData.projectGroups[index].name = name
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.updateGroup(to: old_data, idIs: grpId, undoManager)
        })
    }
    
    func addProject(nameIs prjName : String , for grpId : UUID, _ undoManager : UndoManager?) {
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return }
        
        let res = ProjectInfo(name: prjName, tasks: [TaskInfo]())
        plannerData.projectGroups[index].projects.append(res)
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.removeProject(idIs: res.id, from: grpId, undoManager)
        })
        
    }
    
    func removeProject(idIs prjId : UUID, from grpId : UUID, _ undoManager : UndoManager?){
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return }
        
        guard let indexPrj = plannerData.projectGroups[index].projects.firstIndex (where: { prj in
            prj.id == prjId
        }) else { return }
        
        let old_data = plannerData.projectGroups
        
        plannerData.projectGroups[index].projects.remove(at: indexPrj)
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.replaceTheWholeFile(with: old_data, undoManager)
        })
    }
    
    func updateProject(to prjName :String,idIs prjId : UUID, from grpId : UUID, _ undoManager : UndoManager?){
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return }
        
        guard let indexPrj = plannerData.projectGroups[index].projects.firstIndex (where: { prj in
            prj.id == prjId
        }) else { return }
        
        let old_data = plannerData.projectGroups[index].projects[indexPrj].name
        
        plannerData.projectGroups[index].projects[indexPrj].name = prjName
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.updateProject(to: old_data, idIs: prjId, from: grpId, undoManager)
        })
    }
    
    func addTask(nameIs tskName : String, contentIs taskContent : String, for prjId : UUID,in grpId : UUID ,_ undoManager : UndoManager?) -> TaskInfo?{
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return nil }
        
        guard let indexPrj = plannerData.projectGroups[index].projects.firstIndex (where: { prj in
            prj.id == prjId
        }) else { return nil }
        
        let res = TaskInfo(name: tskName, content: taskContent, status: .original, createDate: Date())
        plannerData.projectGroups[index].projects[indexPrj].tasks.append(res)
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.removeTask(idIs: res.id, from: prjId, in: grpId, undoManager)
        })
        
        return res
    }
    
    func removeTask(idIs tskId : UUID, from prjId : UUID, in grpId : UUID , _ undoManager : UndoManager?){
        guard let index = indexOfTask(idIs: tskId, from: prjId, in: grpId) else { return }
        
        let old_data = plannerData.projectGroups
        plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks.remove(at: index.tskIndex)
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.replaceTheWholeFile(with: old_data, undoManager)
        })
    }
    
    func updateTaskStatus(tskStatus : TaskStatus, idIs tskId : UUID, from prjId : UUID, in grpId : UUID , _ undoManager : UndoManager?){
        guard let index = indexOfTask(idIs: tskId, from: prjId, in: grpId) else { return }
        
        let old_status = plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex].status
        
        plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex].status = tskStatus
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.updateTaskStatus(tskStatus: old_status, idIs: tskId, from: prjId, in: grpId, undoManager)
        })
    }
    
    func updateTaskInfo(tsk : TaskInfo, for index : TaskIndexPath , _ undoManager : UndoManager?){
        let old_tsk = plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex]
        
        plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex] = tsk
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.updateTaskInfo(tsk: old_tsk, for: index, undoManager)
        })
    }
    
    func getLastAddedTask(from prjId : UUID, in grpId : UUID) -> TaskInfo {
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return TaskTemplate()}
        
        guard let indexPrj = plannerData.projectGroups[index].projects.firstIndex (where: { prj in
            prj.id == prjId
        }) else { return TaskTemplate()}
        
        guard let lst_tsk = plannerData.projectGroups[index].projects[indexPrj].tasks.last
        else { return TaskTemplate() }
        return lst_tsk
    }
    
    func getFirstTask(where cmp : (TaskInfo) -> Bool , from prjId : UUID, in grpId : UUID) -> TaskInfo {
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return TaskTemplate()}
        
        guard let indexPrj = plannerData.projectGroups[index].projects.firstIndex (where: { prj in
            prj.id == prjId
        }) else { return TaskTemplate()}
        
        guard let tsk = plannerData.projectGroups[index].projects[indexPrj].tasks.firstIndex(where: { v in
            cmp(v)
        }) else { return TaskTemplate() }
        
        return plannerData.projectGroups[index].projects[indexPrj].tasks[tsk]
    }
    
    func indexOfTask(idIs tskId : UUID, from prjId : UUID, in grpId : UUID) -> TaskIndexPath?{
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return nil }
        
        guard let indexPrj = plannerData.projectGroups[index].projects.firstIndex (where: { prj in
            prj.id == prjId
        }) else { return nil }
        
        guard let indexTsk = plannerData.projectGroups[index].projects[indexPrj].tasks.firstIndex (where: { tsk in
            tsk.id == tskId
        }) else { return nil }
        
        return TaskIndexPath(prjGrpIndex: index, prjIndex: indexPrj, tskIndex: indexTsk)
    }
    
    func updateDisplayCategory(to category: DisplayCatagory ,_ undoManager : UndoManager?){
        let old_category = plannerData.fileInformations.displayCatagory
        plannerData.fileInformations.displayCatagory = category
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.updateDisplayCategory(to: old_category, undoManager)
        })
    }
    
    func toggleDisplayMode(displayMode: DisplayMode ,_ undoManager : UndoManager?){
        let old_val = plannerData.fileInformations.displayMode
        plannerData.fileInformations.displayMode = displayMode
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.toggleDisplayMode(displayMode: old_val, undoManager)
        })
    }
}
