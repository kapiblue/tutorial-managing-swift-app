//
//  SubjectView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 14/01/2025.
//

import SwiftUI

struct SubjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSettings: UserSettings

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
    @State private var filteredLessons: [Lesson] = []

    var body: some View {
        // Compute carryover and current month balance
        let (carryover, currentMonthLessons) = calculateCarryoverAndCurrentLessons(
            allLessons, mode: userSettings.userMode
        )
        let currentMonthDeposits = allDeposits.filter {
            $0.subject == subject && isInCurrentMonth($0.date)
        }
        let currentBalance = calculateCurrentBalance(
            currentMonthLessons: currentMonthLessons,
            currentMonthDeposits: currentMonthDeposits,
            mode: userSettings.userMode
        )

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
                .onChange(of: showAllLessons) {
                    updateFilteredLessons()
                }
                .padding()

            List {
                ForEach(
                    filteredLessons,
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
                        updateFilteredLessons()
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
                        updateFilteredLessons()
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
        .onAppear(perform: updateFilteredLessons)
        .onChange(of: currentDate) {
            updateFilteredLessons()}
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                EditButton()
                NavigationLink {
                    DepositView(subject: subject)
                } label: {
                    Image(systemName: "dollarsign.bank.building")
                }
                NavigationLink {
                    LessonDetailsView(lesson: nil, subject: subject)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }

    private func updateFilteredLessons() {
        filteredLessons = allLessons.filter { lesson in
            lesson.subject == subject && (
                showAllLessons || isInCurrentMonth(lesson.date)
            )
        }
    }

    private func calculateCarryoverAndCurrentLessons(_ lessons: FetchedResults<Lesson>, mode: UserSettings.UserMode) -> (
        carryover: Float,
        currentMonthLessons: [Lesson]
    ) {
        var carryover: Float = 0
        var currentMonthLessons: [Lesson] = []
        let calendar = Calendar.current
        
        let relevantLessons = allLessons.filter { lesson in
            lesson.subject == subject}

        for lesson in relevantLessons {
            guard let lessonDate = lesson.date else { continue }
            if isInCurrentMonth(lessonDate) {
                currentMonthLessons.append(lesson)
            } else if lessonDate < calendar.startOfDay(for: currentDate) {
                if lesson.status != "Paid" {
                    carryover -= lesson.price
                }
            }
        }
        if mode != .student {
            carryover = -1 * carryover
        }

        return (carryover, currentMonthLessons)
    }
    
    private func calculateCurrentBalance(
        currentMonthLessons: [Lesson],
        currentMonthDeposits: [Deposit],
        mode: UserSettings.UserMode
    ) -> Float {

        var balance = currentMonthLessons.reduce(0) { $0 - $1.price } + currentMonthDeposits.reduce(
            0
        ) {
            $0 + $1.amount
        }
        if mode != .student {
            balance = -balance
        }
        return balance
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
            let lessonsToDelete = offsets.map { filteredLessons[$0] }
            lessonsToDelete.forEach(viewContext.delete)

            do {
                try viewContext.save()
                updateFilteredLessons() // Refresh the list after deletion
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
