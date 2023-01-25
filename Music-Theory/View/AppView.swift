import SwiftUI
import CoreData

struct AppView : View {
    @Environment(\.scenePhase) var scenePhase
    
    init() {

    }
    
    var body: some View {
        TabView {
            ChordDegreeView()
            .tabItem {
                Label("Chord Degrees", systemImage: "pyramid")
            }

            DegreeView()
            .tabItem {
                Label("Cadences", systemImage: "music.note.list")
            }

            IntervalView()
            .tabItem {
                Label("Intervals", systemImage: "music.note")
            }
            DegreeView()
            .tabItem {
                Label("Triads", systemImage: "music.quarternote.3")
            }

        }
    }
}
