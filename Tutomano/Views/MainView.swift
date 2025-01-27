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
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Subject.name,
            ascending: true
        )],
        animation: .default
    )
    private var allSubjects: FetchedResults<Subject>
    
    @State private var editMode:Bool = false
    @State private var showArchived = false
    @State private var filteredSubjects: [Subject] = []

    var body: some View {
        VStack{
            NavigationView {
                VStack{
                    Text(
                        userSettings.userMode == .student ? "Your subjects" : "Your students"
                    )
                    .font(.largeTitle)
                    List {
                        ForEach(filteredSubjects,
                                id: \.self) { item in
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
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton() // Built-in edit button
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
                    Toggle("Show archived", isOn: $showArchived)
                        .onChange(of: showArchived) {
                            updateFilteredSubjects()
                        }
                        .padding()
                }
            }
        }
        .onAppear {
                    updateFilteredSubjects()
                }
        // Update the list when a new subject is added
        .onReceive(allSubjects.publisher) { _ in
                    updateFilteredSubjects()
                }
    }
    
    private func goToEdit() {
        editMode.toggle()
    }
    
    private func updateFilteredSubjects() {
        filteredSubjects = allSubjects
            .filter { subject in  showArchived ? subject.archived : !subject.archived
            }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let subjectsToDelete = offsets.map { filteredSubjects[$0] }
            subjectsToDelete.forEach(viewContext.delete)

            do {
                try viewContext.save()
                updateFilteredSubjects()
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

