import SwiftUI
import CoreData
import MessageUI

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        TabView {
            ContentView(system: System())
            .tabItem {
                Label("Ride", systemImage: "bicycle.circle.fill")
            }
            ContentView(system: System())
            .tabItem {
                Label("Members", systemImage: "person.3.fill")
            }
        }
    }
}
