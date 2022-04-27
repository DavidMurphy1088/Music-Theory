import SwiftUI
import CoreData

struct AppView : View {
    @Environment(\.scenePhase) var scenePhase
    
    init() {

    }
    
    var body: some View {
        TabView {
            HarmonicAnalysisView()
            .tabItem {
                Label("Analysis", systemImage: "music.note.list")
            }

            IntervalView()
            .tabItem {
                Label("Intervals", systemImage: "music.note")
            }
            DegreeView()
            .tabItem {
                Label("Triads", systemImage: "music.quarternote.3")
            }
            Test1()
            .tabItem {
                Label("Test1", systemImage: "pyramid")
            }


//            ContentView()
//            .tabItem {
//                Label("Members", systemImage: "music.note.list")
//            }
        }
    }
}
