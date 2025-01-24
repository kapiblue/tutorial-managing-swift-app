import SwiftUI

class UserSettings: ObservableObject {
    @Published var ownershipMode: OwnershipMode = .youOwn // Default mode
    
    enum OwnershipMode {
        case youOwn
        case youAreOwned
    }
}