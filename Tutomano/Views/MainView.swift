//
//  ComputerView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 07/01/2025.
//


import SwiftUI
import CoreData


struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Subject.entity(), // fix the exception
        sortDescriptors: [NSSortDescriptor(keyPath: \Subject.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Subject>
    @State private var editMode:Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        if editMode{
                            SubjectDetailsView(subject : item)
                        }
                        else {
                            SubjectView(subject: item)
                        }
                    } label: {
                        SubjectItemView(subject: item, editMode: editMode)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: goToEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink{
                        SettingsView()}
                    label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            Text("Select an item")
        }
    }
    
    private func goToEdit() {
        editMode.toggle()
    }
    private func addItem() {
        withAnimation {
            let newItem = Subject(context: viewContext)
            newItem.name = "name sub"

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    SubjectsMainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

