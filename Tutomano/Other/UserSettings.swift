//
//  UserSettings.swift
//  Tutomano
//
//  Created by Kacper Dobek on 24/01/2025.
//


import SwiftUI
import CoreData

class UserSettings: ObservableObject {
    @Published var userMode: UserMode = .student {
        didSet {
            saveUserMode()
        }
    }
    // Two user modes
    enum UserMode: String {
        case student = "student"
        case tutor = "tutor"
    }
    
    private var viewContext: NSManagedObjectContext
        
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadUserMode()
    }
    private func loadUserMode() {
        let fetchRequest: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        fetchRequest.fetchLimit = 1
            
        do {
            if let appSettings = try viewContext.fetch(fetchRequest).first {
                if let modeString = appSettings.userMode,
                   let mode = UserMode(rawValue: modeString) {
                    userMode = mode
                }
            }
        } catch {
            print("Error loading user mode from Core Data: \(error)")
        }
    }
        
    private func saveUserMode() {
        let fetchRequest: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        fetchRequest.fetchLimit = 1
            
        do {
            let appSettings = try viewContext.fetch(fetchRequest).first ?? AppSettings(
                context: viewContext
            )
            appSettings.userMode = userMode.rawValue
            try viewContext.save()
        } catch {
            print("Error saving user mode to Core Data: \(error)")
        }
    }
}
