//
//  SmallComponent.swift
//  XPlanner
//
//  Created by W-Mai on 2021/9/29.
//

import SwiftUI
import UIKit

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

class PaddingLabel: UILabel {
    
    var textInsets: UIEdgeInsets = .zero
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insets = textInsets
        var rect = super.textRect(forBounds: bounds.inset(by: insets),
                                  limitedToNumberOfLines: numberOfLines)
        
        rect.origin.x -= insets.left
        rect.origin.y -= insets.top
        rect.size.width += (insets.left + insets.right)
        rect.size.height += (insets.top + insets.bottom)
        return rect
    }
    
}

struct MyCountDownPicker: UIViewRepresentable {
    typealias UIViewType = UIDatePicker
    
    @Binding var val: TimeInterval
    
    func makeUIView(context: Context) -> UIViewType {
        let picker = UIViewType(frame: .zero)
        
        picker.datePickerMode = .countDownTimer
        picker.minuteInterval = 15
        picker.countDownDuration = 3600
        picker.backgroundColor = UIColor(named: "BarsBackgroundColor")
        
        picker.addTarget(context.coordinator, action: #selector(context.coordinator.doSomething(sender:forEvent:)), for: .valueChanged)
        return picker
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.countDownDuration = val
    }

    class Coordinator: NSObject {
        var interval: Binding<TimeInterval>
        
        init(interval: Binding<TimeInterval>) {
            self.interval = interval
        }
        
        @objc func doSomething(sender: UIDatePicker, forEvent event: UIEvent){
            interval.wrappedValue = sender.countDownDuration
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(interval: $val)
    }
}

struct SmallComponent_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MyTextFiled(title: "Title", text: .constant("Hello"), tilt: Color("FavoriteColor7"))
        }.previewLayout(.sizeThatFits)
    }
}
