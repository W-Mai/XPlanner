//
//  MyComponentStyles.swift
//  XPlanner
//
//  Created by Esther on 2021/9/22.
//

import Foundation
import SwiftUI

// MARK: - Toggle
struct ImageToggleStyle: ToggleStyle {
    
    var onImageName: String
    var offImageName: String
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Rectangle()
                .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9))
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(.all, 3)
                        .overlay(
                            Image(systemName: configuration.isOn ? onImageName : offImageName)
                        )
                        .offset(x: configuration.isOn ? 11 : -11, y: 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5))
                ).cornerRadius(20)
                
                
                //
                .onTapGesture { configuration.isOn.toggle() }
                .animation(.spring(response: 0.3, dampingFraction: 0.5))
        }
        
        
    }
}


// MARK: - ProgressBar
struct MyProgressStyle: ProgressViewStyle {
    var missionsWithStatus: [TaskInfo]
    
    let colorMap:[TaskStatus: Color] = [
        .finished : Color.orange,
        .original : Color.gray,
        .todo     : Color.blue
    ]
    
    func makeBody(configuration: Configuration) -> some View {
        VStack{HStack{ForEach(missionsWithStatus.indices, id: \.self){ i in
            RoundedRectangle(cornerRadius: 2.5)
                .frame(height: 5)
                .foregroundColor(
                     colorMap[missionsWithStatus[i].status]
                )
        }}}
        .padding(5)
        .background(Color.white)
        .cornerRadius(7.5)
        .shadow(color: Color("ShallowShadowColor"), radius: 10, x: 0.0, y: 0.0)
    }
}
