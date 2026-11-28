#!/usr/bin/env bash
# Canonical build for the native runtime lifecycle + crossfeed C test.
# Used by both the x86_64 (native-c) and ARM64 (native-arm64) jobs of
# test-suite.yml so the source list lives in exactly one place — when a
# src/*.c file is added to this test, edit it here only.
# Usage (run from source/native_audio_runtime):
#   compile-lifecycle-c-test.sh <compiler> <output-path>
set -euo pipefail
CC="${1:?compiler required}"
OUT="${2:?output path required}"
"$CC" -D_POSIX_C_SOURCE=200809L -DNAR_NATIVE_RUNTIME_TEST_HOOKS \
  -std=c11 -O1 -g -fsanitize=address,undefined \
  -fno-omit-frame-pointer -Isrc \
  test/native_runtime_lifecycle_c_test.c \
  src/native_audio_runtime.c src/audio_buffer.c src/dsp_pipeline.c \
  src/gain_processor.c src/replaygain_processor.c src/biquad_filter.c \
  src/comp_processor.c src/crossfeed_processor.c src/limiter_processor.c \
  src/soft_clipper_processor.c src/loudness_processor.c \
  src/bg_composite.c src/automix_analyzer.c src/automix_neon.S \
  src/automix_live_tracker.c \
  src/automix_phase_lock.c src/automix_planner.c src/automix_tone_processor.c \
  src/neon_kernels.S \
  -lm -pthread -ldl -o "$OUT"
