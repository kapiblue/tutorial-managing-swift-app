//
//  ComputerDetailsView.swift
//  Tutomano
//
//  Created by Kacper Dobek on 07/01/2025.
//


import SwiftUI
import CoreData


struct ComputerDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var computer: Computer?
    
    @State private var name: String = ""
    @State private var id = ""
    @State private var serialNo = ""
    @State private var ip = ""
    @State private var mac = ""
    
    var body: some View {
        VStack {
            Text("Computer details").font(.largeTitle).padding().onAppear() {
                if let c = computer {
                    print(c.name!)
                    name = c.name ?? ""
                    id = c.id ?? ""
                    serialNo = c.serialNo ?? ""
                    ip = c.ip ?? ""
                    mac = c.mac ?? ""
                } else {
                    name = ""
                    id = ""
                    serialNo = ""
                    ip = ""
                    mac = ""
                }
            }
            Form {
                TextField("Name", text: $name)
                TextField("ID", text: $id)
                TextField("Serial No", text: $serialNo)
                TextField("IP", text: $ip)
                TextField("MAC", text: $mac)
            }
            Button("Save"){
            if computer == nil {
                computer = Computer(context: viewContext)
            }
            computer!.name = name
            computer!.id = id
            computer!.serialNo = serialNo
            computer!.ip = ip
            computer!.mac = mac
            try! viewContext.save()
            dismiss()
        }
    }
}
}