/// A handful of representative "legacy" Swift snippets — the kind of code
/// that predates iOS 27's resizable-window push — bundled so the demo's
/// Codebase Scan tab has something real to scan without needing file-system
/// access to an actual project. Each snippet is a plain `String`, not real
/// compiled code in this target, specifically so it can safely contain
/// deprecated/risky patterns (like `UIRequiresFullscreen`) without those
/// patterns actually being live code anywhere in this app.
enum SampleSnippets {
    static let files: [(filePath: String, contents: String)] = [
        (
            filePath: "LegacyOnboardingView.swift",
            contents: """
            import SwiftUI

            struct LegacyOnboardingView: View {
                var body: some View {
                    VStack {
                        Text("Welcome")
                    }
                    .frame(width: 375, height: 812)
                }
            }
            """
        ),
        (
            filePath: "LegacySceneDelegate.swift",
            contents: """
            import UIKit

            final class LegacySceneDelegate: UIResponder {
                func configure() {
                    UIRequiresFullscreen = true
                }
            }
            """
        ),
        (
            filePath: "LegacyDashboardView.swift",
            contents: """
            import SwiftUI

            struct LegacyDashboardView: View {
                @Environment(\\.horizontalSizeClass) private var sizeClass

                var body: some View {
                    let width = UIScreen.main.bounds.width
                    return Text("width: \\(width), class: \\(String(describing: sizeClass))")
                }
            }
            """
        ),
        (
            filePath: "ModernProfileView.swift",
            contents: """
            import SwiftUI
            import AdaptiveLayoutKitUI

            struct ModernProfileView: View {
                var body: some View {
                    Text("Already adaptive — nothing to flag here")
                }
            }
            """
        )
    ]
}
