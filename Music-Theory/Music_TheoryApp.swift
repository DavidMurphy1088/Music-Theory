import SwiftUI

@main
struct Music_TheoryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(system: System())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
