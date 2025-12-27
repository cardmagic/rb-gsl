/*
 * rb_gsl_types.h
 * TypedData type declarations for rb-gsl
 *
 * This header declares rb_data_type_t structs for all GSL wrapper classes.
 * The actual definitions are in rb_gsl_types.c.
 *
 * Include this header and use TypedData_Wrap_Struct/TypedData_Get_Struct
 * instead of the legacy Data_Wrap_Struct/Data_Get_Struct.
 */

#ifndef RB_GSL_TYPES_H
#define RB_GSL_TYPES_H

#include <ruby.h>

/* Vector Types */
extern const rb_data_type_t gsl_vector_data_type;
extern const rb_data_type_t gsl_vector_view_data_type;
extern const rb_data_type_t gsl_vector_int_data_type;
extern const rb_data_type_t gsl_vector_complex_data_type;

/* Matrix Types */
extern const rb_data_type_t gsl_matrix_data_type;
extern const rb_data_type_t gsl_matrix_view_data_type;
extern const rb_data_type_t gsl_matrix_int_data_type;
extern const rb_data_type_t gsl_matrix_complex_data_type;

/* Block Types */
extern const rb_data_type_t gsl_block_data_type;
extern const rb_data_type_t gsl_block_complex_data_type;

/* Permutation & Combination */
extern const rb_data_type_t gsl_permutation_data_type;
extern const rb_data_type_t gsl_combination_data_type;
extern const rb_data_type_t gsl_multiset_data_type;

/* Complex */
extern const rb_data_type_t gsl_complex_data_type;

/* Random Number Generators */
extern const rb_data_type_t gsl_rng_data_type;
extern const rb_data_type_t gsl_qrng_data_type;
extern const rb_data_type_t gsl_ran_discrete_data_type;

/* Histogram Types */
extern const rb_data_type_t gsl_histogram_data_type;
extern const rb_data_type_t gsl_histogram_pdf_data_type;
extern const rb_data_type_t gsl_histogram2d_data_type;
extern const rb_data_type_t gsl_histogram2d_pdf_data_type;
extern const rb_data_type_t gsl_histogram2d_view_data_type;
extern const rb_data_type_t gsl_histogram3d_data_type;
extern const rb_data_type_t gsl_histogram3d_view_data_type;
extern const rb_data_type_t gsl_histogram_range_data_type;

/* Interpolation & Splines */
extern const rb_data_type_t gsl_interp_data_type;
extern const rb_data_type_t gsl_interp_accel_data_type;
extern const rb_data_type_t gsl_spline_data_type;
extern const rb_data_type_t gsl_bspline_workspace_data_type;

/* FFT Types */
extern const rb_data_type_t gsl_fft_complex_wavetable_data_type;
extern const rb_data_type_t gsl_fft_complex_workspace_data_type;
extern const rb_data_type_t gsl_fft_real_wavetable_data_type;
extern const rb_data_type_t gsl_fft_real_workspace_data_type;
extern const rb_data_type_t gsl_fft_halfcomplex_wavetable_data_type;

/* Wavelet Types */
extern const rb_data_type_t gsl_wavelet_data_type;
extern const rb_data_type_t gsl_wavelet_workspace_data_type;

/* Chebyshev */
extern const rb_data_type_t gsl_cheb_series_data_type;

/* Eigen Types */
extern const rb_data_type_t gsl_eigen_symm_workspace_data_type;
extern const rb_data_type_t gsl_eigen_symmv_workspace_data_type;
extern const rb_data_type_t gsl_eigen_herm_workspace_data_type;
extern const rb_data_type_t gsl_eigen_hermv_workspace_data_type;
extern const rb_data_type_t gsl_eigen_nonsymm_workspace_data_type;
extern const rb_data_type_t gsl_eigen_nonsymmv_workspace_data_type;
extern const rb_data_type_t gsl_eigen_gensymm_workspace_data_type;
extern const rb_data_type_t gsl_eigen_gensymmv_workspace_data_type;
extern const rb_data_type_t gsl_eigen_genherm_workspace_data_type;
extern const rb_data_type_t gsl_eigen_genhermv_workspace_data_type;
extern const rb_data_type_t gsl_eigen_gen_workspace_data_type;
extern const rb_data_type_t gsl_eigen_genv_workspace_data_type;

/* Integration Types */
extern const rb_data_type_t gsl_integration_workspace_data_type;
extern const rb_data_type_t gsl_integration_qaws_table_data_type;
extern const rb_data_type_t gsl_integration_qawo_table_data_type;
extern const rb_data_type_t gsl_integration_glfixed_table_data_type;

/* Monte Carlo Types */
extern const rb_data_type_t gsl_monte_plain_state_data_type;
extern const rb_data_type_t gsl_monte_miser_state_data_type;
extern const rb_data_type_t gsl_monte_vegas_state_data_type;

/* Minimization Types */
extern const rb_data_type_t gsl_min_fminimizer_data_type;
extern const rb_data_type_t gsl_multimin_fminimizer_data_type;
extern const rb_data_type_t gsl_multimin_fdfminimizer_data_type;

/* Root Finding Types */
extern const rb_data_type_t gsl_root_fsolver_data_type;
extern const rb_data_type_t gsl_root_fdfsolver_data_type;
extern const rb_data_type_t gsl_multiroot_fsolver_data_type;
extern const rb_data_type_t gsl_multiroot_fdfsolver_data_type;

/* Fitting Types */
extern const rb_data_type_t gsl_multifit_linear_workspace_data_type;
extern const rb_data_type_t gsl_multifit_fdfsolver_data_type;

/* ODE Types */
extern const rb_data_type_t gsl_odeiv_step_data_type;
extern const rb_data_type_t gsl_odeiv_control_data_type;
extern const rb_data_type_t gsl_odeiv_evolve_data_type;

/* Summation Types */
extern const rb_data_type_t gsl_sum_levin_u_workspace_data_type;
extern const rb_data_type_t gsl_sum_levin_utrunc_workspace_data_type;

/* DHT Types */
extern const rb_data_type_t gsl_dht_data_type;

/* Special Function Result Types */
extern const rb_data_type_t gsl_sf_result_data_type;
extern const rb_data_type_t gsl_sf_result_e10_data_type;

/* N-Tuple Types */
extern const rb_data_type_t gsl_ntuple_data_type;

#endif /* RB_GSL_TYPES_H */
