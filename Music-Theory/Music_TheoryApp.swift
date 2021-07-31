//
//  Music_TheoryApp.swift
//  Music-Theory
//
//  Created by David Murphy on 7/30/21.
//

import SwiftUI

@main
struct Music_TheoryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
