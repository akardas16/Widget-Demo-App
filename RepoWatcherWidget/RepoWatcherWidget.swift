//
//  RepoWatcherWidget.swift
//  RepoWatcherWidget
//
//  Created by Abdullah Kardas on 18.09.2022.
//

import WidgetKit
import SwiftUI
import SDWebImageSwiftUI
import Combine

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> RepoEntry {
        RepoEntry(date: Date(), repository: .testRepo, image: UIImage())
    }

    func getSnapshot(in context: Context, completion: @escaping (RepoEntry) -> ()) {
        let entry = RepoEntry(date: Date(), repository: .testRepo, image: UIImage())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        Task{
            let nextUpdate = Date().addingTimeInterval(1800)
            do{
                let repo = try await  WidgetNetworkingMngr.instance.getRepo(from: .sideMenu)
                  
                do {
                    let image = try await WidgetNetworkingMngr.instance.downloadImage(url: repo.owner.avatarUrl)
                    let entry = RepoEntry(date: Date(), repository: repo, image: image)
                      let timeline = Timeline(entries: [entry], policy: .after(nextUpdate)) // seconds = 12 hours
                      completion(timeline)
                } catch  {
                    throw URLError(.badURL)
                }
              
            }catch {
                print("fwedgsdg")
                throw URLError(.badURL)
            }
         
        }
        
        
        
     
    }
}

struct RepoEntry: TimelineEntry {
    let date: Date
    let repository:RepositoryModel
    let image:UIImage
}


struct RepoWatcherWidgetEntryView : View {
    var entry: Provider.Entry
    let dateFormatter = DateFormatter()
   
    var passedDays:Int {
        dayCalculation(dateString: entry.repository.pushedAt)
    }

    var body: some View {
        
        HStack{
            VStack(alignment:.leading){
                Spacer()
                Spacer()
                HStack {
                    Image(uiImage: entry.image).resizable().scaledToFill().frame(width: 45, height: 45).clipShape(Circle())
               
                    VStack(alignment:.leading) {
                        Text(entry.repository.name).font(.headline).bold().minimumScaleFactor(0.6).lineLimit(1)
                        
                    }
                }
                Spacer()
                Text(entry.repository.description).font(.caption).foregroundColor(.gray).minimumScaleFactor(0.6).lineLimit(2)
                Spacer()
                HStack {
                    Label("\(entry.repository.watchers)", systemImage: "star.fill")
                    Label("\(entry.repository.forks)", systemImage: "tuningfork")
                    if entry.repository.openIssues > 0 {
                        Label("\(entry.repository.openIssues)", systemImage: "exclamationmark.triangle.fill")
                    }
                  
                }.labelStyle(CustomLabelStyle(iconColor: .green, titleColor: Color("colorFork"))).font(.subheadline)
                Spacer()
                Spacer()
            }
            Spacer()
            VStack(spacing:0){
                Text("\(passedDays)").foregroundColor(passedDays > 50 ? .pink:.green).font(.system(size: 68, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.6).lineLimit(1)
                Text("days ago").foregroundColor(.secondary)
            }
        }.padding(.horizontal)
           
    }
    
    
    

    
    func dayCalculation(dateString:String) -> Int{
          dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
          let date = dateFormatter.date(from:dateString)!
        
          let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: date)
        
        let finalDate = Calendar.current.date(from:components) ?? Date()
       
        let dif = Calendar.current.dateComponents([.day], from: finalDate, to: Date())
        return dif.day ?? 0
       
    }
}

@main
struct RepoWatcherWidget: Widget {
    let kind: String = "RepoWatcherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            RepoWatcherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Repo Watcher")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}

struct RepoWatcherWidget_Previews: PreviewProvider {
    static var previews: some View {
        RepoWatcherWidgetEntryView(entry: RepoEntry(date: Date(), repository: .testRepo, image: UIImage(named: "image")!))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
    }
}
struct CustomLabelStyle: LabelStyle {
    
    let iconColor: Color
    let titleColor: Color

    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon.foregroundColor(iconColor)
            configuration.title.foregroundColor(titleColor)
        }
        
    } }
