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

This work is intended as a **clean foundation for preservation, maintenance, and future work**, and to serve as a reliable building block for higher-level wrapper or orchestration projects.

---

## What This Patchkit Does

✅ Applies Mother 1 English text  
✅ Applies Mother 1 window/layout ASM changes  
✅ Applies Mother 1 uncensor/restoration graphics  
✅ Applies a **final IPS selector** to produce a standalone Mother 1 build  
✅ Builds cleanly with no unused dependencies  
✅ Leaves Mother 2 code, data, and text untouched  

❌ Does **not** modify Mother 2  
❌ Does **not** inject splash screens or intros  
❌ Does **not** rely on Mother 2 assets or tables  
❌ Does **not** merge or entangle Mother 1 and Mother 2 logic  

---

## High-Level Build Pipeline

The patch process is intentionally simple and strictly ordered:

1. A clean **Mother 1+2 (Japan)** ROM is copied to a temporary working file  
2. `xkas` applies **Mother 1–only ASM patches**  
3. `insert_m1.exe` inserts **Mother 1 English text and data only**  
4. A final **IPS selector patch** is applied to produce a standalone **Mother 1 autoboot ROM**

If ASM assembly or text insertion fails, the process **aborts immediately** to prevent partially patched or ambiguous outputs.

The IPS step is intentionally performed **last** and acts only as a **final selector/routing stage**, not as part of the translation or patch logic itself.


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
- The script produces `Mother1_only.gba`, a standalone **Mother 1 autoboot ROM**.
- Temporary working files (e.g. `test.gba`) are cleaned up automatically.

No Mother 2 data, code, or text is modified in the process.

---

## Rebuilding `insert_m1.exe` (Windows)

The file `source/insert_m1.c` uses C++ references (`int&`), so it must be compiled **as C++** (or renamed to `.cpp`).

### Option A: MinGW-w64 (Recommended)

1. Install **MinGW-w64** and ensure `gcc` is available in your PATH.
2. From the repository root, run: gcc -O2 -std=gnu++03 -x c++ -o insert_m1.exe source/insert_m1.c
3. Ensure `insert_m1.exe` is located in the same directory as `i_m1_only.bat`.
4. Run the build script: i_m1_only.bat

### Option B: MSVC (Developer Command Prompt)

1. Open **Developer Command Prompt for Visual Studio**.
2. From the repository root, run: cl /O2 /EHsc /TP source\insert_m1.c /Fe:insert_m1.exe
3. Run the build script: i_m1_only.bat

## Rebuilding `ips.exe` (Windows)

The file `source/ips.c` is a small, standalone IPS patcher used as the **final selector stage** in the build pipeline.  
It applies a prebuilt IPS patch to a completed ROM and produces the final output file.

Rebuilding `ips.exe` is optional for most users, as a prebuilt binary is included for convenience.

### Option A: MinGW-w64 (Recommended)

1. Install **MinGW-w64** and ensure `gcc` is available in your PATH.
2. From the repository root, run: gcc -O2 -o ips.exe source/ips.c
3. Ensure `ips.exe` is located in the same directory as `i_m1_only.bat`.
4. Run the build script: i_m1_only.bat


### Option B: MSVC (Developer Command Prompt)

1. Open **Developer Command Prompt for Visual Studio**.
2. From the repository root, run: cl /O2 source\ips.c /Fe:ips.exe
3. Run the build script: i_m1_only.bat


### Notes

- `ips.exe` is intentionally simple and self-contained.
- It performs **no translation or ASM logic**.
- It is used only to apply a final IPS selector patch after all Mother 1 content has been inserted.
- Advanced users may replace this tool with another IPS-compatible patcher if desired, provided it supports the same input/output behavior.

## IPS Selector / Autoboot Behaviour (Technical Summary)

The Mother 1+2 GBA ROM boots through a small state-driven intro sequence before reaching the game selection menu.  
This project relies on a **prebuilt IPS patch** (tomato-m12-mother-1-only.ips) created by tonebender using Ghidra a reverse-engineering framework that modifies this boot flow to bypass the cartridge menu and autoboot **Mother 1 only**, without altering any Mother 1 translation logic.

