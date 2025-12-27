#!/bin/bash
#
# Test script for TypedData migration
# Run after each migration batch to verify nothing broke
#

set -e

cd "$(dirname "$0")/.."

echo "=== Compiling extension ==="
cd ext/gsl_native
ruby extconf.rb
make clean
make
cd ../..

echo ""
echo "=== Running tests ==="
rake test

echo ""
echo "=== Checking for deprecation warnings ==="
if ruby -W:deprecated -e "require 'gsl'; v = GSL::Vector.alloc(10)" 2>&1 | grep -qi deprecat; then
    echo "WARNING: Deprecation warnings found!"
    ruby -W:deprecated -e "require 'gsl'" 2>&1 | head -20
else
    echo "No deprecation warnings found."
fi

echo ""
echo "=== Memory check ==="
ruby -e "
  require 'gsl'

  # Allocate and free many objects
  1000.times { GSL::Vector.alloc(1000) }
  GC.start

  # Check we can still use GSL after GC
  v = GSL::Vector.alloc(10)
  v[0] = 1.0
  puts 'Memory check passed'
"

echo ""
echo "=== Migration status ==="
ruby scripts/migrate_typeddata.rb --verify

echo ""
echo "=== All checks passed ==="
