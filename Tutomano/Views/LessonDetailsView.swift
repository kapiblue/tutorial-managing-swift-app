//
//  LessonDetailsView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 14/01/2025.
//

import SwiftUI

struct LessonDetailsView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var lesson: Lesson? // Optional: Handles both new and existing lessons
    @State var subject: Subject? // Optional: Used only for new lessons
    
    @State private var name: String = ""
    @State private var comment: String = "Write your comment here..."
    @State private var time: Date = Date()
    @State private var date: Date = Date()
    @State private var price: Float = 50
    @State private var status: String = "New"
    
    var headerText: String {
        lesson == nil ? "New Lesson" : "Edit Lesson"
    }
    
    init(lesson: Lesson?, subject: Subject? = nil) {
        _lesson = State(initialValue: lesson)
        _subject = State(initialValue: subject)
    }
    
    var body: some View {
        VStack {
            Text(headerText)
                .font(.largeTitle)
                .padding()
                .onAppear {
                    loadLessonData()
                }
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                TextField("Price", value: $price, format: .number)
                TextEditor(text: $comment)
                Picker("Status", selection: $status) {
                    ForEach(["New", "Completed", "Paid"], id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            Button("Save", action: saveAction)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func loadLessonData() {
        guard let lesson = lesson else {
            // Initialize for a new lesson
            date = Date()
            time = Date()
            comment = "Write your comment here..."
            price = 50
            status = "New"
            return
        }
        
        // Load data for an existing lesson
        date = lesson.date ?? Date()
        time = lesson.time ?? Date()
        comment = lesson.comment ?? ""
        price = lesson.price
        status = lesson.status ?? "New"
    }

    private func saveAction() {
        withAnimation {
            let editingLesson = lesson ?? Lesson(context: viewContext)
            
            // Save or update lesson data
            editingLesson.date = date
            editingLesson.time = time
            editingLesson.comment = comment
            editingLesson.price = price
            editingLesson.status = status
            
            if lesson == nil {
                // Only set the subject for new lessons
                editingLesson.subject = subject
            }
            
            do {
                try viewContext.save()
                // Assign the saved lesson to the state variable if it is new
                lesson = editingLesson
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
