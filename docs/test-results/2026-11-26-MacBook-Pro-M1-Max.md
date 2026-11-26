# Real-Mac test results: 26 November 2026

- **Mac:** MacBook Pro, Apple M1 Max
- **macOS:** 27.0.1 (26A434)
- **Xcode:** 26.6 (17F113); XcodeGen 2.46.0
- **Tested commit:** `9a08b233a39e0c72b4bd83e33e90d07a0810b75c`
- **App:** Debug build, installed in `~/Applications/SpeechToTextLocal.app`.

The handoff's referenced scaffold commit is followed by the handoff PR on main; no other PRs had landed when testing
started. Xcode first-launch setup completed on this Mac.

## Build and automated tests

- **Pass:** XcodeGen generated the project and the macOS Debug build succeeded.
- **Pass:** All six `RuleBasedTextEnhancerTests` passed in the app-hosted test suite.
- **Pass:** The built app's Info.plist contains both usage descriptions, and its signed entitlements contain
  `com.apple.security.device.audio-input`.
- **Observation:** The test log included `linkd.autoShortcut` connection errors, but the test suite succeeded.

## Real-Mac checklist

Pass applies only to the behavior explicitly observed. Partial and skipped items are not complete passes.

1. **First launch — pass:** The 900 × 632 window showed the expected initial controls, zero statistics, disabled Copy
   and Clear, and a green On-device badge. The badge remained after reopening.
2. **Permission prompts — partial:** The owner allowed access and dictation worked. Both permission texts were
   verified in the bundle, but the order, text as displayed in the prompts, and automatic start immediately after
   allowing were not independently recorded.
3. **Saying no — partial:** Denying Speech Recognition and reopening produced the expected Speech Recognition
   warning. Denying Microphone produced the expected Microphone warning. After enabling Microphone in System Settings,
   recording started without reopening. Speech Recognition recovery through System Settings was not checked.
4. **Dictating — partial:** The owner's speech produced “I think we should go”, five words, and a nonzero wpm.
   The red stop button and “Listening — on-device” status were observed during another recording. Live transcription
   and the pulsing animation were not independently verified.
5. **Stopping — partial:** The owner stopped recording; the text remained and the status read “Tap the mic to dictate
   again”. Whether the very last words were retained and whether a transient alert appeared were not verified.
6. **No network — skipped:** Owner chose to skip.
7. **Clean up — partial:** The displayed examples were “I think we should go” and “I think the report is good”.
   Turning Clean up off for the second example showed the same text: the recognizer had already omitted the repeated
   word. The raw first example was not captured.
8. **Copy — partial:** The Copy button put the exact displayed second example on the clipboard. Pasting into TextEdit
   and selecting part of the text with ⌘C were not checked.
9. **Clear — partial:** Clear while idle reset text, word count, wpm, and status. Clear while recording was not
   checked.
10. **Dictating again — not tested:** Replacement versus appending within one app session was not verified.
11. **Silence and long dictations — partial:** After approximately 32 seconds of silence the UI still showed
    “Listening — on-device” with no alert; recording was then stopped. During a later two-window attempt one window
    stopped with “No speech detected” while the other showed listening. Two-minute dictation was skipped by the owner.
12. **Microphones — partial:** A real microphone captured the owner's speech; the input device was not independently
    confirmed. Testing another microphone and switching inputs was skipped by the owner.
13. **VoiceOver — skipped:** Owner chose to skip.
14. **A second window — partial:** ⌘N opened a second window. Starting the mic in both resulted in one window showing
    “No speech detected” and stopped, while the other showed “Listening — on-device”. Independent text and the cause
    of the alert were not verified.
15. **Quitting — pass:** The app exited after Quit while one window showed listening; no matching crash report appeared
    in DiagnosticReports in the following check.

An automated spoken-playback attempt produced no transcript; the Mac's output was muted. This was not treated as an
app failure. A subsequent spoken check was skipped by the owner. No issue was opened for the observations above
because a reproducible app problem was not established.
