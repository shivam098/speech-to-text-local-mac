# Handoff: finishing on a real Mac

For whoever picks this up on a Mac — a person, or a coding agent started in this repo (AGENTS.md points here). Work
through it in order: check where things stand, set up the Mac, build and test, install and set up the app, run the
checks only a real Mac can do, then report what you found.

Written 26 November 2026 on a Windows PC with no Mac: this prototype has never been built or run on a Mac yet (there's
no CI). Everything below about how the app behaves is read from the code, not tried.

## 1. Where things stand

Speech To Text Local for Mac is a one-window dictation app: click the mic, speak English, and Apple's Speech framework
writes your words as you talk. A clean-up step, which you can switch off, removes filler words and repeats, and Copy
puts the text on the clipboard. It was scaffolded in one commit in June 2026, and nothing has changed since.

What's in the code (7 Swift files, under `SpeechToTextLocal/` and `Tests/`):

- **App** (`App/SpeechToTextLocalApp.swift`): one window.
- **Dictation** (`Models/DictationModel.swift`): the first time you click the mic, it asks for Speech Recognition, then
  Microphone access. It records with `AVAudioEngine` and transcribes English (US) with `SFSpeechRecognizer`, showing
  the words as they come. It sets `requiresOnDeviceRecognition` only when the recogniser reports on-device support;
  otherwise the request may send the audio to Apple's servers. Also here: the word count, words per minute, Copy and
  Clear.
- **Clean-up** (`Enhance/`): the `TextEnhancer` protocol and `RuleBasedTextEnhancer`. It removes fillers ("um", "uh",
  "hmm" and others), "you know" and "I mean", words said twice in a row, and stray spaces and commas, then capitalises
  sentences and "I". The window shows the cleaned text while the "Clean up" switch is on.
- **Window** (`Views/`): `ContentView` (an "On-device" badge, the "Clean up" switch, the text, the stats, a status line,
  Copy and Clear, and an alert for errors) and `MicButton` (the round button that turns red and pulses while
  recording).
- **Resources:** an asset catalog with the accent colour and empty app-icon slots, and
  `SpeechToTextLocal.entitlements` with `com.apple.security.device.audio-input`, which the Hardened Runtime needs before
  the app can use the microphone.
- **Tests** (`Tests/RuleBasedTextEnhancerTests.swift`): 6 unit tests for the clean-up.
- **`project.yml`**: the XcodeGen spec. The app target `SpeechToTextLocal` (bundle ID `com.speechtotextlocal.app`,
  macOS 14.0 or later, Swift 5, Hardened Runtime, automatic signing with no team, and the two permission texts), the
  test target `SpeechToTextLocalTests` (its tests run inside the app), and a shared scheme `SpeechToTextLocal` that
  builds, runs and tests. No App Sandbox.

What's missing or stubbed:

- English (US) only; the language is fixed in the code.
- Nothing is saved: the text is gone when the window closes.
- No app icon images, no signing team, no CI.
- The README's roadmap: an on-device AI clean-up (Apple Intelligence / Foundation Models), switching languages, and a
  menu-bar mode. None of it is started.
- The original files were committed with Windows (CRLF) line endings, and there's no `.gitattributes`.

