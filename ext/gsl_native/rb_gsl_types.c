/*
 * rb_gsl_types.c
 * TypedData type definitions for rb-gsl
 */

#include <ruby.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_vector_int.h>
#include <gsl/gsl_vector_complex_double.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_matrix_int.h>
#include <gsl/gsl_matrix_complex_double.h>
#include <gsl/gsl_block.h>
#include <gsl/gsl_block_uchar.h>
#include <gsl/gsl_permutation.h>
#include <gsl/gsl_combination.h>
#include <gsl/gsl_multiset.h>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_qrng.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_histogram.h>
#include <gsl/gsl_histogram2d.h>
#include "include/rb_gsl_histogram3d.h"
#include <gsl/gsl_interp.h>
#include <gsl/gsl_spline.h>
#include <gsl/gsl_bspline.h>
#include <gsl/gsl_fft_complex.h>
#include <gsl/gsl_fft_real.h>
#include <gsl/gsl_fft_halfcomplex.h>
#include <gsl/gsl_wavelet.h>
#include <gsl/gsl_chebyshev.h>
#include <gsl/gsl_eigen.h>
#include <gsl/gsl_integration.h>
#include <gsl/gsl_monte.h>
#include <gsl/gsl_monte_plain.h>
#include <gsl/gsl_monte_miser.h>
#include <gsl/gsl_monte_vegas.h>
#include <gsl/gsl_min.h>
#include <gsl/gsl_multimin.h>
#include <gsl/gsl_roots.h>
#include <gsl/gsl_multiroots.h>
#include <gsl/gsl_multifit.h>
#include <gsl/gsl_multifit_nlin.h>
#include <gsl/gsl_odeiv.h>
#include <gsl/gsl_sum.h>
#include <gsl/gsl_dht.h>
#include <gsl/gsl_sf_result.h>
#include <gsl/gsl_ntuple.h>
#include <gsl/gsl_poly.h>

#include "include/rb_gsl_types.h"
#include "include/rb_gsl_function.h"
#include "include/rb_gsl_array.h"

/* ============================================================
 * Vector Types
 * ============================================================ */

