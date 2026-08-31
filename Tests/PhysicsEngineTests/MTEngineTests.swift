import Testing
@testable import PhysicsEngine

@Test func example() async throws {
    let system = ParticleSystem()
    #expect(system.particles.isEmpty)
}
