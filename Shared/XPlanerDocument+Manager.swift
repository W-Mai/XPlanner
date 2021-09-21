//
//  PlannerDataManager.swift
//  XPlanner
//
//  Created by Esther on 2021/9/19.
//

import Foundation
import SwiftUI

extension XPlanerDocument {
    func add() {
        objectWillChange.send()
        plannerData.projectGroups.append(
            ProjectGroupInfo(
            name: Date().description,
            projects: [ProjectInfo](),
            id: UUID()
        ))
    }
}
