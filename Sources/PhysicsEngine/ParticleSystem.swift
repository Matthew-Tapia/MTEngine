import Foundation

public final class ParticleSystem {
    public private(set) var particles: [Particle] = []
    public private(set) var constraints: [Constraint] = []

    public init() {}

    @discardableResult
    public func addParticle(position: SIMD3<Float>, velocity: SIMD3<Float> = .zero, mass: Float = 1.0) -> Int {
        particles.append(Particle(position: position, velocity: velocity,
                                  inverseMass: mass > 0 ? 1 / mass : 0))
        return particles.count - 1
    }

    public func addConstraint(_ constraint: Constraint) {
        constraints.append(constraint)
    }

    public func step(deltaTime: Float, substeps: Int = 4) {
        let h = deltaTime / Float(substeps)
        let gravity = SIMD3<Float>(0, -9.81, 0)

        for _ in 0 ..< substeps {
            for i in 0 ..< particles.count {
                guard particles[i].inverseMass > 0 else { continue }
                particles[i].previousPosition = particles[i].position
                particles[i].velocity += gravity * h
                particles[i].position += particles[i].velocity * h
            }

            for constraint in constraints {
                constraint.solve(particles: &particles, deltaTime: h)
            }

            for i in 0 ..< particles.count {
                guard particles[i].inverseMass > 0 else { continue }
                particles[i].velocity = (particles[i].position - particles[i].previousPosition) / h
            }
        }
    }
}
