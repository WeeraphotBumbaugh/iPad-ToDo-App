import SwiftUI

class StoreManager: ObservableObject {
    @Published var isPro = false
    
    func buyProVersion() {
        // Simulate a purchase completing later
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isPro = true
        }
    }
    
    /// Free users: can have up to 3 groups (0, 1, 2, 3).
    /// When `currentGroupCount` is 3, they cannot add a 4th.
    func canAddGroup(currentGroupCount: Int) -> Bool {
        if isPro {
            return true
        } else {
            return currentGroupCount < 3
        }
    }
    
    /// Free users: can have up to 1 main group (0 or 1).
    /// When `currentMainCount` is 1, they cannot add a 2nd without Pro.
    func canAddMainGroup(currentMainCount: Int) -> Bool {
        if isPro {
            return true
        } else {
            return currentMainCount < 1
        }
    }
}
