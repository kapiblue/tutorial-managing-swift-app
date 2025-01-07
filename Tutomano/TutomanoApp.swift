//
//  TutomanoApp.swift
//  Tutomano
//
//  Created by Kacper Dobek on 07/01/2025.
//

import SwiftUI

@main
struct TutomanoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
