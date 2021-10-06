//
//  MyDateDataSelector.swift
//  XPlanner
//
//  Created by Esther on 2021/10/6.
//

import SwiftUI
import UIKit


class MyCell: UICollectionViewCell {
    var expanded = false
    var originalSize : CGSize!
    
    var finishedTimes : Int = 0
    var hours : Double = 0
    var date : Date = Date()
    
    var fnshAndHourGroup : UIView!
    var fnshLabel : HomePaddingLabel!
    var hourLabel : HomePaddingLabel!
    var dateLabel : HomePaddingLabel!
    var statusDot : UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        originalSize = frame.size
        initView()
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView(){
        fnshAndHourGroup = UIView(frame: CGRect(x: frame.width * 0.1, y: frame.width * 0.1, width: frame.width * 0.8, height: frame.width * 0.8))
        fnshLabel = HomePaddingLabel(frame: CGRect(x: 0, y: 0, width: fnshAndHourGroup.frame.width, height: fnshAndHourGroup.frame.height * 0.6))
        hourLabel = HomePaddingLabel(frame: CGRect(x: 0, y: fnshLabel.frame.height * 0.9, width: fnshLabel.frame.width, height: fnshAndHourGroup.frame.height * 0.4))
        dateLabel = HomePaddingLabel(frame: CGRect(x: 0, y: frame.height / 4 * 3, width: frame.width, height: frame.height / 4))
        statusDot = UIView(frame: CGRect(x: frame.width * 0.45, y: (fnshAndHourGroup.frame.maxY + dateLabel.frame.minY) / 2 - frame.width*0.05, width: frame.width*0.1, height: frame.width*0.1))
        
        fnshLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        fnshLabel.adjustsFontSizeToFitWidth = true
        fnshLabel.textInsets = UIEdgeInsets(top: 6, left: 6, bottom: 0, right: 6)
        fnshLabel.baselineAdjustment = .alignCenters
        hourLabel.font =  UIFont.systemFont(ofSize: 8, weight: .medium)
        hourLabel.adjustsFontSizeToFitWidth = true
        hourLabel.textInsets = UIEdgeInsets(top: 6, left: fnshAndHourGroup.frame.width / 8, bottom: 6, right: fnshAndHourGroup.frame.width / 8)
        dateLabel.font = UIFont.systemFont(ofSize: 8)
        
        fnshLabel.textAlignment = .center
        hourLabel.textAlignment = .center
        dateLabel.textAlignment = .center
        
        fnshAndHourGroup.layer.borderWidth = 1
        fnshAndHourGroup.layer.borderColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        fnshAndHourGroup.layer.cornerRadius = fnshAndHourGroup.frame.size.width / 2
        
        statusDot.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        statusDot.layer.cornerRadius = statusDot.frame.width / 2
        
        self.backgroundColor = UIColor(named: "DateCellBackgroundColor")
        self.layer.cornerRadius = frame.width / 2
        
        fnshAndHourGroup.addSubview(fnshLabel)
        fnshAndHourGroup.addSubview(hourLabel)
        addSubview(fnshAndHourGroup)
        addSubview(statusDot)
        addSubview(dateLabel)
        
        setShadow(color: UIColor(named: "ShallowShadowColor")!)
    }
    
    func setInfos(finishedTimes: Int, hours: Double, date: Date) {
        self.finishedTimes = finishedTimes
        self.hours = hours
        self.date = date
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.setLocalizedDateFormatFromTemplate("MMd")
        
        fnshLabel.text = "\(self.finishedTimes)"
        hourLabel.text = String(format:"%.1fh", self.hours)
        dateLabel.text = dateFormatter.string(from: date)
        statusDot.backgroundColor = finishedTimes > 0 ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : nil
    }
    
    func update() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction) {
            self.backgroundColor = self.expanded ? UIColor(named: "DateCellBackgroundColorBurnt") : UIColor(named: "DateCellBackgroundColor")
            self.layer.borderColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            self.layer.borderWidth = self.expanded ? 1 : 0
            self.fnshAndHourGroup.layer.borderColor = self.fnshAndHourGroup.layer.borderColor?.copy(alpha: self.expanded ? 1 : 0.2)
        }
    }
}

