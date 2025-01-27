//
//  ComputerDetailsView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 07/01/2025.
//


import SwiftUI
import CoreData


struct SubjectDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var userSettings: UserSettings
    
    @State var subject: Subject?
    
    @State private var name: String = ""
    @State private var comment: String = "Write your comment here..."
    @State private var dayofweek = ""
    @State private var time: Date = Date()
    @State private var duration: Int16 = 60
    @State private var price: Float = 50
    @State private var archived: Bool = false
    
    var headerText: String {
        subject == nil ? userSettings.userMode == .student ? "New subject" : "New student" :
        userSettings.userMode == .student ? "Edit subject" : "Edit student"
    }
    
    init(subject: Subject?) {
        _subject = State(initialValue: subject)
    }
    
    var body: some View {
        VStack {
            Text(headerText)
                .font(.largeTitle)
                .padding()
                .onAppear {
                    loadSubjectData()
                }
        }
        Form {
            TextField("Name", text: $name)
            TextEditor(text: $comment)
            Picker("Day of week", selection: $dayofweek) {
                ForEach(
                    [
                        "Monday",
                        "Tuesday",
                        "Wednesday",
                        "Thursday",
                        "Friday",
                        "Saturday",
                        "Sunday"
                    ],
                    id: \.self
                ) { subject in
                    Text(subject)
                }
            }
            DatePicker(
                "Date",
                selection: $time,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.compact)
            TextField("Duration", value: $duration, format: .number)
            TextField("Price", value: $price, format: .number)
            Toggle("Archived", isOn: $archived)
        }
        Button("Save"){
            if subject == nil {
                subject = Subject(context: viewContext)
            }
            subject!.name = name
            subject!.comment = comment
            subject!.dayofweek = dayofweek
            subject!.time = time
            subject!.duration = duration
            subject!.price = price
            subject?.archived = archived
            try! viewContext.save()
            dismiss()
        }
    }

    private func loadSubjectData() {
        guard let subject = subject else {
            // Initialize for a new subject
            name = ""
            comment = "Write your comment here"
            dayofweek = "Monday"
            time = Date()
            duration = 60
            price = 100
            archived = false
            return
        }
    
        // Load data for an existing lesson
        name = subject.name ?? ""
        comment = subject.comment ?? ""
        dayofweek = subject.dayofweek ?? "Monday"
        time = subject.time ?? Date()
        duration = subject.duration
        price = subject.price
        archived = subject.archived
    }
    
    private func saveAction() {
        withAnimation {
            let editingSubject = subject ?? Subject(context: viewContext)
            
            // Save or update subject data
            editingSubject.name = name
            editingSubject.comment = comment
            editingSubject.dayofweek = dayofweek
            editingSubject.time = time
            editingSubject.duration = duration
            editingSubject.price = price
            editingSubject.archived = archived
            
            do {
                try viewContext.save()
                // Assign the saved subject to the state variable if it is new
                subject = editingSubject
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
