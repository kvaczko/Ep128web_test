# 2dfx v1.1.0 source-fidelity policy: built-in eggs and SHOW_FW

**Author / rights holder authorization (2026-10-22):** Károly Vaczkó,
original 2dfx creator, explicitly permits the egg-specific C source from the
hardware-validated v1.1.0 firmware to be preserved, adapted and distributed
within the portable 2dfx emulator under the MIT License, insofar as he owns
the relevant copyright. This also covers his original egg-specific helpers,
generated data, graphics and assets.

This permission is **narrowly scoped**. The original MCU firmware as a whole
is not being open-sourced. RP2354B/MCU-specific execution and hardware
implementation remain private and excluded: PIO, DMA, pixel/video scanout,
interrupt machinery, multicore/worker scheduling, renderer fast paths,
cache layout, optimized blitters and other implementation-specific tricks.
Do not copy those portions into the portable module.

## Required implementation approach

1. **Source of truth:** The hardware-validated v1.1.0 egg-specific source,
   including its state machines, constants, scene/resource setup, animation,
   timing expressed in logical frames, command ordering, and use of the
   public API, defines the expected behaviour. Screenshots are comparison
   evidence, **not** a specification from which to improvise a lookalike.
2. **Expose the public API to egg C code:** The firmware's
   `twodfx_api.h` is a deliberately public source-level interface, just as
   the documented F8h/F9h command protocol is public. Provide a portable
   C99-compatible API adapter implementing the applicable
   `twodfx_api` operations against the *existing* emulator's state:
   resource RAM, descriptors, sprites, 2DPT BG/FG shadow/active frame
   publishing, camera/mesh state, machine profile and drawing resources.
   Preserve public semantics and call ordering. Do not create an unrelated
   imitation drawing engine for eggs.
3. **Port, do not reinterpret:** Prefer to retain original egg C logic and
   egg-owned assets with minimal changes to replace hardware dependencies.
   A file may be included as an `.inc` or compiled as portable C, with
   dependencies kept under `web/src/twodfx/`; choose the build organization
   without changing egg behaviour. Isolate compatibility helpers rather than
   duplicating each egg's API.
4. **Portable substitutions:** Convert Pico SDK time/rand helpers, Core0
   startup/ticks and deferred work into deterministic or host-driven
   emulated equivalents. Advance logical egg time with frame ticks and
   document any differences in nondeterministic seeds. Represent original
   deferred resource operations with equivalent resulting state and
   sequencing without simulating hardware bandwidth or render-overrun time.
5. **Frame contract:** Keep the public API's shadow-to-active publication
   and BG/FG ordering. Operations that write RRAM or resources should
   interact with the same engine used for normal host F8h/F9h commands.
   Don't directly paint egg-specific output into a separate frame buffer
   or bypass the public renderer.
6. **SHOW_FW:** Although it is not an Easter egg, apply the same rule to
   `firmware_page.c`: create the logo/QR/text using the real public API,
   resources and the normal 2DPT renderer. Fixing a black rectangle by
   visually approximating the page is not acceptable.
7. **Validation:** Compare each ported egg to the v1.1.0 source for
   resource contents, setup sequence, frame transitions, coordinates,
   draw commands and palette/transparency. Where feasible, add trace/state
   tests plus comparisons to real Enterprise and TVC hardware. Compilation
   and emulator-only tests are not proof of visual parity. State residual
   differences explicitly; do not describe approximations as faithful ports.

## License and redistribution boundary

- **MIT:** Portable API adapter, portable emulator code, authorized
  egg-specific source and Károly Vaczkó-owned egg/SHOW_FW assets.
- **Not MIT:** Captured/derived third-party *Elite* geometry and *Wriggler*
  imagery; see `../ASSET_LICENSES.md`. No relicensing of rights owned
  by original game authors or publishers is implied.
- **Private / not distributed:** The RP2354B firmware outside the approved
  egg and public-API scope, and all hardware-specific renderer, timing,
  PIO/DMA, multicore and fast-path implementations.
- **Separate upstream licenses:** ep128emu and other third-party components
  retain their own applicable terms.

## Review rule

A proposed egg or SHOW_FW patch should answer:
**Which original v1.1.0 egg functions and public `twodfx_api` calls does
this preserve, and what portable substitutions were required?**
If the patch instead describes how to recreate a screenshot or visual effect
without following those source-level behaviours, revise it before merging.
