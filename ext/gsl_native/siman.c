/*
  siman.c
  Ruby/GSL: Ruby extension library for GSL (GNU Scientific Library)
    (C) Copyright 2001-2006 by Yoshiki Tsunesada

  Ruby/GSL is free software: you can redistribute it and/or modify it
  under the terms of the GNU General Public License.
  This library is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY.
*/

#include <gsl/gsl_rng.h>
#include <gsl/gsl_siman.h>
#include "include/rb_gsl.h"
#include "include/rb_gsl_array.h"
#include "include/rb_gsl_function.h"
#include "include/rb_gsl_rng.h"
#include "include/rb_gsl_common.h"
#include "include/rb_gsl_types.h"

static VALUE cgsl_siman_Efunc;
static VALUE cgsl_siman_step;
static VALUE cgsl_siman_metric;
static VALUE cgsl_siman_print;
static VALUE cgsl_siman_solver;
static VALUE cgsl_siman_params;

/***** siman_solver *****/
typedef struct __siman_solver {
  VALUE proc_efunc;
  VALUE proc_step;
  VALUE proc_metric;
  VALUE proc_print;
  gsl_vector *vx;
} siman_solver;

static siman_solver* gsl_siman_solver_alloc(size_t size);
static void gsl_siman_solver_free(siman_solver *ss);
static void gsl_siman_solver_mark(siman_solver *s);

static void gsl_siman_solver_mark(siman_solver *s)
{
  rb_gc_mark(s->proc_efunc);
  rb_gc_mark(s->proc_step);
  rb_gc_mark(s->proc_metric);
  rb_gc_mark(s->proc_print);
}

static siman_solver* gsl_siman_solver_alloc(size_t size)
{
  siman_solver *ss = NULL;
  ss = ALLOC(siman_solver);
  if (size > 0) {
    ss->vx = gsl_vector_alloc(size);
  } else {
    ss->vx = NULL;
  }
  return ss;
}

static void gsl_siman_solver_free(siman_solver *ss)
{
  if (ss->vx) gsl_vector_free(ss->vx);
  free((siman_solver *) ss);
}

