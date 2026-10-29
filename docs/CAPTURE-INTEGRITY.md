# Capture integrity: initial safeguards

This fork is not yet a validated replacement for unattended meeting capture.

## Changes

- Recover after missing callbacks rather than three seconds of quiet audio.
  A running output device is not evidence that the remote participant is speaking.
- Save `capture-integrity.json` with raw track durations alongside every mix.
- Warn when either track is empty/invalid or durations differ by more than two
  seconds. Keep the audio, but skip automatic transcription of a suspect mix.
- Matching durations never imply verified content completeness.

## Validation

`swift test` exercises normal silence, missing callbacks, half-length capture,
missing/invalid tracks, small start skew, and persisted integrity warnings.
`./build.sh` builds the release bundle. These checks do not exercise live audio
devices or demonstrate that a long call is captured correctly.

## Still required before replacing the installed app

1. Record timestamped chunks across device/rate changes, preserving discontinuities.
2. Verify the aggregate callback format against the tap format, including Bluetooth
   voice mode. Never append a new sample rate under an unchanged file header.
3. Add persistent live warnings for stalled and zero-filled input, without restarting
   merely because the participant is quiet. Persist recovery events and dropped frames.
4. Exercise simultaneous microphone clients, Bluetooth switches, silence, stalls,
   pauses and a long two-sided call. Check both waveform timelines against a fixture.
5. Review app lifecycle while mixing and how capture errors remain visible.

No audio, transcripts, private logs or recovery artifacts belong in this repository.

## Transcription recovery

See [Local transcription](LOCAL-TRANSCRIPTION.md) for the observed improvement
from transcribing original audio directly with local Whisper, the limitations
of timing reconstruction, and a proposed optional backend. This backend is not
yet implemented in the app.
