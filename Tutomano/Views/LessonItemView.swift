//
//  SubjectItemView 2.swift
//  Tutomano
//
//  Created by Kacper Dobek on 21/01/2025.
//


import SwiftUI

struct SubjectItemView: View {
    var subject: Subject
    var editMode = false
    var body: some View {
        HStack {
            if editMode {
                Image(systemName: "pencil").tint(Color.blue)
            }
            Text(subject.name ?? "No name")
        }
    }
}