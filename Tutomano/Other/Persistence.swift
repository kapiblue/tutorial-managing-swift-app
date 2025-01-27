//
//  Persistence.swift
//  Tutomano
//
//  Created by Kacper Dobek on 07/01/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Tutomano")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(
                fileURLWithPath: "/dev/null"
            )
        }
        container
            .loadPersistentStores(
                completionHandler: { (
                    storeDescription,
                    error
                ) in
                    if let error = error as NSError? {
                        fatalError(
                            "Unresolved error \(error), \(error.userInfo)"
                        )
                    }
                })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
