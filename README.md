# MTEngine

This package follows the unified particle-physics architecture described in the project documents. It is organized into a C++ performance core, a Swift public API, debug tooling, benchmark targets, and test coverage for the simulation pipeline.

## Structure

- `Sources/PhysicsCore` — performance-critical C++ runtime
- `Sources/PhysicsEngine` — public Swift API and scene builders
- `Samples/PhysicsDebugView` — debug viewer and tooling target
- `Tests/*` — module and regression tests
- `Benchmarks/PhysicsBenchmarks` — benchmarking utilities
- `Tools/` — analysis scripts
- `docs/` — design and roadmap documents
