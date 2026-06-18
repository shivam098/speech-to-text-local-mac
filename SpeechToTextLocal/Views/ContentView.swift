import SwiftUI

struct ContentView: View {
    @State private var model = DictationModel()

    var body: some View {
        VStack(spacing: 20) {
            header
            transcriptCard
            statsRow
            Text(model.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            MicButton(isRecording: model.isRecording) {
                Task { await model.toggle() }
            }
            actionButtons
        }
        .padding(24)
        .frame(minWidth: 460, minHeight: 600)
        .alert("Notice", isPresented: errorBinding) {
            Button("OK", role: .cancel) { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Speech To Text Local")
                .font(.title2.bold())
            if model.isOnDeviceAvailable {
                Label("On-device", systemImage: "lock.fill")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.15), in: Capsule())
                    .foregroundStyle(.green)
            }
            Spacer()
            Toggle(isOn: $model.cleanUpEnabled) {
                Label("Clean up", systemImage: "wand.and.stars")
            }
            .toggleStyle(.switch)
        }
    }

    private var transcriptCard: some View {
        ScrollView {
            Text(model.displayedText.isEmpty ? "Your words will appear here…" : model.displayedText)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(model.displayedText.isEmpty ? .secondary : .primary)
                .textSelection(.enabled)
                .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 240)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            stat("\(model.wordCount)", "words")
            stat("\(model.wordsPerMinute)", "wpm")
            stat(model.cleanUpEnabled ? "On" : "Off", "clean-up")
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline.monospacedDigit())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                model.copyToClipboard()
            } label: {
                Label("Copy", systemImage: "doc.on.doc").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(model.displayedText.isEmpty)

            Button(role: .destructive) {
                model.clear()
            } label: {
                Label("Clear", systemImage: "trash").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(model.displayedText.isEmpty)
        }
    }
}

#Preview {
    ContentView()
}
