# Local transcription: recovery finding and integration direction

Status: documented recovery workflow, not an implemented app feature.

## Finding (2026-10-29, America/New_York)

Local Whisper large-v3 via MLX produced substantially more coherent Dutch
transcription from an original system-audio track than from a speculative
half-speed reconstruction of the same recording. Four sampled passages were
compared, then the original track was processed in 39 windows. The result
included coherent conversation and a closing goodbye, but also unclear passages.

Both passes used Whisper. This is evidence for preserving the original sample
rate and testing the original audio first, not a model comparison or proof that
Whisper outperforms Gemini. No reference transcript or word-error rate was measured.
Successful decoding and readable speech do not establish complete capture.

## Recovery workflow

1. Preserve the original `desktop.caf` and `mic.caf` files unchanged.
2. Check decoding and metadata separately from transcription quality. Garbled
   generated text does not by itself mean the audio container is corrupted.
3. Transcribe each original track separately before attempting timing repair.
   Resample normally for the model; do not reinterpret the sample rate merely
   because one track has a shorter duration.
4. The successful local run used `mlx-community/whisper-large-v3-mlx`, Dutch
   (`language="nl"`), `condition_on_previous_text=False`, 16 kHz model input,
   and 60-second windows with two seconds of overlap. The model was already
   cached and inference ran offline. Future tooling must handle overlap without
   duplicated words or dropped boundary speech; window completion alone is not
   a quality check.
5. Retain source identity and raw-track timestamps. If capture gaps were lost,
   these timestamps cannot be treated as wall-clock positions or aligned with
   the microphone just because both files started together.
6. Flag uncertain passages and inspect repeated or implausible text. ASR can
   hallucinate on silence. Never infer commitments or recover missing speech
   from model guesses.

## Proposed fork integration

Add an optional local transcription backend with a manual action to transcribe
original tracks, including when the mix has an integrity warning. Keep that
warning visible and keep automatic transcription of suspect mixes disabled.
Record model, language, source track, sample-rate handling and uncertainty in
output metadata. Keep local and cloud modes explicit; never silently upload audio
when local processing fails. The app does not yet implement this backend.

Before shipping: evaluate consented or synthetic Dutch fixtures with known text,
including silence, overlap boundaries, interrupted capture and rate changes.
Check word accuracy, hallucinations, duplicates and timestamp provenance against
an explicit pass bar. A successful personal recovery is not a production eval.

Private audio, meeting contents, participant names and transcripts stay outside
this repository.
