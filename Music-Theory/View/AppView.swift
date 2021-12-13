import SwiftUI
import CoreData

struct AppView : View {
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        TabView {
            Test1()
            .tabItem {
                Label("Test1", systemImage: "music.quarternote.3")
            }

//            IntervalView()
//            .tabItem {
//                Label("Intervals", systemImage: "music.note")
//            }
//            ContentView()
//            .tabItem {
//                Label("Members", systemImage: "music.note.list")
//            }
        }
    }
}