class MyDataSource: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICardScaleFlowLayoutDelegate {
    var preIndex : NSInteger = -1
    func scrolledToTheCurrentItemAtIndex(itemIndex: NSInteger) {
        if preIndex != itemIndex {
            MyFeedBack()
            
            preIndex = itemIndex
        }
        print("???", itemIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCell

        cell.setInfos(finishedTimes: Int.random(in: 0..<10), hours: Double.random(in: 0..<6), date: Date().addingTimeInterval(TimeInterval(indexPath.row * 3600 * 3)))
//        cell.titleLabel?.text = "\(indexPath.row)"
        print("OK", indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

protocol UICardScaleFlowLayoutDelegate {
    func scrolledToTheCurrentItemAtIndex(itemIndex:NSInteger) ->Void
}

class UICardScaleFlowLayout: UICollectionViewLayout {
    var itemCount:Int = 0
    var internalItemSpacing = CGFloat(8)
    var itemSize = CGSize.init(width: 160, height: 300)
    var sectionEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var scale:CGFloat = 0.80
    var currentItemIndex = CGFloat(0.0)
    var delegate:UICardScaleFlowLayoutDelegate?

    override func prepare() {
        super.prepare()
        itemCount = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        if internalItemSpacing == 0 {
            internalItemSpacing = 5
        }
        if sectionEdgeInsets.top == 0 && sectionEdgeInsets.bottom == 0 && sectionEdgeInsets.left == 0 && sectionEdgeInsets.right == 0 {
            sectionEdgeInsets = UIEdgeInsets( top: 0 , left: (UIScreen.main.bounds.size.width - itemSize.width) / 2 , bottom: 0 , right: (UIScreen.main.bounds.size.width - itemSize.width) / 2)
        }
    }
    
    override var collectionViewContentSize: CGSize{
        let contentWidth:CGFloat
            = sectionEdgeInsets.left
            + sectionEdgeInsets.right
            + CGFloat(itemCount) * itemSize.width
            + CGFloat(itemCount - 1) * internalItemSpacing
        
        let contentHeight:CGFloat
            = sectionEdgeInsets.top
            + sectionEdgeInsets.bottom
            + itemSize.height
        return CGSize(width: contentWidth , height: contentHeight)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attr = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        attr.size = itemSize
        attr.frame = CGRect.init(
            x: CGFloat(indexPath.row) * (itemSize.width + internalItemSpacing) + sectionEdgeInsets.left,
            y: (self.collectionView!.bounds.size.height - itemSize.height) / 2,
            width: attr.size.width,
            height: attr.size.height
        )
        return attr
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes:[UICollectionViewLayoutAttributes] = []
        
        let componentWidth: CGFloat = (self.collectionView?.frame.width)!

        let centerX = self.collectionView!.contentOffset.x + componentWidth / 2
        
        let itemIndex = floor(CGFloat(self.collectionView!.contentOffset.x / (itemSize.width + internalItemSpacing)) + 0.5)
        delegate?.scrolledToTheCurrentItemAtIndex(itemIndex: NSInteger(itemIndex))
        
        for i in 0..<itemCount {
            let indexPath = IndexPath.init(row: i, section: 0)
            let attr = layoutAttributesForItem(at: indexPath)!
            
            attributes.append(attr)
            if !rect.intersects(attr.frame) {
                continue
            }
            let xOffset = abs(attr.center.x - centerX)
            
            let _scale = 1 - (xOffset * (1 - scale)) / ((componentWidth + itemSize.width) / 2 - self.internalItemSpacing)
            let _scale2 = _scale * _scale
            attr.transform = CGAffineTransform(scaleX: _scale2, y: _scale2)
            
            
            if let cell = collectionView?.cellForItem(at: indexPath) as? MyCell {
                if NSInteger(itemIndex) == i {
                    cell.expanded = true
                } else {
                    cell.expanded = false
                }
                cell.update()
            }
        }
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                             withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let itemIndex = CGFloat(self.collectionView!.contentOffset.x / (itemSize.width + internalItemSpacing))
        currentItemIndex = CGFloat(floor(Double(itemIndex + 3 * velocity.x) + 0.5))
        let xOffset = currentItemIndex * (internalItemSpacing + itemSize.width)
        return CGPoint(x: xOffset, y: 0)
    }

}


struct MyDateDataSelector: UIViewRepresentable {
    typealias UIViewType = UICollectionView
    
    func makeUIView(context: Context) -> UIViewType {
        var mainCollection: UICollectionView!
        var mainCollectionLayout : UICardScaleFlowLayout!
        var collectionDataSource : MyDataSource!
        
        
        collectionDataSource = MyDataSource()
        
        mainCollectionLayout = UICardScaleFlowLayout()
        mainCollectionLayout.itemSize = CGSize(width: 50, height: 75)
        
        mainCollectionLayout.delegate = collectionDataSource
        
        mainCollection = UIViewType(frame: .zero, collectionViewLayout: mainCollectionLayout)
        
        mainCollection.backgroundColor = UIColor(named: "BarsBackgroundColor")
        
        mainCollection.register(MyCell.self, forCellWithReuseIdentifier: "cell")
        mainCollection.dataSource = collectionDataSource
        mainCollection.contentSize = mainCollectionLayout.collectionViewContentSize
        mainCollection.delegate = collectionDataSource
        mainCollection.showsHorizontalScrollIndicator = false
        
        return mainCollection
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {
        
    }
    
    class Coordinator: NSObject {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
//    func _identifiedViewTree(in uiView: UIViewType) -> _IdentifiedViewTree {
//
//    }
//
//    func _overrideSizeThatFits(_ size: inout CGSize, in proposedSize: _ProposedSize, uiView: UIViewType) {
//
//    }
//
//    func _overrideLayoutTraits(_ layoutTraits: inout _LayoutTraits, for uiView: UIViewType) {
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

struct MyDateDataSelector_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            MyDateDataSelector()
        }
    }
}
