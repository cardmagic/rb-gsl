# TypedData Migration Strategy for Runtime Class Patterns

This document outlines strategies for the 159 occurrences that cannot be auto-migrated
because they determine the Ruby class at runtime.

## Overview

| Pattern | Count | Solution |
|---------|-------|----------|
| `klass` parameter | 101 | Use known type for each alloc method |
| `CLASS_OF(obj)` | 30 | Use same type as source object |
| `VECTOR_*_ROW_COL` | 28 | Use unified vector type |

---

## Pattern 1: `klass` Parameter (101 occurrences)

### Problem
```c
static VALUE rb_gsl_bspline_alloc(VALUE klass, VALUE k, VALUE n)
{
  gsl_bspline_workspace *w = gsl_bspline_alloc(FIX2INT(k), FIX2INT(n));
  return Data_Wrap_Struct(klass, 0, gsl_bspline_free, w);  // klass is runtime
}
```

### Solution
Since each `alloc` method is registered on a specific class via `rb_define_singleton_method`,
we know exactly which type to use. Replace `klass` with the static type:

```c
// Define the type statically
static const rb_data_type_t bspline_workspace_type = {
    .wrap_struct_name = "GSL::BSpline::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_bspline_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

static VALUE rb_gsl_bspline_alloc(VALUE klass, VALUE k, VALUE n)
{
  gsl_bspline_workspace *w = gsl_bspline_alloc(FIX2INT(k), FIX2INT(n));
  return TypedData_Wrap_Struct(klass, &bspline_workspace_type, w);
}
```

### Files Affected
- bspline.c, cheb.c, combination.c, cqp.c, deriv.c, dht.c, diff.c
- dirac.c, eigen.c, fft.c, function.c, histogram.c, histogram2d.c
- histogram3d.c, ieee.c, integration.c, interp.c, interp2d.c
- min.c, monte.c, multifit.c, multimin.c, multimin_fsdf.c
- multiroots.c, multiset.c, ntuple.c, odeiv.c, ool.c
- permutation.c, qrng.c, rng.c, root.c, siman.c, spline.c
- spline2d.c, sum.c, wavelet.c

### Migration Script Addition
```ruby
# In migrate script, for each file with klass pattern:
# 1. Find the class variable the alloc is registered on
# 2. Use corresponding type definition
```

---

## Pattern 2: `CLASS_OF(obj)` (30 occurrences)

### Problem
```c
// Clone/dup operations preserve the original class
static VALUE rb_gsl_combination_clone(VALUE obj)
{
  gsl_combination *c, *c2;
  Data_Get_Struct(obj, gsl_combination, c);
  c2 = gsl_combination_alloc(c->n, c->k);
  gsl_combination_memcpy(c2, c);
  return Data_Wrap_Struct(CLASS_OF(obj), 0, gsl_combination_free, c2);
}
```

### Solution
Since we're extracting data from `obj` with a known type, use the same type:

```c
static VALUE rb_gsl_combination_clone(VALUE obj)
{
  gsl_combination *c, *c2;
  TypedData_Get_Struct(obj, gsl_combination, &combination_type, c);
  c2 = gsl_combination_alloc(c->n, c->k);
  gsl_combination_memcpy(c2, c);
  return TypedData_Wrap_Struct(CLASS_OF(obj), &combination_type, c2);
}
```

**Key insight**: `CLASS_OF(obj)` preserves subclass, but type checking uses parent type.
This is correct behavior - subclasses share the parent's data layout.

### Files Affected
- cheb.c (4), combination.c (1), dht.c (1), eigen.c (2)
- fft.c (2), histogram.c (4), histogram2d.c (6), histogram3d.c (4)
- permutation.c (2), rng.c (2), wavelet.c (2)

---

## Pattern 3: `VECTOR_*_ROW_COL` Macros (28 occurrences)

