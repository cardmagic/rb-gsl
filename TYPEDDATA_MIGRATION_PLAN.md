# TypedData Migration Execution Plan

Step-by-step checklist for migrating rb-gsl from legacy `Data_Wrap_Struct`/`Data_Get_Struct` to the modern TypedData API.

**Approach**: Migrate each file completely in one pass, handling ALL its patterns together.

## Prerequisites

- [x] Ensure all tests pass on current master
- [x] Working branch: `fix/typeddata-migration`
- [x] Ruby 3.4 installed for testing

---

## Automation Scripts

```bash
ruby scripts/migrate_typeddata.rb --analyze      # See current state
ruby scripts/migrate_typeddata.rb --apply FILE   # Migrate a single file
ruby scripts/migrate_typeddata.rb --verify       # Check remaining legacy API
./scripts/test_migration.sh                      # Compile + test + verify
./scripts/cleanup_migration.sh                   # Remove migration files (at end)
```

---

## Phase 1: Setup Migration Scripts

**Status**: Complete

- [x] Create `scripts/migrate_typeddata.rb`
- [x] Create `scripts/test_migration.sh`
- [x] Create `scripts/cleanup_migration.sh`
- [x] Test `--analyze` command
- [x] Remove old scripts

---

## Phase 2: Create Type Definitions Header

**Status**: Complete

**Goal**: Create `ext/gsl_native/include/rb_gsl_types.h` with all type definitions.

### Tasks

- [x] Create the header file with all `rb_data_type_t` definitions
- [x] Include header in `rb_gsl.h` (single include point)
- [x] Update `extconf.rb` if needed
- [x] Verify compilation succeeds
- [x] Run tests

**Commit**: `feat: add rb_gsl_types.h with TypedData type definitions`

---

## Phase 3: Simple Files (No Special Patterns)

**Status**: Complete

**Goal**: Migrate files with only static class variables - no `klass`, `CLASS_OF`, or `VECROW`.

These are fully automatable with `--apply`.

| File | Wrap | Get | Notes |
|------|------|-----|-------|
| alf.c | 7 | 11 | ALF workspace |
| blas2.c | 19 | 128 | BLAS level 2 |
| blas3.c | 15 | 120 | BLAS level 3 |
| dirac.c | 14 | 11 | Dirac matrices |
| geometry.c | 0 | 4 | Get only |
| gsl_nmatrix.c | 6 | 6 | NMatrix integration |
| nmf_wrap.c | 2 | 3 | NMF wrapper |
| poly2.c | 1 | 0 | Polynomial |
| sf_coulomb.c | 10 | 0 | Wrap only |
| sf_gamma.c | 0 | 1 | Get only |
| sf_gegenbauer.c | 1 | 0 | Wrap only |
| sf_legendre.c | 4 | 0 | Wrap only |
| sf_log.c | 0 | 1 | Get only |
| sf_trigonometric.c | 0 | 1 | Get only |

### Commands

```bash
for f in alf.c blas2.c blas3.c dirac.c geometry.c gsl_nmatrix.c nmf_wrap.c \
         poly2.c sf_coulomb.c sf_gamma.c sf_gegenbauer.c sf_legendre.c \
         sf_log.c sf_trigonometric.c; do
  ruby scripts/migrate_typeddata.rb --apply "$f"
done
./scripts/test_migration.sh
```

**Commit**: `refactor: migrate simple files to TypedData`

---

## Phase 4: CLASS_OF Only Files

**Status**: Complete

**Goal**: Migrate files with `CLASS_OF` patterns but no `klass` or `VECROW`.

| File | Wrap | Get | CLASS_OF | Notes |
|------|------|-----|----------|-------|
| array.c | 3 | 6 | 17 | Array views |
| array_complex.c | 9 | 9 | 1 | Complex arrays |
| blas1.c | 11 | 43 | 2 | BLAS level 1 |
| common.c | 2 | 3 | 2 | Common utils |
| complex.c | 21 | 33 | 3 | Complex numbers |
| deriv.c | 4 | 3 | 3 | Derivatives |
| diff.c | 4 | 3 | 3 | Finite diff |
| histogram3d.c | 16 | 56 | 4 | 3D histograms |
| interp2d.c | 3 | 7 | 6 | 2D interpolation |
| linalg_complex.c | 9 | 48 | 15 | Complex linalg |
| math.c | 9 | 11 | 13 | Math ops |
| matrix_int.c | 6 | 8 | 2 | Int matrices |
| ndlinear.c | 4 | 18 | 5 | ND linear |
| sf.c | 31 | 41 | 36 | Special funcs |
| sf_bessel.c | 4 | 2 | 1 | Bessel funcs |
| signal.c | 2 | 4 | 1 | Signal processing |
| sort.c | 7 | 6 | 4 | Sorting |
| spline2d.c | 5 | 8 | 6 | 2D splines |