Speech To Text Local for iPhone and Android is in
[speech-to-text-local-ios](https://github.com/shivam098/speech-to-text-local-ios) and
[speech-to-text-local-android](https://github.com/shivam098/speech-to-text-local-android): one scaffold commit each,
and no CI.

The code described here is `main` at `46bf27aa95d26c960036f5e2d488761a2978f5c5`, the only commit before this
handoff. Before you start: `git pull` and `gh pr list` — later work may have landed.

## 2. Set up this Mac

**macOS 14 (Sonoma) or later.** The app's deployment target is macOS 14.0.

**Xcode 15 or later**, as the README says (the code uses the Observation framework, `@Observable`). Install the newest
Xcode your macOS supports from the App Store, open it once so it finishes installing, then:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
xcodebuild -version
```

**Xcode's command line tools:** `xcode-select --install` (if it says they're already installed, that's fine).

**Homebrew** (<https://brew.sh>), then XcodeGen and the GitHub CLI:

```sh
brew install xcodegen gh
```

**GitHub, as shivam098:**

```sh
gh auth login      # GitHub.com, HTTPS, log in with a browser as shivam098
gh auth setup-git  # git pushes with that login
gh auth status     # should show shivam098
```

**The repo,** with commits in the owner's name:

```sh
gh repo clone shivam098/speech-to-text-local-mac
cd speech-to-text-local-mac
git config user.name shivam098
git config user.email 39924466+shivam098@users.noreply.github.com
```

## 3. Build and test

`project.yml` is the source of truth. The Xcode project is generated from it and isn't committed (`.gitignore` skips
`*.xcodeproj` and `build/`).

```sh
xcodegen generate   # writes SpeechToTextLocal.xcodeproj
xcodebuild -project SpeechToTextLocal.xcodeproj -scheme SpeechToTextLocal -destination 'platform=macOS' -derivedDataPath build build
xcodebuild -project SpeechToTextLocal.xcodeproj -scheme SpeechToTextLocal -destination 'platform=macOS' -derivedDataPath build test
```

Expect `** BUILD SUCCEEDED **` with the app at `build/Build/Products/Debug/SpeechToTextLocal.app`, then
`** TEST SUCCEEDED **` with the 6 tests in `RuleBasedTextEnhancerTests` passing. The tests run inside the app, so its
window may open for a moment. In Xcode, open `SpeechToTextLocal.xcodeproj`: ⌘R runs the app, ⌘U runs the tests.

Then check that the built app has its two permission texts and the microphone entitlement. Without the texts, macOS
ends the app when it asks for permission; without the entitlement, the Hardened Runtime keeps it off the microphone.

```sh
plutil -p build/Build/Products/Debug/SpeechToTextLocal.app/Contents/Info.plist | grep UsageDescription
codesign -d --entitlements - build/Build/Products/Debug/SpeechToTextLocal.app
```

Expect `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription`, then
`com.apple.security.device.audio-input`.

- **Untested: signing.** `project.yml` sets no team. If `xcodebuild` stops with a signing error, add
  `CODE_SIGN_IDENTITY=-` to the commands (Xcode's "Sign to Run Locally", no Apple account needed), or
  `DEVELOPMENT_TEAM=<your team ID>` to sign with your Apple team. The README says to pick your team in Xcode's Signing &
  Capabilities; that works, but anything you change in Xcode's project editor is lost the next time you run
  `xcodegen generate`. Put lasting changes in `project.yml`.
- **If the build or a test fails,** fix it in small PRs, one problem per PR. The code has never been compiled, so there
  may be some errors.
- **A good first PR:** a GitHub Actions workflow on `macos-15` that runs `brew install xcodegen`, `xcodegen generate`
  and the build and test commands above (with `CODE_SIGN_IDENTITY=-`, as the runner has no team).

## 4. Install and set up the app

Run it from Xcode (⌘R), or:

```sh
open build/Build/Products/Debug/SpeechToTextLocal.app
```

Open the app itself (Xcode, Finder or `open`). Don't run the program inside it from Terminal: macOS would then ask for
the microphone on Terminal's behalf. To keep a copy, drag the app into Applications. An app you built on this Mac isn't
quarantined, so macOS doesn't ask you to "Open Anyway".

**Permissions** are asked the first time you click the mic, not at launch:

1. **Speech Recognition**, with the text "Speech To Text Local uses on-device speech recognition to transcribe your
   voice privately."
2. **Microphone**, with the text "Speech To Text Local needs the microphone to turn your voice into text."

Allow both. If you said no, turn them on in System Settings › Privacy & Security › Speech Recognition, and
› Microphone. To get the prompts again (to test saying no, or if a permission looks on but the app says it's missing):

```sh
tccutil reset SpeechRecognition com.speechtotextlocal.app
tccutil reset Microphone com.speechtotextlocal.app
```

Untested: without a signing team, each build is signed differently, so macOS may ask again after a rebuild.

**First run:** there's nothing else to set up. Speak English (US). The text isn't kept after the window closes.

## 5. What only a real Mac can check

These need a person at the Mac, a microphone and a voice. An agent can build the app and run the tests, then walk the
person through this list and write down the answers. Note anything that looks wrong, even if it isn't on the list.

1. **First launch.** A window, at least 460 × 600, headed "Speech To Text Local", with a "Clean up" switch (on), "Your
   words will appear here…", 0 words, 0 wpm, clean-up On, "Tap the mic and start speaking", a round mic button, and
   Copy and Clear greyed out. No permission prompt yet. A green "On-device" badge shows when the recogniser supports
   on-device English (US). Note whether it shows, and whether that changes after you've given the permissions and
   reopened the app (the code checks once, at launch).
2. **Permission prompts.** Click the mic: Speech Recognition is asked first, then Microphone, each with the text from
   section 4. Allow both: recording starts without another click.
3. **Saying no.** Reset both (section 4), click the mic and refuse Speech Recognition: an alert, "Notice", says "Speech
   recognition permission is required. Enable it in System Settings ▸ Privacy & Security." Reset again, allow Speech
   Recognition and refuse the Microphone: "Microphone permission is required…". Then allow both in System Settings and
   click the mic again; note whether the app has to be reopened first.
4. **Dictating.** Click the mic and speak: the button turns red with a stop icon and a pulsing ring, and the status
   says "Listening — on-device" ("Listening…" without the badge). Your words appear as you speak, and the words and wpm
   numbers go up.
5. **Stopping.** Click the red button: recording stops, the text stays, and the status says "Tap the mic to dictate
   again". Note whether the last words before you clicked are kept, and whether an alert appears: `stop()` cancels the
   recognition task right after ending the audio, and the app shows any error the task reports.
6. **No network.** Turn off Wi-Fi (and unplug any network cable), then dictate. With the badge showing, it should still
   work. Without the badge, note what happens.
7. **Clean up.** Dictate "um I think uh we should go": with Clean up on, the text should read "I think we should go".
   Dictate "I think the the report is good": "I think the report is good". Switch Clean up off: the text shows as it
   was recognised. Apple's recogniser may leave some fillers out by itself; note what's left for the clean-up to fix.
8. **Copy.** Click Copy and paste into TextEdit: exactly the text shown (cleaned while Clean up is on). Selecting part
   of the text and pressing ⌘C works too.
9. **Clear.** Click Clear: the text, words and wpm go back to 0, and the status resets. Then click Clear while
   recording: the code doesn't stop the recording, so note whether the old text comes back with your next words.
10. **Dictating again.** Dictate, stop, then dictate again. From the code, the new dictation replaces the earlier text
    instead of adding to it. Note what happens.
11. **Silence and long dictations.** Start and say nothing for 30 seconds. Then talk for 2 minutes without stopping.
    Note any alert, whether recording stops by itself, and whether the button is red only while the app is really
    listening.
12. **Microphones.** Use the built-in microphone, then a headset (AirPods, or a USB one) if you have one, and switch
    the input in System Settings › Sound while recording. The code doesn't watch for input changes; note what happens.
13. **VoiceOver.** With VoiceOver on (⌘F5), the mic button reads "Start dictation", and "Stop dictation" while
    recording.
14. **A second window.** File › New Window (⌘N) opens another window with its own text. Note what happens if you start
    the mic in both.
15. **Quitting.** Quit (⌘Q) while recording: the app closes without a crash.

## 6. Report what you found

Write the results to `docs/test-results/<YYYY-MM-DD>-<Mac model>.md` (for example
`docs/test-results/2026-11-27-MacBook-Air-M2.md`) and open a PR with it. Include the Mac model, chip, macOS version,
Xcode version and the commit you tested, then each item of section 5 (and the build and tests from section 3) with
pass or fail and notes. These print what you need:

```sh
system_profiler SPHardwareDataType | grep -E "Model Name|Chip|Processor Name"
sw_vers
xcodebuild -version
git rev-parse HEAD
```

Open one GitHub issue per problem (`gh issue create`), with the steps to reproduce it, what you expected and what
happened, and your Mac and macOS version. If the app crashed, attach the crash report (Console › Crash Reports, or
`~/Library/Logs/DiagnosticReports`).

## 7. Rules for agents working here

- One PR per change.
- CI green where CI exists. There's none yet; once a workflow is added, don't merge while it's red.
- An independent review before merging: a person or agent that didn't write the change.
- Squash-merge.
- Every PR description starts with the owner's Agent assessment block, before anything else:

  ```markdown
  <!-- copilot-assessment:v1 -->
  ### Agent assessment

  Self-reported assessment, not an independent review.

  Assessed revision: `<full 40-character head SHA>`

  | Dimension | Assessment | Rationale |
  |---|---|---|
  | Change confidence | 7/10 | ↑ what supports the change<br>↓ what isn't verified yet |
  <!-- /copilot-assessment -->
  ```

  The score is out of 10. A bug fix also gets rows for Diagnosis confidence and Evidence fit. Put each ↑ (supporting)
  and ↓ (unverified) item on its own line with `<br>`, keep `|` out of the cells, and update the SHA when you push
  again.
- Never commit secrets or build output. `build/`, `DerivedData/` and the generated `.xcodeproj` are in `.gitignore`.
- Edit `project.yml`, not the generated Xcode project.
- Don't build a reduced version of a feature, or add extra security measures, without asking the owner.
- State measurements as findings, and ask the owner before drawing conclusions from them.
- Commit as `shivam098 <39924466+shivam098@users.noreply.github.com>`.

## 8. Decisions waiting for the owner

- **Is this prototype still wanted?** ThumbFree for Mac
  ([thumbfree-mac](https://github.com/shivam098/thumbfree-mac), in development, with CI that builds a test app) is
  private, on-device dictation too: tap Fn and it types into whatever app you're in, leaves out fillers and repeats,
  adds punctuation, understands English and Hindi + English with its own speech models, and keeps 30 days of history.
  Jarvis for Mac ([mac-voice-assistant](https://github.com/shivam098/mac-voice-assistant), in development) includes
  ThumbFree's dictation. This app dictates into its own window, in English (US) only, with Apple's Speech framework,
  and you copy the text out. ThumbFree also has Android and Windows apps and a planned iPhone app; this family's iOS
  and Android repos are at the same scaffold stage as this one.
- **Using Apple's servers.** When the recogniser doesn't report on-device support, the app doesn't require on-device
  recognition, so the audio may go to Apple's servers; the only sign is the missing "On-device" badge. The README
  says "no cloud, no API keys".
- **If it's kept:** which Apple team signs it, an app icon, and how it's shared.
