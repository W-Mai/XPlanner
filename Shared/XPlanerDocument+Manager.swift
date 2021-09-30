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
    
    func updateGroup(to name : String, idIs grpId : UUID, _ undoManager : UndoManager?){
        guard let index = plannerData.projectGroups.firstIndex (where: { grp in
            grp.id == grpId
        }) else { return }
        
        let old_data = plannerData.projectGroups[index].name
        
        plannerData.projectGroups[index].name = name
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.plannerData.projectGroups[index].name = old_data
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
            doc.plannerData.projectGroups[index].projects[indexPrj].name = old_data
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
            doc.plannerData.projectGroups[index].projects[indexPrj].tasks.removeLast()
        })
        
        return res
    }
    
    func removeTask(idIs tskId : UUID, from prjId : UUID, in grpId : UUID , _ undoManager : UndoManager?){
        guard let index = indexOfTask(idIs: tskId, from: prjId, in: grpId) else { return }
        
        let old_data = plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex]
        
        plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks.remove(at: index.tskIndex)
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks.insert(old_data, at: index.tskIndex)
        })
    }
    
    func updateTaskStatus(tskStatus : TaskStatus, idIs tskId : UUID, from prjId : UUID, in grpId : UUID , _ undoManager : UndoManager?){
        guard let index = indexOfTask(idIs: tskId, from: prjId, in: grpId) else { return }
        
        let old_status = plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex].status
        
        plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex].status = tskStatus
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex].status = old_status
        })
    }
    
    func updateTaskInfo(tsk : TaskInfo, for index : TaskIndexPath , _ undoManager : UndoManager?){
        let old_tsk = plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex]
        
        plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex] = tsk
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex] = old_tsk
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
    
    func toggleDisplayMode(simple: Bool ,_ undoManager : UndoManager?){
        plannerData.fileInformations.displayMode = simple ? .SimpleProcessBarMode : .FullSquareMode
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.toggleDisplayMode(simple: !simple, undoManager)
        })
    }
}