const rb_data_type_t gsl_vector_data_type = {
    .wrap_struct_name = "GSL::Vector",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_vector_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_vector_view_data_type = {
    .wrap_struct_name = "GSL::Vector::View",
    .function = {
        .dmark = NULL,
        .dfree = RUBY_DEFAULT_FREE,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_vector_int_data_type = {
    .wrap_struct_name = "GSL::Vector::Int",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_vector_int_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_vector_complex_data_type = {
    .wrap_struct_name = "GSL::Vector::Complex",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_vector_complex_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Matrix Types
 * ============================================================ */

const rb_data_type_t gsl_matrix_data_type = {
    .wrap_struct_name = "GSL::Matrix",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_matrix_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_matrix_view_data_type = {
    .wrap_struct_name = "GSL::Matrix::View",
    .function = {
        .dmark = NULL,
        .dfree = RUBY_DEFAULT_FREE,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_matrix_int_data_type = {
    .wrap_struct_name = "GSL::Matrix::Int",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_matrix_int_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_matrix_complex_data_type = {
    .wrap_struct_name = "GSL::Matrix::Complex",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_matrix_complex_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Block Types
 * ============================================================ */

const rb_data_type_t gsl_block_data_type = {
    .wrap_struct_name = "GSL::Block",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_block_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_block_complex_data_type = {
    .wrap_struct_name = "GSL::Block::Complex",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_block_complex_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_block_uchar_data_type = {
    .wrap_struct_name = "GSL::Block::Byte",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_block_uchar_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Permutation & Combination
 * ============================================================ */

const rb_data_type_t gsl_permutation_data_type = {
    .wrap_struct_name = "GSL::Permutation",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_permutation_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_combination_data_type = {
    .wrap_struct_name = "GSL::Combination",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_combination_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_multiset_data_type = {
    .wrap_struct_name = "GSL::Multiset",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_multiset_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Complex
 * ============================================================ */

const rb_data_type_t gsl_complex_data_type = {
    .wrap_struct_name = "GSL::Complex",
    .function = {
        .dmark = NULL,
        .dfree = RUBY_DEFAULT_FREE,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Random Number Generators
 * ============================================================ */

const rb_data_type_t gsl_rng_data_type = {
    .wrap_struct_name = "GSL::Rng",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_rng_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_qrng_data_type = {
    .wrap_struct_name = "GSL::QRng",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_qrng_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_ran_discrete_data_type = {
    .wrap_struct_name = "GSL::Ran::Discrete",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_ran_discrete_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Histogram Types
 * ============================================================ */

const rb_data_type_t gsl_histogram_data_type = {
    .wrap_struct_name = "GSL::Histogram",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_histogram_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_histogram_pdf_data_type = {
    .wrap_struct_name = "GSL::Histogram::Pdf",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_histogram_pdf_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_histogram2d_data_type = {
    .wrap_struct_name = "GSL::Histogram2d",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_histogram2d_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_histogram2d_pdf_data_type = {
    .wrap_struct_name = "GSL::Histogram2d::Pdf",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_histogram2d_pdf_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_histogram2d_view_data_type = {
    .wrap_struct_name = "GSL::Histogram2d::View",
    .function = {
        .dmark = NULL,
        .dfree = RUBY_DEFAULT_FREE,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_histogram3d_data_type = {
    .wrap_struct_name = "GSL::Histogram3d",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))mygsl_histogram3d_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_histogram3d_view_data_type = {
    .wrap_struct_name = "GSL::Histogram3d::View",
    .function = {
        .dmark = NULL,
        .dfree = RUBY_DEFAULT_FREE,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* gsl_vector_view_free is declared in rb_gsl_array.h and defined in vector_double.c */

const rb_data_type_t gsl_histogram_range_data_type = {
    .wrap_struct_name = "GSL::Histogram::Range",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_vector_view_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Interpolation & Splines
 * ============================================================ */

const rb_data_type_t gsl_interp_data_type = {
    .wrap_struct_name = "GSL::Interp",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_interp_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_interp_accel_data_type = {
    .wrap_struct_name = "GSL::Interp::Accel",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_interp_accel_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_spline_data_type = {
    .wrap_struct_name = "GSL::Spline",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_spline_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_bspline_workspace_data_type = {
    .wrap_struct_name = "GSL::BSpline::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_bspline_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * FFT Types
 * ============================================================ */

const rb_data_type_t gsl_fft_complex_wavetable_data_type = {
    .wrap_struct_name = "GSL::FFT::ComplexWavetable",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_fft_complex_wavetable_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_fft_complex_workspace_data_type = {
    .wrap_struct_name = "GSL::FFT::ComplexWorkspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_fft_complex_workspace_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_fft_real_wavetable_data_type = {
    .wrap_struct_name = "GSL::FFT::RealWavetable",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_fft_real_wavetable_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_fft_real_workspace_data_type = {
    .wrap_struct_name = "GSL::FFT::RealWorkspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_fft_real_workspace_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_fft_halfcomplex_wavetable_data_type = {
    .wrap_struct_name = "GSL::FFT::HalfComplexWavetable",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_fft_halfcomplex_wavetable_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Wavelet Types
 * ============================================================ */

const rb_data_type_t gsl_wavelet_data_type = {
    .wrap_struct_name = "GSL::Wavelet",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_wavelet_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_wavelet_workspace_data_type = {
    .wrap_struct_name = "GSL::Wavelet::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_wavelet_workspace_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Chebyshev
 * ============================================================ */

const rb_data_type_t gsl_cheb_series_data_type = {
    .wrap_struct_name = "GSL::Cheb",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_cheb_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Eigen Types
 * ============================================================ */

const rb_data_type_t gsl_eigen_symm_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Symm::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_symm_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_symmv_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Symmv::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_symmv_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_herm_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Herm::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_herm_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_hermv_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Hermv::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_hermv_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_nonsymm_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Nonsymm::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_nonsymm_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_nonsymmv_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Nonsymmv::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_nonsymmv_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_gensymm_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Gensymm::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_gensymm_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_gensymmv_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Gensymmv::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_gensymmv_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_genherm_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Genherm::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_genherm_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_genhermv_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Genhermv::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_genhermv_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_gen_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Gen::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_gen_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_genv_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Genv::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_genv_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_eigen_francis_workspace_data_type = {
    .wrap_struct_name = "GSL::Eigen::Francis::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_eigen_francis_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Integration Types
 * ============================================================ */

const rb_data_type_t gsl_integration_workspace_data_type = {
    .wrap_struct_name = "GSL::Integration::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_integration_workspace_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_integration_qaws_table_data_type = {
    .wrap_struct_name = "GSL::Integration::QAWS_Table",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_integration_qaws_table_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_integration_qawo_table_data_type = {
    .wrap_struct_name = "GSL::Integration::QAWO_Table",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_integration_qawo_table_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_integration_glfixed_table_data_type = {
    .wrap_struct_name = "GSL::Integration::GLFixed_Table",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_integration_glfixed_table_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Monte Carlo Types
 * ============================================================ */

const rb_data_type_t gsl_monte_plain_state_data_type = {
    .wrap_struct_name = "GSL::Monte::Plain",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_monte_plain_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_monte_miser_state_data_type = {
    .wrap_struct_name = "GSL::Monte::Miser",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_monte_miser_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_monte_vegas_state_data_type = {
    .wrap_struct_name = "GSL::Monte::Vegas",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_monte_vegas_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_monte_miser_params_data_type = {
    .wrap_struct_name = "GSL::Monte::Miser::Params",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_monte_vegas_params_data_type = {
    .wrap_struct_name = "GSL::Monte::Vegas::Params",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Minimization Types
 * ============================================================ */

const rb_data_type_t gsl_min_fminimizer_data_type = {
    .wrap_struct_name = "GSL::Min::FMinimizer",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_min_fminimizer_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_multimin_fminimizer_data_type = {
    .wrap_struct_name = "GSL::MultiMin::FMinimizer",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_multimin_fminimizer_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_multimin_fdfminimizer_data_type = {
    .wrap_struct_name = "GSL::MultiMin::FdfMinimizer",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_multimin_fdfminimizer_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Root Finding Types
 * ============================================================ */

const rb_data_type_t gsl_root_fsolver_data_type = {
    .wrap_struct_name = "GSL::Root::FSolver",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_root_fsolver_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_root_fdfsolver_data_type = {
    .wrap_struct_name = "GSL::Root::FdfSolver",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_root_fdfsolver_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_multiroot_fsolver_data_type = {
    .wrap_struct_name = "GSL::MultiRoot::FSolver",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_multiroot_fsolver_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_multiroot_fdfsolver_data_type = {
    .wrap_struct_name = "GSL::MultiRoot::FdfSolver",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_multiroot_fdfsolver_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Polynomial Types
 * ============================================================ */

const rb_data_type_t gsl_poly_complex_workspace_data_type = {
    .wrap_struct_name = "GSL::Poly::Complex::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_poly_complex_workspace_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Fitting Types
 * ============================================================ */

const rb_data_type_t gsl_multifit_linear_workspace_data_type = {
    .wrap_struct_name = "GSL::MultiFit::Workspace",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_multifit_linear_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_multifit_fdfsolver_data_type = {
    .wrap_struct_name = "GSL::MultiFit::FdfSolver",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_multifit_fdfsolver_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_multifit_function_fdf_data_type = {
    .wrap_struct_name = "GSL::MultiFit::Function_fdf",
    .function = {
        .dmark = NULL,
        .dfree = NULL,  /* Not owned by Ruby - owned by solver */
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * ODE Types
 * ============================================================ */

const rb_data_type_t gsl_odeiv_step_data_type = {
    .wrap_struct_name = "GSL::Odeiv::Step",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_odeiv_step_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_odeiv_control_data_type = {
    .wrap_struct_name = "GSL::Odeiv::Control",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_odeiv_control_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_odeiv_evolve_data_type = {
    .wrap_struct_name = "GSL::Odeiv::Evolve",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_odeiv_evolve_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_odeiv_system_data_type = {
    .wrap_struct_name = "GSL::Odeiv::System",
    .function = {
        .dmark = NULL,
        .dfree = NULL,  /* Not owned by Ruby - owned by solver */
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Summation Types
 * ============================================================ */

const rb_data_type_t gsl_sum_levin_u_workspace_data_type = {
    .wrap_struct_name = "GSL::Sum::Levin_u",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_sum_levin_u_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_sum_levin_utrunc_workspace_data_type = {
    .wrap_struct_name = "GSL::Sum::Levin_utrunc",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_sum_levin_utrunc_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * DHT Types
 * ============================================================ */

const rb_data_type_t gsl_dht_data_type = {
    .wrap_struct_name = "GSL::DHT",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_dht_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * GSL Function Types
 * ============================================================ */

const rb_data_type_t gsl_function_data_type = {
    .wrap_struct_name = "GSL::Function",
    .function = {
        .dmark = (void (*)(void *))gsl_function_mark,
        .dfree = (void (*)(void *))gsl_function_free,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * Special Function Result Types
 * ============================================================ */

const rb_data_type_t gsl_sf_result_data_type = {
    .wrap_struct_name = "GSL::Sf::Result",
    .function = {
        .dmark = NULL,
        .dfree = RUBY_DEFAULT_FREE,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

const rb_data_type_t gsl_sf_result_e10_data_type = {
    .wrap_struct_name = "GSL::Sf::Result_e10",
    .function = {
        .dmark = NULL,
        .dfree = RUBY_DEFAULT_FREE,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

/* ============================================================
 * N-Tuple Types
 * ============================================================ */

const rb_data_type_t gsl_ntuple_data_type = {
    .wrap_struct_name = "GSL::NTuple",
    .function = {
        .dmark = NULL,
        .dfree = (void (*)(void *))gsl_ntuple_close,
        .dsize = NULL,
    },
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};
