//
//  ComputerCellView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 07/01/2025.
//


import SwiftUI
struct ComputerCellView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Fullfilment.date,
            ascending: true
        )],
        animation: .default
    ) private var tasks: FetchedResults<Fullfilment>
    var computer: Computer
    var editMode = false
    var body: some View {
        HStack {
            if editMode {
                Image(systemName: "pencil").tint(Color.blue)
            }
            Text(computer.name ?? "No name")
            Spacer()
            if let c = countUnfinishedTasks() {
                Text("\(c)")
            } else {
                Image(systemName: "checkmark.rectangle.stack").tint(Color.green)
            }
        }
    }
    func countUnfinishedTasks() -> Int? {
        var c = 0
        if let ff = computer.tasks as? Set<Fullfilment> {
            for t in ff {
                if !t.done {
                    c += 1
                }
            }
        }
        if c == 0 {
            return nil
        }
        return c
    }
}