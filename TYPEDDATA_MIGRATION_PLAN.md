# TypedData Migration Execution Plan

Step-by-step checklist for migrating rb-gsl from legacy `Data_Wrap_Struct`/`Data_Get_Struct` to the modern TypedData API.

## Prerequisites

- [ ] Ensure all tests pass on current master
- [ ] Working branch: `fix/typeddata-migration`
- [ ] Ruby 3.4 installed for testing

---

## Automation Scripts

The following scripts automate much of the migration work:

### `scripts/migrate_typeddata.rb` - Main Migration Script

```bash
# Analyze current state
ruby scripts/migrate_typeddata.rb --analyze

# Generate type definitions header
ruby scripts/migrate_typeddata.rb --generate-header > ext/gsl_native/include/rb_gsl_types.h

# Preview changes for a file (dry run)
ruby scripts/migrate_typeddata.rb --migrate FILE.c

# Apply changes to a file
ruby scripts/migrate_typeddata.rb --apply FILE.c

# Migrate all automatable files
ruby scripts/migrate_typeddata.rb --apply-all

# Verify no legacy API remains
ruby scripts/migrate_typeddata.rb --verify
```

### `scripts/test_migration.sh` - Test Runner

```bash
#!/bin/bash
# Run after each migration batch

set -e

echo "=== Compiling extension ==="
cd ext/gsl_native && ruby extconf.rb && make clean && make && cd ../..

echo "=== Running tests ==="
rake test

echo "=== Checking for deprecation warnings ==="
ruby -W:deprecated -e "require 'gsl'; v = GSL::Vector.alloc(10)" 2>&1 | grep -i deprecat || echo "No deprecation warnings!"

echo "=== Memory check ==="
ruby -e "1000.times { GSL::Vector.alloc(1000) }; GC.start; puts 'Memory check passed'"
```

### Automation Coverage

| Phase | Automatable | Manual Work Required |
|-------|-------------|---------------------|
| 1 | **100%** | Test script output |
| 2 | **100%** | Review generated header |
| 3 | **95%** | Review edge cases |
| 4 | **90%** | Verify clone semantics |
| 5 | **80%** | May need macro adjustments |
| 6 | **70%** | Verify alloc restructuring |
| 7 | **30%** | Requires macro expertise |
| 8 | **100%** | Just run scripts |
| 9 | **100%** | Just run cleanup |

---

## Phase 1: Setup and Verify Migration Scripts

**Goal**: Consolidate migration scripts and verify they work correctly.

### Tasks

- [ ] Create `scripts/` directory
- [ ] Create consolidated `scripts/migrate_typeddata.rb`
- [ ] Create `scripts/test_migration.sh`
- [ ] Create `scripts/cleanup_migration.sh`
- [ ] Make scripts executable: `chmod +x scripts/*.sh`
- [ ] Test analysis: `ruby scripts/migrate_typeddata.rb --analyze`
- [ ] Verify header generation: `ruby scripts/migrate_typeddata.rb --generate-header | head -50`
- [ ] Test dry-run on a simple file: `ruby scripts/migrate_typeddata.rb --migrate sum.c`
- [ ] Remove old scripts: `rm -f migrate_to_typeddata.sh migrate_to_typeddata_v2.rb`

**Commit**: `chore: add consolidated TypedData migration scripts`

---

## Phase 2: Create Type Definitions Header

**Goal**: Create `include/rb_gsl_types.h` with all `rb_data_type_t` definitions.

### Tasks

- [ ] Generate header: `ruby scripts/migrate_typeddata.rb --generate-header > ext/gsl_native/include/rb_gsl_types.h`
- [ ] Add type definitions for core types:
  - [ ] `gsl_rng_data_type`
  - [ ] `gsl_vector_data_type`
  - [ ] `gsl_vector_complex_data_type`
  - [ ] `gsl_vector_int_data_type`
  - [ ] `gsl_matrix_data_type`
  - [ ] `gsl_matrix_complex_data_type`
  - [ ] `gsl_matrix_int_data_type`
  - [ ] `gsl_permutation_data_type`
  - [ ] `gsl_combination_data_type`
  - [ ] `gsl_block_data_type`
  - [ ] `gsl_complex_data_type`
