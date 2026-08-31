import XCTest
@testable import PhysicsEngine

final class ParticleSystemTests: XCTestCase {
    func testParticleSystemCanBeCreated() {
        let system = ParticleSystem()
        XCTAssertNotNil(system)
    }

    func testParticleCanBeAdded() {
        let system = ParticleSystem()
        let position: SIMD2<Float> = .zero
        _ = system.addParticle(position: position)
        XCTAssertEqual(system.particles.count, 1)
    }

    func testAddParticleReturnsIncrementingIndices() {
        let system = ParticleSystem()
        let first = system.addParticle(position: .zero)
        let second = system.addParticle(position: SIMD2<Float>(1, 0))
        XCTAssertEqual(first, 0)
        XCTAssertEqual(second, 1)
    }

    func testZeroMassParticleHasZeroInverseMass() {
        let system = ParticleSystem()
        let index = system.addParticle(position: .zero, mass: 0)
        XCTAssertEqual(system.particles[index].inverseMass, 0)
    }

    func testAddConstraintIncreasesConstraintCount() {
        let system = ParticleSystem()
        let a = system.addParticle(position: .zero)
        let b = system.addParticle(position: SIMD2<Float>(2, 0))
        system.addConstraint(DistanceConstraint(particleA: a, particleB: b, restLength: 1))
        XCTAssertEqual(system.constraints.count, 1)
    }

    func testStepAppliesGravityToFreeParticle() {
        let system = ParticleSystem()
        let index = system.addParticle(position: .zero)
        system.step(deltaTime: 1.0 / 60.0)
        XCTAssertLessThan(system.particles[index].position.y, 0)
        XCTAssertLessThan(system.particles[index].velocity.y, 0)
    }

    func testStepDoesNotMoveStaticParticle() {
        let system = ParticleSystem()
        let index = system.addParticle(position: .zero, mass: 0)
        system.step(deltaTime: 1.0 / 60.0)
        XCTAssertEqual(system.particles[index].position, .zero)
        XCTAssertEqual(system.particles[index].velocity, .zero)
    }
}
