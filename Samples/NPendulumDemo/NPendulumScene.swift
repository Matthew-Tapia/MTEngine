import Foundation
import PhysicsEngine

/// Builds an N-link pendulum from a fixed anchor and rigid rods.
enum NPendulumScene {
    static func make(n: Int) -> ParticleSystem {
        precondition(n > 0, "An N-pendulum must have at least one link.")

        let system = ParticleSystem()
        let rodLength: Float = 3
        let pivot = SIMD3<Float>(0, 0, 0)
        let pivotIndex = system.addParticle(position: pivot, mass: 0)

        var previousIndex = pivotIndex
        var previousPosition = pivot
        for _ in 0 ..< n {
            let azimuth = Float.random(in: 0 ..< 2 * .pi)
            let tilt = Float.random(in: .pi / 6 ... .pi / 3)
            let direction = SIMD3(
                sin(tilt) * cos(azimuth),
                -cos(tilt),
                sin(tilt) * sin(azimuth)
            )
            let bobPosition = previousPosition + direction * rodLength
            let bobIndex = system.addParticle(position: bobPosition)
            system.addConstraint(DistanceConstraint(
                particleA: previousIndex,
                particleB: bobIndex,
                restLength: rodLength
            ))
            previousIndex = bobIndex
            previousPosition = bobPosition
        }

        return system
    }
}