static const rb_data_type_t siman_solver_data_type = {
    .wrap_struct_name = "GSL::Siman::Solver",
    .function = {
        .dmark = (void (*)(void *))gsl_siman_solver_mark,
        .dfree = (void (*)(void *))gsl_siman_solver_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

static VALUE rb_gsl_siman_solver_new(int argc, VALUE *argv, VALUE klass)
{
  siman_solver *ss = NULL;
  if (argc == 1) ss = gsl_siman_solver_alloc(FIX2INT(argv[0]));
  else ss = gsl_siman_solver_alloc(0);
  return TypedData_Wrap_Struct(klass, &siman_solver_data_type, ss);
}

/***** siman_Efunc *****/
typedef struct ___siman_Efunc {
  double (*siman_Efunc_t)(void *);
  VALUE proc;
} siman_Efunc;

static siman_Efunc* siman_Efunc_alloc();
static void siman_Efunc_free(siman_Efunc *se);
static double rb_gsl_siman_Efunc_t(void *xp);
static VALUE rb_gsl_siman_Efunc_set(int argc, VALUE *argv, VALUE obj);
static void siman_Efunc_mark(siman_Efunc *se);

static siman_Efunc* siman_Efunc_alloc()
{
  siman_Efunc *se = NULL;
  se = ALLOC(siman_Efunc);
  se->siman_Efunc_t = rb_gsl_siman_Efunc_t;
  return se;
}

static void siman_Efunc_mark(siman_Efunc *se)
{
  rb_gc_mark(se->proc);
}

static void siman_Efunc_free(siman_Efunc *se)
{
  free((siman_Efunc *) se);
}

static const rb_data_type_t siman_Efunc_data_type = {
    .wrap_struct_name = "GSL::Siman::Efunc",
    .function = {
        .dmark = (void (*)(void *))siman_Efunc_mark,
        .dfree = (void (*)(void *))siman_Efunc_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

static VALUE rb_gsl_siman_Efunc_new(int argc, VALUE *argv, VALUE klass)
{
  VALUE obj;
  siman_Efunc *se = NULL;
  se = siman_Efunc_alloc();
  obj = TypedData_Wrap_Struct(klass, &siman_Efunc_data_type, se);
  rb_gsl_siman_Efunc_set(argc, argv, obj);
  return obj;
}

static double rb_gsl_siman_Efunc_t(void *data)
{
  VALUE proc, params, result;
  siman_solver *ss = NULL;
  ss = (siman_solver *) data;
  proc = (VALUE) ss->proc_efunc;
  params = TypedData_Wrap_Struct(cgsl_vector, &gsl_vector_data_type, ss->vx);
  result = rb_funcall(proc, RBGSL_ID_call, 1, params);
  return NUM2DBL(result);
}

static VALUE rb_gsl_siman_Efunc_set(int argc, VALUE *argv, VALUE obj)
{
  siman_Efunc *se = NULL;
  TypedData_Get_Struct(obj, siman_Efunc, &siman_Efunc_data_type, se);
  switch (argc) {
  case 0:
    if (rb_block_given_p()) se->proc = rb_block_proc();
    break;
  case 1:
    if (rb_obj_is_kind_of(argv[0], rb_cProc)) se->proc = argv[0];
    else rb_raise(rb_eTypeError, "Proc expected");
    break;
  default:
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
  }
  return obj;
}

/***** siman_copy *****/
static void rb_gsl_siman_copy_t(void *source, void *dest);
static void* rb_gsl_siman_copy_construct_t(void *data);
static void rb_gsl_siman_destroy_t(void *data);

static void rb_gsl_siman_copy_t(void *source, void *dest)
{
  siman_solver *sssrc = NULL, *ssdest = NULL;
  sssrc = (siman_solver *) source;
  ssdest = (siman_solver *) dest;
  gsl_vector_memcpy(ssdest->vx, sssrc->vx);
}

/***** siman_copy_construct *****/
static void* rb_gsl_siman_copy_construct_t(void *data)
{
  siman_solver *ssdest = NULL;
  siman_solver *sssrc = NULL;
  sssrc = (siman_solver *) data;
  ssdest = (siman_solver *) gsl_siman_solver_alloc(sssrc->vx->size);
  ssdest->proc_efunc = sssrc->proc_efunc;
  ssdest->proc_step = sssrc->proc_step;
  ssdest->proc_metric = sssrc->proc_metric;
  ssdest->proc_print = sssrc->proc_print;
  gsl_vector_memcpy(ssdest->vx, sssrc->vx);
  return ssdest;
}

/***** siman_destroy *****/
static void rb_gsl_siman_destroy_t(void *data)
{
  siman_solver *ss = NULL;
  ss = (siman_solver *) data;
  gsl_siman_solver_free(ss);
}

/****** siman_print *****/
typedef struct ___siman_print {
  void (*siman_print_t)(void *);
  VALUE proc;
} siman_print;

static siman_print* siman_print_alloc();
static void siman_print_free(siman_print *se);
static void rb_gsl_siman_print_t(void *xp);
static VALUE rb_gsl_siman_print_set(int argc, VALUE *argv, VALUE obj);
static void siman_print_mark(siman_print *se);

static siman_print* siman_print_alloc()
{
  siman_print *se = NULL;
  se = ALLOC(siman_print);
  se->siman_print_t = &rb_gsl_siman_print_t;
  return se;
}

static void siman_print_mark(siman_print *se)
{
  rb_gc_mark(se->proc);
}

static void siman_print_free(siman_print *se)
{
  free((siman_print *) se);
}

static const rb_data_type_t siman_print_data_type = {
    .wrap_struct_name = "GSL::Siman::Print",
    .function = {
        .dmark = (void (*)(void *))siman_print_mark,
        .dfree = (void (*)(void *))siman_print_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

static VALUE rb_gsl_siman_print_new(int argc, VALUE *argv, VALUE klass)
{
  VALUE obj;
  siman_print *se = NULL;
  se = siman_print_alloc();
  obj = TypedData_Wrap_Struct(klass, &siman_print_data_type, se);
  rb_gsl_siman_print_set(argc, argv, obj);
  return obj;
}

static void rb_gsl_siman_print_t(void *data)
{
  VALUE proc, params;
  siman_solver *ss = NULL;
  ss = (siman_solver *) data;
  proc = ss->proc_print;
  if (NIL_P(proc)) return;
  params = TypedData_Wrap_Struct(cgsl_vector, &gsl_vector_data_type, ss->vx);
  rb_funcall(proc, RBGSL_ID_call, 1, params);
}

static VALUE rb_gsl_siman_print_set(int argc, VALUE *argv, VALUE obj)
{
  siman_print *se = NULL;
  TypedData_Get_Struct(obj, siman_print, &siman_print_data_type, se);
  switch (argc) {
  case 0:
    if (rb_block_given_p()) se->proc = rb_block_proc();
    break;
  case 1:
    if (rb_obj_is_kind_of(argv[0], rb_cProc)) se->proc = argv[0];
    break;
  default:
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
  }
  return obj;
}

/***** siman_step *****/
typedef struct ___siman_step {
  void (*siman_step_t)(const gsl_rng *r, void *xp, double step_size);
  VALUE proc;
} siman_step;

static siman_step* siman_step_alloc();
static void siman_step_free(siman_step *se);
static void rb_gsl_siman_step_t(const gsl_rng *r, void *xp, double step_size);
static VALUE rb_gsl_siman_step_set(int argc, VALUE *argv, VALUE obj);
static void siman_step_mark(siman_step *se);

static siman_step* siman_step_alloc()
{
  siman_step *se = NULL;
  se = ALLOC(siman_step);
  se->siman_step_t = rb_gsl_siman_step_t;
  return se;
}

static void siman_step_mark(siman_step *se)
{
  rb_gc_mark(se->proc);
}

static void siman_step_free(siman_step *se)
{
  free((siman_step *) se);
}

static const rb_data_type_t siman_step_data_type = {
    .wrap_struct_name = "GSL::Siman::Step",
    .function = {
        .dmark = (void (*)(void *))siman_step_mark,
        .dfree = (void (*)(void *))siman_step_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

static VALUE rb_gsl_siman_step_new(int argc, VALUE *argv, VALUE klass)
{
  VALUE obj;
  siman_step *se = NULL;
  se = siman_step_alloc();
  obj = TypedData_Wrap_Struct(klass, &siman_step_data_type, se);
  rb_gsl_siman_step_set(argc, argv, obj);
  return obj;
}

static void rb_gsl_siman_step_t(const gsl_rng *r, void *data, double step_size)
{
  VALUE proc, params;
  VALUE rng;
  siman_solver *ss = NULL;
  ss = (siman_solver *) data;
  proc = (VALUE) ss->proc_step;
  rng = TypedData_Wrap_Struct(cgsl_rng, &gsl_rng_data_type, (gsl_rng *) r);
  params = TypedData_Wrap_Struct(cgsl_vector, &gsl_vector_data_type, ss->vx);
  rb_funcall(proc, RBGSL_ID_call, 3, rng, params, rb_float_new(step_size));
}

static VALUE rb_gsl_siman_step_set(int argc, VALUE *argv, VALUE obj)
{
  siman_step *se = NULL;
  TypedData_Get_Struct(obj, siman_step, &siman_step_data_type, se);
  switch (argc) {
  case 0:
    if (rb_block_given_p()) se->proc = rb_block_proc();
    break;
  case 1:
    if (rb_obj_is_kind_of(argv[0], rb_cProc)) se->proc = argv[0];
    break;
  default:
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
  }
  return obj;
}

/***** siman_metric *****/
typedef struct ___siman_metric {
  double (*siman_metric_t)(void *, void *);
  VALUE proc;
} siman_metric;

static siman_metric* siman_metric_alloc();
static void siman_metric_free(siman_metric *se);
static double rb_gsl_siman_metric_t(void *xp, void *yp);
static VALUE rb_gsl_siman_metric_set(int argc, VALUE *argv, VALUE obj);
static void siman_metric_mark(siman_metric *se);

static siman_metric* siman_metric_alloc()
{
  siman_metric *se = NULL;
  se = ALLOC(siman_metric);
  if (se == NULL) rb_raise(rb_eRuntimeError, "ALLOC failed");
  se->siman_metric_t = &rb_gsl_siman_metric_t;
  return se;
}

static void siman_metric_mark(siman_metric *se)
{
  rb_gc_mark(se->proc);
}

static void siman_metric_free(siman_metric *se)
{
  free((siman_metric *) se);
}

static const rb_data_type_t siman_metric_data_type = {
    .wrap_struct_name = "GSL::Siman::Metric",
    .function = {
        .dmark = (void (*)(void *))siman_metric_mark,
        .dfree = (void (*)(void *))siman_metric_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

static VALUE rb_gsl_siman_metric_new(int argc, VALUE *argv, VALUE klass)
{
  VALUE obj;
  siman_metric *se = NULL;
  se = siman_metric_alloc();
  obj = TypedData_Wrap_Struct(klass, &siman_metric_data_type, se);
  rb_gsl_siman_metric_set(argc, argv, obj);
  return obj;
}

static double rb_gsl_siman_metric_t(void *data, void *yp)
{
  VALUE proc, vxp, vyp, result;
  siman_solver *ss = NULL, *ssy = NULL;
  ss = (siman_solver *) data;
  ssy = (siman_solver *) yp;
  proc = ss->proc_metric;
  vxp = TypedData_Wrap_Struct(cgsl_vector, &gsl_vector_data_type, ss->vx);
  vyp = TypedData_Wrap_Struct(cgsl_vector, &gsl_vector_data_type, ssy->vx);
  result = rb_funcall(proc, RBGSL_ID_call, 2, vxp, vyp);
  return NUM2DBL(result);
}

static VALUE rb_gsl_siman_metric_set(int argc, VALUE *argv, VALUE obj)
{
  siman_metric *se = NULL;
  TypedData_Get_Struct(obj, siman_metric, &siman_metric_data_type, se);
  switch (argc) {
  case 0:
    if (rb_block_given_p()) se->proc = rb_block_proc();
    break;
  case 1:
    if (rb_obj_is_kind_of(argv[0], rb_cProc)) se->proc = argv[0];
    break;
  default:
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
  }
  return obj;
}

/***** siman_params_t *****/
static gsl_siman_params_t* gsl_siman_params_alloc();
static void gsl_siman_params_free(gsl_siman_params_t *params);

static gsl_siman_params_t* gsl_siman_params_alloc()
{
  gsl_siman_params_t *params = NULL;
  params = ALLOC(gsl_siman_params_t);
  return params;
}

static void gsl_siman_params_free(gsl_siman_params_t *params)
{
  free((gsl_siman_params_t *) params);
}

static const rb_data_type_t gsl_siman_params_data_type = {
    .wrap_struct_name = "GSL::Siman::Params",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_siman_params_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

static VALUE rb_gsl_siman_params_set(int argc, VALUE *argv, VALUE obj);

static VALUE rb_gsl_siman_params_new(int argc, VALUE *argv, VALUE klass)
{
  gsl_siman_params_t *params = NULL;
  VALUE obj;
  params = gsl_siman_params_alloc();
  obj = TypedData_Wrap_Struct(klass, &gsl_siman_params_data_type, params);
  rb_gsl_siman_params_set(argc, argv, obj);
  return obj;
}

static VALUE rb_gsl_siman_params_set(int argc, VALUE *argv, VALUE obj)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  switch (argc) {
  case 7:
    params->t_min = NUM2DBL(argv[6]);
  /* no break */
  case 6:
    params->mu_t = NUM2DBL(argv[5]);
  /* no break */
  case 5:
    params->t_initial = NUM2DBL(argv[4]);
  /* no break */
  case 4:
    params->k = NUM2DBL(argv[3]);
  /* no break */
  case 3:
    params->step_size = NUM2DBL(argv[2]);
  /* no break */
  case 2:
    params->iters_fixed_T = NUM2INT(argv[1]);
  /* no break */
  case 1:
    params->n_tries = NUM2INT(argv[0]);
  }
  return obj;
}

static VALUE rb_gsl_siman_params_n_tries(VALUE obj)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  return INT2FIX(params->n_tries);
}

static VALUE rb_gsl_siman_params_set_n_tries(VALUE obj, VALUE n)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  params->n_tries = NUM2INT(n);
  return obj;
}

static VALUE rb_gsl_siman_params_iters_fixed_T(VALUE obj)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  return INT2FIX(params->iters_fixed_T);
}

static VALUE rb_gsl_siman_params_set_iters_fixed_T(VALUE obj, VALUE n)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  params->iters_fixed_T = NUM2INT(n);
  return obj;
}

static VALUE rb_gsl_siman_params_step_size(VALUE obj)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  return rb_float_new(params->step_size);
}

static VALUE rb_gsl_siman_params_set_step_size(VALUE obj, VALUE s)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  params->step_size = NUM2DBL(s);
  return obj;
}

static VALUE rb_gsl_siman_params_k(VALUE obj)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  return rb_float_new(params->k);
}

static VALUE rb_gsl_siman_params_set_k(VALUE obj, VALUE s)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  params->k = NUM2DBL(s);
  return obj;
}

static VALUE rb_gsl_siman_params_t_initial(VALUE obj)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  return rb_float_new(params->t_initial);
}

static VALUE rb_gsl_siman_params_set_t_initial(VALUE obj, VALUE s)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  params->t_initial = NUM2DBL(s);
  return obj;
}

