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
    var onClick : (()->Void)?
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Rectangle()
                .foregroundColor(Color("ToggleBarBackgroundColor"))
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Circle()
                        .strokeBorder()
                        .foregroundColor(Color("AccentColor"))
                        .padding(.all, 3)
                        .overlay(
                            Image(systemName: configuration.isOn ? onImageName : offImageName).scaleEffect(0.6 )
                        )
                        .offset(x: configuration.isOn ? 11 : -11, y: 0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5))
                ).cornerRadius(20)
                .onTapGesture {
                    configuration.isOn.toggle()
                    onClick?()
                }
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
        VStack{HStack{
            ForEach(missionsWithStatus.indices, id: \.self){ i in
            RoundedRectangle(cornerRadius: 2.5)
                .frame(height: 5)
                .foregroundColor(
                     colorMap[missionsWithStatus[i].status]
                )
            }}.frame(maxWidth: .infinity)
        }
        .frame(height: 10)
        .padding(5)
        .background(Color("BarsBackgroundColor"))
        .cornerRadius(7.5)
        .shadow(color: Color("ShallowShadowColor"), radius: 10, x: 0.0, y: 0.0)
    }
}
