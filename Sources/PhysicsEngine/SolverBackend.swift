import Foundation

public protocol SolverBackend {
    func step(particles: inout [Particle], deltaTime: Float)
}

public struct CPUSolverBackend: SolverBackend {
    public init() {}

    public func step(particles: inout [Particle], deltaTime: Float) {
        _ = particles
        _ = deltaTime
    }
}
