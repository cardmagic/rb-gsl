#!/usr/bin/env ruby
#
# TypedData Migration Script for rb-gsl
# Migrates from legacy Data_Wrap_Struct to TypedData API
#
# Usage: ruby migrate_to_typeddata.sh [--analyze] [--generate-header] [--migrate FILE] [--apply FILE]
#

require 'set'
require 'fileutils'

EXT_DIR = File.join(__dir__, 'ext', 'gsl_native')

class TypedDataMigrator
  # Skip macro-generated and runtime-determined class names
  # These need manual handling or different approaches
  SKIP_PATTERNS = /^(GSL_TYPE|QUALIFIED_VIEW|CONCAT|FUNCTION|VECTOR_.*_ROW_COL|VEC_ROW_COL)\(|^CLASS_OF|^klass$|^argv\[/

  # Map from C struct type to the class variable that wraps it
  STRUCT_TO_CLASS = {
    'gsl_rng' => 'cgsl_rng',
    'gsl_vector' => 'cgsl_vector',
    'gsl_vector_complex' => 'cgsl_vector_complex',
    'gsl_vector_int' => 'cgsl_vector_int',
    'gsl_matrix' => 'cgsl_matrix',
    'gsl_matrix_complex' => 'cgsl_matrix_complex',
    'gsl_matrix_int' => 'cgsl_matrix_int',
    'gsl_permutation' => 'cgsl_permutation',
    'gsl_combination' => 'cgsl_combination',
    'gsl_histogram' => 'cgsl_histogram',
    'gsl_histogram2d' => 'cgsl_histogram2d',
    'gsl_spline' => 'cgsl_spline',
    'gsl_interp' => 'cgsl_interp',
    'gsl_interp_accel' => 'cgsl_interp_accel',
    'gsl_complex' => 'cgsl_complex',
    'gsl_bspline_workspace' => 'cgsl_bspline_workspace',
    'gsl_block' => 'cgsl_block',
    'gsl_block_complex' => 'cgsl_block_complex',
    'gsl_sf_result' => 'cgsl_sf_result',
    'gsl_integration_workspace' => 'cgsl_integration_workspace',
    'gsl_monte_function' => 'cgsl_monte_function',
    'gsl_multifit_linear_workspace' => 'cgsl_multifit_linear_workspace',
    'gsl_multifit_fdfsolver' => 'cgsl_multifit_fdfsolver',
    'gsl_multimin_fdfminimizer' => 'cgsl_multimin_fdfminimizer',
    'gsl_multimin_fminimizer' => 'cgsl_multimin_fminimizer',
    'gsl_multiroot_fsolver' => 'cgsl_multiroot_fsolver',
    'gsl_multiroot_fdfsolver' => 'cgsl_multiroot_fdfsolver',
    'gsl_odeiv_step' => 'cgsl_odeiv_step',
    'gsl_odeiv_control' => 'cgsl_odeiv_control',
    'gsl_odeiv_evolve' => 'cgsl_odeiv_evolve',
    'gsl_root_fsolver' => 'cgsl_root_fsolver',
    'gsl_root_fdfsolver' => 'cgsl_root_fdfsolver',
    'gsl_sum_levin_u_workspace' => 'cgsl_sum_levin_u',
    'gsl_sum_levin_utrunc_workspace' => 'cgsl_sum_levin_utrunc',
    'gsl_wavelet' => 'cgsl_wavelet',
    'gsl_wavelet_workspace' => 'cgsl_wavelet_workspace',
  }

  def initialize
    @pairs = extract_pairs
    @simple_pairs = @pairs.reject { |cls, _, _| cls =~ SKIP_PATTERNS }
    @class_to_type = {}
    @class_to_free = {}

    @simple_pairs.each do |class_var, mark, free|
      @class_to_type[class_var] ||= "#{class_var.sub(/^c/, '')}_data_type"
      @class_to_free[class_var] ||= free
    end
  end

  def extract_pairs
    pairs = []
    Dir.glob(File.join(EXT_DIR, '*.{c,h}')).each do |file|
      content = File.read(file)
      content.scan(/Data_Wrap_Struct\s*\(\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,/) do |match|
        pairs << match.map(&:strip)
      end
    end
    pairs.uniq
  end

  def analyze
    puts "=" * 70
    puts "TypedData Migration Analysis for rb-gsl"
    puts "=" * 70
    puts

    puts "## Total unique class/free pairs: #{@pairs.size}"
    puts "   Simple (non-macro) pairs:      #{@simple_pairs.size}"
    puts "   Macro-based pairs:             #{@pairs.size - @simple_pairs.size}"
    puts

    # Count by file
    file_counts = Hash.new { |h, k| h[k] = {wrap: 0, get: 0} }

    Dir.glob(File.join(EXT_DIR, '*.c')).each do |file|
      content = File.read(file)
      basename = File.basename(file)
      file_counts[basename][:wrap] = content.scan(/Data_Wrap_Struct/).size
      file_counts[basename][:get] = content.scan(/Data_Get_Struct/).size
    end

    puts "## Top 20 files by occurrence count:"
    puts
    puts "%-35s %10s %10s %10s" % ["File", "Wrap", "Get", "Total"]
    puts "-" * 67

    file_counts.sort_by { |f, c| -(c[:wrap] + c[:get]) }.first(20).each do |file, counts|
      total = counts[:wrap] + counts[:get]
      next if total == 0
      puts "%-35s %10d %10d %10d" % [file, counts[:wrap], counts[:get], total]
    end

    total_wrap = file_counts.values.sum { |c| c[:wrap] }
    total_get = file_counts.values.sum { |c| c[:get] }

    puts
    puts "## Summary:"
    puts "   Total Data_Wrap_Struct: #{total_wrap}"
    puts "   Total Data_Get_Struct:  #{total_get}"
    puts "   Total to migrate:       #{total_wrap + total_get}"
    puts

    puts "## Simple type definitions (non-macro): #{@class_to_type.size}"
    puts
    @class_to_type.keys.sort.first(30).each do |cls|
      puts "   %-40s -> %s" % [cls, @class_to_type[cls]]
    end
    puts "   ... and #{@class_to_type.size - 30} more" if @class_to_type.size > 30

    puts
    puts "## Recommended migration order:"
    puts "   1. Start with simple, self-contained files (rng.c, sum.c, qrng.c)"
    puts "   2. Then migrate core types (vector, matrix, complex)"
    puts "   3. Finally handle macro-based templates"
  end

  def generate_types_header
    header = <<~HEADER
      /*
       * rb_gsl_types.h
       * TypedData type definitions for rb-gsl
       * Auto-generated - do not edit manually
       */

      #ifndef RB_GSL_TYPES_H
      #define RB_GSL_TYPES_H

      #include <ruby.h>
      #include <gsl/gsl_rng.h>
      #include <gsl/gsl_vector.h>
      #include <gsl/gsl_matrix.h>
      #include <gsl/gsl_permutation.h>
      #include <gsl/gsl_combination.h>
      #include <gsl/gsl_histogram.h>
      #include <gsl/gsl_histogram2d.h>
      #include <gsl/gsl_spline.h>
      #include <gsl/gsl_bspline.h>
      #include <gsl/gsl_sum.h>
      #include <gsl/gsl_wavelet.h>

      /*
       * TypedData type definitions
       * Each GSL wrapper class needs a corresponding rb_data_type_t
       */

    HEADER

    @class_to_type.sort.each do |class_var, type_name|
      free_func = @class_to_free[class_var]

      # Skip problematic patterns
      next if free_func =~ /\(|argv/

      dfree = case free_func
              when '0', 'NULL' then 'RUBY_DEFAULT_FREE'
              when 'free' then 'ruby_xfree'
              else "(void (*)(void *))#{free_func}"
              end

      header += <<~TYPE
        static const rb_data_type_t #{type_name} = {
            .wrap_struct_name = "#{class_var.sub(/^c/, '')}",
            .function = {
                .dmark = NULL,
                .dfree = #{dfree},
                .dsize = NULL,
            },
            .flags = RUBY_TYPED_FREE_IMMEDIATELY,
        };

      TYPE
    end

    header += "#endif /* RB_GSL_TYPES_H */\n"
    header
  end

  def migrate_file(filename, apply: false)
    filepath = File.join(EXT_DIR, filename)
    unless File.exist?(filepath)
      puts "File not found: #{filepath}"
      return
    end

    content = File.read(filepath)
    original = content.dup
    changes = []

    # Track what class variables are used in this file
    used_classes = Set.new
    content.scan(/Data_Wrap_Struct\s*\(\s*([^,]+)/).each do |match|
      cls = match[0].strip
      used_classes << cls if @class_to_type[cls]
    end

    puts "File: #{filename}"
    puts "Classes used: #{used_classes.to_a.sort.join(', ')}"
    puts

    # Replace Data_Wrap_Struct
    content.gsub!(/Data_Wrap_Struct\s*\(\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^)]+)\)/) do |match|
      cls = $1.strip
      mark = $2.strip
      free = $3.strip
      ptr = $4.strip

      if type = @class_to_type[cls]
        changes << {
          type: :wrap,
          old: match,
          new: "TypedData_Wrap_Struct(#{cls}, &#{type}, #{ptr})"
        }
        changes.last[:new]
      else
        match
      end
    end

    # Replace Data_Get_Struct - need to map C type to rb_data_type_t
    content.gsub!(/Data_Get_Struct\s*\(\s*([^,]+)\s*,\s*([^,]+)\s*,\s*([^)]+)\)/) do |match|
      obj = $1.strip
      ctype = $2.strip
      ptr = $3.strip

      # Try to find the corresponding class from the C type
      if class_var = STRUCT_TO_CLASS[ctype]
        if type = @class_to_type[class_var]
          changes << {
            type: :get,
            old: match,
            new: "TypedData_Get_Struct(#{obj}, #{ctype}, &#{type}, #{ptr})"
          }
          next changes.last[:new]
        end
      end
      match
    end

    puts "Changes: #{changes.size}"
    puts

    if changes.any?
      puts "Preview (first 10 changes):"
      changes.first(10).each_with_index do |c, i|
        puts "  #{i + 1}. [#{c[:type]}]"
        puts "     - #{c[:old]}"
        puts "     + #{c[:new]}"
        puts
      end

      if apply
        File.write(filepath, content)
        puts "Applied #{changes.size} changes to #{filename}"
      else
        puts "Run with --apply #{filename} to apply changes"
      end
    else
      puts "No changes needed (or all uses are macro-based)"
    end
  end

  def run(args)
    if args.include?('--analyze') || args.empty?
      analyze
    elsif args.include?('--generate-header')
      puts generate_types_header
    elsif idx = args.index('--migrate')
      file = args[idx + 1]
      migrate_file(file) if file
    elsif idx = args.index('--apply')
      file = args[idx + 1]
      migrate_file(file, apply: true) if file
    else
      puts "Usage: ruby #{$0} [--analyze] [--generate-header] [--migrate FILE] [--apply FILE]"
    end
  end
end

TypedDataMigrator.new.run(ARGV)
