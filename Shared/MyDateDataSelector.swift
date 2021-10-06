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
    var fnshLabel : PaddingLabel!
    var hourLabel : PaddingLabel!
    var dateLabel : PaddingLabel!
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
        fnshLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: fnshAndHourGroup.frame.width, height: fnshAndHourGroup.frame.height * 0.6))
        hourLabel = PaddingLabel(frame: CGRect(x: 0, y: fnshLabel.frame.height * 0.9, width: fnshLabel.frame.width, height: fnshAndHourGroup.frame.height * 0.4))
        dateLabel = PaddingLabel(frame: CGRect(x: 0, y: frame.height / 4 * 3, width: frame.width, height: frame.height / 4))
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
    var scrollingAction: ((Int)->())?
    
    var itemNumber = 0
    
    var source: [Date : DateDataDayInfo]!
    
    var preIndex : NSInteger = -1
    
    func scrolledToTheCurrentItemAtIndex(itemIndex: NSInteger) {
        
        if preIndex != itemIndex {
            MyFeedBack()
            
            scrollingAction?(xlimit(itemIndex, min: 0, max: itemNumber))
            
            preIndex = itemIndex
        }
    }
    
    func findInfo(of date: Date) -> DateDataDayInfo? {
        let targetDate = formatDateOnlyYMD(date: date)
        return source[targetDate]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let current = Date()
        let f = DateFormatter()
        f.dateFormat = "YYYYMMdd"
        let fromDate = f.date(from: "20201123")!
    
        itemNumber = Calendar.current.dateComponents([.day], from: fromDate, to: current).day ?? 0
        return itemNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCell
        
        let targetDate = index2date(index: indexPath.row)
        if let info = findInfo(of: targetDate) {
            cell.setInfos(finishedTimes: info.finishedNumber, hours: info.spentHours, date: info.date)
        } else {
            cell.setInfos(finishedTimes: 0, hours: 0, date: targetDate)
        }
        
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
    var delegate: UICardScaleFlowLayoutDelegate?
    
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
        
        let itemIndex: NSInteger = NSInteger(floor(CGFloat(self.collectionView!.contentOffset.x / (itemSize.width + internalItemSpacing)) + 0.5))
        delegate?.scrolledToTheCurrentItemAtIndex(itemIndex: itemIndex)
        
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

struct MyDateDataSelectorReader: View {
    var view : MyDateDataSelector
    var function: ()->()
    
    var body: some View {
        function()
        
        return view
    }
}

struct MyDateDataSelector: UIViewRepresentable {
    typealias UIViewType = UICollectionView
    
    var scrollingAction: ((Int, @escaping (Int)->())->())?
    
    @Binding var currentIndex : Int
    @State var datasource : [Date: DateDataDayInfo]
    
    func makeUIView(context: Context) -> UIViewType {
        var mainCollection: UICollectionView!
        var mainCollectionLayout : UICardScaleFlowLayout!
        var collectionDataSource : MyDataSource!
        
        collectionDataSource = MyDataSource()
        collectionDataSource.source = context.coordinator.source.wrappedValue
        collectionDataSource.scrollingAction = updateScrollIndexAction(_:)
        
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
        (uiView.dataSource as! MyDataSource).source = context.coordinator.source.wrappedValue
        //        if targetIndex != -1{
        //        uiView.scrollToItem(at: IndexPath(row: context.coordinator.index.wrappedValue, section: 0), at: .centeredHorizontally, animated: true)
        //            targetIndex = -1
        //        }
    }
    
    static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {
        
    }
    
    func updateScrollIndexAction(_ index: Int) {
        currentIndex = index
        
        scrollingAction?(index, scrollTo(index:))
    }
    
    func scrollTo(index: Int) {
        //        targetIndex = index
    }
    
    class Coordinator: NSObject {
        var index : Binding<Int>
        var source : Binding<[Date: DateDataDayInfo]>
        
        var lastTargetIndex : Int = 0
        var targetIndex : Int = 0
        
        init(index : Binding<Int>, source: Binding<[Date: DateDataDayInfo]>) {
            self.index = index
            self.source = source
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(index: $currentIndex, source: $datasource)
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
}

func extractDateDataInfos(from pln: XPlanerDocument) -> [Date: DateDataDayInfo] {
    var dateTasksMap:[Date:[TaskInfo]] = [:]
    
    for item in pln.plannerData.taskStatusChanges {
        if item.operate != .finished {
            continue
        }
        
        guard let index = pln.indexOfTask(idIs: item.taskId, from: item.projectId, in: item.groupId) else {
            pln.removeTaskChangeRecord(record: item)
            continue
        }
        
        let tsk = pln.plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex]
        
        let targetDate = Calendar.current.dateComponents([.year, .month, .day, .calendar], from: item.changeDate).date!
        
        dateTasksMap[targetDate] = dateTasksMap[targetDate] ?? []
        dateTasksMap[targetDate]!.append(tsk)
    }
    
    var result: [Date: DateDataDayInfo] = [:]
    
    for item in dateTasksMap {
        var times: Int = 0
        var hours: Double = 0.0
        
        for _ in item.value {
            times += 1
            hours += 1
        }
        
        result[item.key] = DateDataDayInfo(finishedNumber: times, spentHours: hours, date: item.key)
    }
    
    return result
}

func index2date(index: Int) -> Date {
    let date = Date()
    let targetDate = Calendar.current.date(byAdding: Calendar.Component.day, value: -index, to: date)!
    return targetDate
}

func formatDateOnlyYMD(date: Date) -> Date {
    return Calendar.current.dateComponents([.year, .month, .day, .calendar], from: date).date!
}

func filterTasks(pln: XPlanerDocument , on date: Date) -> PlannerFileStruct {
    var result: PlannerFileStruct = PlannerFileStruct(
        fileInformations: pln.plannerData.fileInformations,
        projectGroups: [ProjectGroupInfo](
            arrayLiteral: ProjectGroupInfo(
                name: L("TEMPLATE.PROJECTGROUP.NAME"),
                projects: [ProjectInfo](
                    arrayLiteral: ProjectInfo(name: L("TASK.STATUS.FINISHED"), tasks: [TaskInfo]())
                ))),
        taskStatusChanges: [TaskStatusChangeRecord]())
    
    for item in pln.plannerData.taskStatusChanges {
        let targetDate = formatDateOnlyYMD(date: date)
        let compatedDate = formatDateOnlyYMD(date: item.changeDate)
        
        if targetDate != compatedDate || item.operate != .finished {
            continue
        }
        
        guard let index = pln.indexOfTask(idIs: item.taskId, from: item.projectId, in: item.groupId)
        else { continue }
        
        result.projectGroups[0].projects[0].tasks.append(
            pln.plannerData.projectGroups[index.prjGrpIndex].projects[index.prjIndex].tasks[index.tskIndex]
        )
    }
    
    return result
}

struct OK: View {
    @State var num : Int = 0
    
    @State var scrollToFunc : ((Int)->())? = nil
    
    
    var source:[Date: DateDataDayInfo] = [Calendar.current.dateComponents([.year, .month, .day, .calendar], from: Date()).date!: DateDataDayInfo(finishedNumber: 1, spentHours: 1, date: Date())]
    
    var body: some View{
        VStack{
            Text("\(num)")
            Button(action: {
                num += 1
            }, label: {
                Text("Add")
            })
            
            MyDateDataSelector(currentIndex: $num, datasource: source)
        }
    }
}

struct MyDateDataSelector_Previews: PreviewProvider {
    
    
    static var previews: some View {
        OK()
    }
}
