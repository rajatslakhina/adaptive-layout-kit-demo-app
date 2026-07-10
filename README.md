# AdaptiveLayoutKit Demo

A SwiftUI app that consumes [`adaptive-layout-kit`](https://github.com/rajatslakhina/adaptive-layout-kit) as a **remote** Swift Package dependency — the same way any real external consumer would — to show both halves of the library working end to end.

## Why this matters

A library's README can claim anything. This repo exists to prove `AdaptiveLayoutKit` behaves like a real dependency, not a folder that happens to sit next to a demo target: `Demo.xcodeproj` resolves `AdaptiveLayoutKitCore`/`AdaptiveLayoutKitUI` from the library's published GitHub URL on branch `main`, the same integration path a teammate on another machine would use.

The app itself has two tabs that map directly to the library's two halves:

- **Adaptive Layout** — a live `AdaptiveContainer` bound to the window's actual available width, plus a slider-driven preview that calls `BreakpointLayoutResolver` directly at any width from 0–1100pt, so every breakpoint (compact / regular / expanded) is reachable and visible without needing to physically resize or fold a device.
- **Codebase Scan** — runs `CodebaseScanner` against four bundled "legacy" Swift snippets (one with a hardcoded `.frame(width:height:)`, one with `UIRequiresFullscreen`, one reading `horizontalSizeClass`/`UIScreen.main.bounds`, and one already-adaptive file that should produce zero findings) and lists the results grouped by severity — a real, runnable version of the exact scan a CI job or coding-agent skill would perform.

## Other design decisions in this app

**Bundled string snippets, not real resource files, for the scan demo.** `SampleSnippets.swift` embeds four "legacy" code samples as plain Swift strings rather than shipping them as real `.swift.txt` resource files bundled into the app. *Rejected:* real bundled files — more realistic, but it means `CodebaseScanner` (which takes in-memory `(filePath, contents)` pairs by design, see the library README) would need a `Bundle`/`FileManager` reading step here just to demo it, adding UIKit-adjacent file I/O to a demo whose actual point is the scanner's logic, not file handling.

**A slider-driven preview panel, not just the live window-bound container.** The Adaptive Layout tab pairs a real `AdaptiveContainer` (bound to actual window width) with a second panel that calls `BreakpointLayoutResolver.resolve(for:)` directly against a slider value. *Rejected:* showing only the live container — on a single iPhone Simulator in portrait, actual window width never crosses the `regular`/`expanded` breakpoints, so a reviewer would only ever see the `compact` layout without physically rotating or resizing the simulator. The slider makes every breakpoint reachable and demo-able regardless of device/orientation.

## How to run it

1. Clone this repo and open `Demo.xcodeproj` in Xcode.
2. Let Xcode resolve the remote Swift Package dependency (`adaptive-layout-kit`, branch `main`) — this happens automatically on first open, or via File → Packages → Resolve Package Versions.
3. Select the `Demo` scheme and any iOS Simulator destination.
4. Build & Run (⌘R).
5. On the **Adaptive Layout** tab, drag the slider to see the layout flip between compact/regular/expanded. On the **Codebase Scan** tab, tap "Scan sample codebase" to see `CodebaseScanner` run for real.

## Verification — read this before trusting a green checkmark

This repo was built and pushed by an unattended, scheduled automation run with no human present to approve screen-control access. Concretely:

- **Library logic (`AdaptiveLayoutKitCore`): fully compiled and tested.** A real Swift 5.10.1 toolchain built the library headlessly and ran its test suite — `swift build` was clean (zero errors, zero warnings) and `swift test` passed **40/40**. See the [library repo's README](https://github.com/rajatslakhina/adaptive-layout-kit) for the full breakdown.
- **This app's Swift files: syntax-verified, not compiled.** `DemoApp.swift`, `ContentView.swift`, `ScanView.swift`, and `SampleSnippets.swift` were each run through `swiftc -parse` (syntax-only, no SwiftUI/UIKit available in the headless Linux sandbox this was built in) — all four parsed with zero errors. They were additionally reviewed by hand against the same crash classes as the tested library code: no force-unwraps, bounds-safe collection access, `@State`-driven optionals instead of implicitly-unwrapped ones.
- **`Demo.xcodeproj/project.pbxproj`: structurally validated, not opened in Xcode.** Checked with a scripted brace/paren/bracket balance pass (clean) and a full cross-reference of every object UUID referenced in the file against every UUID actually defined (28 distinct IDs, all consistently used — no dangling or typo'd references).
- **Simulator run: not completed, and this is disclosed rather than faked.** `request_access` for Xcode/Simulator was called twice this run (an immediate retry, per this pipeline's own procedure) and both times returned "Computer-use access ... can't be approved during a scheduled run" — unattended scheduled runs cannot get the human-in-the-loop approval that screen control requires on this machine. **No screenshots exist in this repo, and none are claimed.** The `Demo/Screenshots/` folder is intentionally absent rather than populated with placeholders.

The honest ceiling for this specific repo, this specific run: compiles-by-inspection and syntax-clean, with a genuinely tested library underneath it — not "confirmed launched on Simulator." If you clone this and it doesn't build cleanly in real Xcode, that's exactly the gap this section is flagging in advance rather than hiding.

## Library

This app is the runnable half of a two-repo pair. The actual logic — `BreakpointLayoutResolver`, `FoldTransitionDebouncer`, `CodebaseScanner`, and the three risk rules — lives in [`adaptive-layout-kit`](https://github.com/rajatslakhina/adaptive-layout-kit), including its design rationale, rejected alternatives, and full test breakdown.
