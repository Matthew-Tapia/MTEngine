import XCTest
import simd
@testable import PhysicsEngine

final class ConstraintTests: XCTestCase {
    func testDistanceConstraintPullsParticlesTogether() {
        var particles = [
            Particle(position: .zero, velocity: .zero, inverseMass: 1),
            Particle(position: SIMD2<Float>(2, 0), velocity: .zero, inverseMass: 1)
        ]
        let constraint = DistanceConstraint(particleA: 0, particleB: 1, restLength: 1)

        constraint.solve(particles: &particles, deltaTime: 1.0 / 60.0)

        let distance = length(particles[1].position - particles[0].position)
        XCTAssertEqual(distance, 1, accuracy: 0.0001)
    }

    func testDistanceConstraintPushesParticlesApart() {
        var particles = [
            Particle(position: .zero, velocity: .zero, inverseMass: 1),
            Particle(position: SIMD2<Float>(0.5, 0), velocity: .zero, inverseMass: 1)
        ]
        let constraint = DistanceConstraint(particleA: 0, particleB: 1, restLength: 1)

        constraint.solve(particles: &particles, deltaTime: 1.0 / 60.0)

        let distance = length(particles[1].position - particles[0].position)
        XCTAssertEqual(distance, 1, accuracy: 0.0001)
    }

    func testDistanceConstraintKeepsPinnedParticleInPlace() {
        var particles = [
            Particle(position: .zero, velocity: .zero, inverseMass: 0),
            Particle(position: SIMD2<Float>(2, 0), velocity: .zero, inverseMass: 1)
        ]
        let constraint = DistanceConstraint(particleA: 0, particleB: 1, restLength: 1)

        constraint.solve(particles: &particles, deltaTime: 1.0 / 60.0)

        XCTAssertEqual(particles[0].position, .zero)
        let distance = length(particles[1].position - particles[0].position)
        XCTAssertEqual(distance, 1, accuracy: 0.0001)
    }

    func testDistanceConstraintIgnoresCoincidentParticles() {
        var particles = [
            Particle(position: .zero, velocity: .zero, inverseMass: 1),
            Particle(position: .zero, velocity: .zero, inverseMass: 1)
        ]
        let constraint = DistanceConstraint(particleA: 0, particleB: 1, restLength: 1)

        // Zero-length delta would divide by zero without the guard clause in solve(_:).
        constraint.solve(particles: &particles, deltaTime: 1.0 / 60.0)

        XCTAssertEqual(particles[0].position, .zero)
        XCTAssertEqual(particles[1].position, .zero)
    }

    func testConnectedParticleIndicesReportsPair() {
        let constraint = DistanceConstraint(particleA: 3, particleB: 5, restLength: 1)
        XCTAssertEqual(constraint.connectedParticleIndices.count, 1)
        XCTAssertEqual(constraint.connectedParticleIndices[0].0, 3)
        XCTAssertEqual(constraint.connectedParticleIndices[0].1, 5)
    }
}
