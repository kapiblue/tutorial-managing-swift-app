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
    
    @EnvironmentObject var userSettings: UserSettings

    @FetchRequest(
        entity: Subject.entity(),
 // fix the exception
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Subject.name,
            ascending: true
        )],
        animation: .default
    )
    private var items: FetchedResults<Subject>
    @State private var editMode:Bool = false

    var body: some View {
        VStack{
            NavigationView {
                VStack{
                    Text(
                        userSettings.userMode == .student ? "Your subjects" : "Your students"
                    )
                    .font(.largeTitle)
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
                                SubjectItemView(
                                    subject: item,
                                    editMode: editMode
                                )
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: goToEdit) {
                                Label("Remove", systemImage: "pencil")
                            }
                        }
                        ToolbarItem {
                            NavigationLink {
                                SubjectDetailsView(subject: nil)
                            } label: {
                                Image(systemName: "plus")
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
        }
    }
    
    private func goToEdit() {
        editMode.toggle()
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

//#Preview {
//    MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}

