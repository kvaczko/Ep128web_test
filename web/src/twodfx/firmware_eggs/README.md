# Original 2dfx v1.1.0 egg-source import

The 23 `egg_*.c` modules and their original headers/assets, plus
`firmware_page.c` and the public `twodfx_api.h`, are **byte-for-byte copies**
from Károly Vaczkó's hardware-validated RP2354B v1.1.0 source archive.
`ORIGIN_SHA256.json` records the SHA-256 digest of every imported file.

**Scope of copyright authorization:** Károly Vaczkó, as copyright holder,
authorized the egg-specific original C source and artwork he owns to be
preserved, adapted and distributed under MIT in the portable emulator.
This is NOT permission to redistribute the original entire MCU firmware.
The hardware-specific private renderer, pixel output, PIO, DMA, parallel
scheduler, scanout, and optimized fast paths are NOT imported. In particular,
`twodfx_api.c` is excluded; instead the emulator independently implements
its public `twodfx_api.h` interface in `core/twodfx_public_api_adapter.inc`.

The source includes genuine Elite-derived geometry and Wriggler-derived
images. Those third-party assets remain outside the MIT grant; see
`../ASSET_LICENSES.md`. No third-party relicensing is implied.

The `portable/pico/*` stubs and the small `2dfx.h` compatibility wrapper are
new portable equivalents, **not** copied MCU implementations. Some eggs use
logical frame scheduling in place of Core0 idle-time workers. Resource jobs
and rendering do not simulate RP2354B execution speed, work budgets or
hardware overrun timing.

**Known differences and limitations:**
- The original egg `.c` modules use process-global static state, matching the
  firmware's single-card calling model. Do not concurrently run eggs on
  multiple independent 2dfx emulators in one process; the per-egg state is
  not per-device.
- Existing portable device snapshot v13 does NOT serialize the original egg
  modules' private static state. Resuming a snapshot captured during an egg
  animation is not source-faithful and needs explicit future snapshot hooks.
- Pico's hardware RNG is replaced with a deterministic pseudorandom fallback;
  timed diagnostic counters use portable `clock()` rather than RP2354 timings.
- D3/D4/D5 worker work is drained to logical completion at frame acceptance,
  not scheduled against Core0 wall-clock idle time.
- Native C99, ASan, UBSan and scenario smoke testing are available.
  On 22 October 2026 the original 2dfx creator reported manually checking all
  Web-emulator eggs against physical Enterprise and TVC hardware (where
  applicable) and finding the visuals identical. This is a user-reported
  visual-comparison result, not automated pixel-by-pixel proof and not a
  verification of hardware execution/overrun timing.

The public F8h/F9h protocol and ordinary BG / sprites / FG renderer are shared
by original egg API actions and host writes; there is no egg-specific overlay.
