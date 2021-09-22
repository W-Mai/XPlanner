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
}
