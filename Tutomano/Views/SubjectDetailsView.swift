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
    
    @State var subject: Subject?
    
    @State private var name: String = ""
    @State private var comment: String = "Write your comment here..."
    @State private var dayofweek = ""
    @State private var time: Date = Date()
    @State private var duration: Int16 = 60
    @State private var price: Float = 50
    @State private var archived: Bool = false
    
    var body: some View {
        VStack {
            Text("Subject details").font(.largeTitle).padding().onAppear() {
                if let c = subject {
                    print(c.name!)
                    name = c.name ?? ""
                    comment = c.comment ?? ""
                    dayofweek = c.dayofweek ?? ""
                    time = c.time ?? Date.now
                    duration = c.duration ?? 60
                    price = c.price ?? 50
                    archived = c.archived ?? false
                } else {
                    name = ""
                    comment = ""
                    dayofweek = ""
                    time = Date.now
                    duration = 60
                    price = 50
                    archived = false
                }
            }
            Form {
                TextField("Name", text: $name)
                TextEditor(text: $comment)
                Picker("Day of week", selection: $dayofweek) {
                          ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], id: \.self) { subject in
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
    }
}
