import PhysicsEngine
import SwiftUI

let particleSize: CGFloat = 12
let scale: CGFloat = 20

/// A generic host view: it owns the render loop and draws whatever particles
/// and constraints are in the system it's given. It knows nothing about how
/// any particular demo scene (pendulum, ball pit, etc.) is built — that lives
/// in a separate per-demo file that produces a `ParticleSystem`.
struct DebugView: View {
    let makeScene: (CGSize) -> ParticleSystem
    let substeps: Int

    @State private var system = ParticleSystem()
    @State private var lastFrame = Date.now
    @State private var isPaused = true
    @State private var didConfigureScene = false

    init(substeps: Int = 4, makeScene: @escaping (CGSize) -> ParticleSystem) {
        self.substeps = substeps
        self.makeScene = makeScene
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                TimelineView(.animation(paused: isPaused)) { timeline in
                    Canvas { context, size in
                        draw(system, in: &context, size: size)
                    }
                    .onChange(of: timeline.date) { _, now in
                        let dt = Float(now.timeIntervalSince(lastFrame))
                        system
                            .step(deltaTime: min(dt, 1.0 / 60.0),
                                  substeps: substeps) // clamp to avoid spiral of death on hitches
                        lastFrame = now
                    }
                }
                .background(Color.black)

                HStack {
                    Button(isPaused ? "Play" : "Pause") { isPaused.toggle() }
                    Button("Step") { system.step(deltaTime: 1.0 / 60.0, substeps: substeps); isPaused = true }
                    Button("Restart") {
                        system = makeScene(geometry.size)
                        lastFrame = Date.now
                        isPaused = true
                    }
                }
                .padding(8)
                .background(.thinMaterial)
                .cornerRadius(8)
                .padding()
            }
            .onAppear {
                guard !didConfigureScene else { return }
                didConfigureScene = true
                system = makeScene(geometry.size)
            }
        }
    }

    func draw(_ system: ParticleSystem, in context: inout GraphicsContext, size: CGSize) {
        let origin = CGPoint(x: 0, y: size.height)

        func point(for position: SIMD2<Float>) -> CGPoint {
            CGPoint(x: origin.x + CGFloat(position.x) * scale,
                    y: origin.y - CGFloat(position.y) * scale)
        }

        for constraint in system.constraints {
            for (a, b) in constraint.connectedParticleIndices {
                let path = Path { path in
                    path.move(to: point(for: system.particles[a].position))
                    path.addLine(to: point(for: system.particles[b].position))
                }
                context.stroke(path, with: .color(.white), lineWidth: 1)
            }
        }

        for p in system.particles {
            let center = point(for: p.position)
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - particleSize / 2,
                    y: center.y - particleSize / 2,
                    width: particleSize,
                    height: particleSize
                )),
                with: .color(.white)
            )
        }
    }
}
