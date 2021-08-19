import SwiftUI
import CoreData
import MessageUI

struct MainView1: View {
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        TabView {
            ContentView()
            .tabItem {
                Label("Ride", systemImage: "bicycle.circle.fill")
            }
            ContentView()
            .tabItem {
                Label("Members", systemImage: "person.3.fill")
            }
        }
    }
}
