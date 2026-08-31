import Foundation
import simd

/// A constraint that can adjust particle state during a solver substep.
/// This is the seam for future constraint types (distance, pin, angle, etc.)
/// once you're ready to build them out.
public protocol Constraint {
    func solve(particles: inout [Particle], deltaTime: Float)
    /// Particle index pairs a renderer can draw a line between, if any.
    var connectedParticleIndices: [(Int, Int)] { get }
}

public extension Constraint {
    var connectedParticleIndices: [(Int, Int)] { [] }
}

public struct DistanceConstraint: Constraint {
    public let particleA: Int
    public let particleB: Int
    public let restLength: Float

    public var connectedParticleIndices: [(Int, Int)] { [(particleA, particleB)] }

    public init(particleA: Int, particleB: Int, restLength: Float) {
        self.particleA = particleA
        self.particleB = particleB
        self.restLength = restLength
    }

    public func solve(particles: inout [Particle], deltaTime _: Float) {
        let pA = particles[particleA]
        let pB = particles[particleB]

        let delta = pB.position - pA.position
        let currentLength = length(delta)
        let difference = currentLength - restLength

        guard currentLength > 0 else { return }

        let normalizedDelta = delta / currentLength
        let correctionFactorA = pA.inverseMass / (pA.inverseMass + pB.inverseMass)
        let correctionFactorB = pB.inverseMass / (pA.inverseMass + pB.inverseMass)

        particles[particleA].position += normalizedDelta * difference * correctionFactorA
        particles[particleB].position -= normalizedDelta * difference * correctionFactorB
    }
}
