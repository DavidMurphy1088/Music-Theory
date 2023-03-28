import SwiftUI
import CoreData
import MusicKit

struct AppView : View {
    @Environment(\.scenePhase) var scenePhase
    
    init() {

    }

    var body: some View {
        TabView {
            IntervalView()
            .tabItem {
                Label("Intervals", image: "intervals")
            }
            DegreeTriadsView()
            .tabItem {
                Label("Triad", image: "triads")
            }

            DegreeView()
            .tabItem {
                Label("Cadences", image: "cadences")
            }
//            DegreeView()
//            .tabItem {
//                Label("Triads", systemImage: "music.quarternote.3")
//            }
        }
    }
}
