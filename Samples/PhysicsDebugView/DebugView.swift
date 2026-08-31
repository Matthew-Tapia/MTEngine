import PhysicsEngine
import RealityKit
import simd
import SwiftUI

#if os(macOS)
    import AppKit
#endif

private let particleRadius: Float = 0.3
private let rodThickness: Float = 0.08
private let floorSize: Float = 24
private let particleColors: [SimpleMaterial.Color] = [.gray, .red, .orange, .yellow, .green, .cyan, .blue, .magenta]

/// Owns the RealityKit entities mirroring a `ParticleSystem` and keeps their
/// transforms in sync each frame. Knows nothing about any specific demo scene.
@MainActor
private final class DebugScene {
    var system: ParticleSystem
    private(set) var particleEntities: [ModelEntity] = []
    private var rodEntities: [(entity: ModelEntity, a: Int, b: Int)] = []
    let cameraTarget = Entity()
    let camera = PerspectiveCamera()
    private var cameraFocus = SIMD3<Float>(0, -1, 0)
    private var cameraAzimuth: Float = .pi / 4
    private var cameraElevation: Float = .pi / 8
    private var cameraDistance: Float = 15

    init(system: ParticleSystem) {
        self.system = system
        updateCamera()
    }

    func rebuildEntities(in _: RealityViewCameraContent) {
        for entity in particleEntities {
            entity.removeFromParent()
        }
        for rod in rodEntities {
            rod.entity.removeFromParent()
        }

        particleEntities = system.particles.enumerated().map { index, _ in
            Self.makeParticleEntity(color: particleColors[index % particleColors.count])
        }
        particleEntities.forEach { cameraTarget.addChild($0) }

        rodEntities = system.constraints.flatMap(\.connectedParticleIndices).map { pair in
            let entity = Self.makeRodEntity()
            cameraTarget.addChild(entity)
            return (entity, pair.0, pair.1)
        }

        syncTransforms()
    }

    func syncTransforms() {
        for (index, entity) in particleEntities.enumerated() {
            entity.position = system.particles[index].position
        }

        for (entity, a, b) in rodEntities {
            let start = system.particles[a].position
            let end = system.particles[b].position
            let delta = end - start
            let distance = length(delta)

            entity.position = (start + end) / 2
            entity.scale = SIMD3(rodThickness, distance, rodThickness)

            guard distance > 1e-5 else { continue }
            entity.orientation = simd_quatf(from: SIMD3(0, 1, 0), to: delta / distance)
        }
    }

    func orbit(by translation: CGSize) {
        cameraAzimuth -= Float(translation.width) * 0.01
        cameraElevation = min(max(cameraElevation + Float(translation.height) * 0.01, -.pi / 2 + 0.05), .pi / 2 - 0.05)
        updateCamera()
    }

    func pan(by translation: CGSize) {
        let scale = cameraDistance * 0.002
        let rotation = camera.transform.rotation
        let right = rotation.act(SIMD3<Float>(1, 0, 0))
        let up = rotation.act(SIMD3<Float>(0, 1, 0))
        cameraFocus -= right * Float(translation.width) * scale
        cameraFocus += up * Float(translation.height) * scale
        updateCamera()
    }

    func zoom(by delta: CGFloat) {
        cameraDistance = min(max(cameraDistance - Float(delta) * 0.04, 3), 50)
        updateCamera()
    }

    private func updateCamera() {
        let horizontalDistance = cameraDistance * cos(cameraElevation)
        let position = cameraFocus + SIMD3(
            horizontalDistance * sin(cameraAzimuth),
            cameraDistance * sin(cameraElevation),
            horizontalDistance * cos(cameraAzimuth)
        )
        camera.look(at: cameraFocus, from: position, relativeTo: nil)
    }

    private static func makeParticleEntity(color: SimpleMaterial.Color) -> ModelEntity {
        ModelEntity(
            mesh: .generateSphere(radius: particleRadius),
            materials: [SimpleMaterial(color: color, isMetallic: false)]
        )
    }

    private static func makeRodEntity() -> ModelEntity {
        ModelEntity(mesh: .generateBox(size: 1), materials: [SimpleMaterial(color: .white, isMetallic: false)])
    }
}

/// A generic host view: it owns the render loop and draws whatever particles
/// and constraints are in the system it's given. It knows nothing about how
/// any particular demo scene (pendulum, ball pit, etc.) is built — that lives
/// in a separate per-demo file that produces a `ParticleSystem`.
struct DebugView: View {
    let makeScene: () -> ParticleSystem
    let substeps: Int

    @State private var scene: DebugScene
    @State private var isPaused = true

    init(substeps: Int = 4, makeScene: @escaping () -> ParticleSystem) {
        self.substeps = substeps
        self.makeScene = makeScene
        _scene = State(initialValue: DebugScene(system: makeScene()))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            RealityView { content in
                content.camera = .virtual
                content.add(scene.cameraTarget)
                content.add(scene.camera)
                content.add(makeFloor())
                content.add(makeKeyLight())
                content.add(makeFillLight())
                scene.rebuildEntities(in: content)
                content.cameraTarget = scene.cameraTarget

                let pausedBinding = $isPaused
                _ = content.subscribe(to: SceneEvents.Update.self) { event in
                    guard !pausedBinding.wrappedValue else { return }
                    scene.system
                        .step(deltaTime: min(Float(event.deltaTime), 1.0 / 60.0),
                              substeps: substeps) // clamp to avoid spiral of death on hitches
                    scene.syncTransforms()
                }
            }
            .background(Color.black)
            .overlay {
                #if os(macOS)
                    CameraInputView(
                        onOrbit: scene.orbit,
                        onPan: scene.pan,
                        onZoom: scene.zoom
                    )
                #endif
            }

            HStack {
                Button(isPaused ? "Play" : "Pause") { isPaused.toggle() }
                Button("Step") {
                    scene.system.step(deltaTime: 1.0 / 60.0, substeps: substeps)
                    scene.syncTransforms()
                    isPaused = true
                }
                Button("Restart") {
                    scene.system = makeScene()
                    scene.syncTransforms()
                    isPaused = true
                }
            }
            .padding(8)
            .background(.thinMaterial)
            .cornerRadius(8)
            .padding()
        }
    }

    private func makeFloor() -> ModelEntity {
        let floor = ModelEntity(
            mesh: .generatePlane(width: floorSize, depth: floorSize),
            materials: [SimpleMaterial(color: .darkGray, isMetallic: false)]
        )
        floor.position.y = -20
        return floor
    }

    private func makeKeyLight() -> DirectionalLight {
        let light = DirectionalLight()
        light.light.intensity = 3000
        light.look(at: .zero, from: SIMD3(5, 8, 5), relativeTo: nil)
        return light
    }

    private func makeFillLight() -> DirectionalLight {
        let light = DirectionalLight()
        light.light.intensity = 1000
        light.look(at: .zero, from: SIMD3(-4, 3, -4), relativeTo: nil)
        return light
    }
}