- [ ] Add type definitions for histogram types:
  - [ ] `gsl_histogram_data_type`
  - [ ] `gsl_histogram_pdf_data_type`
  - [ ] `gsl_histogram2d_data_type`
  - [ ] `gsl_histogram2d_pdf_data_type`
  - [ ] `gsl_histogram3d_data_type`
- [ ] Add type definitions for interpolation types:
  - [ ] `gsl_interp_data_type`
  - [ ] `gsl_interp_accel_data_type`
  - [ ] `gsl_spline_data_type`
  - [ ] `gsl_interp2d_data_type`
  - [ ] `gsl_spline2d_data_type`
  - [ ] `gsl_bspline_workspace_data_type`
- [ ] Add type definitions for FFT/Wavelet types:
  - [ ] `gsl_fft_complex_wavetable_data_type`
  - [ ] `gsl_fft_complex_workspace_data_type`
  - [ ] `gsl_fft_real_wavetable_data_type`
  - [ ] `gsl_fft_real_workspace_data_type`
  - [ ] `gsl_fft_halfcomplex_wavetable_data_type`
  - [ ] `gsl_wavelet_data_type`
  - [ ] `gsl_wavelet_workspace_data_type`
- [ ] Add type definitions for fitting/optimization:
  - [ ] `gsl_multifit_linear_workspace_data_type`
  - [ ] `gsl_multifit_fdfsolver_data_type`
  - [ ] `gsl_multimin_fdfminimizer_data_type`
  - [ ] `gsl_multimin_fminimizer_data_type`
  - [ ] `gsl_min_fminimizer_data_type`
- [ ] Add type definitions for root finding:
  - [ ] `gsl_root_fsolver_data_type`
  - [ ] `gsl_root_fdfsolver_data_type`
  - [ ] `gsl_multiroot_fsolver_data_type`
  - [ ] `gsl_multiroot_fdfsolver_data_type`
- [ ] Add type definitions for ODE:
  - [ ] `gsl_odeiv_step_data_type`
  - [ ] `gsl_odeiv_control_data_type`
  - [ ] `gsl_odeiv_evolve_data_type`
  - [ ] `gsl_odeiv_system_data_type`
- [ ] Add type definitions for eigen:
  - [ ] `gsl_eigen_symm_workspace_data_type`
  - [ ] `gsl_eigen_symmv_workspace_data_type`
  - [ ] `gsl_eigen_herm_workspace_data_type`
  - [ ] `gsl_eigen_hermv_workspace_data_type`
  - [ ] `gsl_eigen_nonsymm_workspace_data_type`
  - [ ] `gsl_eigen_nonsymmv_workspace_data_type`
  - [ ] `gsl_eigen_gen_workspace_data_type`
  - [ ] `gsl_eigen_genv_workspace_data_type`
- [ ] Add type definitions for misc types:
  - [ ] `gsl_function_data_type`
  - [ ] `gsl_function_fdf_data_type`
  - [ ] `gsl_multiset_data_type`
  - [ ] `gsl_dht_data_type`
  - [ ] `gsl_qrng_data_type`
  - [ ] `gsl_cheb_series_data_type`
  - [ ] `gsl_sum_levin_u_workspace_data_type`
  - [ ] `gsl_sum_levin_utrunc_workspace_data_type`
  - [ ] `gsl_integration_workspace_data_type`
  - [ ] `gsl_monte_plain_state_data_type`
  - [ ] `gsl_monte_miser_state_data_type`
  - [ ] `gsl_monte_vegas_state_data_type`
