import SwiftUI
import AdaptiveLayoutKitCore

struct ScanView: View {
    @State private var findings: [LayoutRiskFinding] = []
    @State private var isScanning = false
    @State private var hasScanned = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        runScan()
                    } label: {
                        if isScanning {
                            ProgressView()
                        } else {
                            Text(hasScanned ? "Re-scan sample codebase" : "Scan sample codebase")
                        }
                    }
                    .disabled(isScanning)
                } footer: {
                    Text("Runs CodebaseScanner against \(SampleSnippets.files.count) bundled \"legacy\" Swift snippets that mimic pre-iOS-27 code.")
                }

                if hasScanned {
                    if findings.isEmpty {
                        Section {
                            Label("No fixed-layout risk found", systemImage: "checkmark.circle")
                                .foregroundStyle(.green)
                        }
                    } else {
                        ForEach(LayoutRiskSeverity.allCases.reversed(), id: \.self) { severity in
                            let severityFindings = findings.filter { $0.severity == severity }
                            if !severityFindings.isEmpty {
                                Section("\(label(for: severity)) (\(severityFindings.count))") {
                                    ForEach(severityFindings) { finding in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(finding.filePath):\(finding.lineNumber)")
                                                .font(.caption.monospaced())
                                                .foregroundStyle(.secondary)
                                            Text(finding.message)
                                                .font(.subheadline)
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Codebase Scan")
        }
    }

    private func label(for severity: LayoutRiskSeverity) -> String {
        switch severity {
        case .blocker: return "Blocker"
        case .warning: return "Warning"
        case .info: return "Info"
        }
    }

    private func runScan() {
        isScanning = true
        Task {
            let scanner = CodebaseScanner()
            let result = await scanner.scan(files: SampleSnippets.files)
            // Explicit MainActor hop rather than relying on Task-inherits-
            // MainActor-from-View inference — makes the actor-safety of this
            // UI mutation obvious at the call site rather than implicit.
            await MainActor.run {
                findings = result
                isScanning = false
                hasScanned = true
            }
        }
    }
}
