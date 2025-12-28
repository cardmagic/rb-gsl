#!/usr/bin/env ruby
#
# TypedData Migration Script
# Consolidated script for migrating rb-gsl to TypedData API
#
# Usage:
#   ruby scripts/migrate_typeddata.rb --analyze
#   ruby scripts/migrate_typeddata.rb --generate-header
#   ruby scripts/migrate_typeddata.rb --migrate FILE.c
#   ruby scripts/migrate_typeddata.rb --apply FILE.c
#   ruby scripts/migrate_typeddata.rb --apply-all
#   ruby scripts/migrate_typeddata.rb --verify

require 'set'
require 'fileutils'

EXT_DIR = File.join(__dir__, '..', 'ext', 'gsl_native')

class TypedDataMigrator
  # Extended mapping from C struct type to class variable
  STRUCT_TO_CLASS = {
    # Core types
    'gsl_rng' => 'cgsl_rng',
    'gsl_vector' => 'cgsl_vector',
    'gsl_vector_view' => 'cgsl_vector_view',
    'gsl_vector_complex' => 'cgsl_vector_complex',
    'gsl_vector_complex_view' => 'cgsl_vector_complex_view',
    'gsl_vector_int' => 'cgsl_vector_int',
    'gsl_vector_int_view' => 'cgsl_vector_int_view',
    'gsl_matrix' => 'cgsl_matrix',
    'gsl_matrix_view' => 'cgsl_matrix_view',
    'gsl_matrix_complex' => 'cgsl_matrix_complex',
    'gsl_matrix_complex_view' => 'cgsl_matrix_complex_view',
    'gsl_matrix_int' => 'cgsl_matrix_int',
    'gsl_permutation' => 'cgsl_permutation',
    'gsl_combination' => 'cgsl_combination',
    'gsl_complex' => 'cgsl_complex',
    'gsl_block' => 'cgsl_block',
    'gsl_block_complex' => 'cgsl_block_complex',

    # Histogram
    'gsl_histogram' => 'cgsl_histogram',
    'gsl_histogram_pdf' => 'cgsl_histogram_pdf',
    'gsl_histogram2d' => 'cgsl_histogram2d',
    'gsl_histogram2d_pdf' => 'cgsl_histogram2d_pdf',
    'mygsl_histogram3d' => 'cgsl_histogram3d',

    # Interpolation
    'gsl_interp' => 'cgsl_interp',
    'gsl_interp_accel' => 'cgsl_interp_accel',
    'gsl_spline' => 'cgsl_spline',
    'rb_gsl_interp' => 'cgsl_interp',
    'rb_gsl_spline' => 'cgsl_spline',
    'gsl_interp2d' => 'cgsl_interp2d',
    'gsl_spline2d' => 'cgsl_spline2d',
    'gsl_bspline_workspace' => 'cgsl_bspline_workspace',

    # Special functions
    'gsl_sf_result' => 'cgsl_sf_result',
    'gsl_sf_result_e10' => 'cgsl_sf_result_e10',

    # Integration
    'gsl_integration_workspace' => 'cgsl_integration_workspace',
    'gsl_integration_qaws_table' => 'cgsl_integration_qaws_table',
    'gsl_integration_qawo_table' => 'cgsl_integration_qawo_table',
    'gsl_integration_glfixed_table' => 'cgsl_integration_glfixed_table',

    # Monte Carlo
    'gsl_monte_function' => 'cgsl_monte_function',
    'gsl_monte_plain_state' => 'cgsl_monte_plain',
    'gsl_monte_miser_state' => 'cgsl_monte_miser',
    'gsl_monte_vegas_state' => 'cgsl_monte_vegas',

    # Fitting
    'gsl_multifit_linear_workspace' => 'cgsl_multifit_workspace',
    'gsl_multifit_fdfsolver' => 'cgsl_multifit_fdfsolver',
    'gsl_multifit_fsolver' => 'cgsl_multifit_fsolver',
    'gsl_multifit_function_fdf' => 'cgsl_multifit_function_fdf',

    # Minimization
    'gsl_multimin_fdfminimizer' => 'cgsl_multimin_fdfminimizer',
    'gsl_multimin_fminimizer' => 'cgsl_multimin_fminimizer',
    'gsl_min_fminimizer' => 'cgsl_min_fminimizer',

    # Root finding
    'gsl_multiroot_fsolver' => 'cgsl_multiroot_fsolver',
    'gsl_multiroot_fdfsolver' => 'cgsl_multiroot_fdfsolver',
    'gsl_multiroot_function' => 'cgsl_multiroot_function',
    'gsl_multiroot_function_fdf' => 'cgsl_multiroot_function_fdf',
    'gsl_root_fsolver' => 'cgsl_root_fsolver',
    'gsl_root_fdfsolver' => 'cgsl_root_fdfsolver',

    # ODE
    'gsl_odeiv_step' => 'cgsl_odeiv_step',
    'gsl_odeiv_control' => 'cgsl_odeiv_control',
    'gsl_odeiv_evolve' => 'cgsl_odeiv_evolve',
    'gsl_odeiv_system' => 'cgsl_odeiv_system',
    'gsl_odeiv_solver' => 'cgsl_odeiv_solver',

    # Summation
    'gsl_sum_levin_u_workspace' => 'cgsl_sum_levin_u',
    'gsl_sum_levin_utrunc_workspace' => 'cgsl_sum_levin_utrunc',

    # Wavelets
    'gsl_wavelet' => 'cgsl_wavelet',
    'gsl_wavelet_workspace' => 'cgsl_wavelet_workspace',

    # Chebyshev
    'gsl_cheb_series' => 'cgsl_cheb',

    # FFT
    'gsl_fft_complex_wavetable' => 'cgsl_fft_complex_wavetable',
    'gsl_fft_complex_workspace' => 'cgsl_fft_complex_workspace',
    'gsl_fft_real_wavetable' => 'cgsl_fft_real_wavetable',
    'gsl_fft_real_workspace' => 'cgsl_fft_real_workspace',
    'gsl_fft_halfcomplex_wavetable' => 'cgsl_fft_halfcomplex_wavetable',

    # Eigen
    'gsl_eigen_symm_workspace' => 'cgsl_eigen_symm_workspace',
    'gsl_eigen_symmv_workspace' => 'cgsl_eigen_symmv_workspace',
    'gsl_eigen_herm_workspace' => 'cgsl_eigen_herm_workspace',
    'gsl_eigen_hermv_workspace' => 'cgsl_eigen_hermv_workspace',
    'gsl_eigen_nonsymm_workspace' => 'cgsl_eigen_nonsymm_workspace',
    'gsl_eigen_nonsymmv_workspace' => 'cgsl_eigen_nonsymmv_workspace',
    'gsl_eigen_gensymm_workspace' => 'cgsl_eigen_gensymm_workspace',
    'gsl_eigen_gensymmv_workspace' => 'cgsl_eigen_gensymmv_workspace',
    'gsl_eigen_genherm_workspace' => 'cgsl_eigen_genherm_workspace',
    'gsl_eigen_genhermv_workspace' => 'cgsl_eigen_genhermv_workspace',
    'gsl_eigen_gen_workspace' => 'cgsl_eigen_gen_workspace',
    'gsl_eigen_genv_workspace' => 'cgsl_eigen_genv_workspace',
    'gsl_eigen_francis_workspace' => 'cgsl_eigen_francis_workspace',

    # Misc
    'gsl_function' => 'cgsl_function',
    'gsl_function_fdf' => 'cgsl_function_fdf',
    'gsl_multiset' => 'cgsl_multiset',
    'gsl_dht' => 'cgsl_dht',
    'gsl_qrng' => 'cgsl_qrng',
    'gsl_ntuple' => 'cgsl_ntuple',
    'gsl_rational' => 'cgsl_rational',
    'gsl_siman_params_t' => 'cgsl_siman_params',
    'gsl_ran_discrete_t' => 'cgsl_ran_discrete',
    'gsl_poly' => 'cgsl_poly',

    # OOL
    'ool_conmin_minimizer' => 'cgsl_ool_conmin_minimizer',
    'ool_conmin_function' => 'cgsl_ool_conmin_function',
    'ool_conmin_constraint' => 'cgsl_ool_conmin_constraint',

    # CQP
    'gsl_cqp_data' => 'cgsl_cqp_data',
    'gsl_cqpminimizer' => 'cgsl_cqpminimizer',

    # Jacobi
    'jac_quadrature' => 'cgsl_jacobi',

    # Mathieu
    'gsl_sf_mathieu_workspace' => 'cgsl_sf_mathieu_workspace',

    # ALF
    'alf_workspace' => 'cgsl_alf_workspace',

    # NTuple
    'gsl_ntuple_value_fn' => 'cgsl_ntuple_value_fn',
    'gsl_ntuple_select_fn' => 'cgsl_ntuple_select_fn',
  }.freeze

  # Direct struct type to data type mapping for Data_Get_Struct
  # This avoids relying on the dynamically built @class_to_type
  STRUCT_TO_TYPE = {
    # Core types
    'gsl_vector' => 'gsl_vector_data_type',
    'gsl_vector_view' => 'gsl_vector_view_data_type',
    'gsl_vector_complex' => 'gsl_vector_complex_data_type',
    'gsl_vector_int' => 'gsl_vector_int_data_type',
    'gsl_matrix' => 'gsl_matrix_data_type',
    'gsl_matrix_view' => 'gsl_matrix_view_data_type',
    'gsl_matrix_complex' => 'gsl_matrix_complex_data_type',
    'gsl_matrix_int' => 'gsl_matrix_int_data_type',
    'gsl_permutation' => 'gsl_permutation_data_type',
    'gsl_combination' => 'gsl_combination_data_type',
    'gsl_multiset' => 'gsl_multiset_data_type',
    'gsl_complex' => 'gsl_complex_data_type',
    'gsl_block' => 'gsl_block_data_type',
    'gsl_block_complex' => 'gsl_block_complex_data_type',
    # Random
    'gsl_rng' => 'gsl_rng_data_type',
    'gsl_qrng' => 'gsl_qrng_data_type',
    'gsl_ran_discrete_t' => 'gsl_ran_discrete_data_type',
    # Histogram
    'gsl_histogram' => 'gsl_histogram_data_type',
    'gsl_histogram_pdf' => 'gsl_histogram_pdf_data_type',
    'gsl_histogram2d' => 'gsl_histogram2d_data_type',
    'gsl_histogram2d_pdf' => 'gsl_histogram2d_pdf_data_type',
    # Interpolation
    'gsl_interp' => 'gsl_interp_data_type',
    'gsl_interp_accel' => 'gsl_interp_accel_data_type',
    'gsl_spline' => 'gsl_spline_data_type',
    'gsl_bspline_workspace' => 'gsl_bspline_workspace_data_type',
    # FFT
    'gsl_fft_complex_wavetable' => 'gsl_fft_complex_wavetable_data_type',
    'gsl_fft_complex_workspace' => 'gsl_fft_complex_workspace_data_type',
    'gsl_fft_real_wavetable' => 'gsl_fft_real_wavetable_data_type',
    'gsl_fft_real_workspace' => 'gsl_fft_real_workspace_data_type',
    'gsl_fft_halfcomplex_wavetable' => 'gsl_fft_halfcomplex_wavetable_data_type',
    # Wavelet
    'gsl_wavelet' => 'gsl_wavelet_data_type',
    'gsl_wavelet_workspace' => 'gsl_wavelet_workspace_data_type',
    # Chebyshev
    'gsl_cheb_series' => 'gsl_cheb_series_data_type',
    # Eigen
    'gsl_eigen_symm_workspace' => 'gsl_eigen_symm_workspace_data_type',
    'gsl_eigen_symmv_workspace' => 'gsl_eigen_symmv_workspace_data_type',
    'gsl_eigen_herm_workspace' => 'gsl_eigen_herm_workspace_data_type',
    'gsl_eigen_hermv_workspace' => 'gsl_eigen_hermv_workspace_data_type',
    'gsl_eigen_nonsymm_workspace' => 'gsl_eigen_nonsymm_workspace_data_type',
    'gsl_eigen_nonsymmv_workspace' => 'gsl_eigen_nonsymmv_workspace_data_type',
    'gsl_eigen_gensymm_workspace' => 'gsl_eigen_gensymm_workspace_data_type',
    'gsl_eigen_gensymmv_workspace' => 'gsl_eigen_gensymmv_workspace_data_type',
    'gsl_eigen_genherm_workspace' => 'gsl_eigen_genherm_workspace_data_type',
    'gsl_eigen_genhermv_workspace' => 'gsl_eigen_genhermv_workspace_data_type',
    'gsl_eigen_gen_workspace' => 'gsl_eigen_gen_workspace_data_type',
    'gsl_eigen_genv_workspace' => 'gsl_eigen_genv_workspace_data_type',
    'gsl_eigen_francis_workspace' => 'gsl_eigen_francis_workspace_data_type',
    # Integration
    'gsl_integration_workspace' => 'gsl_integration_workspace_data_type',
    'gsl_integration_qaws_table' => 'gsl_integration_qaws_table_data_type',
    'gsl_integration_qawo_table' => 'gsl_integration_qawo_table_data_type',
    'gsl_integration_glfixed_table' => 'gsl_integration_glfixed_table_data_type',
    # Monte Carlo
    'gsl_monte_plain_state' => 'gsl_monte_plain_state_data_type',
    'gsl_monte_miser_state' => 'gsl_monte_miser_state_data_type',
    'gsl_monte_vegas_state' => 'gsl_monte_vegas_state_data_type',
    # Minimization
    'gsl_min_fminimizer' => 'gsl_min_fminimizer_data_type',
    'gsl_multimin_fminimizer' => 'gsl_multimin_fminimizer_data_type',
    'gsl_multimin_fdfminimizer' => 'gsl_multimin_fdfminimizer_data_type',
    # Root finding
    'gsl_root_fsolver' => 'gsl_root_fsolver_data_type',
    'gsl_root_fdfsolver' => 'gsl_root_fdfsolver_data_type',
    'gsl_multiroot_fsolver' => 'gsl_multiroot_fsolver_data_type',
    'gsl_multiroot_fdfsolver' => 'gsl_multiroot_fdfsolver_data_type',
    # Fitting
    'gsl_multifit_linear_workspace' => 'gsl_multifit_linear_workspace_data_type',
    'gsl_multifit_fdfsolver' => 'gsl_multifit_fdfsolver_data_type',
    'gsl_multifit_function_fdf' => 'gsl_multifit_function_fdf_data_type',
    # ODE
    'gsl_odeiv_step' => 'gsl_odeiv_step_data_type',
    'gsl_odeiv_control' => 'gsl_odeiv_control_data_type',
    'gsl_odeiv_evolve' => 'gsl_odeiv_evolve_data_type',
    'gsl_odeiv_system' => 'gsl_odeiv_system_data_type',
    # Summation
    'gsl_sum_levin_u_workspace' => 'gsl_sum_levin_u_workspace_data_type',
    'gsl_sum_levin_utrunc_workspace' => 'gsl_sum_levin_utrunc_workspace_data_type',
    # DHT
    'gsl_dht' => 'gsl_dht_data_type',
    # GSL Function
    'gsl_function' => 'gsl_function_data_type',
    'gsl_function_fdf' => 'gsl_function_fdf_data_type',
    # Multi-root Functions
    'gsl_multiroot_function' => 'gsl_multiroot_function_data_type',
    'gsl_multiroot_function_fdf' => 'gsl_multiroot_function_fdf_data_type',
    # Multi-min Functions
    'gsl_multimin_function' => 'gsl_multimin_function_data_type',
    'gsl_multimin_function_fdf' => 'gsl_multimin_function_fdf_data_type',
    # Interpolation wrappers
    'rb_gsl_interp' => 'rb_gsl_interp_data_type',
    'rb_gsl_spline' => 'rb_gsl_spline_data_type',
    # Special Functions
    'gsl_sf_result' => 'gsl_sf_result_data_type',
    'gsl_sf_result_e10' => 'gsl_sf_result_e10_data_type',
    # N-Tuple
    'gsl_ntuple' => 'gsl_ntuple_data_type',
  }.freeze

  # Patterns that need manual handling - completely skip these
  # Note: klass and CLASS_OF are now handled via FREE_FUNCTION_TO_TYPE
  SKIP_PATTERNS = /^(GSL_TYPE|QUALIFIED_VIEW|CONCAT|FUNCTION)\(/

  # Classes without corresponding data types - skip these
  SKIP_CLASSES = %w[
    cgsl_poly_int
    cgsl_index
    cgsl_permutation_luc
  ].freeze

  # Runtime class patterns that can be handled with known data types
  # Maps the macro/class pattern to its data type
  RUNTIME_CLASS_TO_TYPE = {
    # Vector types
    'VECTOR_ROW_COL(obj)' => 'gsl_vector_data_type',
    'VECTOR_ROW_COL(argv[0])' => 'gsl_vector_data_type',
    'VEC_ROW_COL(obj)' => 'gsl_vector_data_type',
    'VEC_ROW_COL(argv[0])' => 'gsl_vector_data_type',
    # Vector int types
    'VECTOR_INT_ROW_COL(obj)' => 'gsl_vector_int_data_type',
    'VECTOR_INT_ROW_COL(argv[0])' => 'gsl_vector_int_data_type',
    # Vector complex types
    'VECTOR_COMPLEX_ROW_COL(obj)' => 'gsl_vector_complex_data_type',
    'VECTOR_COMPLEX_ROW_COL(argv[0])' => 'gsl_vector_complex_data_type',
    # Matrix types
    'MATRIX_ROW_COL(obj)' => 'gsl_matrix_data_type',
    'MATRIX_ROW_COL(argv[0])' => 'gsl_matrix_data_type',
    'MATRIX_INT_ROW_COL(obj)' => 'gsl_matrix_int_data_type',
    'MATRIX_COMPLEX_ROW_COL(obj)' => 'gsl_matrix_complex_data_type',
  }.freeze

  # Pattern to detect runtime class macros that we don't have a mapping for
  RUNTIME_CLASS_MACRO_PATTERN = /^(VECTOR|MATRIX|VEC).*ROW_COL\(/

  # Free function to data type mapping - for klass/CLASS_OF patterns
  FREE_FUNCTION_TO_TYPE = {
    # Histogram
    'gsl_histogram_free' => 'gsl_histogram_data_type',
    'gsl_histogram_pdf_free' => 'gsl_histogram_pdf_data_type',
    'gsl_histogram2d_free' => 'gsl_histogram2d_data_type',
    'gsl_histogram2d_pdf_free' => 'gsl_histogram2d_pdf_data_type',
    # ODE
    'gsl_odeiv_step_free' => 'gsl_odeiv_step_data_type',
    'gsl_odeiv_control_free' => 'gsl_odeiv_control_data_type',
    'gsl_odeiv_evolve_free' => 'gsl_odeiv_evolve_data_type',
    # Root finding
    'gsl_root_fsolver_free' => 'gsl_root_fsolver_data_type',
    'gsl_root_fdfsolver_free' => 'gsl_root_fdfsolver_data_type',
    'gsl_multiroot_fsolver_free' => 'gsl_multiroot_fsolver_data_type',
    'gsl_multiroot_fdfsolver_free' => 'gsl_multiroot_fdfsolver_data_type',
    # Minimization
    'gsl_min_fminimizer_free' => 'gsl_min_fminimizer_data_type',
    'gsl_multimin_fminimizer_free' => 'gsl_multimin_fminimizer_data_type',
    'gsl_multimin_fdfminimizer_free' => 'gsl_multimin_fdfminimizer_data_type',
    # Fitting
    'gsl_multifit_linear_free' => 'gsl_multifit_linear_workspace_data_type',
    'gsl_multifit_fdfsolver_free' => 'gsl_multifit_fdfsolver_data_type',
    'gsl_multifit_fsolver_free' => 'gsl_multifit_fsolver_data_type',
    # Interpolation
    'gsl_interp_free' => 'gsl_interp_data_type',
    'gsl_interp_accel_free' => 'gsl_interp_accel_data_type',
    'gsl_spline_free' => 'gsl_spline_data_type',
    'gsl_bspline_free' => 'gsl_bspline_workspace_data_type',
    # Integration
    'gsl_integration_workspace_free' => 'gsl_integration_workspace_data_type',
    'gsl_integration_qaws_table_free' => 'gsl_integration_qaws_table_data_type',
    'gsl_integration_qawo_table_free' => 'gsl_integration_qawo_table_data_type',
    'gsl_integration_glfixed_table_free' => 'gsl_integration_glfixed_table_data_type',
    # Random
    'gsl_rng_free' => 'gsl_rng_data_type',
    'gsl_qrng_free' => 'gsl_qrng_data_type',
    'gsl_ran_discrete_free' => 'gsl_ran_discrete_data_type',
    # Combination/Multiset
    'gsl_combination_free' => 'gsl_combination_data_type',
    'gsl_multiset_free' => 'gsl_multiset_data_type',
    # Vectors and matrices
    'gsl_vector_free' => 'gsl_vector_data_type',
    'gsl_vector_int_free' => 'gsl_vector_int_data_type',
    'gsl_vector_complex_free' => 'gsl_vector_complex_data_type',
    'gsl_matrix_free' => 'gsl_matrix_data_type',
    'gsl_matrix_int_free' => 'gsl_matrix_int_data_type',
    'gsl_matrix_complex_free' => 'gsl_matrix_complex_data_type',
    # Summation
    'gsl_sum_levin_u_free' => 'gsl_sum_levin_u_workspace_data_type',
    'gsl_sum_levin_utrunc_free' => 'gsl_sum_levin_utrunc_workspace_data_type',
    # Wavelets
    'gsl_wavelet_free' => 'gsl_wavelet_data_type',
    'gsl_wavelet_workspace_free' => 'gsl_wavelet_workspace_data_type',
    # FFT
    'gsl_fft_complex_wavetable_free' => 'gsl_fft_complex_wavetable_data_type',
    'gsl_fft_complex_workspace_free' => 'gsl_fft_complex_workspace_data_type',
    'gsl_fft_real_wavetable_free' => 'gsl_fft_real_wavetable_data_type',
    'gsl_fft_real_workspace_free' => 'gsl_fft_real_workspace_data_type',
    'gsl_fft_halfcomplex_wavetable_free' => 'gsl_fft_halfcomplex_wavetable_data_type',
    # DHT
    'gsl_dht_free' => 'gsl_dht_data_type',
    # Chebyshev
    'gsl_cheb_free' => 'gsl_cheb_series_data_type',
    # NTuple
    'gsl_ntuple_close' => 'gsl_ntuple_data_type',
    # Note: siman, mathieu, alf don't have types defined yet
  }.freeze

  # Runtime class patterns
  RUNTIME_PATTERNS = {
    'klass' => :alloc_function,
    'CLASS_OF(obj)' => :clone_dup,
    'CLASS_OF(h1)' => :clone_dup,
    'CLASS_OF(argv[0])' => :clone_dup,
  }.freeze

  def initialize
    @class_to_type = {}
    @class_to_free = {}
    extract_class_info
  end

  def extract_class_info
    Dir.glob(File.join(EXT_DIR, '*.c')).each do |file|
      content = File.read(file)
      content.scan(/Data_Wrap_Struct\s*\(\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,/) do |cls, mark, free|
        cls = cls.strip
        next if cls =~ SKIP_PATTERNS
        next if RUNTIME_PATTERNS[cls]

        @class_to_type[cls] ||= "#{cls.sub(/^c/, '')}_data_type"
        @class_to_free[cls] ||= free.strip
      end
    end
  end

  def analyze
    total_wrap = 0
    total_get = 0
    fixable_wrap = 0
    fixable_get = 0
    runtime_wrap = 0
    macro_wrap = 0

    file_stats = {}

    Dir.glob(File.join(EXT_DIR, '*.c')).each do |file|
      content = File.read(file)
      basename = File.basename(file)
      file_stats[basename] = { wrap: 0, get: 0, fixable: 0, runtime: 0, macro: 0 }

      content.scan(/Data_Wrap_Struct\s*\(\s*([^,]+)/) do |m|
        cls = m[0].strip
        total_wrap += 1
        file_stats[basename][:wrap] += 1

        if RUNTIME_PATTERNS[cls]
          runtime_wrap += 1
          file_stats[basename][:runtime] += 1
        elsif cls =~ SKIP_PATTERNS
          macro_wrap += 1
          file_stats[basename][:macro] += 1
        elsif @class_to_type[cls]
          fixable_wrap += 1
          file_stats[basename][:fixable] += 1
        end
      end

      content.scan(/Data_Get_Struct\s*\(\s*[^,]+\s*,\s*([^,]+)/) do |m|
        ctype = m[0].strip
        total_get += 1
        file_stats[basename][:get] += 1
        if STRUCT_TO_CLASS[ctype]
          fixable_get += 1
          file_stats[basename][:fixable] += 1
        end
      end
    end

    total = total_wrap + total_get
    fixable = fixable_wrap + fixable_get

    puts "=" * 70
    puts "TypedData Migration Analysis"
    puts "=" * 70
    puts
    puts "Data_Wrap_Struct: #{total_wrap}"
    puts "  Automatable (static class):  #{fixable_wrap}"
    puts "  Runtime class (klass etc):   #{runtime_wrap}"
    puts "  Macro-based:                 #{macro_wrap}"
    puts "  Other:                       #{total_wrap - fixable_wrap - runtime_wrap - macro_wrap}"
    puts
    puts "Data_Get_Struct: #{total_get}"
    puts "  Automatable:                 #{fixable_get}"
    puts "  Manual (no mapping):         #{total_get - fixable_get}"
    puts
    puts "=" * 70
    puts "AUTOMATABLE: #{fixable}/#{total} (#{(fixable.to_f / total * 100).round(1)}%)"
    puts "=" * 70
    puts
    puts "Top 15 files by occurrence:"
    puts "%-30s %6s %6s %8s %8s %6s" % %w[File Wrap Get Fixable Runtime Macro]
    puts "-" * 70

    file_stats.sort_by { |_, s| -(s[:wrap] + s[:get]) }.first(15).each do |file, stats|
      next if stats[:wrap] + stats[:get] == 0
      puts "%-30s %6d %6d %8d %8d %6d" % [
        file, stats[:wrap], stats[:get], stats[:fixable], stats[:runtime], stats[:macro]
      ]
    end
  end

  def generate_header
    puts <<~HEADER
      /*
       * rb_gsl_types.h
       * TypedData type definitions for rb-gsl
       * Auto-generated by scripts/migrate_typeddata.rb
       */

      #ifndef RB_GSL_TYPES_H
      #define RB_GSL_TYPES_H

      #include <ruby.h>

      /* Helper macros */
      #define GSL_GET_STRUCT(obj, type, var) \\
          TypedData_Get_Struct(obj, type, &type##_data_type, var)

      #define GSL_WRAP_STRUCT(klass, type, ptr) \\
          TypedData_Wrap_Struct(klass, &type##_data_type, ptr)

      /*
       * Type definitions
       * Each GSL wrapper class needs a corresponding rb_data_type_t
       */

    HEADER

    @class_to_type.sort.each do |class_var, type_name|
      free_func = @class_to_free[class_var]
      next if free_func =~ /\(|argv/

      dfree = case free_func
              when '0', 'NULL' then 'RUBY_DEFAULT_FREE'
              when 'free' then 'ruby_xfree'
              else "(void (*)(void *))#{free_func}"
              end

      struct_name = class_var.sub(/^c/, '').gsub('_', '::')

      puts <<~TYPE
        static const rb_data_type_t #{type_name} = {
            .wrap_struct_name = "#{struct_name}",
            .function = {
                .dmark = NULL,
                .dfree = #{dfree},
                .dsize = NULL,
            },
            .flags = RUBY_TYPED_FREE_IMMEDIATELY,
        };

      TYPE
    end

    puts "#endif /* RB_GSL_TYPES_H */"
  end

  def migrate_file(filename, apply: false)
    filepath = File.join(EXT_DIR, filename)
    unless File.exist?(filepath)
      puts "File not found: #{filepath}"
      return false
    end

    content = File.read(filepath)
    original = content.dup
    changes = []

    # Helper to match balanced parentheses for a single argument
    # Returns the argument and the position after it
    def extract_arg(str, start_pos)
      depth = 0
      pos = start_pos
      arg_start = pos

      # Skip leading whitespace
      while pos < str.length && str[pos] =~ /\s/
        pos += 1
        arg_start = pos
      end

      while pos < str.length
        char = str[pos]
        case char
        when '('
          depth += 1
        when ')'
          if depth == 0
            return [str[arg_start...pos].strip, pos]
          end
          depth -= 1
        when ','
          if depth == 0
            return [str[arg_start...pos].strip, pos + 1]
          end
        end
        pos += 1
      end
      [str[arg_start...pos].strip, pos]
    end

    # Replace Data_Wrap_Struct - use line-by-line to avoid cross-line issues
    new_lines = []
    content.each_line do |line|
      # Skip lines that already have TypedData
      if line.include?('TypedData_Wrap_Struct') || line.include?('TypedData_Get_Struct')
        new_lines << line
        next
      end

      # Process Data_Wrap_Struct
      if line =~ /Data_Wrap_Struct\s*\(/
        line = line.gsub(/Data_Wrap_Struct\s*\(\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^);]+)\s*\)/) do |match|
          cls = $1.strip
          mark = $2.strip
          free = $3.strip
          ptr = $4.strip

          # Skip if already looks like TypedData format
          if mark.include?('&') || mark.include?('data_type')
            match
          # Skip complete skip patterns
          elsif cls =~ SKIP_PATTERNS
            match
          # Skip classes without data types
          elsif SKIP_CLASSES.include?(cls)
            match
          # Handle runtime class macros with known types
          elsif runtime_type = RUNTIME_CLASS_TO_TYPE[cls]
            new_code = "TypedData_Wrap_Struct(#{cls}, &#{runtime_type}, #{ptr})"
            changes << { type: :wrap, old: match.strip, new: new_code }
            new_code
          # Skip unknown runtime class macros (we don't have a mapping for them)
          elsif cls =~ RUNTIME_CLASS_MACRO_PATTERN
            match
          # Handle klass/CLASS_OF patterns via free function
          elsif cls == 'klass' || cls.start_with?('CLASS_OF')
            if data_type = FREE_FUNCTION_TO_TYPE[free]
              new_code = "TypedData_Wrap_Struct(#{cls}, &#{data_type}, #{ptr})"
              changes << { type: :wrap, old: match.strip, new: new_code }
              new_code
            else
              match  # Unknown free function, skip
            end
          # Handle static class mappings
          elsif type = @class_to_type[cls]
            new_code = "TypedData_Wrap_Struct(#{cls}, &#{type}, #{ptr})"
            changes << { type: :wrap, old: match.strip, new: new_code }
            new_code
          else
            match
          end
        end
      end

      # Process Data_Get_Struct
      if line =~ /Data_Get_Struct\s*\(/
        line = line.gsub(/Data_Get_Struct\s*\(\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^);]+)\s*\)/) do |match|
          obj = $1.strip
          ctype = $2.strip
          ptr = $3.strip

          # Skip if ptr already contains a type reference (already migrated)
          if ptr.include?('&') || ptr.include?('data_type')
            match
          # Use direct STRUCT_TO_TYPE mapping first
          elsif type = STRUCT_TO_TYPE[ctype]
            new_code = "TypedData_Get_Struct(#{obj}, #{ctype}, &#{type}, #{ptr})"
            changes << { type: :get, old: match.strip, new: new_code }
            new_code
          # Fall back to STRUCT_TO_CLASS -> @class_to_type
          elsif class_var = STRUCT_TO_CLASS[ctype]
            if type = @class_to_type[class_var]
              new_code = "TypedData_Get_Struct(#{obj}, #{ctype}, &#{type}, #{ptr})"
              changes << { type: :get, old: match.strip, new: new_code }
              new_code
            else
              match
            end
          else
            match
          end
        end
      end

      new_lines << line
    end

    content = new_lines.join

    puts "File: #{filename}"
    puts "Changes: #{changes.size}"

    if changes.any?
      puts "\nPreview (first 5):"
      changes.first(5).each_with_index do |c, i|
        puts "  #{i + 1}. [#{c[:type]}]"
        puts "     - #{c[:old][0, 70]}#{c[:old].length > 70 ? '...' : ''}"
        puts "     + #{c[:new][0, 70]}#{c[:new].length > 70 ? '...' : ''}"
      end

      if apply
        File.write(filepath, content)
        puts "\nApplied #{changes.size} changes to #{filename}"
        return true
      else
        puts "\nRun with --apply #{filename} to apply changes"
      end
    else
      puts "No automatable changes (may have runtime/macro patterns)"
    end
    false
  end

  def apply_all
    migrated = []
    Dir.glob(File.join(EXT_DIR, '*.c')).each do |file|
      basename = File.basename(file)
      if migrate_file(basename, apply: true)
        migrated << basename
      end
    end
    puts "\n" + "=" * 70
    puts "Migrated #{migrated.size} files"
    migrated
  end

  def verify
    remaining_wrap = 0
    remaining_get = 0
    files_with_legacy = []

    Dir.glob(File.join(EXT_DIR, '*.c')).each do |file|
      content = File.read(file)
      basename = File.basename(file)

      # Count only non-TypedData versions
      wrap_count = content.scan(/(?<!Typed)Data_Wrap_Struct/).size
      get_count = content.scan(/(?<!Typed)Data_Get_Struct/).size

      if wrap_count > 0 || get_count > 0
        files_with_legacy << [basename, wrap_count, get_count]
        remaining_wrap += wrap_count
        remaining_get += get_count
      end
    end

    puts "=" * 70
    puts "Verification Report"
    puts "=" * 70

    if files_with_legacy.empty?
      puts "\nNo legacy Data_Wrap_Struct or Data_Get_Struct found!"
      puts "Migration complete."
    else
      puts "\nRemaining legacy API usage:"
      puts "%-30s %10s %10s" % %w[File Wrap Get]
      puts "-" * 52
      files_with_legacy.each do |file, wrap, get|
        puts "%-30s %10d %10d" % [file, wrap, get]
      end
      puts "-" * 52
      puts "%-30s %10d %10d" % ["TOTAL", remaining_wrap, remaining_get]
      puts "\nThese require manual migration (runtime class, macros, etc.)"
    end
  end

  def run(args)
    case
    when args.include?('--analyze')
      analyze
    when args.include?('--generate-header')
      generate_header
    when idx = args.index('--migrate')
      file = args[idx + 1]
      migrate_file(file) if file
    when idx = args.index('--apply')
      file = args[idx + 1]
      migrate_file(file, apply: true) if file
    when args.include?('--apply-all')
      apply_all
    when args.include?('--verify')
      verify
    else
      puts <<~USAGE
        Usage: ruby #{$0} [command]

        Commands:
          --analyze         Show migration statistics
          --generate-header Generate rb_gsl_types.h content
          --migrate FILE    Preview changes for FILE (dry run)
          --apply FILE      Apply changes to FILE
          --apply-all       Apply changes to all automatable files
          --verify          Check for remaining legacy API usage
      USAGE
    end
  end
end

TypedDataMigrator.new.run(ARGV)
