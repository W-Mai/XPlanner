//
//  XPlanner_Widget.swift
//  XPlanner Widget
//
//  Created by Esther on 2021/9/30.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let config =  ConfigurationIntent()
        config.parameter2 = DisplayCategory.value
        return SimpleEntry(date: Date(), displayCategory : .All, tasks: [TaskWithIndexPath]())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), displayCategory : .All, tasks: [TaskWithIndexPath]())
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 1 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            let displayCategory: DisplayCatagory = configuration.parameter2 == .value ? .Todos : .All
            let file : INFile? = configuration.parameter
            var tasks: [TaskWithIndexPath]
            
            if file == nil {
                tasks = [TaskWithIndexPath]()
            } else {
//                let doc = try! XPlanerDocument(with: file!)
                
//                tasks = doc.getAllTasks(of: displayCategory)
                tasks = [TaskWithIndexPath](arrayLiteral: TaskWithIndexPath(task: TaskInfo(name: file!.fileURL!.description, content: "", status: .todo, createDate: Date()), index: TaskIndexPath(prjGrpIndex: 0, prjIndex: 0, tskIndex: 0)))
                
                let data = file!.data
                let myfile = try! FileWrapper(url: file!.fileURL!)
            }
            
            let entry = SimpleEntry(date: entryDate, displayCategory : displayCategory, tasks: tasks)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    
    let displayCategory : DisplayCatagory
    let tasks : [TaskWithIndexPath]
}

struct XPlanner_WidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            VStack{
                if entry.displayCategory == .All {
                    ForEach(entry.tasks) { tsk in
                        Text(tsk.task.name).minimumScaleFactor(0.2)
                    }
                } else {
                    Text("Todo")
                }
            }
            
        case .systemMedium:
            Text("Medium!!")
        case .systemLarge:
            Text(Calendar.current.date(byAdding: .hour, value: 2, to: Date())!, style: .time)
        case .systemExtraLarge:
            Text(Calendar.current.date(byAdding: .hour, value: 2, to: Date())!, style: .time)
        default:
            Text(entry.date, style: .time)
        }
        
    }
}

@main
struct XPlanner_Widget: Widget {
    let kind: String = "XPlanner_Widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            XPlanner_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct XPlanner_Widget_Previews: PreviewProvider {
    //    let conf = SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    
    static var previews: some View {
        Group {
            XPlanner_WidgetEntryView(entry: SimpleEntry(date: Date(),displayCategory : .All, tasks: [TaskWithIndexPath]()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            XPlanner_WidgetEntryView(entry: SimpleEntry(date: Date(), displayCategory : .All, tasks: [TaskWithIndexPath]()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            XPlanner_WidgetEntryView(entry: SimpleEntry(date: Date(), displayCategory : .All, tasks: [TaskWithIndexPath]()))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
