import SwiftUI

@main
struct NPendulumDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DebugView(substeps: 16, makeScene: TriplePendulumScene.make)
        }
    }
}
