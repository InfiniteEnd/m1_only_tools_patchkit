# Mother 1 GBA – M1-Only Tools Patchkit

## Project Background & Relationship to Other Mother GBA Projects

This repository contains a **clean, refactored, M1-only patch toolchain** for **Mother 1 GBA**, as found on the official **Mother 1+2 (Game Boy Advance)** cartridge.

It is derived from, and would not exist without, the original **free, unofficial fan-made translation of MOTHER 1+2 for the Game Boy Advance**, originally released by the Mother/EarthBound fan community:  
http://mother12.earthboundcentral.com/

That original project provided a combined translation pipeline for **both Mother 1 and Mother 2**, sharing tools, ASM hooks, assets, and build logic across both games.

### Relationship to Jeffman’s Mother 2 GBA Project

This project is **closely related to**, but **intentionally separate from**, Jeffman’s ongoing Mother 2 work:

🔗 **Jeffman – Mother 2 GBA Translation Project**  
https://github.com/jeffman/Mother2GbaTranslation

Jeffman’s repository focuses on **Mother 2 (EarthBound) GBA specifically**, building on and extending the original Mother 1+2 translation work with new tooling, ASM changes, and refinements that target Mother 2 alone.

By contrast, **this repository exists solely to isolate and stabilize the Mother 1 side** of the original project.

---

## Why This Project Exists (Technical Rationale)

The original Mother 1+2 fan translation tooling was designed as a **single shared pipeline** that patched *both games at once*. While effective at the time, this approach introduces serious technical and maintenance issues today.

Specifically:

- Shared ASM hooks modify code paths used by *both* games
- Mother 1 and Mother 2 data tables are interleaved in the toolchain
- Intro/splash systems and experimental hooks affect shared ROM regions
- Text insertion tools expect both games’ assets to be present
- Build order and patch order become critical and fragile

As a result, the original toolchain **cannot safely be used as a modular system**.

---

## Why “Double Patching” Is a Bad Idea

A common temptation is to:
1. Patch Mother 1 using the original fan-made translation of MOTHER 1+2
2. Then patch Mother 2 using another (or vice versa)

**This is strongly discouraged.**

From a technical standpoint, double patching is unsafe because:

### 1. Overlapping ASM Hooks
Both Mother 1 and Mother 2 patches modify **shared code regions** in the ROM (menus, window logic, shared engine routines). Applying a second patch can overwrite or invalidate hooks installed by the first.

### 2. Branch Distance & Hook Placement
ASM hooks rely on precise branch distances and known free space. Reordering patches can push routines out of range, causing subtle runtime failures or outright crashes.

### 3. Shared Data Structures
Some structures (window layouts, font tables, engine state) are shared across both games. Re-patching can corrupt or desynchronize these structures.

### 4. Silent Failure Modes
The original tools do not always abort on error. It is possible to produce a ROM that *appears* to work but contains partially applied patches.

### 5. Maintenance Nightmare
Once a ROM has been double-patched, it becomes extremely difficult to audit:
- which tool modified which region
- which ASM hooks are active
- which text tables are authoritative

In short:
> **Double patching creates an opaque, unstable, fragile ROM that might initially load but could start failing randomly and cannot be reliably maintained or debugged.**

---

## The Philosophy of This Repository

This project solves those problems by enforcing a strict rule:

> **One game, one pipeline.**

This repository:
- Patches **Mother 1 only**
- Requires **no Mother 2 assets**
- Installs **no shared or ambiguous hooks**
- Produces deterministic, auditable results

Mother 2 work should be performed **separately**, using a toolchain designed specifically for it (such as Jeffman’s project).

---

## Intended Use

This repository is intended to serve as:

- A **clean preservation baseline** for Mother 1 GBA
- A **maintenance-friendly toolchain**
- A safe foundation for future Mother 1–specific work
- A clear separation point between Mother 1 and Mother 2 development

It is **not** intended to replace or subsume Mother 2 projects, but to coexist with them in a technically sound way.

In short:

> Mother 1 and Mother 2 may share a cartridge,  
> but they deserve **separate, disciplined build pipelines**.

The purpose of this project is **not** to re-translate Mother 1, nor to alter Mother 2 in any way.  
Instead, it isolates and stabilizes the tooling required to apply **Mother 1–specific English text and ASM patches only**, while leaving the Mother 2 side of the ROM completely untouched.

This work is intended as a **clean foundation for preservation, maintenance, and future work**.

## What This Patchkit Does

