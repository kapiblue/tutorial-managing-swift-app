//
//  ComputerView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 07/01/2025.
//


import SwiftUI
import CoreData
struct ComputerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Computer.name,
            ascending: true
        )],
        animation: .default
    )
    private var items: FetchedResults<Computer>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Fullfilment.date,
            ascending: true
        )],
        predicate: NSPredicate(format: "done == %@", NSNumber(value: false)),
        animation: .default
    )
    private var tasks: FetchedResults<Fullfilment>
    @State private var showingDetail = false
    @State private var newComputer = false
    @State private var editMode = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(items, id: \.self) { item in
                        NavigationLink {
                            if editMode {
                                ComputerDetailsView(computer: item)
                            } else {
                                ComputerTasksView(computer: item)
                            }
                        } label: {
                            ComputerCellView(computer: item, editMode: editMode)
                        }.swipeActions(edge: .leading) {
                            Button (action: { showDetails(computer: item) }) {
                                Label("Edit", systemImage: "pencil")
                            }.tint(.blue)
                        }.swipeActions(edge: .trailing) {
                            Button (action: { deleteComputer(computer: item)}) {
                                Label("Delete", systemImage: "trash")
                            }.tint(.red)
                        }
                    }
                }.listStyle(.grouped)
                    .toolbar {
                        if editMode {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: goToEdit) {
                                    Label("Edit", systemImage: "pencil.slash")
                                }
                            }
                        }
                        else {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: goToEdit) {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                            ToolbarItem {
                                Button(action: addItem) {
                                    Label("Add Computer", systemImage: "plus")
                                }
                            }
                        }
                    }.toolbarTitleDisplayMode(.inline)
                Text("To do: \(tasks.count) tasks")
            }
        }
    }
    
    private func goToEdit() {
        editMode.toggle()
    }
    private func addItem() {
        withAnimation {
            let newItem = Computer(context: viewContext)
            newItem.name = "Computer \(items.count + 1)"
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    private func deleteComputer(computer: Computer) {
        withAnimation {
            viewContext.delete(computer)
            do {
                try viewContext.save()
            } catch {
            }
        }
    }
    
    private func showDetails(computer: Computer) {
        withAnimation {
            showingDetail = true
        }
    }
}