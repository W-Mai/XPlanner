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
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct XPlanner_WidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            if entry.configuration.parameter2 == DisplayCategory.value {
                Text(entry.configuration.description)
            } else {
                let file : INFile? = entry.configuration.parameter
                if file == nil {
                    Text("Nothing")
                }else{
                    Text(file!.fileURL!.path).minimumScaleFactor(0.2)
                }
                
            }
            
        case .systemMedium:
            Text("Medium!!")
        case .systemLarge:
            Text(entry.date, style: .time)
        case .systemExtraLarge:
            Text(entry.date, style: .time)
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
            XPlanner_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            XPlanner_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            XPlanner_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
