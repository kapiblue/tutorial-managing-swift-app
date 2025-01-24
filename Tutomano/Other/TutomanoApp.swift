//
//  TutomanoApp.swift
//  Tutomano
//
//  Created by Kacper Dobek on 07/01/2025.
//

import SwiftUI

@main
struct TutomanoApp: App {
    let persistenceController = PersistenceController.shared.container

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(UserSettings(context: persistenceController.viewContext)) // Inject settings into environment
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
