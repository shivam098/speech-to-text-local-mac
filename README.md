# Speech To Text Local — macOS

Private, **on-device** voice-to-text for the Mac. Tap the mic, speak, and your words
are transcribed locally using Apple's Speech framework — no cloud, no API keys. A
pluggable clean-up step removes filler words and stutters, fixes capitalisation and
spacing, and you can copy the result anywhere.

## Stack
- Swift + SwiftUI (macOS 14+)
- Speech framework with `requiresOnDeviceRecognition` (offline-capable)
- AVAudioEngine for microphone capture (no `AVAudioSession` on macOS)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project generation

## Requirements
- macOS 14 (Sonoma) or newer with Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Build & run
```bash
# 1. Generate the Xcode project from project.yml
xcodegen generate

# 2. Open it
open SpeechToTextLocal.xcodeproj

# 3. In Xcode: select your Team under Signing & Capabilities, then press Cmd-R.
```

Prefer the command line?
```bash
xcodegen generate
xcodebuild -scheme SpeechToTextLocal -destination 'platform=macOS' build
```

## Permissions & entitlements
On first use the app asks for **Microphone** and **Speech Recognition** access. The
app enables the Hardened Runtime and ships `SpeechToTextLocal.entitlements` with
`com.apple.security.device.audio-input`. Usage strings are declared in `project.yml`.

## Project layout
```
SpeechToTextLocal/
├── App/            SwiftUI entry point
├── Models/         DictationModel — speech, audio and stats (macOS variant)
├── Enhance/        TextEnhancer protocol + RuleBasedTextEnhancer
├── Views/          ContentView, MicButton
├── Resources/      Asset catalogue (accent colour, app icon slots)
└── SpeechToTextLocal.entitlements
Tests/              Unit tests for the text enhancer
project.yml         XcodeGen spec (source of truth)
```

## Tests
```bash
xcodegen generate
xcodebuild test -scheme SpeechToTextLocal -destination 'platform=macOS'
```

## Roadmap
- On-device LLM enhancer (Apple Intelligence / Foundation Models) for smart
  formatting, list detection and "speak to edit"
- Multi-language switching
- Menu-bar quick-dictation mode

---
Part of the **Speech To Text Local** family: iOS · macOS · Android.
