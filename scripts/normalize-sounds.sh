#!/usr/bin/env bash
# Normalizes every sound file in sounds/ to a consistent loudness, sample
# rate, and bitrate, in place - same filename/extension/codec family in and
# out (mp3 stays mp3, ogg stays ogg, wav stays wav), so Core/Constants.lua's
# sound-file references never need to change.
#
# Loudness: two-pass EBU R128 (ffmpeg's loudnorm filter), -16 LUFS integrated
# / -1.5 dBTP true peak / LRA 11 - a common game-SFX target, not a strict
# broadcast requirement, chosen since no per-file loudness spec existed
# before. Sample rate: 44.1kHz across the board. Bitrate: mp3 at 128k CBR,
# ogg at libvorbis -q:a 5 (~160kbps equivalent). wav stays uncompressed
# PCM. Channel count is left untouched.
set -euo pipefail

cd "$(dirname "$0")/.."

docker run --rm --entrypoint bash -v "$PWD/sounds":/sounds linuxserver/ffmpeg -c '
set -euo pipefail
shopt -s nullglob

for f in /sounds/*.mp3 /sounds/*.wav /sounds/*.ogg; do
    ext="${f##*.}"
    echo "== $f =="

    json=$(ffmpeg -hide_banner -nostdin -i "$f" \
        -af loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json -f null - 2>&1 \
        | awk "/^\{/,/^\}/")

    measured_I=$(echo "$json" | jq -r .input_i)
    measured_TP=$(echo "$json" | jq -r .input_tp)
    measured_LRA=$(echo "$json" | jq -r .input_lra)
    measured_thresh=$(echo "$json" | jq -r .input_thresh)
    offset=$(echo "$json" | jq -r .target_offset)

    # A handful of these files are old, junk-laden novelty rips
    # (misdetected containers, garbage bytes at the start) whose measured
    # loudness comes back nonsensical (e.g. positive LUFS) - loudnorm
    # rejects those outside its own [-99, 0] range and pass two would
    # abort the whole file. Falls back to loudnorms one-pass dynamic mode
    # (no measured_* args, less precise but always succeeds) instead of
    # failing the file entirely.
    if awk -v v="$measured_I" "BEGIN { exit !(v >= -70 && v <= 0) }"; then
        filter="loudnorm=I=-16:TP=-1.5:LRA=11:measured_I=${measured_I}:measured_TP=${measured_TP}:measured_LRA=${measured_LRA}:measured_thresh=${measured_thresh}:offset=${offset}:linear=true:print_format=summary"
    else
        echo "  measured_I=${measured_I} out of sane range - falling back to one-pass dynamic loudnorm"
        filter="loudnorm=I=-16:TP=-1.5:LRA=11:print_format=summary"
    fi

    tmp="${f}.norm.${ext}"
    case "$ext" in
        mp3) codec_args=(-c:a libmp3lame -b:a 128k) ;;
        ogg) codec_args=(-c:a libvorbis -q:a 5) ;;
        wav) codec_args=(-c:a pcm_s16le) ;;
        *) echo "unknown extension: $ext"; exit 1 ;;
    esac

    ffmpeg -hide_banner -nostdin -y -i "$f" -af "$filter" -ar 44100 "${codec_args[@]}" "$tmp"
    mv "$tmp" "$f"
done
'
