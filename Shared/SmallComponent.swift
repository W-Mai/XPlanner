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

struct MyDateScroller : View {
    var componentSize : CGSize = CGSize(width: 50, height: 50)
    
    struct contentItem : View {
        var value : String
        var size : CGSize
        
        var showDetailsValue : Double
        var showDetailsThreshold : Double = 0.9
        
        var body: some View{
            let expanded: Bool = showDetailsValue > showDetailsThreshold
            let scaleFactor : CGFloat = expanded ? CGFloat((showDetailsValue - showDetailsThreshold)/(1-showDetailsThreshold)*0.5 + 1) : 1.0
            ZStack{
                Color("FavoriteColor7").clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                Text(value)
            }.frame(width: size.width, height: scaleFactor * size.height)
        }
    }
    
    @State var a = 1
    
    var body: some View {
        GeometryReader{ geoReaderScroll in
            VStack {
                Text("\(a)")
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(alignment: .center, spacing: 0){
                        ForEach(0..<10){ i in
                            GeometryReader{ geoReaderContent in
                                let res = getScaleFactor(parentPos: geoReaderScroll.frame(in: .global), subPos: geoReaderContent.frame(in: .global))
                                VStack{
                                    contentItem(value: "\(res[0])", size: componentSize, showDetailsValue: res[0])
                                        .scaleEffect(CGFloat(res[0]))
                                }.frame(height: 75)
                            }.frame(width: 50, height: 75)
                        }
                    }.frame(minWidth: geoReaderScroll.size.width , maxWidth: .infinity)
                }
            }.padding([.vertical], 10)
        }.frame(height: 100)
    }
    
    func getScaleFactor(parentPos : CGRect, subPos: CGRect) -> [Double] {
        let midPos: Double = Double((parentPos.minX + parentPos.maxX) / 2)
        let diff: Double = Double((subPos.maxX + subPos.minX)) / 2 - midPos
        let absDiff: Double = abs(diff)
        let scaleFactor: Double = absDiff < Double(componentSize.width)
            ? 1 - 0.2 * sin(absDiff / Double(componentSize.width) * Double.pi / 2)
            : 0.8
        
        return [scaleFactor, 1 - absDiff / Double(componentSize.width) ]
    }
}

struct SmallComponent_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            MyTextFiled(title: "Title", text: .constant("Hello"), tilt: Color("FavoriteColor7"))

            MyDateScroller()
        }.previewLayout(.sizeThatFits)
    }
}
