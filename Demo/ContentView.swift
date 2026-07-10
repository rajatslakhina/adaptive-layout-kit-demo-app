import SwiftUI
import AdaptiveLayoutKitCore
import AdaptiveLayoutKitUI

/// The layout variants this demo resolves between. A real app would likely
/// use distinct, richer view types per case rather than a plain enum switch,
/// but the enum keeps this demo's actual point — breakpoint resolution and
/// fold-transition debouncing — visible without an unrelated view-hierarchy
/// detour.
enum ProfileLayout: Sendable, Equatable {
    case compact
    case regular
    case expanded
}

struct ContentView: View {
    var body: some View {
        TabView {
            AdaptiveLayoutDemoView()
                .tabItem {
                    Label("Adaptive Layout", systemImage: "rectangle.split.3x1")
                }
            ScanView()
                .tabItem {
                    Label("Codebase Scan", systemImage: "magnifyingglass.circle")
                }
        }
    }
}

private struct AdaptiveLayoutDemoView: View {
    private let resolver = BreakpointLayoutResolver<ProfileLayout>(
        breakpoints: [
            LayoutBreakpoint(name: "compact", minWidth: 0, layout: .compact),
            LayoutBreakpoint(name: "regular", minWidth: 500, layout: .regular),
            LayoutBreakpoint(name: "expanded", minWidth: 900, layout: .expanded)
        ],
        fallback: .compact
    )

    @State private var previewWidth: Double = 320

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Live window width")
                            .font(.headline)
                        Text("Resolved from this window's actual available width via GeometryReader + AdaptiveContainer.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        AdaptiveContainer(resolver: resolver) { layout in
                            LayoutPreview(layout: layout)
                        }
                        .frame(height: 200)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview at any width")
                            .font(.headline)
                        Text("Drives the same BreakpointLayoutResolver directly, so every breakpoint is reachable without physically resizing the window.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        let previewLayout = resolver.resolve(
                            for: LayoutEnvironment(availableWidth: previewWidth, availableHeight: 400)
                        )
                        LayoutPreview(layout: previewLayout)
                            .frame(height: 160)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))

                        Slider(value: $previewWidth, in: 0...1100, step: 10)
                        Text("\(Int(previewWidth)) pt  →  \(name(for: previewLayout))")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("AdaptiveLayoutKit")
        }
    }

    private func name(for layout: ProfileLayout) -> String {
        switch layout {
        case .compact: return "compact"
        case .regular: return "regular"
        case .expanded: return "expanded"
        }
    }
}

private struct LayoutPreview: View {
    let layout: ProfileLayout

    var body: some View {
        switch layout {
        case .compact:
            VStack(spacing: 12) {
                Label("Compact", systemImage: "iphone")
                    .font(.title2.bold())
                Text("width < 500pt — single column")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.25)).frame(height: 60)
            }
            .padding()
        case .regular:
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Regular", systemImage: "ipad")
                        .font(.title2.bold())
                    Text("500–900pt — two columns")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                RoundedRectangle(cornerRadius: 12).fill(Color.green.opacity(0.25)).frame(width: 120, height: 100)
            }
            .padding()
        case .expanded:
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Expanded", systemImage: "laptopcomputer")
                        .font(.title2.bold())
                    Text("≥ 900pt — sidebar-shaped layout")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.25)).frame(width: 90, height: 100)
                RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.25)).frame(width: 90, height: 100)
            }
            .padding()
        }
    }
}
