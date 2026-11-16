#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

# 14s keep + 1s skip video cutter for Termux
# Usage: bash cut_video.sh "/sdcard/Download/video.mp4" [keep_seconds] [skip_seconds]

INPUT="${1:-}"
KEEP="${2:-14}"
SKIP="${3:-1}"

if [[ -z "$INPUT" ]]; then
  echo "ব্যবহার: bash cut_video.sh \"/sdcard/Download/video.mp4\" [রাখবে] [বাদ]"
  echo 'উদাহরণ: bash cut_video.sh "/sdcard/Download/movie.mp4" 14 1'
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "ফাইল পাওয়া যায়নি: $INPUT"
  exit 1
fi

if ! [[ "$KEEP" =~ ^[0-9]+$ ]] || ! [[ "$SKIP" =~ ^[0-9]+$ ]] || (( KEEP < 1 )); then
  echo "রাখবে/বাদ দেবে—দুটিই পূর্ণসংখ্যা হতে হবে; রাখার সময় ১ বা বেশি দিন।"
  exit 1
fi

for cmd in ffmpeg ffprobe zip; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "প্রয়োজনীয় কমান্ড নেই: $cmd"
    echo "ইনস্টল করো: pkg install ffmpeg zip"
    exit 1
  fi
done

DURATION="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT" | head -n 1)"
if [[ -z "$DURATION" ]]; then
  echo "ভিডিওর দৈর্ঘ্য পড়া যায়নি।"
  exit 1
fi

NAME="$(basename "$INPUT")"
NAME="${NAME%.*}"
OUTDIR="$(dirname "$INPUT")/${NAME}_clips"
mkdir -p "$OUTDIR"
CYCLE=$((KEEP + SKIP))

echo "ভিডিও: $INPUT"
echo "ভিডিওর দৈর্ঘ্য: ${DURATION} সেকেন্ড"
echo "নিয়ম: ${KEEP}s রাখবে + ${SKIP}s বাদ"
echo "আউটপুট: $OUTDIR"
echo

INDEX=1
START=0
while awk -v s="$START" -v d="$DURATION" 'BEGIN{exit !(s<d)}'; do
  REMAIN="$(awk -v d="$DURATION" -v s="$START" 'BEGIN{printf "%.3f",d-s}')"
  LEN="$(awk -v r="$REMAIN" -v k="$KEEP" 'BEGIN{printf "%.3f",(r<k?r:k)}')"
  if awk -v l="$LEN" 'BEGIN{exit !(l<=0)}'; then break; fi

  OUT="$OUTDIR/clip_$(printf '%04d' "$INDEX").mp4"
  echo "ক্লিপ $INDEX | শুরু ${START}s | দৈর্ঘ্য ${LEN}s"

  ffmpeg -hide_banner -loglevel error -y \
    -ss "$START" -i "$INPUT" -t "$LEN" \
    -map 0:v:0? -map 0:a:0? \
    -c:v libx264 -preset ultrafast -crf 18 \
    -c:a aac -b:a 192k -movflags +faststart \
    "$OUT"

  START=$((START + CYCLE))
  INDEX=$((INDEX + 1))
done

if ! compgen -G "$OUTDIR/*.mp4" > /dev/null; then
  echo "কোনো ক্লিপ তৈরি হয়নি।"
  exit 1
fi

ZIPFILE="${OUTDIR}.zip"
rm -f "$ZIPFILE"
(
  cd "$(dirname "$OUTDIR")"
  zip -q -r "$ZIPFILE" "$(basename "$OUTDIR")"
)

echo
echo "সম্পন্ন!"
echo "ক্লিপ ফোল্ডার: $OUTDIR"
echo "ZIP ফাইল: $ZIPFILE"
echo "মোট ক্লিপ: $((INDEX - 1))"
