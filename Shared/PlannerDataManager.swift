//
//  PlannerDataManager.swift
//  XPlanner
//
//  Created by Esther on 2021/9/19.
//

import Foundation

class PlannerDataManager: ObservableObject {
    @Published var docData : PlannerFileStruct
    
    init(data : PlannerFileStruct) {
        docData = data
    }
}