### Boot Flow Overview

- The ROM entry point initializes a function pointer (`DAT_030012d0`) that controls which routine runs each frame.
- Boot progresses through a sequence of intro handlers:
  1. Nintendo logo
  2. “MOTHER 1+2” splash
  3. Game selection screen

Each stage updates `DAT_030012d0` to point to the next handler.

### Key Boot Functions

- `FUN_08013878`  
  Central routine responsible for displaying:
  - Nintendo screen
  - “MOTHER 1+2” splash
  - Game selection menu  
  (Behaviour determined by a parameter value.)

- `UndefinedFunction_080137a4`  
  Displays the Nintendo logo and advances the boot state.

- `UndefinedFunction_080137c0`  
  Displays the “MOTHER 1+2” splash screen.

- `UndefinedFunction_08013740`  
  Displays the game selection screen and launches Mother 1 or Mother 2 depending on an internal flag.

### No-Op Helpers

Two simple functions are useful for neutralizing behaviour without breaking control flow:

- `FUN_08000754`  
  No arguments, no return — used to safely replace calls that only perform side effects (e.g. drawing screens).

- `FUN_080f8ca4`  
  No arguments, returns `1` — used when a return value is required but logic should be bypassed.

### Selector Patch Strategy

The IPS selector used by this project:

- Replaces specific calls to `FUN_08013878` with no-ops
- Skips all visual intro and menu logic
- Allows initialization code to run normally
- Forces execution directly into the Mother 1 launch path

Importantly:

- **Mother 1 logic, data, and translation are not modified**
- **Mother 2 code is not altered or depended upon**
- The IPS patch functions purely as a **final routing/selection step**

### Project Scope Note

While similar techniques can be used to autoboot Mother 2, this project intentionally applies **only the Mother 1 selector IPS**.  
Mother 2 behaviour is documented here solely for technical context and is not used or modified by this patchkit.



---

## Linux / macOS Notes

This repository currently ships Windows-native tools (`xkas.exe`, `insert_m1.exe`, `ips.exe`) and a Windows batch script (`i_m1_only.bat`).

Linux and macOS users can still build the text inserter, but applying the full pipeline requires additional setup.

### Building the Text Inserter on Linux / macOS

From the repository root: g++ -O2 -std=gnu++03 -o insert_m1 source/insert_m1.c

This produces: ./insert_m1


### Applying the ASM Patch (`m12.asm`)

The ASM patch uses **xkas** syntax.

On Linux or macOS, you must either:

- Run `xkas.exe` and `ips.exe` through a Wine environment, **or**
- Port the ASM and IPS steps to compatible modern tools (advanced users only).

At present, the officially supported and tested workflow is **Windows via `i_m1_only.bat`**.

---

## Expected Build Behaviour

When the build succeeds:

- `xkas` applies all **Mother 1–only ASM patches**
- `insert_m1.exe` inserts **Mother 1 English text and data**
- A final **IPS selector patch** is applied
- The resulting ROM (`Mother1_only.gba`) autoboots directly into **Mother 1**
- Temporary working files are removed automatically

If any stage fails, the build script **aborts immediately** to prevent partially patched or ambiguous ROMs.




## Credits & Acknowledgements

- Original Mother 1+2 GBA fan translation team **jeffman** and **tomato** 
- Tooling and ASM work by the original project authors  
- Cleanup, refactor, and M1-only isolation work by **InfiniteEnd**
- ips.c tool by the Shaver of Yaks **mrehkopf**
- Reverse-engineering work on the Mother 1+2 GBA ROM boot process by **tonebender**.

This project builds on prior community work with respect and attribution.

## License / Use

"Software is like sex, it's better when it's free!" -Linus Torvalds

This repository contains **tools and patch data only**.  
**No ROMs are included.**

Use responsibly and in accordance with your local laws.