static VALUE rb_gsl_siman_params_mu_t(VALUE obj)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  return rb_float_new(params->mu_t);
}

static VALUE rb_gsl_siman_params_set_mu_t(VALUE obj, VALUE s)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  params->mu_t = NUM2DBL(s);
  return obj;
}

static VALUE rb_gsl_siman_params_t_min(VALUE obj)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  return rb_float_new(params->t_min);
}

static VALUE rb_gsl_siman_params_set_t_min(VALUE obj, VALUE s)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  params->t_min = NUM2DBL(s);
  return obj;
}

static VALUE rb_gsl_siman_params_params(VALUE obj)
{
  gsl_siman_params_t *params = NULL;
  TypedData_Get_Struct(obj, gsl_siman_params_t, &gsl_siman_params_data_type, params);
  return rb_ary_new3(7, INT2FIX(params->n_tries), INT2FIX(params->iters_fixed_T),
                     rb_float_new(params->step_size), rb_float_new(params->k),
                     rb_float_new(params->t_initial), rb_float_new(params->mu_t),
                     rb_float_new(params->t_min));
}

/***** solver *****/
static VALUE rb_gsl_siman_solver_solve(VALUE obj, VALUE rng,
                                       VALUE vx0p, VALUE vefunc,
                                       VALUE vstep, VALUE vmetric, VALUE vprint,
                                       VALUE vparams)
{
  gsl_rng *r = NULL;
  siman_solver *ss = NULL;
  siman_Efunc *efunc = NULL;
  siman_step *step = NULL;
  siman_metric *metric = NULL;
  siman_print *print = NULL;
  gsl_vector *vtmp = NULL;
  gsl_siman_params_t *params = NULL;
  int flag = 0;
  /*  Data_Get_Struct(obj, siman_solver, ss);*/
  CHECK_VECTOR(vx0p);
  TypedData_Get_Struct(vx0p, gsl_vector, &gsl_vector_data_type, vtmp);

  switch (TYPE(obj)) {
  case T_MODULE:
  case T_CLASS:
  case T_OBJECT:
    ss = gsl_siman_solver_alloc(vtmp->size);
    flag = 1;
    break;
  default:
    TypedData_Get_Struct(obj, siman_solver, &siman_solver_data_type, ss);
  }
  if (!rb_obj_is_kind_of(rng, cgsl_rng))
    rb_raise(rb_eTypeError, "wrong argument type %s (GSL::Rng expected)",
             rb_class2name(CLASS_OF(rng)));
  if (!rb_obj_is_kind_of(vefunc, cgsl_siman_Efunc))
    rb_raise(rb_eTypeError, "wrong argument type %s (GSL::Siman::Efunc expected)",
             rb_class2name(CLASS_OF(vefunc)));
  if (!rb_obj_is_kind_of(vstep, cgsl_siman_step))
    rb_raise(rb_eTypeError, "wrong argument type %s (GSL::Siman::Step expected)",
             rb_class2name(CLASS_OF(vstep)));
  if (!rb_obj_is_kind_of(vmetric, cgsl_siman_metric))
    rb_raise(rb_eTypeError, "wrong argument type %s (GSL::Siman::Metric expected)",
             rb_class2name(CLASS_OF(vmetric)));
  TypedData_Get_Struct(rng, gsl_rng, &gsl_rng_data_type, r);
  TypedData_Get_Struct(vefunc, siman_Efunc, &siman_Efunc_data_type, efunc);
  TypedData_Get_Struct(vstep, siman_step, &siman_step_data_type, step);
  TypedData_Get_Struct(vmetric, siman_metric, &siman_metric_data_type, metric);
  if (NIL_P(vprint)) {
    ss->proc_print = Qnil;
  } else {
    if (!rb_obj_is_kind_of(vprint, cgsl_siman_print))
      rb_raise(rb_eTypeError, "wrong argument type %s (GSL::Siman::Print expected)",
               rb_class2name(CLASS_OF(vprint)));
    TypedData_Get_Struct(vprint, siman_print, &siman_print_data_type, print);
    ss->proc_print   = print->proc;
  }
  if (!rb_obj_is_kind_of(vparams, cgsl_siman_params))
    rb_raise(rb_eTypeError, "wrong argument type %s (GSL::Siman::Params expected)",
             rb_class2name(CLASS_OF(vparams)));
  TypedData_Get_Struct(vparams, gsl_siman_params_t, &gsl_siman_params_data_type, params);

  ss->proc_efunc   = efunc->proc;
  ss->proc_step    = step->proc;
  ss->proc_metric  = metric->proc;

  gsl_vector_memcpy(ss->vx, vtmp);

  if (NIL_P(vprint)) {
    gsl_siman_solve(r, ss, rb_gsl_siman_Efunc_t,
                    rb_gsl_siman_step_t,
                    rb_gsl_siman_metric_t,
                    NULL,
                    rb_gsl_siman_copy_t,
                    rb_gsl_siman_copy_construct_t,
                    rb_gsl_siman_destroy_t, 0,
                    *params);

  } else {
    gsl_siman_solve(r, ss, rb_gsl_siman_Efunc_t,
                    rb_gsl_siman_step_t,
                    rb_gsl_siman_metric_t,
                    rb_gsl_siman_print_t,
                    rb_gsl_siman_copy_t,
                    rb_gsl_siman_copy_construct_t,
                    rb_gsl_siman_destroy_t, 0,
                    *params);
  }
  gsl_vector_memcpy(vtmp, ss->vx);

  if (flag == 1) gsl_siman_solver_free(ss);
  return obj;
}

