//
//  SmallComponent.swift
//  XPlanner
//
//  Created by Esther on 2021/9/29.
//

import SwiftUI

struct MyTextFiled: View {
    var title : String
    @Binding var text : String
    var tilt : Color
    
    var body: some View {
        HStack{
            Text(title).padding(10).foregroundColor(tilt).minimumScaleFactor(0.2).frame(width: 60)
            Divider()
            TextField(text, text: $text)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tilt, lineWidth: 1)
        ).background(Color("BarsBackgroundColor"))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .frame(height: 40)
    }
}

struct SmallComponent_Previews: PreviewProvider {
    static var previews: some View {
        MyTextFiled(title: "Title", text: .constant("Hello"), tilt: Color("FavoriteColor7"))
    }
}
