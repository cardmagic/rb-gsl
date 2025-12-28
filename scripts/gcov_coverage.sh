#!/bin/bash
# Script to generate C code coverage using gcov/lcov
#
# Prerequisites:
#   brew install lcov
#
# Usage:
#   ./scripts/gcov_coverage.sh          # Full rebuild + test + report
#   ./scripts/gcov_coverage.sh --report # Just generate report from existing .gcda files
#   ./scripts/gcov_coverage.sh --clean  # Clean coverage data

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
EXT_DIR="$PROJECT_DIR/ext/gsl_native"
COVERAGE_DIR="$PROJECT_DIR/coverage-c"

cd "$PROJECT_DIR"

# Check for lcov
if ! command -v lcov &> /dev/null; then
    echo "lcov is required but not installed."
    echo "Install with: brew install lcov"
    exit 1
fi

case "${1:-}" in
    --clean)
        echo "Cleaning coverage data..."
        rm -rf "$COVERAGE_DIR"
        find "$EXT_DIR" -name "*.gcda" -delete
        find "$EXT_DIR" -name "*.gcno" -delete
        echo "Done."
        exit 0
        ;;
    --report)
        echo "Generating report from existing data..."
        ;;
    *)
        echo "=== Step 1: Clean previous build ==="
        cd "$EXT_DIR"
        make clean 2>/dev/null || true
        rm -f Makefile
        find . -name "*.gcda" -delete
        find . -name "*.gcno" -delete
        rm -rf "$COVERAGE_DIR"

        echo "=== Step 2: Configure with coverage flags ==="
        GCOV=1 ruby extconf.rb

        echo "=== Step 3: Build with coverage instrumentation ==="
        make

        echo "=== Step 4: Run tests ==="
        cd "$PROJECT_DIR"
        ruby -I./lib -I./ext/gsl_native -I./test -e "
          require 'test_helper'
          Dir['test/gsl/*_test.rb'].each { |f| load f }
        " 2>&1 | tail -20
        ;;
esac

echo "=== Step 5: Generate coverage report ==="
mkdir -p "$COVERAGE_DIR"

# Capture coverage data
lcov --capture \
     --directory "$EXT_DIR" \
     --output-file "$COVERAGE_DIR/coverage.info" \
     --ignore-errors inconsistent \
     --rc lcov_branch_coverage=1 \
     2>/dev/null

# Remove system headers and test files from coverage
lcov --remove "$COVERAGE_DIR/coverage.info" \
     '/usr/*' \
     '/opt/*' \
     '*/include/*' \
     --output-file "$COVERAGE_DIR/coverage.filtered.info" \
     --ignore-errors inconsistent \
     --rc lcov_branch_coverage=1 \
     2>/dev/null

# Generate HTML report
genhtml "$COVERAGE_DIR/coverage.filtered.info" \
        --output-directory "$COVERAGE_DIR/html" \
        --branch-coverage \
        --legend \
        --title "rb-gsl C Extension Coverage" \
        --ignore-errors inconsistent \
        2>/dev/null

# Print summary
echo ""
echo "=== Coverage Summary ==="
lcov --summary "$COVERAGE_DIR/coverage.filtered.info" --rc lcov_branch_coverage=1 2>/dev/null

echo ""
echo "HTML report: $COVERAGE_DIR/html/index.html"
echo "Open with: open $COVERAGE_DIR/html/index.html"