- [ ] Add helper macros (GSL_GET_STRUCT, GSL_WRAP_STRUCT)
- [ ] Update `extconf.rb` to include the new header path
- [ ] Verify compilation succeeds
- [ ] Run tests

**Commit**: `feat: add rb_gsl_types.h with TypedData type definitions`

---

## Phase 3: Migrate Simple Files (Static Class Only)

**Goal**: Migrate files that only use static class variables (no `klass`, `CLASS_OF`, or macros).

### Batch 3.1: Core Simple Types

- [ ] **sum.c** - Levin summation
  - [ ] Include `rb_gsl_types.h`
  - [ ] Replace `Data_Wrap_Struct` with `TypedData_Wrap_Struct`
  - [ ] Replace `Data_Get_Struct` with `TypedData_Get_Struct`
  - [ ] Run tests: `ruby -Ilib test/gsl/*sum*`

- [ ] **qrng.c** - Quasi-random number generators
  - [ ] Include `rb_gsl_types.h`
  - [ ] Replace `Data_Wrap_Struct` with `TypedData_Wrap_Struct`
  - [ ] Replace `Data_Get_Struct` with `TypedData_Get_Struct`
  - [ ] Run tests

- [ ] **dht.c** - Discrete Hankel Transform
  - [ ] Include `rb_gsl_types.h`
  - [ ] Replace `Data_Wrap_Struct` with `TypedData_Wrap_Struct`
  - [ ] Replace `Data_Get_Struct` with `TypedData_Get_Struct`
  - [ ] Handle `CLASS_OF` pattern (1 occurrence) - use same type as source
  - [ ] Run tests

- [ ] **deriv.c** - Numerical differentiation
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate all occurrences
  - [ ] Run tests

- [ ] **diff.c** - Finite differences
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate all occurrences
  - [ ] Run tests

**Commit**: `refactor: migrate sum, qrng, dht, deriv, diff to TypedData`

### Batch 3.2: Integration & Fitting

- [ ] **integration.c** - Numerical integration
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate workspace types
  - [ ] Handle `klass` pattern - restructure alloc functions
  - [ ] Run tests

- [ ] **min.c** - 1D minimization
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate all occurrences
  - [ ] Run tests

- [ ] **root.c** - 1D root finding
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate all occurrences
  - [ ] Run tests

- [ ] **multifit.c** - Multidimensional fitting
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate all occurrences
  - [ ] Run tests

**Commit**: `refactor: migrate integration, min, root, multifit to TypedData`

### Batch 3.3: Multi-dimensional Optimization

- [ ] **multimin.c** - Multidimensional minimization
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate all occurrences
  - [ ] Run tests

- [ ] **multimin_fsdf.c** - FSDF minimization
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate all occurrences
  - [ ] Run tests

- [ ] **multiroots.c** - Multi-root finding
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate all occurrences
  - [ ] Run tests

**Commit**: `refactor: migrate multimin, multiroots to TypedData`

### Batch 3.4: ODE & Monte Carlo

- [ ] **odeiv.c** - ODE solvers
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate all occurrences
  - [ ] Run tests

- [ ] **monte.c** - Monte Carlo integration
  - [ ] Include `rb_gsl_types.h`
  - [ ] Migrate all occurrences
  - [ ] Run tests

**Commit**: `refactor: migrate odeiv, monte to TypedData`

---

## Phase 4: Migrate Clone/Dup Patterns (CLASS_OF)

**Goal**: Migrate files with `CLASS_OF(obj)` pattern for clone/dup operations.

### Batch 4.1: Simple Clone Types

- [ ] **combination.c** (1 CLASS_OF)
  - [ ] Use `&combination_data_type` for clone
  - [ ] Keep `CLASS_OF(obj)` for Ruby class preservation
  - [ ] Run tests

- [ ] **permutation.c** (2 CLASS_OF)
  - [ ] Migrate clone/dup functions
  - [ ] Run tests

- [ ] **rng.c** (2 CLASS_OF)
  - [ ] Migrate clone/dup functions
  - [ ] Run tests

