import SwiftUI
import CoreData

struct AppView : View {
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        TabView {
            IntervalView()
            .tabItem {
                Label("Intervals", systemImage: "music.quarternote.3")
            }
            ContentView()
            .tabItem {
                Label("Members", systemImage: "music.note.list")
            }
        }
    }
}