✅ Applies Mother 1 English text  
✅ Applies Mother 1 window/layout ASM changes  
✅ Applies Mother 1 uncensor/restoration graphics  
✅ Builds cleanly with no unused dependencies  
✅ Leaves Mother 2 code, data, and text untouched  

❌ Does **not** modify Mother 2  
❌ Does **not** apply splash screens or intros  
❌ Does **not** rely on Mother 2 assets or tables  

## High-Level Build Pipeline

The patch process is intentionally simple:

1. A clean **Mother 1+2 (Japan)** ROM is copied to a working file  
2. `xkas` applies **Mother 1–only ASM patches**  
3. `insert_m1.exe` inserts **Mother 1 English text only**  

If ASM assembly fails, the process **aborts immediately** to prevent partially patched ROMs.

## Design Philosophy

This project follows a few strict rules:

### No dead code  
Every file that exists is referenced and required.

### No silent behaviour  
If something fails, the build stops.

### One game, one pipeline  
Mother 1 and Mother 2 are treated as logically separate projects.

### Preservation-first  
Changes are minimal, reversible, and well-documented.

## What This Project Is *Not*

❌ A new translation  
❌ A ROM or ROM distribution  
❌ A combined Mother 1 + Mother 2 patch  
❌ A gameplay hack or balance mod  

You must supply your own **legally obtained ROM**.

## Status

**Current state:**

- ✔ Builds cleanly  
- ✔ Boots and runs correctly  
- ✔ Stable baseline achieved  

This repository is now suitable for:

- Long-term maintenance  
- Documentation  
- Further clean refactors  
- Serving as a base for future Mother 1 GBA work  

## Build & Run

This patchkit can be used as-is (prebuilt tools included), or you can rebuild the Mother 1–only text inserter from source.

---

### Prerequisites

- A clean **Mother 1+2 (Japan)** ROM (not included).  
  Place it in the repository root and name it: m12.gba

- A Windows environment is currently recommended for the full build pipeline.

> ⚠️ This repository does **not** include ROMs.  
> You must provide your own legally obtained copy.

## Quick Start (Windows)

1. Place your clean `m12.gba` ROM in the repository root.
2. Run the build script: i_m1_only.bat
3. Output:
- The script creates `test.gba`, which is your patched working ROM.

## Rebuilding `insert_m1.exe` (Windows)

The file `source/insert_m1.c` uses C++ references (`int&`), so it must be compiled **as C++** (or renamed to `.cpp`).

### Option A: MinGW-w64 (Recommended)

1. Install **MinGW-w64** and ensure `gcc` is available in your PATH.
2. From the repository root, run: gcc -O2 -std=gnu++03 -x c++ -o insert_m1.exe source/insert_m1.c
3. Ensure `insert_m1.exe` is located in the same directory as `i_m1_only.bat`.
4. Run the patch: i_m1_only.bat

### Option B: MSVC (Developer Command Prompt)

1. Open **Developer Command Prompt for Visual Studio**.
2. From the repository root, run: cl /O2 /EHsc /TP source\insert_m1.c /Fe:insert_m1.exe
3. Run the patch: i_m1_only.bat

## Linux / macOS Notes

This repository ships Windows-native tools (`xkas.exe`, `insert_m1.exe`) and a Windows batch script (`i_m1_only.bat`).  
Linux and macOS users can still build the text inserter, but applying the ASM patch requires additional setup.

### Building the Text Inserter on Linux / macOS

From the repository root: g++ -O2 -std=gnu++03 -o insert_m1 source/insert_m1.c

This produces: ./insert_m1

### Applying the ASM Patch (`m12.asm`)

The ASM patch uses **xkas** syntax.

On Linux or macOS, you must either:

- Run `xkas.exe` through a Wine environment, **or**
- Port the ASM to a compatible modern assembler (advanced users only).

At present, the officially supported and tested workflow is **Windows via `i_m1_only.bat`**.

## Expected Build Behaviour

When the build succeeds:

- `xkas` applies all **Mother 1–only ASM patches**
- `insert_m1.exe` inserts **Mother 1 English text**
- The resulting ROM (`test.gba`) boots and runs correctly

If ASM assembly fails, the build script **aborts immediately** to prevent partially patched ROMs.

## Credits & Acknowledgements

- Original Mother 1+2 GBA fan translation team  
- Tooling and ASM work by the original project authors  
- Cleanup, refactor, and M1-only isolation work by **InfiniteEnd**

This project builds on prior community work with respect and attribution.

## License / Use

"Software is like sex, it's better when it's free!" -Linus Torvalds

This repository contains **tools and patch data only**.  
**No ROMs are included.**

Use responsibly and in accordance with your local laws.