**Commit**: `refactor: migrate clone/dup in combination, permutation, rng`

### Batch 4.2: Histogram Types

- [ ] **histogram.c** (4 CLASS_OF)
  - [ ] Migrate clone, dup, and related functions
  - [ ] Run tests

- [ ] **histogram2d.c** (6 CLASS_OF)
  - [ ] Migrate all clone/dup patterns
  - [ ] Run tests

- [ ] **histogram3d.c** (4 CLASS_OF)
  - [ ] Migrate all clone/dup patterns
  - [ ] Run tests

**Commit**: `refactor: migrate histogram clone/dup to TypedData`

### Batch 4.3: Complex Types

- [ ] **cheb.c** (4 CLASS_OF)
  - [ ] Migrate Chebyshev series clone/dup
  - [ ] Run tests

- [ ] **eigen.c** (2 CLASS_OF)
  - [ ] Migrate eigenvalue clone/dup
  - [ ] Run tests

- [ ] **fft.c** (2 CLASS_OF)
  - [ ] Migrate FFT clone/dup
  - [ ] Run tests

- [ ] **wavelet.c** (2 CLASS_OF)
  - [ ] Migrate wavelet clone/dup
  - [ ] Run tests

**Commit**: `refactor: migrate cheb, eigen, fft, wavelet clone/dup`

---

## Phase 5: Migrate VECTOR_ROW_COL Patterns

**Goal**: Migrate vector orientation macros using unified type approach.

### Tasks

- [ ] Define unified `gsl_vector_data_type` for all vector variants
- [ ] Keep `VECTOR_ROW_COL` macro for Ruby class selection
- [ ] Migrate files:
  - [ ] **jacobi.c** (6 occurrences)
  - [ ] **linalg.c** (11 occurrences)
  - [ ] **math.c** (2 occurrences)
  - [ ] **randist.c** (2 occurrences)
  - [ ] **signal.c** (2 occurrences)
  - [ ] **sort.c** (2 occurrences)
  - [ ] **dht.c** (1 occurrence) - if not done in Phase 2
  - [ ] **fft.c** (2 occurrences) - if not done in Phase 3
- [ ] Run full test suite

**Commit**: `refactor: migrate VECTOR_ROW_COL patterns to TypedData`

---

## Phase 6: Migrate klass Parameter Patterns

**Goal**: Restructure alloc functions to use static types.

### Strategy

For each file with `klass` parameter:
1. Identify which class the alloc is registered on
2. Replace `Data_Wrap_Struct(klass, ...)` with `TypedData_Wrap_Struct(klass, &known_type, ...)`
3. The type is known at compile time even though klass is runtime

### Batch 6.1: Core Alloc Functions

- [ ] **rng.c** - gsl_rng alloc
- [ ] **permutation.c** - gsl_permutation alloc
- [ ] **combination.c** - gsl_combination alloc
- [ ] **multiset.c** - gsl_multiset alloc

**Commit**: `refactor: migrate rng, permutation, combination, multiset alloc`

### Batch 6.2: Interpolation & Spline

- [ ] **interp.c**
- [ ] **interp2d.c**
- [ ] **spline.c**
- [ ] **spline2d.c**
- [ ] **bspline.c**

**Commit**: `refactor: migrate interpolation alloc functions`

### Batch 6.3: FFT & Wavelet

- [ ] **fft.c** - remaining klass patterns
- [ ] **wavelet.c** - remaining klass patterns

**Commit**: `refactor: migrate FFT/wavelet alloc functions`

### Batch 6.4: Remaining Files

- [ ] **cheb.c**
- [ ] **cqp.c**
- [ ] **dirac.c**
- [ ] **eigen.c**
- [ ] **function.c**
- [ ] **ieee.c**
- [ ] **ntuple.c**
- [ ] **ool.c**
- [ ] **siman.c**

**Commit**: `refactor: migrate remaining alloc functions`

