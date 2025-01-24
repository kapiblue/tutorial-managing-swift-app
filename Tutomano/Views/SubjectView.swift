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

    var subject: Subject
    @State private var currentDate = Date.now
    @State private var showAllLessons = false // Toggle to control filtering

    var body: some View {
        // Convert FetchedResults to a regular Swift array
        // Optionally filter by month
        let lessons: [Lesson] = allLessons.filter { lesson in
            lesson.subject == subject && (
                showAllLessons || isInCurrentMonth(lesson.date)
            )
        }

        VStack {
            Text("Lessons for \(subject.name!)")
                .font(.largeTitle)
                .padding(.top, 20)
            Text("Carryover: " + String(format: "%.2f zł", subject.price))
                .font(.title3)
                .padding()

            // Toggle for showing all lessons
            Toggle("Show All Lessons", isOn: $showAllLessons)
                .padding()

            if !showAllLessons {
                // Month navigation only applies when filtering
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
                    Text(get_month_year(date: currentDate))
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
            }

            List {
                ForEach(lessons, id: \.self) { item in
                    NavigationLink {
                        LessonDetailsView(lesson: item)
                    } label: {
                        LessonItemView(lesson: item)
                    }
                }
                .onDelete(perform: deleteItems)
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

    private func isInCurrentMonth(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)
        return month == currentMonth && year == currentYear
    }
    
    private func get_month_year(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        formatter.dateFormat = "MMM"
        let month = formatter.string(from: date)
        return month + " " +  year
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
