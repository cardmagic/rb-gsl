#!/usr/bin/env ruby
#
# TypedData Migration Script v2 - Extended coverage
#
# Handles:
# 1. Expanded STRUCT_TO_CLASS mappings (covers most Data_Get_Struct)
# 2. Generates helper macros for common patterns
#

require 'set'

EXT_DIR = File.join(__dir__, 'ext', 'gsl_native')

class TypedDataMigratorV2
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

    # BSpline
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

    # Misc
    'gsl_function' => 'cgsl_function',
    'gsl_function_fdf' => 'cgsl_function_fdf',
    'gsl_multiset' => 'cgsl_multiset',
    'gsl_dht' => 'cgsl_dht',
    'gsl_qrng' => 'cgsl_qrng',
    'gsl_ntuple' => 'cgsl_ntuple',
    'gsl_rational' => 'cgsl_rational',
    'gsl_graph' => 'cgsl_graph',
    'gsl_siman_params_t' => 'cgsl_siman_params',

    # OOL
    'ool_conmin_minimizer' => 'cgsl_ool_conmin_minimizer',
    'ool_conmin_function' => 'cgsl_ool_conmin_function',

    # CQP
    'gsl_cqp_data' => 'cgsl_cqp_data',
    'gsl_cqpminimizer' => 'cgsl_cqpminimizer',

    # Jacobi
    'jac_quadrature' => 'cgsl_jacobi',

    # Additional Monte Carlo
    'gsl_monte_miser_params' => 'cgsl_monte_miser_params',
    'gsl_monte_vegas_params' => 'cgsl_monte_vegas_params',

    # Additional minimization
    'gsl_multimin_fsdfminimizer' => 'cgsl_multimin_fsdfminimizer',
    'gsl_multimin_function' => 'cgsl_multimin_function',
    'gsl_multimin_function_fdf' => 'cgsl_multimin_function_fdf',
    'gsl_multimin_function_fsdf' => 'cgsl_multimin_function_fsdf',

    # Additional fitting
    'gsl_multifit_ndlinear_workspace' => 'cgsl_multifit_ndlinear_workspace',

    # Additional eigen
    'gsl_eigen_francis_workspace' => 'cgsl_eigen_francis_workspace',

    # OOL additional
    'ool_conmin_constraint' => 'cgsl_ool_conmin_constraint',

    # NTuple
    'gsl_ntuple_value_fn' => 'cgsl_ntuple_value_fn',
    'gsl_ntuple_select_fn' => 'cgsl_ntuple_select_fn',

    # Spline2d
    'rb_gsl_spline2d' => 'cgsl_spline2d',
    'rb_gsl_interp2d' => 'cgsl_interp2d',

    # Mathieu
    'gsl_sf_mathieu_workspace' => 'cgsl_sf_mathieu_workspace',

    # FFT
    'GSL_FFT_Wavetable' => 'cgsl_fft_wavetable',

    # ALF
    'alf_workspace' => 'cgsl_alf_workspace',

    # Misc
    'gsl_index' => 'cgsl_index',
    'gsl_ran_discrete_t' => 'cgsl_ran_discrete',
    'gsl_poly' => 'cgsl_poly',
    'gsl_vector_long' => 'cgsl_vector_long',

    # SIMAN
    'siman_Efunc' => 'cgsl_siman_Efunc',
    'siman_print' => 'cgsl_siman_print',
    'siman_step' => 'cgsl_siman_step',
    'siman_metric' => 'cgsl_siman_metric',
    'siman_solver' => 'cgsl_siman_solver',

    # TAMU ANOVA
    'struct tamu_anova_table' => 'cgsl_tamu_anova_table',
  }

  # Runtime class patterns that need special handling
  RUNTIME_CLASS_PATTERNS = {
    'klass' => :alloc_function,      # Passed to alloc, needs restructure
    'CLASS_OF(obj)' => :clone_dup,   # Clone/dup pattern
    'CLASS_OF(h1)' => :clone_dup,
    'CLASS_OF(argv[0])' => :clone_dup,
  }

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
        next if cls =~ /^(GSL_TYPE|QUALIFIED_VIEW|CONCAT|FUNCTION|VECTOR_|VEC_ROW)/
        next if RUNTIME_CLASS_PATTERNS[cls]

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

    Dir.glob(File.join(EXT_DIR, '*.c')).each do |file|
      content = File.read(file)

      content.scan(/Data_Wrap_Struct\s*\(\s*([^,]+)/) do |m|
        cls = m[0].strip
        total_wrap += 1
        if RUNTIME_CLASS_PATTERNS[cls]
          runtime_wrap += 1
        elsif @class_to_type[cls]
          fixable_wrap += 1
        end
      end

      content.scan(/Data_Get_Struct\s*\(\s*[^,]+\s*,\s*([^,]+)/) do |m|
        ctype = m[0].strip
        total_get += 1
        # If we have a mapping for this C type, it's fixable
        fixable_get += 1 if STRUCT_TO_CLASS[ctype]
      end
    end

    total = total_wrap + total_get
    fixable = fixable_wrap + fixable_get

    puts "=" * 70
    puts "TypedData Migration Analysis v2 (Extended Mappings)"
    puts "=" * 70
    puts
    puts "Data_Wrap_Struct:"
    puts "  Fixable (static class):    #{fixable_wrap}"
    puts "  Runtime class (klass etc): #{runtime_wrap}"
    puts "  Other unfixable:           #{total_wrap - fixable_wrap - runtime_wrap}"
    puts "  Total:                     #{total_wrap}"
    puts
    puts "Data_Get_Struct:"
    puts "  Fixable:                   #{fixable_get}"
    puts "  Unfixable (no mapping):    #{total_get - fixable_get}"
    puts "  Total:                     #{total_get}"
    puts
    puts "=" * 70
    puts "TOTAL FIXABLE: #{fixable}/#{total} (#{(fixable.to_f/total*100).round(1)}%)"
    puts "=" * 70
    puts
    puts "Remaining #{total - fixable} occurrences need:"
    puts "  - #{runtime_wrap} runtime class restructuring (klass, CLASS_OF)"
    puts "  - #{total_get - fixable_get} additional type mappings"
    puts "  - Macro-based code (GSL_TYPE, QUALIFIED_VIEW, etc.)"
  end

  def generate_helper_header
    puts <<~HEADER
      /*
       * rb_gsl_typeddata.h
       * Helper macros for TypedData migration
       */

      #ifndef RB_GSL_TYPEDDATA_H
      #define RB_GSL_TYPEDDATA_H

      #include <ruby.h>

      /*
       * For runtime class cases (klass parameter), we need to store
       * the type alongside the class. One approach:
       */

      /* Get the rb_data_type_t for a known class variable */
      #define GSL_DATA_TYPE(class_var) (&class_var##_data_type)

      /*
       * Alternative: Use a lookup table from class to type
       * This would be initialized at extension load time
       */

      /*
       * For CLASS_OF(obj) cases (clone/dup), we can use the same type
       * as the original object since we know the type at the call site
       */
      #define TypedData_Clone(klass, type, ptr) \\
          TypedData_Wrap_Struct(klass, type, ptr)

      #endif
    HEADER
  end

  def run(args)
    if args.include?('--analyze')
      analyze
    elsif args.include?('--helper-header')
      generate_helper_header
    else
      puts "Usage: ruby #{$0} --analyze | --helper-header"
    end
  end
end

TypedDataMigratorV2.new.run(ARGV)
