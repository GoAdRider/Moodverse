#!/bin/bash
# ── Emotion Diary — build helper ───────────────────────────────────────────────
# Run this once after cloning to generate Drift and Riverpod boilerplate.
#
# Usage:
#   chmod +x build.sh
#   ./build.sh

set -e

echo "📦  Installing dependencies..."
flutter pub get

echo "⚙️   Running code generators (Drift + Riverpod)..."
dart run build_runner build --delete-conflicting-outputs

echo "✅  Build complete. Run with: flutter run"