### Commands

```bash
for f in array.c array_complex.c blas1.c common.c complex.c deriv.c diff.c \
         histogram3d.c interp2d.c linalg_complex.c math.c matrix_int.c \
         ndlinear.c sf.c sf_bessel.c signal.c sort.c spline2d.c; do
  ruby scripts/migrate_typeddata.rb --apply "$f"
done
./scripts/test_migration.sh
```

**Commit**: `refactor: migrate CLASS_OF pattern files to TypedData`

---

## Phase 5: klass + CLASS_OF Files (Medium Complexity)

**Status**: Complete

**Goal**: Migrate files with both `klass` and `CLASS_OF` patterns.

Handle each file completely - both patterns in one pass.

| File | Wrap | Get | klass | CLASS_OF | Notes |
|------|------|-----|-------|----------|-------|
| bspline.c | 5 | 11 | 1 | 1 | B-splines |
| combination.c | 4 | 21 | 2 | 3 | Combinations |
| cqp.c | 11 | 31 | 2 | 1 | CQP solver |
| function.c | 4 | 15 | 2 | 4 | GSL functions |
| graph.c | 1 | 100 | 1 | 5 | Graph utils |
| gsl_narray.c | 24 | 11 | 3 | 1 | NArray integration |
| integration.c | 10 | 52 | 3 | 5 | Integration |
| interp.c | 4 | 18 | 1 | 5 | Interpolation |
| min.c | 1 | 13 | 1 | 1 | 1D minimization |
| multifit.c | 30 | 24 | 2 | 5 | Curve fitting |
| multimin.c | 13 | 29 | 4 | 5 | ND minimization |
| multimin_fsdf.c | 3 | 12 | 1 | 2 | FSDF minimizer |
| multiroots.c | 26 | 42 | 4 | 6 | Root finding |
| multiset.c | 3 | 17 | 2 | 2 | Multisets |
| odeiv.c | 21 | 55 | 9 | 13 | ODE solvers |
| ool.c | 14 | 40 | 3 | 8 | OOL optimizer |
| permutation.c | 12 | 48 | 2 | 8 | Permutations |
| qrng.c | 3 | 8 | 1 | 2 | Quasi-RNG |
| randist.c | 32 | 92 | 1 | 12 | Distributions |
| rational.c | 15 | 22 | 1 | 3 | Rationals |
| rng.c | 4 | 15 | 1 | 1 | RNG |
| root.c | 2 | 18 | 2 | 2 | 1D root finding |
| sf_mathieu.c | 4 | 3 | 1 | 3 | Mathieu funcs |
| siman.c | 12 | 29 | 6 | 6 | Simulated annealing |
| spline.c | 4 | 16 | 1 | 5 | Splines |
| sum.c | 2 | 4 | 2 | 0 | Summation |
| tamu_anova.c | 1 | 3 | 1 | 0 | ANOVA |
| wavelet.c | 6 | 35 | 2 | 1 | Wavelets |

### Batch 5.1: Small files (< 20 total)

```bash
for f in bspline.c min.c qrng.c rng.c sum.c tamu_anova.c function.c \
         sf_mathieu.c combination.c multiset.c root.c; do
  ruby scripts/migrate_typeddata.rb --apply "$f"
done
./scripts/test_migration.sh
```

**Commit**: `refactor: migrate small klass+CLASS_OF files to TypedData`

### Batch 5.2: Medium files (20-50 total)

```bash
for f in bspline.c cqp.c gsl_narray.c integration.c interp.c multifit.c \
         multimin.c multimin_fsdf.c permutation.c rational.c spline.c \
         wavelet.c siman.c; do
  ruby scripts/migrate_typeddata.rb --apply "$f"
done
./scripts/test_migration.sh
```

**Commit**: `refactor: migrate medium klass+CLASS_OF files to TypedData`

### Batch 5.3: Large files (50+ total)

```bash
for f in multiroots.c odeiv.c ool.c graph.c randist.c; do
  ruby scripts/migrate_typeddata.rb --apply "$f"
done
./scripts/test_migration.sh
```

**Commit**: `refactor: migrate large klass+CLASS_OF files to TypedData`

---

## Phase 6: High Complexity Files

**Status**: In Progress

**Goal**: Migrate files with many patterns or high occurrence counts.

