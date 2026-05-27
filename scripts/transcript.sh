#!/usr/bin/env bash
# transcript.sh - Generic YouTube transcript tool.
# Strategy:
#   1. yt-dlp auto-subtitles (fast, may fail on PO Token)
#   2. Fallback: yt-dlp audio + whisper local
#   3. SRT-to-TXT recovery if only SRT is produced
#
# Usage:
#   ./transcript.sh <youtube_url> <output_dir>
#
# Env vars:
#   WHISPER_BIN     path to whisper binary (default: mlx_whisper)
#   WHISPER_MODEL   model name (default: large-v3-turbo)
#   WHISPER_LANG    language code or 'auto' (default: auto)
#   AUDIO_CACHE     dir for cached audio (default: ~/.cache/yt_transcript)
#   DEBUG_LOG       debug log path (default: /tmp/yt_transcript_debug.log)
#
# Exit codes:
#   0  success (txt and srt present)
#   2  yt-dlp not installed
#   3  whisper not installed
#   4  invalid args
#   5  fetch failed in all strategies

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <youtube_url> <output_dir>" >&2
  exit 4
fi

URL="$1"
OUT_DIR="$2"
WHISPER_BIN="${WHISPER_BIN:-mlx_whisper}"
WHISPER_MODEL="${WHISPER_MODEL:-large-v3-turbo}"
WHISPER_LANG="${WHISPER_LANG:-auto}"
AUDIO_CACHE="${AUDIO_CACHE:-$HOME/.cache/yt_transcript}"
DEBUG_LOG="${DEBUG_LOG:-/tmp/yt_transcript_debug.log}"

mkdir -p "$OUT_DIR" "$AUDIO_CACHE"
: > "$DEBUG_LOG"

log() {
  echo "[$(date +%H:%M:%S)] $*" >> "$DEBUG_LOG"
}

# Dependency checks
command -v yt-dlp >/dev/null 2>&1 || { echo "yt-dlp not installed" >&2; exit 2; }

# Extract video ID
VID=$(yt-dlp --get-id "$URL" 2>>"$DEBUG_LOG") || {
  echo "Failed to extract video ID. See $DEBUG_LOG" >&2
  exit 5
}
log "VID=$VID URL=$URL"

# Save metadata
yt-dlp --dump-json --skip-download "$URL" > "$OUT_DIR/${VID}.meta.json" 2>>"$DEBUG_LOG" || {
  log "metadata fetch failed"
}

TXT_OUT="$OUT_DIR/${VID}.txt"
SRT_OUT="$OUT_DIR/${VID}.srt"

# ------------------------------------------------------------------
# Strategy 1: auto-subtitles
# ------------------------------------------------------------------
log "Strategy 1: auto-subtitles"
yt-dlp \
  --write-auto-sub --sub-lang "en,it" \
  --skip-download \
  --convert-subs srt \
  -o "$OUT_DIR/%(id)s.%(ext)s" \
  "$URL" >>"$DEBUG_LOG" 2>&1 || log "yt-dlp auto-sub failed"

# Try to find a SRT in any language
SRT_FOUND=$(find "$OUT_DIR" -name "${VID}*.srt" -size +100c 2>/dev/null | head -1)

if [[ -n "$SRT_FOUND" ]]; then
  log "SRT found: $SRT_FOUND"
  cp "$SRT_FOUND" "$SRT_OUT" 2>/dev/null || true
  # Convert SRT to plain text
  if [[ ! -s "$TXT_OUT" ]]; then
    python3 - "$SRT_FOUND" "$TXT_OUT" <<'PYEOF'
import sys, re
src, dst = sys.argv[1], sys.argv[2]
with open(src) as f:
    raw = f.read()
# Remove timestamps and index lines, keep text
lines = []
for block in re.split(r'\n\s*\n', raw):
    parts = block.strip().split('\n')
    text = [p for p in parts if not re.match(r'^\d+$|-->|\d{2}:\d{2}', p)]
    if text:
        lines.append(' '.join(text))
with open(dst, 'w') as f:
    f.write('\n'.join(lines))
PYEOF
  fi
  if [[ -s "$TXT_OUT" ]]; then
    log "Strategy 1 success"
    echo "$TXT_OUT"
    exit 0
  fi
fi

# ------------------------------------------------------------------
# Strategy 2: download audio + whisper
# ------------------------------------------------------------------
log "Strategy 2: audio + whisper"
command -v "$WHISPER_BIN" >/dev/null 2>&1 || {
  command -v whisper >/dev/null 2>&1 || {
    echo "Whisper not installed (tried $WHISPER_BIN and whisper)" >&2
    exit 3
  }
  WHISPER_BIN="whisper"
}

AUDIO_FILE="$AUDIO_CACHE/${VID}.mp3"
if [[ ! -s "$AUDIO_FILE" ]]; then
  # Audio fallback chain: best m4a -> best audio -> mp4 360p audio
  yt-dlp -x --audio-format mp3 \
    -f "bestaudio[ext=m4a]/bestaudio/best" \
    -o "$AUDIO_CACHE/%(id)s.%(ext)s" \
    "$URL" >>"$DEBUG_LOG" 2>&1 || {
    log "audio fetch fallback 1 failed, trying mp4 360p"
    yt-dlp -x --audio-format mp3 -f 18 \
      -o "$AUDIO_CACHE/%(id)s.%(ext)s" \
      "$URL" >>"$DEBUG_LOG" 2>&1 || {
      echo "Audio fetch failed in all strategies. See $DEBUG_LOG" >&2
      exit 5
    }
  }
fi

if [[ ! -s "$AUDIO_FILE" ]] || [[ $(stat -f%z "$AUDIO_FILE" 2>/dev/null || stat -c%s "$AUDIO_FILE") -lt 100000 ]]; then
  echo "Audio file too small or missing. See $DEBUG_LOG" >&2
  tail -20 "$DEBUG_LOG" >&2
  exit 5
fi
log "Audio ready: $AUDIO_FILE"

# Whisper run
WHISPER_ARGS=(
  "$AUDIO_FILE"
  --model "$WHISPER_MODEL"
  --output-dir "$OUT_DIR"
  --output-format all
)
if [[ "$WHISPER_LANG" != "auto" ]]; then
  WHISPER_ARGS+=(--language "$WHISPER_LANG")
fi

log "Running whisper: $WHISPER_BIN ${WHISPER_ARGS[*]}"
"$WHISPER_BIN" "${WHISPER_ARGS[@]}" >>"$DEBUG_LOG" 2>&1 || {
  echo "Whisper failed. See $DEBUG_LOG" >&2
  tail -20 "$DEBUG_LOG" >&2
  exit 5
}

# Whisper may output VID.txt or AUDIO_BASE.txt depending on binary
AUDIO_BASE=$(basename "$AUDIO_FILE" .mp3)
if [[ -s "$OUT_DIR/${AUDIO_BASE}.txt" && "$AUDIO_BASE" != "$VID" ]]; then
  mv "$OUT_DIR/${AUDIO_BASE}.txt" "$TXT_OUT"
  [[ -s "$OUT_DIR/${AUDIO_BASE}.srt" ]] && mv "$OUT_DIR/${AUDIO_BASE}.srt" "$SRT_OUT"
fi

if [[ ! -s "$TXT_OUT" ]]; then
  echo "Transcript TXT not produced. See $DEBUG_LOG" >&2
  exit 5
fi

log "Strategy 2 success"
echo "$TXT_OUT"
exit 0
