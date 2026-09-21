#!/bin/bash
# ---------------------------------------------------------------------------
# add-clip.sh — put ONE chosen video onto the portfolio.
#
#   ./add-clip.sh <source-video> <client-key> "<label>" [EN|FR]
#
# Example:
#   ./add-clip.sh incoming/new-ad.mov carhealers "Winter promo" FR
#
# It compresses the video for web, cuts a poster frame, drops both in media/,
# and prints the entry to paste into the CLIPS list in index.html.
#
# Nothing is added to the site until you paste that entry in — so the
# portfolio only ever shows work you picked.
# ---------------------------------------------------------------------------
set -euo pipefail

FFDIR="$HOME/Documents/remotion-video/node_modules/@remotion/compositor-darwin-arm64"
export DYLD_LIBRARY_PATH="$FFDIR"
FFMPEG="$FFDIR/ffmpeg"
FFPROBE="$FFDIR/ffprobe"

if [ $# -lt 3 ]; then
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
fi

SRC="$1"; CLIENT="$2"; LABEL="$3"; LANG="${4:-EN}"
HERE="$(cd "$(dirname "$0")" && pwd)"

[ -f "$SRC" ]      || { echo "No such video: $SRC" >&2; exit 1; }
[ -x "$FFMPEG" ]   || { echo "ffmpeg not found at $FFMPEG" >&2; exit 1; }

mkdir -p "$HERE/media"

# Next free slot for this client: carhealers-01, carhealers-02, ...
n=1
while [ -f "$(printf '%s/media/%s-%02d.mp4' "$HERE" "$CLIENT" "$n")" ]; do n=$((n+1)); done
NAME="$(printf '%s-%02d' "$CLIENT" "$n")"
OUT="$HERE/media/$NAME.mp4"

echo "→ Encoding $(basename "$SRC") as $NAME.mp4"
"$FFMPEG" -v error -y -i "$SRC" -vf "scale=1080:-2" \
  -c:v libx264 -preset slow -crf 30 -profile:v high -pix_fmt yuv420p \
  -movflags +faststart -c:a aac -b:a 128k -ac 2 "$OUT"

# Poster from 1s in (or the first frame for very short clips).
"$FFMPEG" -v error -y -ss 1 -i "$OUT" -frames:v 1 -vf "scale=540:-2" -q:v 4 "$HERE/media/$NAME.jpg" \
  || "$FFMPEG" -v error -y -i "$OUT" -frames:v 1 -vf "scale=540:-2" -q:v 4 "$HERE/media/$NAME.jpg"

DUR=$("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$OUT" | cut -d. -f1)
SIZE=$(du -h "$OUT" | cut -f1 | tr -d ' ')
echo "  done — ${DUR}s, $SIZE"
echo
echo "Paste this into the CLIPS list in index.html:"
echo
cat <<EOF
  {
    client: "$CLIENT",
    file:   "$NAME",
    label:  "$LABEL",
    lang:   "$LANG",
    leads:      "",   // how many leads it brought in
    views:      "",   // e.g. "128K"
    engagement: "",   // e.g. "2.4K"
    engagementLabel: "Saves",
    why: ""           // why this one performed
  },
EOF