---

## Phase 7: Migrate Macro-based Templates

**Goal**: Handle `GSL_TYPE`, `QUALIFIED_VIEW`, `CONCAT`, `FUNCTION` macros.

### Analysis Required

- [ ] Identify all template files using these macros
- [ ] Determine if type can be parameterized in macros
- [ ] Consider creating type-specific macros

### Files to Review

- [ ] **vector_source.h** / **vector_double.c**, **vector_int.c**, etc.
- [ ] **matrix_source.h** / **matrix_double.c**, **matrix_int.c**, etc.
- [ ] **block_source.h**
- [ ] Any other template-based files

### Strategy Options

1. **Expand macros**: Replace macro-based code with explicit type-specific versions
2. **Parameterize types**: Add type parameter to macros
3. **Type lookup**: Create runtime type lookup from class variable

**Commit**: `refactor: migrate template-based vector/matrix code`

---

## Phase 8: Final Verification

- [ ] Run full test suite: `rake test`
- [ ] Run tests without GSL: `NATIVE_VECTOR=true rake test`
- [ ] Check for deprecation warnings: `ruby -W:deprecated -e "require 'gsl'"`
- [ ] Memory leak check: `ruby -e "1000.times { GSL::Vector.alloc(1000) }; GC.start"`
- [ ] Build gem: `gem build gsl.gemspec`
- [ ] Test gem installation

---

## Rollback Plan

If issues are found:

1. Each phase has its own commit - can revert individual phases
2. Keep `fix/typeddata-migration` branch until fully verified
3. Original code preserved in `master` branch

---

## Progress Tracking

| Phase | Description | Status | Files | Occurrences | Automated |
|-------|-------------|--------|-------|-------------|-----------|
| 1 | Setup migration scripts | Not started | 3 | - | 100% |
| 2 | Type definitions header | Not started | 1 | ~100 types | 100% |
| 3 | Simple files | Not started | ~20 | ~500 | 95% |
| 4 | CLASS_OF patterns | Not started | ~11 | 30 | 90% |
| 5 | VECTOR_ROW_COL | Not started | ~8 | 28 | 80% |
| 6 | klass patterns | Not started | ~35 | 101 | 70% |
| 7 | Macro templates | Not started | ~10 | ~200 | 30% |
| 8 | Verification | Not started | - | - | 100% |
| 9 | Cleanup | Not started | - | - | 100% |

**Total**: ~3,298 occurrences across ~65 files

---

## Phase 9: Cleanup

**Goal**: Remove all migration-related files after successful completion.

### Cleanup Script

Create and run `scripts/cleanup_migration.sh`:

```bash
#!/bin/bash
# Run this ONLY after migration is complete and merged to master

set -e

echo "=== Removing migration scripts and docs ==="

# Migration scripts (root level)
rm -f migrate_to_typeddata.sh
rm -f migrate_to_typeddata_v2.rb

# Migration documentation
rm -f TYPEDDATA_MIGRATION_STRATEGY.md
rm -f TYPEDDATA_MIGRATION_PLAN.md

# Scripts directory (if created for migration)
rm -f scripts/migrate_typeddata.rb
rm -f scripts/test_migration.sh
rm -f scripts/cleanup_migration.sh

# Remove scripts dir if empty
rmdir scripts 2>/dev/null || true

echo "=== Cleanup complete ==="
echo "Don't forget to commit: git add -A && git commit -m 'chore: remove TypedData migration scripts'"
```

### Cleanup Checklist

- [ ] Verify all tests pass
- [ ] Verify no deprecation warnings remain
- [ ] Merge PR to master
- [ ] Run cleanup script
- [ ] Commit cleanup changes
- [ ] Delete feature branch

**Commit**: `chore: remove TypedData migration scripts and docs`

---

## Notes

- Run tests frequently to catch regressions early
- Each commit should leave the codebase in a working state
- Keep the branch until migration is verified in production