| File | Wrap | Get | klass | CLASS_OF | Notes |
|------|------|-----|-------|----------|-------|
| cheb.c | 19 | 29 | 1 | 22 | Chebyshev |
| eigen.c | 68 | 146 | 1 | 78 | Eigenvalues |
| fft.c | 19 | 14 | 4 | 0 | FFT (+ VECROW) |
| histogram.c | 27 | 89 | 11 | 14 | Histograms |
| histogram2d.c | 20 | 72 | 5 | 10 | 2D histograms |
| linalg.c | 103 | 203 | 0 | 55 | Linear algebra |
| matrix_complex.c | 46 | 82 | 3 | 10 | Complex matrices |
| monte.c | 7 | 83 | 4 | 4 | Monte Carlo |
| ntuple.c | 7 | 24 | 4 | 0 | N-tuples |

### Batch 6.1

```bash
for f in cheb.c ntuple.c monte.c; do
  ruby scripts/migrate_typeddata.rb --apply "$f"
done
./scripts/test_migration.sh
```

**Commit**: `refactor: migrate cheb, ntuple, monte to TypedData`

### Batch 6.2

```bash
for f in histogram.c histogram2d.c fft.c; do
  ruby scripts/migrate_typeddata.rb --apply "$f"
done
./scripts/test_migration.sh
```

**Commit**: `refactor: migrate histogram, fft to TypedData`

### Batch 6.3

```bash
for f in matrix_complex.c eigen.c; do
  ruby scripts/migrate_typeddata.rb --apply "$f"
done
./scripts/test_migration.sh
```

**Commit**: `refactor: migrate matrix_complex, eigen to TypedData`

### Batch 6.4

```bash
ruby scripts/migrate_typeddata.rb --apply linalg.c
./scripts/test_migration.sh
```

**Commit**: `refactor: migrate linalg to TypedData`

---

## Phase 7: VECTOR_ROW_COL Files

**Goal**: Migrate files with `VECTOR_ROW_COL` or `VEC_ROW_COL` macros.

| File | Wrap | Get | VECROW | Notes |
|------|------|-----|--------|-------|
| dht.c | 11 | 18 | 1 | Also has klass+CLASS_OF |
| jacobi.c | 13 | 39 | 4 | Also has klass+CLASS_OF |
| matrix_double.c | 18 | 23 | 2 | Also has klass+CLASS_OF |
| vector_complex.c | 44 | 91 | 8 | Also has klass+CLASS_OF |
| vector_double.c | 37 | 47 | 7 | Also has klass+CLASS_OF |
| vector_int.c | 9 | 11 | 3 | CLASS_OF only |

### Strategy

Use unified `gsl_vector_data_type` for all VECROW patterns:
```c
// Keep VECTOR_ROW_COL for Ruby class, use unified type
TypedData_Wrap_Struct(VECTOR_ROW_COL(obj), &gsl_vector_data_type, v);
```

### Commands

```bash
for f in dht.c jacobi.c matrix_double.c vector_int.c vector_double.c vector_complex.c; do
  ruby scripts/migrate_typeddata.rb --apply "$f"
  # Manual review may be needed for VECROW patterns
done
./scripts/test_migration.sh
```

**Commit**: `refactor: migrate VECTOR_ROW_COL files to TypedData`

---

## Phase 8: Verification

- [ ] Run `ruby scripts/migrate_typeddata.rb --verify`
- [ ] Run full test suite: `rake test`
- [ ] Check for deprecation warnings: `ruby -W:deprecated -e "require 'gsl'"`
- [ ] Memory check: `ruby -e "1000.times { GSL::Vector.alloc(1000) }; GC.start"`
- [ ] Build gem: `gem build gsl.gemspec`

---

## Phase 9: Cleanup

- [ ] Verify all tests pass
- [ ] Merge PR to master
- [ ] Run `./scripts/cleanup_migration.sh`
- [ ] Commit cleanup
- [ ] Delete feature branch

**Commit**: `chore: remove TypedData migration scripts`

---

## Progress Tracking

| Phase | Description | Files | Status |
|-------|-------------|-------|--------|
| 1 | Setup scripts | 3 | Complete |
| 2 | Type definitions header | 1 | Complete |
| 3 | Simple files | 14 | Complete |
| 4 | CLASS_OF only | 18 | Complete |
| 5 | klass + CLASS_OF | 28 | Complete |
| 6 | High complexity | 9 | In progress |
| 7 | VECTOR_ROW_COL | 6 | Not started |
| 8 | Verification | - | Not started |
| 9 | Cleanup | - | Not started |

**Total**: 75 files with Data_Wrap/Get_Struct usage
