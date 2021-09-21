//
//  PlannerDataManager.swift
//  XPlanner
//
//  Created by Esther on 2021/9/19.
//

import Foundation
import SwiftUI

class PlannerDataManager: ObservableObject {
    @Published var docData : PlannerFileStruct
    
    init(data :inout PlannerFileStruct) {
        docData = data
    }
    
    func add() {
//        objectWillChange.send()
        docData.projectGroups.append(
            ProjectGroupInfo(
            name: Date().description,
            projects: [ProjectInfo](),
            id: UUID()
        ))
    }
}
