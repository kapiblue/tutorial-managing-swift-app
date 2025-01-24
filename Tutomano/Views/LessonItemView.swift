//
//  SubjectItemView 2.swift
//  Tutomano
//
//  Created by Kacper Dobek on 21/01/2025.
//


import SwiftUI

struct LessonItemView: View {
    // Observe changes to the lesson object
    @ObservedObject var lesson: Lesson
    
    var body: some View {
        HStack {
            VStack {
                Text(lesson.date ?? Date(), formatter: itemFormatter)
                    .font(.title2)
                Text(String(format: "%.2f zł", lesson.price))
            }
            Spacer()
            if lesson.status == "Paid" {
                Image(systemName: "circle.badge.checkmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40, alignment: .topLeading)
                    .foregroundColor(.green)
            } else if lesson.status == "New" {
                Image(systemName: "circle.badge.exclamationmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40, alignment: .topLeading)
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "circle.badge.xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40, alignment: .topLeading)
                    .foregroundColor(.red)
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yy"
    return formatter
}()