### Problem
```c
// Macro determines class based on input vector orientation
#define VECTOR_ROW_COL(x) \
  ((rb_obj_is_kind_of(x, cgsl_vector_col) || \
    rb_obj_is_kind_of(x, cgsl_vector_int_col)) ? cgsl_vector_col : cgsl_vector)

// Used like:
vout = Data_Wrap_Struct(VECTOR_ROW_COL(obj), 0, gsl_vector_free, v);
```

### Solution A: Unified Type (Recommended)
Use a single `gsl_vector_type` for all vector variants. The row/col distinction
is a Ruby-level concept, not a C data layout difference:

```c
static const rb_data_type_t gsl_vector_type = {
    .wrap_struct_name = "GSL::Vector",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_vector_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

// Still use VECTOR_ROW_COL for class, but unified type
vout = TypedData_Wrap_Struct(VECTOR_ROW_COL(obj), &gsl_vector_type, v);
```

### Solution B: Type Selection Macro
If separate types are needed:

```c
#define VECTOR_TYPE_FOR(x) \
  ((rb_obj_is_kind_of(x, cgsl_vector_col) || \
    rb_obj_is_kind_of(x, cgsl_vector_int_col)) \
    ? &gsl_vector_col_type : &gsl_vector_type)

vout = TypedData_Wrap_Struct(VECTOR_ROW_COL(obj), VECTOR_TYPE_FOR(obj), v);
```

### Files Affected
- dht.c (1), fft.c (2), jacobi.c (6), linalg.c (11)
- math.c (2), randist.c (2), signal.c (2), sort.c (2)

---

## Implementation Order

### Phase 1: Type Definitions (1 PR)
Create `include/rb_gsl_types.h` with all `rb_data_type_t` definitions.
~100 type definitions needed.

### Phase 2: Simple klass Pattern (3-4 PRs)
Migrate files with only `klass` pattern, grouped by subsystem:
1. Core: rng.c, permutation.c, combination.c, multiset.c
2. Math: cheb.c, deriv.c, diff.c, integration.c
3. FFT/Wavelet: fft.c, wavelet.c
4. Fitting/Optimization: multifit.c, multimin.c, multiroots.c, root.c, min.c

### Phase 3: CLASS_OF Pattern (2 PRs)
Migrate clone/dup operations:
1. Simple types: combination.c, permutation.c, rng.c
2. Complex types: histogram.c, histogram2d.c, histogram3d.c, eigen.c

### Phase 4: VECTOR_ROW_COL Pattern (1 PR)
Migrate vector operations with unified type approach.

### Phase 5: Macro-based Code (2-3 PRs)
Handle `GSL_TYPE`, `QUALIFIED_VIEW` patterns in template files.

---

## Helper Macros

Add to `include/rb_gsl_types.h`:

```c
/* Get typed data with correct type */
#define GSL_GET_STRUCT(obj, type, var) \
    TypedData_Get_Struct(obj, type, &type##_data_type, var)

/* Wrap with correct type, preserving runtime class */
#define GSL_WRAP_STRUCT(klass, type, ptr) \
    TypedData_Wrap_Struct(klass, &type##_data_type, ptr)
```

---

## Testing Strategy

1. **Unit tests**: Run `rake test` after each file migration
2. **Smoke test**: Verify basic operations for each migrated class
3. **Memory test**: Check for leaks with `ruby -e "1000.times { GSL::Vector.alloc(1000) }; GC.start"`
4. **Warning check**: Verify deprecation warnings are eliminated

---

## Estimated Effort

| Phase | Files | Est. Time |
|-------|-------|-----------|
| Type definitions | 1 | 2-3 hours |
| klass pattern | ~35 | 4-6 hours |
| CLASS_OF pattern | ~11 | 2-3 hours |
| VECTOR_ROW_COL | ~8 | 1-2 hours |
| Macro-based | ~10 | 3-4 hours |
| **Total** | **~65** | **12-18 hours** |

This can be done incrementally across multiple PRs.
