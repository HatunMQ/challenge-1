// xcode: set sdk=iOS

import SwiftUI

struct ContentView: View {
    var body: some View {
        Page13(drawing: UIImage(named: "matchstick") ?? UIImage())
    }
}

#Preview {
    ContentView()
}
