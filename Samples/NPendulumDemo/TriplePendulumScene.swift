import CoreGraphics
import PhysicsEngine

/// Builds a triple pendulum: a fixed anchor followed by three rigid rods,
/// each starting at a random angle with no initial velocity.
enum TriplePendulumScene {
    static func make(for size: CGSize) -> ParticleSystem {
        let system = ParticleSystem()

        // Keep the full particle inside the visible canvas by insetting the
        // bounds by its radius (converted from screen pixels to world units).
        let margin = Float(particleSize / 2) / Float(scale)
        let maxX = Float(size.width / scale) - margin
        let maxY = Float(size.height / scale) - margin

        let rodLength: Float = 3
        let pivot = SIMD2<Float>((margin + maxX) / 2, maxY / 2)  // center of the canvas
        let pivotIndex = system.addParticle(position: pivot, mass: 0)  // fixed anchor, never moves

        var previousIndex = pivotIndex
        var previousPosition = pivot
        for _ in 0..<3 {
            let angle = Float.random(in: 0..<(2 * Float.pi))
            let bobPosition = previousPosition + SIMD2(cos(angle), sin(angle)) * rodLength
            let bobIndex = system.addParticle(position: bobPosition)  // velocity defaults to .zero
            system.addConstraint(DistanceConstraint(particleA: previousIndex, particleB: bobIndex, restLength: rodLength))
            previousIndex = bobIndex
            previousPosition = bobPosition
        }

        return system
    }
}
