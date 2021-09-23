//
//  PlannerDataManager.swift
//  XPlanner
//
//  Created by Esther on 2021/9/19.
//

import Foundation
import SwiftUI

extension XPlanerDocument {
    func add(_ undoManager : UndoManager?) {
        plannerData.projectGroups.append(
            ProjectGroupInfo(
            name: Date().description,
            projects: [ProjectInfo](),
            id: UUID()
        ))
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.plannerData.projectGroups.removeLast()
        })
        
    }
    
    func toggleDisplayMode(simple: Bool ,_ undoManager : UndoManager?){
        plannerData.fileInformations.displayMode = simple ? .SimpleProcessBarMode : .FullSquareMode
        
        undoManager?.registerUndo(withTarget: self, handler: { doc in
            doc.toggleDisplayMode(simple: !simple, undoManager)
        })
    }
}
