#!/usr/bin/env bash
# Canonical build for the AutoMix C suite. Used by both the x86_64
# (native-c) and ARM64 (native-arm64) jobs of test-suite.yml so the base
# source list lives in exactly one place; architecture-specific sources
# (the NEON .S files) are passed as extra arguments by the ARM64 job.
# Usage (run from source/native_audio_runtime):
#   compile-automix-c-test.sh <compiler words, e.g. "ccache clang"> <output-path> [extra sources...]
set -euo pipefail
CC_WORDS="${1:?compiler required}"
OUT="${2:?output path required}"
shift 2
C_FLAGS=(
  -std=c11 -O1 -g -fno-omit-frame-pointer
  -fsanitize=address,undefined -Wall -Wextra -pthread
  -I src
)
C_SOURCES=(
  test/automix_native_c_test.c
  src/automix_analyzer.c src/automix_planner.c
  src/automix_phase_lock.c src/automix_tone_processor.c
  src/automix_live_tracker.c
  "$@"
)
read -ra CC_ARR <<< "$CC_WORDS"
OBJECTS=()
for source_file in "${C_SOURCES[@]}"; do
  object_file="/tmp/automix-c-test-$(basename "${source_file%.*}").o"
  "${CC_ARR[@]}" "${C_FLAGS[@]}" -c "$source_file" -o "$object_file"
  OBJECTS+=("$object_file")
done
"${CC_ARR[@]}" "${C_FLAGS[@]}" "${OBJECTS[@]}" -lm -o "$OUT"
