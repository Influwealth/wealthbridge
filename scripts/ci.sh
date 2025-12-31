#!/usr/bin/env bash
set -euo pipefail

echo "Running static analysis..."
flutter analyze

echo "Running unit and widget tests..."
flutter test

echo "Running integration tests..."
flutter test integration_test
