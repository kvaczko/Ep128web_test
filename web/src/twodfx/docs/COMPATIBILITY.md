# Compatibility and verification scope

The real **2dfx v1.1.0 firmware is hardware validated**. The portable module independently reproduces its public interfaces but has **not been certified pixel-for-pixel or event-for-event** against complete hardware captures.

| Functional area | Portable implementation / qualification |
|---|---|
| F8/F9 parser, sessions, 8 MiB uploads, RAW/NICK/TVC conversion, ZX1, resources | Implemented and exercised by synthetic unit tests; physical bus timing edge cases require hardware comparison |
| 2DPT BG/FG, frame-latched camera and scene, sprites, collisions, raster IRQ | Logical implementations and regression coverage; host IRQ/video wiring to be verified in real Enterprise/TVC VMs |
| 2D primitives, fonts, bitmaps, patterns, tilemaps, fill and clipping | Implemented; isolated pixel and boundary differences are possible |
| 3D mesh API, 10-bit rotations, culling/projection | Implemented; final clipping/visibility/ordering precision versus physical render may differ |
| SHOW_FW and original 2dfx logo | Included; physical screenshot comparison still useful |
| Eggs C0–CF, D0–D2 and DF | Original v1.1.0 egg C implementations imported; creator reports browser visuals match physical hardware on the applicable Enterprise/TVC profiles (22 October 2026); not an automated pixel-diff certification |
| Egg D3 | Original v1.1.0 egg and authentic five-ship Elite geometry retained; included in creator-reported successful browser/hardware comparison |
| Egg D4 | Original v1.1.0 source and Asp geometry run through portable public-API adapter and shared renderer; creator reports visual agreement with hardware; execution-time behavior is not reproduced |
| Egg D5 | Original v1.1.0 public-mesh egg source imported; creator reports visual agreement with hardware; exact internal execution timing remains out of scope |
| Snapshots | Format v13, exact-size/CRC/invariant verification; incompatible with older formats |
| TVC256+++ | Existing VM feature is outside this module; preserve its separate implementation during integration |
| RP2354B render-time/overrun | Intentionally NOT modeled. Device overrun duration cannot be inferred from portable host speed |

All 23 Easter egg IDs are present as original v1.1.0 C source. **On 22 October 2026, the 2dfx creator reported checking all eggs in the Web emulator against physical hardware on both Enterprise and TVC (where each egg applies), and finding the visuals identical.** This is user-conducted manual hardware comparison, not an automated pixel-perfect trace or timing certification.

The C9 Wriggler sprite captures and Elite ship models are included **unchanged** to preserve the original firmware showcase appearance. They are third-party-derived material **outside this project's MIT grant** and may be removed without advance notice; see `ASSET_LICENSES.md`.

The supplied C++ adapter is a thin buildable connector **not a patched or validated ep128emu branch**. Zoltán Balogh and Károly Kiss can independently wire the same host ABI; physical waveform/image tests and regression of existing TVC256+++ behavior are integration-stage tasks.

## Original v1.1.0 egg-source import (developer fidelity branch)

The firmware-resident eggs and `SHOW_FW` now call the original v1.1.0 C
source through the portable `twodfx_api` layer, sharing the normal BG/sprite/FG
renderer. The former independently scripted approximation `.inc` modules and
firmware-page raster redraw have been removed from the build and repository.
All five D3 Elite ships and D4 Asp geometry come from the original
`firmware_eggs/egg_D3_elite_showcase_data.h` (byte-exact provenance is stored
in `firmware_eggs/ORIGIN_SHA256.json`).

**Unresolved contractual limitations:** firmware eggs retain original module
static state, which means per-device concurrent independent egg animation and
v13 snapshot restoration of running eggs are not source faithful. Pico entropy,
Core0 idle-worker scheduling and diagnostic timing are replaced with portable
logical equivalents; render-overrun timing remains deliberately unimplemented.
The Emscripten 6.0.13 WebAssembly build has succeeded on the Debian test VM, and the original creator reports a successful manual visual comparison of all supported eggs on the applicable Enterprise/TVC hardware. These observations do not cover internal execution timing, concurrent emulator instances, snapshot restoration in mid-egg, every renderer edge case, or bit-exact framebuffer comparison.
See `firmware_eggs/README.md` for licensing, evidence and boundaries.