void Init_gsl_siman(VALUE module)
{
  VALUE mgsl_siman;

  mgsl_siman = rb_define_module_under(module, "Siman");

  cgsl_siman_Efunc = rb_define_class_under(mgsl_siman, "Efunc", cGSL_Object);
  cgsl_siman_step = rb_define_class_under(mgsl_siman, "Step", cGSL_Object);
  cgsl_siman_metric = rb_define_class_under(mgsl_siman, "Metric", cGSL_Object);
  cgsl_siman_print = rb_define_class_under(mgsl_siman, "Print", cGSL_Object);
  cgsl_siman_params = rb_define_class_under(mgsl_siman, "Params", cGSL_Object);
  cgsl_siman_solver = rb_define_class_under(mgsl_siman, "Solver", cGSL_Object);

  /***** Efunc *****/
  rb_define_singleton_method(cgsl_siman_Efunc, "alloc", rb_gsl_siman_Efunc_new, -1);
  rb_define_method(cgsl_siman_Efunc, "set", rb_gsl_siman_Efunc_set, -1);
  rb_define_alias(cgsl_siman_Efunc, "set_proc", "set");

  /***** Print *****/
  rb_define_singleton_method(cgsl_siman_print, "alloc", rb_gsl_siman_print_new, -1);
  rb_define_method(cgsl_siman_print, "set", rb_gsl_siman_print_set, -1);
  rb_define_alias(cgsl_siman_print, "set_proc", "set");

  rb_define_singleton_method(cgsl_siman_step, "alloc", rb_gsl_siman_step_new, -1);
  rb_define_method(cgsl_siman_step, "set", rb_gsl_siman_step_set, -1);
  rb_define_alias(cgsl_siman_step, "set_proc", "set");

  rb_define_singleton_method(cgsl_siman_metric, "alloc", rb_gsl_siman_metric_new, -1);
  rb_define_method(cgsl_siman_metric, "set", rb_gsl_siman_metric_set, -1);
  rb_define_alias(cgsl_siman_metric, "set_proc", "set");

  /***** params *****/
  rb_define_singleton_method(cgsl_siman_params, "alloc", rb_gsl_siman_params_new, -1);
  rb_define_method(cgsl_siman_params, "set", rb_gsl_siman_params_set, -1);
  rb_define_method(cgsl_siman_params, "params", rb_gsl_siman_params_params, 0);
  rb_define_method(cgsl_siman_params, "n_tries", rb_gsl_siman_params_n_tries, 0);
  rb_define_method(cgsl_siman_params, "set_n_tries", rb_gsl_siman_params_set_n_tries, 1);
  rb_define_alias(cgsl_siman_params, "n_tries=", "set_n_tries");
  rb_define_method(cgsl_siman_params, "iters_fixed_T", rb_gsl_siman_params_iters_fixed_T, 0);
  rb_define_method(cgsl_siman_params, "set_iters_fixed_T", rb_gsl_siman_params_set_iters_fixed_T, 1);
  rb_define_alias(cgsl_siman_params, "iters_fixed_T=", "set_iters_fixed_T");
  rb_define_method(cgsl_siman_params, "step_size", rb_gsl_siman_params_step_size, 0);
  rb_define_method(cgsl_siman_params, "set_step_size", rb_gsl_siman_params_set_step_size, 1);
  rb_define_alias(cgsl_siman_params, "step_size=", "set_step_size");
  rb_define_method(cgsl_siman_params, "k", rb_gsl_siman_params_k, 0);
  rb_define_method(cgsl_siman_params, "set_k", rb_gsl_siman_params_set_k, 1);
  rb_define_alias(cgsl_siman_params, "k=", "set_k");
  rb_define_method(cgsl_siman_params, "t_initial", rb_gsl_siman_params_t_initial, 0);
  rb_define_method(cgsl_siman_params, "set_t_initial", rb_gsl_siman_params_set_t_initial, 1);
  rb_define_alias(cgsl_siman_params, "t_initial=", "set_t_initial");
  rb_define_method(cgsl_siman_params, "mu_t", rb_gsl_siman_params_mu_t, 0);
  rb_define_method(cgsl_siman_params, "set_mu_t", rb_gsl_siman_params_set_mu_t, 1);
  rb_define_alias(cgsl_siman_params, "mu_t=", "set_mu_t");
  rb_define_method(cgsl_siman_params, "t_min", rb_gsl_siman_params_t_min, 0);
  rb_define_method(cgsl_siman_params, "set_t_min", rb_gsl_siman_params_set_t_min, 1);
  rb_define_alias(cgsl_siman_params, "t_min=", "set_t_min");

  /***** solver *****/
  rb_define_singleton_method(cgsl_siman_solver, "alloc", rb_gsl_siman_solver_new, -1);
  rb_define_method(cgsl_siman_solver, "solve", rb_gsl_siman_solver_solve, 7);

  rb_define_singleton_method(cgsl_siman_solver, "solve", rb_gsl_siman_solver_solve, 7);
  rb_define_singleton_method(mgsl_siman, "solve", rb_gsl_siman_solver_solve, 7);
}
