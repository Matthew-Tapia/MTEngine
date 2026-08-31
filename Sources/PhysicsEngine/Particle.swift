import Foundation

public struct Particle {
    public var previousPosition: SIMD3<Float>
    public var position: SIMD3<Float>
    public var velocity: SIMD3<Float>
    public var inverseMass: Float

    public init(position: SIMD3<Float>, velocity: SIMD3<Float>, inverseMass: Float) {
        previousPosition = position
        self.position = position
        self.velocity = velocity
        self.inverseMass = inverseMass
    }
}
