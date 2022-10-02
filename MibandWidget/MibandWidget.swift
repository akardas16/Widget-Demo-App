//
//  MibandWidget.swift
//  MibandWidget
//
//  Created by Abdullah Kardas on 1.10.2022.
//

import WidgetKit
import SwiftUI
import Combine

struct Provider: TimelineProvider {
    var cancallable = Set<AnyCancellable>()
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), mibandData: .exampleModel)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), mibandData: .exampleModel)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        
        Task{
            
            do{
                let mibandData:MibandDataModel = try await MibandClass.instance.updateBattery()
                
                let nextUpdate = Date().addingTimeInterval(1800)
                let entry = SimpleEntry(date: Date(), mibandData: mibandData)
                  let timeline = Timeline(entries: [entry], policy: .after(nextUpdate)) // seconds = 12 hours
                completion(timeline)
            }catch {
                
            }
            
         
        }

        
           
        

        
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let mibandData:MibandDataModel
}

struct MibandWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
        
            Spacer()
            Text(entry.mibandData.deviceName).font(.title2.bold())
            Spacer()
            HStack{
                Spacer()
                VStack(spacing:4){
                    if entry.mibandData.batteryDiv == 0 {
                        Image(systemName: "battery.25")
                    }else if entry.mibandData.batteryDiv == 1 {
                        Image(systemName: "battery.50")
                    }else if entry.mibandData.batteryDiv == 2 {
                        Image(systemName: "battery.75")
                    }else if entry.mibandData.batteryDiv == 3 {
                        Image(systemName: "battery.100")
                    }
                    
                    Image(systemName: "scribble.variable")
                    
                    Image(systemName: "flame.fill")
                    
                    Image(systemName: "figure.walk")
                }.foregroundColor(.cyan)
                Spacer()
                VStack(alignment:.leading,spacing: 4){
                    Text(entry.mibandData.battery)
                    Text(entry.mibandData.distance)
                    Text(entry.mibandData.calory)
                    Text(entry.mibandData.steps)
                }.font(.headline)
                Spacer()
            }
            Spacer()
            
        }
    }
}

@main
struct MibandWidget: Widget {
    let kind: String = "MibandWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MibandWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MiBand Widget")
        .description("Widget for your MiBand device")
        .supportedFamilies([.systemSmall])
    }
}

struct MibandWidget_Previews: PreviewProvider {
    static var previews: some View {
        MibandWidgetEntryView(entry: SimpleEntry(date: Date(), mibandData: .exampleModel))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
