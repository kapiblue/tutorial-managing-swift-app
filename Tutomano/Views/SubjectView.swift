//
//  SubjectView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 14/01/2025.
//

import SwiftUI

struct SubjectView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Lesson.entity(),
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Lesson.date,
            ascending: true
        )],
        animation: .default
    )
    private var allLessons: FetchedResults<Lesson>

    @FetchRequest(
        entity: Deposit.entity(),
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Deposit.date,
            ascending: true
        )],
        animation: .default
    )
    private var allDeposits: FetchedResults<Deposit>

    var subject: Subject
    @State private var currentDate = Date.now
    @State private var showAllLessons = false // Toggle to control filtering

    var body: some View {
        // Filter lessons and deposits by the current subject
        let filteredLessons = allLessons.filter { $0.subject == subject }
        let filteredDeposits = allDeposits.filter { $0.subject == subject }

        // Compute carryover and current month balance
        let (carryover, currentMonthLessons) = calculateCarryoverAndCurrentLessons(
            filteredLessons
        )
        let currentMonthDeposits = filteredDeposits.filter {
            isInCurrentMonth($0.date)
        }
        let currentBalance = currentMonthLessons.reduce(0) { $0 - $1.price } + currentMonthDeposits.reduce(
            0
        ) {
            $0 + $1.amount
        }

        VStack {
            Text("Lessons for \(subject.name!)")
                .font(.largeTitle)
                .padding(.top, 20)

            // Display carryover sum
            HStack {
                Text("Carryover:")
                Text(String(format: "%.2f", carryover))
                    .foregroundColor(
                        carryover < 0 ? .red : (
                            carryover > 0 ? .green : .primary
                        )
                    )
                Text("PLN")
            }
            .padding(5)

            // Toggle for showing all lessons
            Toggle("Show All Lessons", isOn: $showAllLessons)
                .padding()

            List {
                ForEach(
                    showAllLessons ? filteredLessons : currentMonthLessons,
                    id: \.self
                ) { lesson in
                    NavigationLink {
                        LessonDetailsView(lesson: lesson)
                    } label: {
                        LessonItemView(lesson: lesson)
                    }
                }
                .onDelete(perform: deleteItems)
            }

            HStack {
                Text("Current Balance:")
                Text(String(format: "%.2f", currentBalance))
                    .foregroundColor(
                        currentBalance < 0 ? .red : (
                            currentBalance > 0 ? .green : .primary
                        )
                    )
                Text("PLN")
            }
            .padding(5)

            // Month navigation
            if !showAllLessons {
                HStack {
                    Button {
                        currentDate = Calendar.current
                            .date(byAdding: .month, value: -1, to: currentDate)!
                    } label: {
                        Image(systemName: "minus.circle")
                            .font(.title3)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(Circle())
                    }
                    Text(getMonthYear(date: currentDate))
                    Button {
                        currentDate = Calendar.current
                            .date(byAdding: .month, value: 1, to: currentDate)!
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                NavigationLink {
                    DepositView(subject: subject)
                } label: {
                    Image(systemName: "dollarsign.bank.building")
                }
            }
            ToolbarItem {
                NavigationLink {
                    LessonDetailsView(lesson: nil, subject: subject)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    // Helper to filter by current month and calculate carryover
    private func calculateCarryoverAndCurrentLessons(_ lessons: [Lesson]) -> (
        carryover: Float,
        currentMonthLessons: [Lesson]
    ) {
        var carryover: Float = 0
        var currentMonthLessons: [Lesson] = []
        let calendar = Calendar.current

        for lesson in lessons {
            guard let lessonDate = lesson.date else { continue }
            if isInCurrentMonth(lessonDate) {
                currentMonthLessons.append(lesson)
            } else if lessonDate < calendar.startOfDay(for: currentDate) {
                carryover -= lesson.price
            }
        }

        return (carryover, currentMonthLessons)
    }

    private func isInCurrentMonth(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        return month == currentMonth && year == currentYear
    }

    private func getMonthYear(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { allLessons[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
