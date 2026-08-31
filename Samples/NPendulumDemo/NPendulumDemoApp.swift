import SwiftUI

@main
struct NPendulumDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DebugView(substeps: 16) { NPendulumScene.make(n: 3) }
        }
    }
}
