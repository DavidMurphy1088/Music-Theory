import SwiftUI
import CoreData

struct AppView : View {
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        print("App VIEW STARTED")
    }
    
    var body: some View {
        TabView {
            TriadView()
            .tabItem {
                Label("Triads", systemImage: "pyramid")
            }

            IntervalView()
            .tabItem {
                Label("Intervals", systemImage: "music.note")
            }
            Test1()
            .tabItem {
                Label("Test1", systemImage: "music.quarternote.3")
            }


//            ContentView()
//            .tabItem {
//                Label("Members", systemImage: "music.note.list")
//            }
        }
    }
}
