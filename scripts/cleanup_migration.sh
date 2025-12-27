#!/bin/bash
#
# Cleanup script - removes all migration-related files
# Run this ONLY after migration is complete and merged to master
#

set -e

cd "$(dirname "$0")/.."

echo "=== Removing migration scripts and docs ==="

# Root level migration scripts (old versions)
rm -vf migrate_to_typeddata.sh
rm -vf migrate_to_typeddata_v2.rb

# Migration documentation
rm -vf TYPEDDATA_MIGRATION_STRATEGY.md
rm -vf TYPEDDATA_MIGRATION_PLAN.md

# Scripts directory
rm -vf scripts/migrate_typeddata.rb
rm -vf scripts/test_migration.sh
rm -vf scripts/cleanup_migration.sh

# Remove scripts dir if empty
rmdir scripts 2>/dev/null && echo "Removed empty scripts/" || true

echo ""
echo "=== Cleanup complete ==="
echo ""
echo "Don't forget to commit:"
echo "  git add -A && git commit -m 'chore: remove TypedData migration scripts'"
