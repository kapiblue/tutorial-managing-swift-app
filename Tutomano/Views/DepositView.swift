//
//  DepositView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 14/01/2025.
//

import SwiftUI

struct DepositView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSettings: UserSettings
    
    var subject: Subject
    @State var date: Date = Date.now
    @State var amount: Float = 0.0
    @State var comment: String = "Comment"

    
    var body: some View {
        VStack {
            Text(
                userSettings.userMode == .student ? "Make a deposit for \(subject.name!)" : "Make a withdrawal for \(subject.name!)"
            )
            .font(.title)
            .padding()
            Form {
                DatePicker(
                    "Date",
                    selection: $date,
                    displayedComponents: .date
                )
                TextField("Amount", value: $amount, format: .number)
                TextEditor(text: $comment)
            }
            Button("Save", action: saveAction)
                .font(.headline)
                .frame(maxWidth:.infinity, alignment: .center)
        }
    }
    
    func saveAction()
    {
        withAnimation{
            let deposit = Deposit(context: viewContext)
            deposit.date = date
            deposit.comment = comment
            deposit.subject = subject
            deposit.amount = amount
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
