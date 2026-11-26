# Agent instructions

Speech To Text Local for Mac: a SwiftUI prototype of private dictation with Apple's Speech framework (click the mic,
speak, clean up the text, copy it), scaffolded in June 2026. The Xcode project is generated from `project.yml` with
XcodeGen.

**On a real Mac?** Start with [docs/HANDOFF-mac.md](docs/HANDOFF-mac.md): where the project stands, and how to finish
testing and set the app up.

- Build, test and run: `xcodegen generate`, then
  `xcodebuild -project SpeechToTextLocal.xcodeproj -scheme SpeechToTextLocal -destination 'platform=macOS' -derivedDataPath build build`,
  the same command with `test` in place of the last `build`, and
  `open build/Build/Products/Debug/SpeechToTextLocal.app`. Edit `project.yml`, not the generated (git-ignored) Xcode
  project.
- Commit as `shivam098 <39924466+shivam098@users.noreply.github.com>`.
- One PR per change and an independent review before merging (squash). PR descriptions start with the owner's Agent
  assessment block (docs/HANDOFF-mac.md, section 7).
