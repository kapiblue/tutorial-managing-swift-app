//
//  SubjectItemView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 14/01/2025.
//

extension Subject {
    var lessonsArray: [Lesson] {
        (lessons as? Set<Lesson> ?? []).sorted {
            $0.date ?? Date.distantPast < $1.date ?? Date.distantPast
        }
    }

    var depositsArray: [Deposit] {
        (deposits as? Set<Deposit> ?? []).sorted {
            $0.date ?? Date.distantPast < $1.date ?? Date.distantPast
        }
    }
}

import SwiftUI

struct SubjectItemView: View {
    @ObservedObject var subject: Subject
    var editMode = false

    var body: some View {
        
        let totalBalance = calculateTotalBalance()
        
        HStack {
            if editMode {
                Image(systemName: "pencil")
                    .tint(Color.blue)
            }
            VStack(alignment: .leading) {
                Text(subject.name ?? "No name")
                    .font(.headline)
                Text("Balance: \(totalBalance, specifier: "%.2f") PLN")
                    .foregroundColor(
                        totalBalance < 0 ? .red : (
                            totalBalance > 0 ? .green : .primary
                        )
                    )
                    .font(.subheadline)
            }
        }
    }


    private func calculateTotalBalance() -> Float {
        let lessonsBalance = subject.lessonsArray.reduce(0) { $0 - $1.price }
        let depositsBalance = subject.depositsArray.reduce(0) { $0 + $1.amount }
        return lessonsBalance + depositsBalance
    }
}
