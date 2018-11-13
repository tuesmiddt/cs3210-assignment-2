# Architecture

## Jetson TX2

- 2 Pascal SM
- 128 CUDA cores/SM
- L2 Cache Size: 524288 bytes
- Total constant memory: 65536 bytes
- Total shared memory per block: 49152 bytes
- Total registers available per block: 32768

## Volta V100

- 80 Volta SM
- 64 CUDA cores/SM
- L2 Cache Size: 6144 KB
- Total registers per block: many many many

# General

- Managed memory may migrate into shared memory based on some unknown heuristic
- Generally gets faster with more total threads.
- Generally want to maximise SM efficiency (occupancy)
- Speedup observed even when number of threads > number of CUDA cores:
  - Having more eligible concurrent warps allows warp scheduler to hide latency by swapping out active thread.
  - 0 cost context switches by maintaining large register bank.

# Performance (Jetson)

- Main bottleneck is memory dependency
- Spike in write misses when running 32/64 blocks.
- Spike in write misses when running > 1024 total threads.
  - Conjecture: 0 cost context switch assumption breaks down. Not all threads mapped to a SM can have execution state maintained in registers.
- In general, fewer read misses with more total threads. Significant drop when there are at least 32 threads in a block.
- Consider cache misses vs run time for saturated cases (2 or more blocks, 256 or more total threads):
  - Write misses unrelated to time.
  - Read misses correlated to time.

# Performance (XGPC)

- Main bottleneck is execution dependency
- Peak speedup at total threads = 5120
  - Execution dependency bottleneck, hiding memory latency by scheduling extra threads does not give significant benefits.
- Greater SM efficiency -> faster
- No cache behaviour analysis because too few test cases saturated the hardware.
