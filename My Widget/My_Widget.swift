//
//  My_Widget.swift
//  My Widget
//
//  Created by Abdullah Kardas on 17.09.2022.
//

import WidgetKit
import SwiftUI
import Intents


struct Provider: TimelineProvider {
  
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        
        let nextUpdate = Date().addingTimeInterval(1800)
        let entry = SimpleEntry(date: Date())
          let timeline = Timeline(entries: [entry], policy: .after(nextUpdate)) // seconds = 12 hours
          completion(timeline)
        
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    
}

struct My_WidgetEntryView : View {
    var entry: Provider.Entry
    var monthlyConfig:MonthConfig

    var body: some View {
        ZStack {
            if #available(iOSApplicationExtension 16.0, *) {
                ContainerRelativeShape().fill(monthlyConfig.backgroundColor.gradient)
            } else {
                ContainerRelativeShape().fill(monthlyConfig.backgroundColor)
            }
            VStack{
                HStack(spacing:4){
                    Text(monthlyConfig.emojiText).font(.title2).bold()
                    Text(entry.date.formatted(.dateTime.weekday(.wide))).foregroundColor(monthlyConfig.weekdayTextColor).font(.title)
                }
                Text(entry.date.formatted(.dateTime.day())).font(.system(size: 80, weight: .bold, design: .monospaced)).foregroundColor(monthlyConfig.dayTextColor)
            
            }
            
           
        }
    }
}


@main
struct My_Widget: Widget {
    let kind: String = "My_Widget"

    var body: some WidgetConfiguration {
      
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            My_WidgetEntryView(entry: entry, monthlyConfig: .determineConfig(date: Date()))
        }
        .configurationDisplayName("Monthly Style Widget")
        .description("Theme of widget based of month")
        .supportedFamilies([.systemSmall])
        
    }
}

struct My_Widget_Previews: PreviewProvider {
    static var previews: some View {
        My_WidgetEntryView(entry: SimpleEntry(date: Date()), monthlyConfig: .determineConfig(date: Date(yourDate: "2020-02-30")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}




