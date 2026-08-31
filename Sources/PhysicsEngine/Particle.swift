import Foundation

public struct Particle {
    public var previousPosition: SIMD2<Float>
    public var position: SIMD2<Float>
    public var velocity: SIMD2<Float>
    public var inverseMass: Float

    public init(position: SIMD2<Float>, velocity: SIMD2<Float>, inverseMass: Float) {
        self.previousPosition = position
        self.position = position
        self.velocity = velocity
        self.inverseMass = inverseMass
    }
}