//
//  SettingsView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 14/01/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSettings: UserSettings
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(Color.blue)
            VStack{
                Text("About")
                    .font(.system(size:50))
                    .foregroundColor(Color.white)
                    .bold()
                    .padding(.bottom, 30)
                
                Text("Author: Kacper Dobek")
                    .font(.system(size: 30))
                    .foregroundColor(Color.white)
                VStack {
                    Text("Set user mode")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding()
                    // Set the text according to the mode
                    Text(
                        userSettings.userMode == .student ? "Student" : "Tutor"
                    )
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding()
                            
                    Button(action: {
                        toggleUserMode()
                    }) {
                        Text("Toggle User Mode")
                            .padding()
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                    .padding()
                }
            }
            .padding(.top, 30)
            .offset(y: -150)
        }
        .frame(width: UIScreen.main.bounds.width * 3)
    }
    
    private func toggleUserMode() {
        userSettings.userMode = userSettings.userMode == .student ? .tutor : .student
    }
}
