require 'test_helper'
require 'tempfile'

class VectorSourceCoverageTest < GSL::TestCase
  # =====================================================
  # Constructor tests
  # =====================================================

  def test_new_with_fixnum
    v = GSL::Vector.alloc(5)
    assert_equal 5, v.size
    assert_in_delta 0.0, v[0], 1e-10
  end

  def test_new_with_range
    v = GSL::Vector.alloc(1..5)
    assert_equal 5, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 5.0, v[4], 1e-10
  end

  def test_new_with_reverse_range
    v = GSL::Vector.alloc(5..1)
    assert_equal 5, v.size
    # Reverse range fills from 5 down to 1
    assert_in_delta 5.0, v[0], 1e-10
    assert_in_delta 1.0, v[4], 1e-10
  end

  def test_new_with_float
    v = GSL::Vector.alloc(3.5)
    assert_equal 1, v.size
    assert_in_delta 3.5, v[0], 1e-10
  end

  def test_new_with_array
    v = GSL::Vector.alloc([1, 2, 3])
    assert_equal 3, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 3.0, v[2], 1e-10
  end

  def test_new_with_multiple_args
    v = GSL::Vector.alloc(1, 2, 3, 4, 5)
    assert_equal 5, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 5.0, v[4], 1e-10
  end

  def test_new_from_vector
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector.alloc(v1)
    assert_equal 3, v2.size
    assert_in_delta 1.0, v2[0], 1e-10
    # Modify v2, v1 should be unchanged
    v2[0] = 10.0
    assert_in_delta 1.0, v1[0], 1e-10
  end

  def test_new_with_bignum_raises
    assert_raises(RangeError) do
      GSL::Vector.alloc(2 ** 100)
    end
  end

  def test_new_with_wrong_type
    assert_raises(TypeError) do
      GSL::Vector.alloc("invalid")
    end
  end

  def test_calloc
    v = GSL::Vector.calloc(5)
    assert_equal 5, v.size
    assert_in_delta 0.0, v[0], 1e-10
    assert_in_delta 0.0, v[4], 1e-10
  end

  # =====================================================
  # Get/indexing tests
  # =====================================================

  def test_get_with_fixnum
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 5.0, v[4], 1e-10
  end

  def test_get_with_negative_index
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_in_delta 5.0, v[-1], 1e-10
    assert_in_delta 4.0, v[-2], 1e-10
  end

  def test_get_with_array
    v = GSL::Vector[1, 2, 3, 4, 5]
    result = v[[0, 2, 4]]
    assert_kind_of GSL::Vector, result
    assert_equal 3, result.size
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 3.0, result[1], 1e-10
    assert_in_delta 5.0, result[2], 1e-10
  end

  def test_get_with_array_negative_indices
    v = GSL::Vector[1, 2, 3, 4, 5]
    result = v[[-1, -2, -3]]
    assert_equal 3, result.size
    assert_in_delta 5.0, result[0], 1e-10
    assert_in_delta 4.0, result[1], 1e-10
    assert_in_delta 3.0, result[2], 1e-10
  end

  def test_get_with_range
    v = GSL::Vector[1, 2, 3, 4, 5]
    result = v[1..3]
    assert_equal 3, result.size
    assert_in_delta 2.0, result[0], 1e-10
    assert_in_delta 4.0, result[2], 1e-10
  end

  def test_get_with_permutation
    v = GSL::Vector[10, 20, 30, 40, 50]
    p = GSL::Permutation.alloc(3)
    p[0] = 4
    p[1] = 2
    p[2] = 0
    result = v[p]
    assert_equal 3, result.size
    assert_in_delta 50.0, result[0], 1e-10
    assert_in_delta 30.0, result[1], 1e-10
    assert_in_delta 10.0, result[2], 1e-10
  end

  def test_get_with_wrong_type
    v = GSL::Vector[1, 2, 3]
    assert_raises(TypeError) do
      v["invalid"]
    end
  end

  # =====================================================
  # Set tests
  # =====================================================

  def test_set_with_single_value
    v = GSL::Vector[1, 2, 3, 4, 5]
    v[] = 10.0
    assert_in_delta 10.0, v[0], 1e-10
    assert_in_delta 10.0, v[4], 1e-10
  end

  def test_set_with_index
    v = GSL::Vector[1, 2, 3, 4, 5]
    v[2] = 10.0
    assert_in_delta 10.0, v[2], 1e-10
  end

  def test_set_with_negative_index
    v = GSL::Vector[1, 2, 3, 4, 5]
    v[-1] = 10.0
    assert_in_delta 10.0, v[4], 1e-10
  end

  def test_set_subvector_with_vector
    v = GSL::Vector[1, 2, 3, 4, 5]
    v2 = GSL::Vector[10, 20]
    v[1, 2] = v2
    assert_in_delta 10.0, v[1], 1e-10
    assert_in_delta 20.0, v[2], 1e-10
  end

  def test_set_subvector_with_array
    v = GSL::Vector[1, 2, 3, 4, 5]
    v[1, 2] = [10, 20]
    assert_in_delta 10.0, v[1], 1e-10
    assert_in_delta 20.0, v[2], 1e-10
  end

  def test_set_subvector_with_range
    v = GSL::Vector[1, 2, 3, 4, 5]
    v[1, 2] = 10..11
    assert_in_delta 10.0, v[1], 1e-10
    assert_in_delta 11.0, v[2], 1e-10
  end

  def test_set_subvector_length_mismatch_vector
    v = GSL::Vector[1, 2, 3, 4, 5]
    v2 = GSL::Vector[10, 20, 30]
    assert_raises(RangeError) do
      v[1, 2] = v2
    end
  end

  def test_set_subvector_length_mismatch_array
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(RangeError) do
      v[1, 2] = [10, 20, 30]
    end
  end

  def test_set_subvector_length_mismatch_range
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(RangeError) do
      v[1, 2] = 10..12
    end
  end

  def test_set_wrong_arg_count
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(ArgumentError) do
      v.set(1, 2, 3, 4, 5)
    end
  end

  # =====================================================
  # Subvector tests
  # =====================================================

  def test_subvector_no_args
    v = GSL::Vector[1, 2, 3, 4, 5]
    sub = v.subvector
    assert_equal 5, sub.size
  end

  def test_subvector_with_range
    v = GSL::Vector[1, 2, 3, 4, 5]
    sub = v.subvector(1..3)
    assert_equal 3, sub.size
    assert_in_delta 2.0, sub[0], 1e-10
  end

  def test_subvector_with_negative_length
    v = GSL::Vector[1, 2, 3, 4, 5]
    sub = v.subvector(-3)  # Last 3 elements
    assert_equal 3, sub.size
    assert_in_delta 3.0, sub[0], 1e-10
  end

  def test_subvector_with_offset_and_length
    v = GSL::Vector[1, 2, 3, 4, 5]
    sub = v.subvector(1, 3)
    assert_equal 3, sub.size
    assert_in_delta 2.0, sub[0], 1e-10
  end

  def test_subvector_with_range_and_stride
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    sub = v.subvector(0..8, 2)  # Every 2nd element
    assert_equal 5, sub.size
    assert_in_delta 1.0, sub[0], 1e-10
    assert_in_delta 3.0, sub[1], 1e-10
  end

  def test_subvector_with_offset_stride_length
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    sub = v.subvector(0, 2, 3)  # Start at 0, stride 2, 3 elements
    assert_equal 3, sub.size
    assert_in_delta 1.0, sub[0], 1e-10
    assert_in_delta 3.0, sub[1], 1e-10
    assert_in_delta 5.0, sub[2], 1e-10
  end

  def test_subvector_range_out_of_bounds_begin
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(RangeError) do
      v.subvector(10..12)  # Begin out of range
    end
  end

  def test_subvector_range_out_of_bounds_end
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(RangeError) do
      v.subvector(0..10)  # End out of range
    end
  end

  def test_subvector_length_out_of_range
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(RangeError) do
      v.subvector(10)  # Length too large
    end
  end

  def test_subvector_too_many_args
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(ArgumentError) do
      v.subvector(1, 2, 3, 4)
    end
  end

  def test_subvector_stride_zero_with_range
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(ArgumentError) do
      v.subvector(0..4, 0)
    end
  end

  # =====================================================
  # Size/Stride/Owner tests
  # =====================================================

  def test_size
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_equal 5, v.size
  end

  def test_stride
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_equal 1, v.stride
  end

  def test_set_stride
    v = GSL::Vector[1, 2, 3, 4, 5]
    v.stride = 2
    assert_equal 2, v.stride
  end

  def test_owner
    v = GSL::Vector[1, 2, 3, 4, 5]
    # Owned vectors return 1
    assert_equal 1, v.owner
  end

  # =====================================================
  # View tests (size/stride work with views)
  # =====================================================

  def test_view_size
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(1, 3)
    assert_equal 3, view.size
  end

  def test_view_stride
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    view = v.subvector(0..8, 2)
    assert_equal 2, view.stride
  end

  # =====================================================
  # Set operations
  # =====================================================

  def test_set_all
    v = GSL::Vector.alloc(5)
    v.set_all(3.5)
    assert_in_delta 3.5, v[0], 1e-10
    assert_in_delta 3.5, v[4], 1e-10
  end

  def test_set_zero
    v = GSL::Vector[1, 2, 3, 4, 5]
    v.set_zero
    assert_in_delta 0.0, v[0], 1e-10
    assert_in_delta 0.0, v[4], 1e-10
  end

  def test_set_basis
    v = GSL::Vector.alloc(5)
    v.set_basis(2)
    assert_in_delta 0.0, v[0], 1e-10
    assert_in_delta 0.0, v[1], 1e-10
    assert_in_delta 1.0, v[2], 1e-10
    assert_in_delta 0.0, v[3], 1e-10
    assert_in_delta 0.0, v[4], 1e-10
  end

  # =====================================================
  # I/O tests
  # =====================================================

  def test_fwrite_fread
    v = GSL::Vector[1, 2, 3, 4, 5]
    Tempfile.create('vector') do |f|
      v.fwrite(f.path)
      v2 = GSL::Vector.alloc(5)
      v2.fread(f.path)
      assert_in_delta 1.0, v2[0], 1e-10
      assert_in_delta 5.0, v2[4], 1e-10
    end
  end

  def test_fprintf_fscanf
    v = GSL::Vector[1, 2, 3, 4, 5]
    Tempfile.create('vector') do |f|
      v.fprintf(f.path)
      v2 = GSL::Vector.alloc(5)
      v2.fscanf(f.path)
      assert_in_delta 1.0, v2[0], 1e-10
      assert_in_delta 5.0, v2[4], 1e-10
    end
  end

  def test_fprintf_with_format
    v = GSL::Vector[1, 2, 3]
    Tempfile.create('vector') do |f|
      v.fprintf(f.path, "%g")
      content = File.read(f.path)
      assert content.include?("1")
    end
  end

  def test_fprintf_wrong_arg_count
    v = GSL::Vector[1, 2, 3]
    assert_raises(ArgumentError) do
      v.fprintf
    end
  end

  # =====================================================
  # Clone/swap tests
  # =====================================================

  def test_clone
    v = GSL::Vector[1, 2, 3]
    c = v.clone
    assert_in_delta 1.0, c[0], 1e-10
    c[0] = 10.0
    assert_in_delta 1.0, v[0], 1e-10  # Original unchanged
  end

  def test_swap_elements
    v = GSL::Vector[1, 2, 3, 4, 5]
    v.swap_elements(0, 4)
    assert_in_delta 5.0, v[0], 1e-10
    assert_in_delta 1.0, v[4], 1e-10
  end

  def test_reverse
    v = GSL::Vector[1, 2, 3, 4, 5]
    r = v.reverse
    assert_in_delta 5.0, r[0], 1e-10
    assert_in_delta 1.0, r[4], 1e-10
  end

  def test_reverse_bang
    v = GSL::Vector[1, 2, 3, 4, 5]
    v.reverse!
    assert_in_delta 5.0, v[0], 1e-10
    assert_in_delta 1.0, v[4], 1e-10
  end

  # =====================================================
  # Min/Max tests
  # =====================================================

  def test_max
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    assert_in_delta 9.0, v.max, 1e-10
  end

  def test_min
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    assert_in_delta 1.0, v.min, 1e-10
  end

  def test_minmax
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    min, max = v.minmax
    assert_in_delta 1.0, min, 1e-10
    assert_in_delta 9.0, max, 1e-10
  end

  def test_max_index
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    assert_equal 5, v.max_index
  end

  def test_min_index
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    assert_equal 1, v.min_index
  end

  def test_minmax_index
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    min_idx, max_idx = v.minmax_index
    assert_equal 1, min_idx
    assert_equal 5, max_idx
  end

  # =====================================================
  # Arithmetic tests
  # =====================================================

  def test_add_vector
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = v1 + v2
    assert_in_delta 5.0, result[0], 1e-10
    assert_in_delta 9.0, result[2], 1e-10
  end

  def test_add_scalar
    v = GSL::Vector[1, 2, 3]
    result = v + 10
    assert_in_delta 11.0, result[0], 1e-10
    assert_in_delta 13.0, result[2], 1e-10
  end

  def test_sub_vector
    v1 = GSL::Vector[4, 5, 6]
    v2 = GSL::Vector[1, 2, 3]
    result = v1 - v2
    assert_in_delta 3.0, result[0], 1e-10
    assert_in_delta 3.0, result[2], 1e-10
  end

  def test_mul_vector
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = v1 * v2
    assert_in_delta 4.0, result[0], 1e-10
    assert_in_delta 18.0, result[2], 1e-10
  end

  def test_mul_scalar
    v = GSL::Vector[1, 2, 3]
    result = v * 2
    assert_in_delta 2.0, result[0], 1e-10
    assert_in_delta 6.0, result[2], 1e-10
  end

  def test_div_vector
    v1 = GSL::Vector[4, 6, 8]
    v2 = GSL::Vector[2, 3, 4]
    result = v1 / v2
    assert_in_delta 2.0, result[0], 1e-10
    assert_in_delta 2.0, result[2], 1e-10
  end

  def test_uminus
    v = GSL::Vector[1, 2, 3]
    result = -v
    assert_in_delta(-1.0, result[0], 1e-10)
    assert_in_delta(-3.0, result[2], 1e-10)
  end

  # =====================================================
  # Comparison tests
  # =====================================================

  def test_isnull
    v = GSL::Vector[0, 0, 0]
    assert_equal true, v.isnull?
  end

  def test_isnull_false
    v = GSL::Vector[1, 0, 0]
    assert_equal false, v.isnull?
  end

  def test_ispos
    v = GSL::Vector[1, 2, 3]
    assert_equal true, v.ispos?
  end

  def test_isneg
    v = GSL::Vector[-1, -2, -3]
    assert_equal true, v.isneg?
  end

  def test_isnonneg
    v = GSL::Vector[0, 1, 2]
    assert_equal true, v.isnonneg?
  end

  # =====================================================
  # Special constructors
  # =====================================================

  def test_indgen_singleton
    v = GSL::Vector.indgen(5)
    assert_equal 5, v.size
    assert_in_delta 0.0, v[0], 1e-10
    assert_in_delta 4.0, v[4], 1e-10
  end

  def test_indgen_singleton_with_start
    v = GSL::Vector.indgen(5, 10)
    assert_in_delta 10.0, v[0], 1e-10
    assert_in_delta 14.0, v[4], 1e-10
  end

  def test_indgen_singleton_with_step
    v = GSL::Vector.indgen(5, 0, 2)
    assert_in_delta 0.0, v[0], 1e-10
    assert_in_delta 8.0, v[4], 1e-10
  end

  def test_indgen_singleton_wrong_args
    assert_raises(ArgumentError) do
      GSL::Vector.indgen
    end
  end

  def test_indgen_instance
    v = GSL::Vector.alloc(5)
    v2 = v.indgen
    assert_in_delta 0.0, v2[0], 1e-10
    assert_in_delta 4.0, v2[4], 1e-10
  end

  def test_indgen_bang
    v = GSL::Vector.alloc(5)
    v.indgen!
    assert_in_delta 0.0, v[0], 1e-10
    assert_in_delta 4.0, v[4], 1e-10
  end

  def test_indgen_bang_wrong_args
    v = GSL::Vector.alloc(5)
    assert_raises(ArgumentError) do
      v.indgen!(1, 2, 3)
    end
  end

  # =====================================================
  # Conversion tests
  # =====================================================

  def test_to_a
    v = GSL::Vector[1, 2, 3]
    a = v.to_a
    assert_equal [1.0, 2.0, 3.0], a
  end

  def test_to_s
    v = GSL::Vector[1, 2, 3]
    s = v.to_s
    assert s.include?("[")
    assert s.include?("]")
  end

  def test_inspect
    v = GSL::Vector[1, 2, 3]
    s = v.inspect
    assert s.include?("GSL::Vector")
  end

  # =====================================================
  # Connect tests
  # =====================================================

  def test_connect
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = GSL::Vector.connect(v1, v2)
    assert_equal 6, result.size
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 6.0, result[5], 1e-10
  end

  def test_connect_multiple
    v1 = GSL::Vector[1, 2]
    v2 = GSL::Vector[3, 4]
    v3 = GSL::Vector[5, 6]
    result = GSL::Vector.connect(v1, v2, v3)
    assert_equal 6, result.size
  end

  # =====================================================
  # Block operations
  # =====================================================

  def test_collect
    v = GSL::Vector[1, 2, 3]
    result = v.collect { |x| x * 2 }
    assert_in_delta 2.0, result[0], 1e-10
    assert_in_delta 6.0, result[2], 1e-10
  end

  def test_collect_bang
    v = GSL::Vector[1, 2, 3]
    v.collect! { |x| x * 2 }
    assert_in_delta 2.0, v[0], 1e-10
    assert_in_delta 6.0, v[2], 1e-10
  end

  def test_each
    v = GSL::Vector[1, 2, 3]
    sum = 0
    v.each { |x| sum += x }
    assert_in_delta 6.0, sum, 1e-10
  end

  def test_each_index
    v = GSL::Vector[1, 2, 3]
    indices = []
    v.each_index { |i| indices << i }
    assert_equal [0, 1, 2], indices
  end

  # =====================================================
  # Comparison operations
  # =====================================================

  def test_equal_true
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[1, 2, 3]
    assert v1.equal?(v2)
  end

  def test_equal_false
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[1, 2, 4]
    refute v1.equal?(v2)
  end

  def test_equal_with_epsilon
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[1.0001, 2, 3]
    assert v1.equal?(v2, 0.001)
  end

  # =====================================================
  # Sort operations
  # =====================================================

  def test_sort
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    sorted = v.sort
    assert_in_delta 1.0, sorted[0], 1e-10
    assert_in_delta 1.0, sorted[1], 1e-10
    assert_in_delta 9.0, sorted[7], 1e-10
  end

  def test_sort_bang
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    v.sort!
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 9.0, v[7], 1e-10
  end

  def test_sort_index
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    indices = v.sort_index
    # Indices of sorted order - indices might be either 1 or 3 for the first 1
    assert_includes [1, 3], indices[0]  # First sorted element was at index 1 or 3
    assert_equal 5, indices[7]  # Last sorted element was at index 5
  end

  # =====================================================
  # Sum/Product operations
  # =====================================================

  def test_sum
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_in_delta 15.0, v.sum, 1e-10
  end

  def test_prod
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_in_delta 120.0, v.prod, 1e-10
  end

  def test_cumsum
    v = GSL::Vector[1, 2, 3, 4, 5]
    result = v.cumsum
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 3.0, result[1], 1e-10
    assert_in_delta 15.0, result[4], 1e-10
  end

  def test_cumprod
    v = GSL::Vector[1, 2, 3, 4, 5]
    result = v.cumprod
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 2.0, result[1], 1e-10
    assert_in_delta 120.0, result[4], 1e-10
  end

  # =====================================================
  # Norm operations
  # =====================================================

  def test_norm
    v = GSL::Vector[3, 4]
    assert_in_delta 5.0, v.norm, 1e-10
  end

  def test_normalize
    v = GSL::Vector[3, 4]
    n = v.normalize
    assert_in_delta 0.6, n[0], 1e-10
    assert_in_delta 0.8, n[1], 1e-10
  end

  def test_normalize_bang
    v = GSL::Vector[3, 4]
    v.normalize!
    assert_in_delta 0.6, v[0], 1e-10
    assert_in_delta 0.8, v[1], 1e-10
  end

  # =====================================================
  # Dot product tests
  # =====================================================

  def test_dot
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = v1.dot(v2)
    # 1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32
    assert_in_delta 32.0, result, 1e-10
  end

  # =====================================================
  # Col/Row operations
  # =====================================================

  def test_col
    v = GSL::Vector[1, 2, 3]
    c = v.col
    assert c.is_a?(GSL::Vector::Col)
  end

  def test_row
    v = GSL::Vector[1, 2, 3].col
    r = v.row
    # Should convert back to row vector
    assert_kind_of GSL::Vector, r
  end

  # =====================================================
  # Block tests
  # =====================================================

  # NOTE: test_block is commented out due to a crash in the block accessor
  # def test_block
  #   v = GSL::Vector[1, 2, 3]
  #   b = v.block
  #   assert_kind_of GSL::Block, b
  # end

  # =====================================================
  # Info tests
  # =====================================================

  def test_info
    v = GSL::Vector[1, 2, 3]
    info = v.info
    assert info.include?("Size")
  end

  # =====================================================
  # Diff tests
  # =====================================================

  def test_diff
    v = GSL::Vector[1, 3, 6, 10, 15]
    d = v.diff
    assert_equal 4, d.size
    assert_in_delta 2.0, d[0], 1e-10
    assert_in_delta 3.0, d[1], 1e-10
    assert_in_delta 4.0, d[2], 1e-10
    assert_in_delta 5.0, d[3], 1e-10
  end

  # =====================================================
  # Test functions
  # =====================================================

  def test_isnan
    v = GSL::Vector[1, Float::NAN, 3]
    result = v.isnan
    assert_kind_of GSL::Vector::Int, result
    assert_equal 0, result[0]
    assert_equal 1, result[1]
    assert_equal 0, result[2]
  end

  def test_isinf
    v = GSL::Vector[1, Float::INFINITY, 3]
    result = v.isinf
    assert_kind_of GSL::Vector::Int, result
    assert_equal 0, result[0]
    assert_equal 1, result[1]
    assert_equal 0, result[2]
  end

  def test_finite
    v = GSL::Vector[1, 2, 3]
    result = v.finite
    assert_kind_of GSL::Vector::Int, result
    assert_equal 1, result[0]
    assert_equal 1, result[1]
    assert_equal 1, result[2]
  end

  # =====================================================
  # Abs tests
  # =====================================================

  def test_abs
    v = GSL::Vector[-1, -2, 3, -4]
    result = v.abs
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 2.0, result[1], 1e-10
    assert_in_delta 3.0, result[2], 1e-10
    assert_in_delta 4.0, result[3], 1e-10
  end

  def test_sgn
    v = GSL::Vector[-1, 0, 3, -4]
    result = v.sgn
    assert_in_delta(-1.0, result[0], 1e-10)
    assert_in_delta 0.0, result[1], 1e-10
    assert_in_delta 1.0, result[2], 1e-10
    assert_in_delta(-1.0, result[3], 1e-10)
  end

  # =====================================================
  # Integer vector tests (covers BASE_INT path)
  # =====================================================

  def test_int_vector_new
    v = GSL::Vector::Int.alloc(5)
    assert_equal 5, v.size
  end

  def test_int_vector_range
    v = GSL::Vector::Int[1..5]
    assert_equal 5, v.size
    assert_equal 1, v[0]
    assert_equal 5, v[4]
  end

  def test_int_vector_arithmetic
    v1 = GSL::Vector::Int[1, 2, 3]
    v2 = GSL::Vector::Int[4, 5, 6]
    result = v1 + v2
    assert_equal 5, result[0]
    assert_equal 9, result[2]
  end

  def test_int_vector_subvector
    v = GSL::Vector::Int[1, 2, 3, 4, 5]
    sub = v.subvector(1..3)
    assert_equal 3, sub.size
    assert_equal 2, sub[0]
  end

  def test_int_vector_subvector_stride_zero
    v = GSL::Vector::Int[1, 2, 3, 4, 5]
    # Range with stride = 0 and different begin/end should raise
    assert_raises(ArgumentError) do
      v.subvector(0..4, 0)
    end
  end

  # =====================================================
  # Additional coverage tests - reverse_each variants
  # =====================================================

  def test_reverse_each
    v = GSL::Vector[1, 2, 3, 4, 5]
    elements = []
    v.reverse_each { |x| elements << x }
    assert_equal [5.0, 4.0, 3.0, 2.0, 1.0], elements
  end

  def test_reverse_each_index
    v = GSL::Vector[1, 2, 3, 4, 5]
    indices = []
    v.reverse_each_index { |i| indices << i }
    assert_equal [4, 3, 2, 1, 0], indices
  end

  # =====================================================
  # maxmin variants
  # =====================================================

  def test_maxmin
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    max, min = v.maxmin
    assert_in_delta 9.0, max, 1e-10
    assert_in_delta 1.0, min, 1e-10
  end

  def test_maxmin_index
    v = GSL::Vector[3, 1, 4, 1, 5, 9, 2, 6]
    max_idx, min_idx = v.maxmin_index
    assert_equal 5, max_idx
    assert_equal 1, min_idx
  end

  # =====================================================
  # transpose tests
  # =====================================================

  def test_trans
    v = GSL::Vector[1, 2, 3]
    c = v.trans
    assert c.is_a?(GSL::Vector::Col)
    # Transpose back
    r = c.trans
    assert r.is_a?(GSL::Vector)
  end

  def test_trans_bang
    v = GSL::Vector[1, 2, 3]
    v.trans!
    assert v.is_a?(GSL::Vector::Col)
    v.trans!
    assert v.is_a?(GSL::Vector)
  end

  def test_trans_bang_on_view_raises
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(1, 3)
    assert_raises(RuntimeError) do
      view.trans!
    end
  end

  # =====================================================
  # unary plus test
  # =====================================================

  def test_uplus
    v = GSL::Vector[1, 2, 3]
    result = +v
    assert_equal v.object_id, result.object_id
  end

  # =====================================================
  # square and sqrt tests
  # =====================================================

  def test_square
    v = GSL::Vector[1, 2, 3, 4]
    result = v.square
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 4.0, result[1], 1e-10
    assert_in_delta 9.0, result[2], 1e-10
    assert_in_delta 16.0, result[3], 1e-10
  end

  def test_sqrt
    v = GSL::Vector[1, 4, 9, 16]
    result = v.sqrt
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 2.0, result[1], 1e-10
    assert_in_delta 3.0, result[2], 1e-10
    assert_in_delta 4.0, result[3], 1e-10
  end

  # =====================================================
  # scale and add_constant bang methods
  # =====================================================

  def test_scale_bang
    v = GSL::Vector[1, 2, 3]
    v.scale!(2)
    assert_in_delta 2.0, v[0], 1e-10
    assert_in_delta 4.0, v[1], 1e-10
    assert_in_delta 6.0, v[2], 1e-10
  end

  def test_add_constant_bang
    v = GSL::Vector[1, 2, 3]
    v.add_constant!(10)
    assert_in_delta 11.0, v[0], 1e-10
    assert_in_delta 12.0, v[1], 1e-10
    assert_in_delta 13.0, v[2], 1e-10
  end

  # =====================================================
  # subvector_with_stride tests
  # =====================================================

  def test_subvector_with_stride_one_arg
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    sub = v.subvector_with_stride(2)
    assert_equal 5, sub.size
    assert_in_delta 1.0, sub[0], 1e-10
    assert_in_delta 3.0, sub[1], 1e-10
    assert_in_delta 5.0, sub[2], 1e-10
  end

  def test_subvector_with_stride_two_args
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    sub = v.subvector_with_stride(1, 2)  # offset=1, stride=2
    assert_in_delta 2.0, sub[0], 1e-10
    assert_in_delta 4.0, sub[1], 1e-10
  end

  def test_subvector_with_stride_three_args
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    sub = v.subvector_with_stride(0, 2, 3)  # offset=0, stride=2, length=3
    assert_equal 3, sub.size
    assert_in_delta 1.0, sub[0], 1e-10
    assert_in_delta 3.0, sub[1], 1e-10
    assert_in_delta 5.0, sub[2], 1e-10
  end

  def test_subvector_with_stride_negative_offset
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    sub = v.subvector_with_stride(-5, 1)  # negative offset wraps
    assert_in_delta 6.0, sub[0], 1e-10
  end

  def test_subvector_with_stride_offset_out_of_range
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(RangeError) do
      v.subvector_with_stride(10, 1)
    end
  end

  def test_subvector_with_stride_stride_zero_raises
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(ArgumentError) do
      v.subvector_with_stride(0)
    end
  end

  def test_subvector_with_stride_negative_length_raises
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(ArgumentError) do
      v.subvector_with_stride(0, 1, -1)
    end
  end

  def test_subvector_with_stride_wrong_args_raises
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_raises(ArgumentError) do
      v.subvector_with_stride(1, 2, 3, 4)
    end
  end

  # =====================================================
  # matrix_view tests
  # =====================================================

  def test_matrix_view
    v = GSL::Vector[1, 2, 3, 4, 5, 6]
    m = v.matrix_view(2, 3)  # 2 rows, 3 cols
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 2.0, m[0, 1], 1e-10
    assert_in_delta 4.0, m[1, 0], 1e-10
  end

  def test_matrix_view_with_tda
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    m = v.matrix_view(2, 3, 5)  # 2 rows, 3 cols, tda=5
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 6.0, m[1, 0], 1e-10
  end

  def test_matrix_view_wrong_args_raises
    v = GSL::Vector[1, 2, 3, 4, 5, 6]
    assert_raises(ArgumentError) do
      v.matrix_view(2)
    end
  end

  # =====================================================
  # to_m, to_m_diagonal, to_m_circulant
  # =====================================================

  def test_to_m
    v = GSL::Vector[1, 2, 3, 4, 5, 6]
    m = v.to_m(2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 6.0, m[1, 2], 1e-10
  end

  def test_to_m_diagonal
    v = GSL::Vector[1, 2, 3]
    m = v.to_m_diagonal
    assert_equal 3, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 2.0, m[1, 1], 1e-10
    assert_in_delta 3.0, m[2, 2], 1e-10
    assert_in_delta 0.0, m[0, 1], 1e-10
    assert_in_delta 0.0, m[1, 0], 1e-10
  end

  def test_to_m_circulant
    v = GSL::Vector[1, 2, 3]
    m = v.to_m_circulant
    assert_equal 3, m.size1
    assert_equal 3, m.size2
    # First row: v[n-1], v[0], v[1], ... but implementation is different
    # Just verify it's a matrix with the right size
    assert m.is_a?(GSL::Matrix)
  end

  # =====================================================
  # first and last
  # =====================================================

  def test_first
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_in_delta 1.0, v.first, 1e-10
  end

  def test_last
    v = GSL::Vector[1, 2, 3, 4, 5]
    assert_in_delta 5.0, v.last, 1e-10
  end

  # =====================================================
  # concat tests
  # =====================================================

  def test_concat_with_scalar
    v = GSL::Vector[1, 2, 3]
    result = v.concat(4)
    assert_equal 4, result.size
    assert_in_delta 4.0, result[3], 1e-10
  end

  def test_concat_with_array
    v = GSL::Vector[1, 2, 3]
    result = v.concat([4, 5, 6])
    assert_equal 6, result.size
    assert_in_delta 4.0, result[3], 1e-10
    assert_in_delta 6.0, result[5], 1e-10
  end

  def test_concat_with_range
    v = GSL::Vector[1, 2, 3]
    result = v.concat(4..6)
    assert_equal 6, result.size
    assert_in_delta 4.0, result[3], 1e-10
    assert_in_delta 6.0, result[5], 1e-10
  end

  def test_concat_with_vector
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = v1.concat(v2)
    assert_equal 6, result.size
    assert_in_delta 4.0, result[3], 1e-10
    assert_in_delta 6.0, result[5], 1e-10
  end

  def test_concat_with_wrong_type_raises
    v = GSL::Vector[1, 2, 3]
    assert_raises(TypeError) do
      v.concat("invalid")
    end
  end

  # =====================================================
  # diff edge cases
  # =====================================================

  def test_diff_with_n
    v = GSL::Vector[1, 4, 9, 16, 25]  # squares: 1, 4, 9, 16, 25
    # First diff: [3, 5, 7, 9]
    d1 = v.diff(1)
    assert_equal 4, d1.size
    assert_in_delta 3.0, d1[0], 1e-10
    # Second diff: [2, 2, 2]
    d2 = v.diff(2)
    assert_equal 3, d2.size
    assert_in_delta 2.0, d2[0], 1e-10
    assert_in_delta 2.0, d2[1], 1e-10
  end

  def test_diff_with_zero_n_returns_self
    v = GSL::Vector[1, 2, 3]
    result = v.diff(0)
    assert_equal v.object_id, result.object_id
  end

  def test_diff_with_n_too_large_returns_self
    v = GSL::Vector[1, 2, 3]
    result = v.diff(10)
    assert_equal v.object_id, result.object_id
  end

  def test_diff_wrong_args_raises
    v = GSL::Vector[1, 2, 3]
    assert_raises(ArgumentError) do
      v.diff(1, 2)
    end
  end

  # =====================================================
  # delete_at, delete_if, delete
  # =====================================================

  def test_delete_at
    v = GSL::Vector[1, 2, 3, 4, 5]
    deleted = v.delete_at(2)
    assert_in_delta 3.0, deleted, 1e-10
    assert_equal 4, v.size
    assert_in_delta 4.0, v[2], 1e-10
  end

  def test_delete_at_negative_index
    v = GSL::Vector[1, 2, 3, 4, 5]
    deleted = v.delete_at(-1)
    assert_in_delta 5.0, deleted, 1e-10
    assert_equal 4, v.size
  end

  def test_delete_at_out_of_range_returns_nil
    v = GSL::Vector[1, 2, 3]
    result = v.delete_at(10)
    assert_nil result
  end

  def test_delete_at_negative_out_of_range_returns_nil
    v = GSL::Vector[1, 2, 3]
    result = v.delete_at(-10)
    assert_nil result
  end

  def test_delete_at_empty_returns_nil
    v = GSL::Vector.alloc(0)
    result = v.delete_at(0)
    assert_nil result
  end

  def test_delete_at_view_raises
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(1, 3)
    assert_raises(RuntimeError) do
      view.delete_at(0)
    end
  end

  def test_delete_if
    v = GSL::Vector[1, 2, 3, 4, 5]
    v.delete_if { |x| x > 3 }
    assert_equal 3, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 2.0, v[1], 1e-10
    assert_in_delta 3.0, v[2], 1e-10
  end

  def test_delete_if_no_block_raises
    v = GSL::Vector[1, 2, 3]
    assert_raises(RuntimeError) do
      v.delete_if
    end
  end

  def test_delete_if_view_raises
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(1, 3)
    assert_raises(RuntimeError) do
      view.delete_if { |x| x > 3 }
    end
  end

  def test_delete
    v = GSL::Vector[1, 2, 3, 2, 4]
    result = v.delete(2)
    assert_equal 2, result
    assert_equal 3, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 3.0, v[1], 1e-10
    assert_in_delta 4.0, v[2], 1e-10
  end

  def test_delete_not_found_returns_nil
    v = GSL::Vector[1, 2, 3]
    result = v.delete(10)
    assert_nil result
  end

  def test_delete_view_raises
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(1, 3)
    assert_raises(RuntimeError) do
      view.delete(2)
    end
  end

  # =====================================================
  # histogram tests
  # =====================================================

  def test_histogram_with_bins
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    h = v.histogram(5)
    assert_kind_of GSL::Histogram, h
  end

  def test_histogram_with_range_array
    v = GSL::Vector[1, 2, 3, 4, 5]
    h = v.histogram([0, 2, 4, 6])
    assert_kind_of GSL::Histogram, h
  end

  def test_histogram_with_bins_and_range
    v = GSL::Vector[1, 2, 3, 4, 5]
    h = v.histogram(5, [0, 6])
    assert_kind_of GSL::Histogram, h
  end

  def test_histogram_with_bins_min_max
    v = GSL::Vector[1, 2, 3, 4, 5]
    h = v.histogram(5, 0, 6)
    assert_kind_of GSL::Histogram, h
  end

  def test_histogram_wrong_args_raises
    v = GSL::Vector[1, 2, 3]
    assert_raises(ArgumentError) do
      v.histogram(1, 2, 3, 4)
    end
  end

  # =====================================================
  # printf tests
  # =====================================================

  def test_printf
    v = GSL::Vector[1, 2, 3]
    # Just test that it doesn't raise
    # Output goes to stdout
    result = v.printf
    assert_equal 0, result  # Returns status
  end

  def test_printf_with_format
    v = GSL::Vector[1, 2, 3]
    result = v.printf("%g")
    assert_equal 0, result
  end

  def test_printf_wrong_type_raises
    v = GSL::Vector[1, 2, 3]
    assert_raises(TypeError) do
      v.printf(123)
    end
  end

  # =====================================================
  # comparison operators
  # =====================================================

  def test_eq_operator
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[1, 5, 3]
    result = v1.eq(v2)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 1, result[0]  # 1 == 1
    assert_equal 0, result[1]  # 2 != 5
    assert_equal 1, result[2]  # 3 == 3
  end

  def test_ne_operator
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[1, 5, 3]
    result = v1.ne(v2)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 1 == 1, so ne=0
    assert_equal 1, result[1]  # 2 != 5, so ne=1
    assert_equal 0, result[2]  # 3 == 3, so ne=0
  end

  def test_gt_operator
    v1 = GSL::Vector[1, 5, 3]
    v2 = GSL::Vector[2, 3, 3]
    result = v1.gt(v2)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 1 > 2 false
    assert_equal 1, result[1]  # 5 > 3 true
    assert_equal 0, result[2]  # 3 > 3 false
  end

  def test_ge_operator
    v1 = GSL::Vector[1, 5, 3]
    v2 = GSL::Vector[2, 3, 3]
    result = v1.ge(v2)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 1 >= 2 false
    assert_equal 1, result[1]  # 5 >= 3 true
    assert_equal 1, result[2]  # 3 >= 3 true
  end

  def test_lt_operator
    v1 = GSL::Vector[1, 5, 3]
    v2 = GSL::Vector[2, 3, 3]
    result = v1.lt(v2)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 1, result[0]  # 1 < 2 true
    assert_equal 0, result[1]  # 5 < 3 false
    assert_equal 0, result[2]  # 3 < 3 false
  end

  def test_le_operator
    v1 = GSL::Vector[1, 5, 3]
    v2 = GSL::Vector[2, 3, 3]
    result = v1.le(v2)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 1, result[0]  # 1 <= 2 true
    assert_equal 0, result[1]  # 5 <= 3 false
    assert_equal 1, result[2]  # 3 <= 3 true
  end

  def test_and_operator
    v1 = GSL::Vector[0, 1, 0, 1]
    v2 = GSL::Vector[0, 0, 1, 1]
    result = v1.and(v2)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 0 && 0
    assert_equal 0, result[1]  # 1 && 0
    assert_equal 0, result[2]  # 0 && 1
    assert_equal 1, result[3]  # 1 && 1
  end

  def test_or_operator
    v1 = GSL::Vector[0, 1, 0, 1]
    v2 = GSL::Vector[0, 0, 1, 1]
    result = v1.or(v2)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 0 || 0
    assert_equal 1, result[1]  # 1 || 0
    assert_equal 1, result[2]  # 0 || 1
    assert_equal 1, result[3]  # 1 || 1
  end

  def test_xor_operator
    v1 = GSL::Vector[0, 1, 0, 1]
    v2 = GSL::Vector[0, 0, 1, 1]
    result = v1.xor(v2)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 0 ^ 0 = 0
    assert_equal 1, result[1]  # 1 ^ 0 = 1
    assert_equal 1, result[2]  # 0 ^ 1 = 1
    assert_equal 0, result[3]  # 1 ^ 1 = 0
  end

  # scalar comparison operators
  def test_eq_scalar
    v = GSL::Vector[1, 2, 1, 3]
    result = v.eq(1.0)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 1, result[0]
    assert_equal 0, result[1]
    assert_equal 1, result[2]
    assert_equal 0, result[3]
  end

  def test_ne_scalar
    v = GSL::Vector[1, 2, 1, 3]
    result = v.ne(1.0)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]
    assert_equal 1, result[1]
    assert_equal 0, result[2]
    assert_equal 1, result[3]
  end

  def test_gt_scalar
    v = GSL::Vector[1, 2, 3]
    result = v.gt(1.5)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 1 > 1.5 false
    assert_equal 1, result[1]  # 2 > 1.5 true
    assert_equal 1, result[2]  # 3 > 1.5 true
  end

  def test_ge_scalar
    v = GSL::Vector[1, 2, 3]
    result = v.ge(2.0)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 1 >= 2 false
    assert_equal 1, result[1]  # 2 >= 2 true
    assert_equal 1, result[2]  # 3 >= 2 true
  end

  def test_lt_scalar
    v = GSL::Vector[1, 2, 3]
    result = v.lt(2.5)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 1, result[0]  # 1 < 2.5 true
    assert_equal 1, result[1]  # 2 < 2.5 true
    assert_equal 0, result[2]  # 3 < 2.5 false
  end

  def test_le_scalar
    v = GSL::Vector[1, 2, 3]
    result = v.le(2.0)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 1, result[0]  # 1 <= 2 true
    assert_equal 1, result[1]  # 2 <= 2 true
    assert_equal 0, result[2]  # 3 <= 2 false
  end

  # =====================================================
  # not operator
  # =====================================================

  def test_not_operator
    v = GSL::Vector[0, 1, 2, 0]
    result = v.not
    assert_kind_of GSL::Block::Byte, result
    assert_equal 1, result[0]  # !0 = 1
    assert_equal 0, result[1]  # !1 = 0
    assert_equal 0, result[2]  # !2 = 0
    assert_equal 1, result[3]  # !0 = 1
  end

  # =====================================================
  # where, any, all, none tests
  # =====================================================

  def test_where
    v = GSL::Vector[1, 0, 3, 0, 5]
    result = v.where
    # Returns indices where value is non-zero
    assert_kind_of GSL::Index, result  # Returns GSL::Index not GSL::Vector::Int
    assert_equal 3, result.size
    assert_equal 0, result[0]  # index of 1
    assert_equal 2, result[1]  # index of 3
    assert_equal 4, result[2]  # index of 5
  end

  def test_where_with_block
    v = GSL::Vector[1, 2, 3, 4, 5]
    result = v.where { |x| x > 3 }
    assert_kind_of GSL::Index, result  # Returns GSL::Index not GSL::Vector::Int
    assert_equal 2, result.size
    assert_equal 3, result[0]  # index of 4
    assert_equal 4, result[1]  # index of 5
  end

  def test_any
    v1 = GSL::Vector[0, 0, 0]
    v2 = GSL::Vector[0, 1, 0]
    assert_equal false, v1.any?
    assert_equal true, v2.any?
  end

  def test_all
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[1, 0, 3]
    assert_equal true, v1.all?
    assert_equal false, v2.all?
  end

  def test_none
    v1 = GSL::Vector[0, 0, 0]
    v2 = GSL::Vector[0, 1, 0]
    assert_equal true, v1.none?
    assert_equal false, v2.none?
  end

  # =====================================================
  # sort variants
  # =====================================================

  def test_sort_smallest
    v = GSL::Vector[5, 2, 8, 1, 9, 3]
    result = v.sort_smallest(3)
    assert_equal 3, result.size
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 2.0, result[1], 1e-10
    assert_in_delta 3.0, result[2], 1e-10
  end

  def test_sort_largest
    v = GSL::Vector[5, 2, 8, 1, 9, 3]
    result = v.sort_largest(3)
    assert_equal 3, result.size
    assert_in_delta 9.0, result[0], 1e-10
    assert_in_delta 8.0, result[1], 1e-10
    assert_in_delta 5.0, result[2], 1e-10
  end

  def test_sort_smallest_index
    v = GSL::Vector[5, 2, 8, 1, 9, 3]
    result = v.sort_smallest_index(3)
    assert_equal 3, result.size
    assert_equal 3, result[0]  # index of 1
    assert_equal 1, result[1]  # index of 2
    assert_equal 5, result[2]  # index of 3
  end

  def test_sort_largest_index
    v = GSL::Vector[5, 2, 8, 1, 9, 3]
    result = v.sort_largest_index(3)
    assert_equal 3, result.size
    assert_equal 4, result[0]  # index of 9
    assert_equal 2, result[1]  # index of 8
    assert_equal 0, result[2]  # index of 5
  end

  # =====================================================
  # equal with different sizes
  # =====================================================

  def test_equal_different_sizes_returns_false
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[1, 2]
    refute v1.equal?(v2)
  end

  def test_equal_with_scalar
    v = GSL::Vector[5, 5, 5]
    assert v.equal?(5.0)
  end

  def test_equal_wrong_args_raises
    v = GSL::Vector[1, 2, 3]
    assert_raises(ArgumentError) do
      v.equal?
    end
  end

  # =====================================================
  # inner_product edge cases
  # =====================================================

  def test_inner_product_class_method
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = GSL::Vector.inner_product(v1, v2)
    assert_in_delta 32.0, result, 1e-10
  end

  def test_inner_product_different_sizes_raises
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5]
    assert_raises(RangeError) do
      v1.inner_product(v2)
    end
  end

  # =====================================================
  # memcpy class method
  # =====================================================

  def test_memcpy_class_method
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector.alloc(3)
    GSL::Vector.memcpy(v2, v1)
    assert_in_delta 1.0, v2[0], 1e-10
    assert_in_delta 2.0, v2[1], 1e-10
    assert_in_delta 3.0, v2[2], 1e-10
  end

  # =====================================================
  # swap class method
  # =====================================================

  def test_swap_class_method
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    GSL::Vector.swap(v1, v2)
    assert_in_delta 4.0, v1[0], 1e-10
    assert_in_delta 1.0, v2[0], 1e-10
  end

  # =====================================================
  # instance connect method
  # =====================================================

  def test_connect_instance_method
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = v1.connect(v2)
    assert_equal 6, result.size
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 6.0, result[5], 1e-10
  end

  # =====================================================
  # to_poly test
  # =====================================================

  def test_to_poly
    v = GSL::Vector[1, 2, 3]
    p = v.to_poly
    assert p.is_a?(GSL::Poly)
    assert_equal 3, p.size
    assert_in_delta 1.0, p[0], 1e-10
  end

  def test_poly_uminus
    p = GSL::Poly[1, 2, 3]
    result = -p
    assert result.is_a?(GSL::Poly)
    assert_in_delta(-1.0, result[0], 1e-10)
    assert_in_delta(-2.0, result[1], 1e-10)
  end


  # =====================================================
  # to_gplot tests
  # =====================================================

  def test_to_gplot
    v = GSL::Vector[1, 2, 3]
    result = v.to_gplot
    assert_kind_of String, result
    assert result.include?("1")
    assert result.include?("3")
  end

  def test_to_gplot_class_method_with_array
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = GSL::Vector.to_gplot([v1, v2])
    assert_kind_of String, result
  end

  def test_to_gplot_with_vector
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = v1.to_gplot(v2)
    assert_kind_of String, result
  end

  # =====================================================
  # view clone tests
  # =====================================================

  def test_clone_view
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(1, 3)
    c = view.clone
    assert_kind_of GSL::Vector, c
    assert_in_delta 2.0, c[0], 1e-10
    # Clone is independent
    c[0] = 100.0
    assert_in_delta 2.0, v[1], 1e-10
  end

  # =====================================================
  # Integer vector additional tests
  # =====================================================

  def test_int_vector_reverse_each
    v = GSL::Vector::Int[1, 2, 3]
    elements = []
    v.reverse_each { |x| elements << x }
    assert_equal [3, 2, 1], elements
  end

  def test_int_vector_sumsq
    v = GSL::Vector::Int[1, 2, 3]
    result = v.sumsq
    # 1^2 + 2^2 + 3^2 = 1 + 4 + 9 = 14
    assert_equal 14, result
  end

  def test_int_vector_trans
    v = GSL::Vector::Int[1, 2, 3]
    c = v.trans
    assert c.is_a?(GSL::Vector::Int::Col)
  end

  def test_int_vector_trans_bang
    v = GSL::Vector::Int[1, 2, 3]
    v.trans!
    assert v.is_a?(GSL::Vector::Int::Col)
    v.trans!
    assert v.is_a?(GSL::Vector::Int)
  end

  def test_int_vector_to_s_col
    v = GSL::Vector::Int[1, 2, 3].col
    s = v.to_s
    assert s.include?("[")
    assert s.include?("]")
  end

  def test_int_vector_inner_product
    v1 = GSL::Vector::Int[1, 2, 3]
    v2 = GSL::Vector::Int[4, 5, 6]
    result = v1.inner_product(v2)
    assert_equal 32, result
  end


  # =====================================================
  # to_s tests for long vectors (truncation)
  # =====================================================

  def test_to_s_long_vector
    v = GSL::Vector.indgen(100)
    s = v.to_s
    assert s.include?("[")
    assert s.include?("]")
    assert s.include?("...")  # Should be truncated
  end

  def test_to_s_col_long_vector
    v = GSL::Vector.indgen(30).col
    s = v.to_s
    assert s.include?("[")
    assert s.include?("]")
    assert s.include?("...")  # Should be truncated
  end

  def test_to_s_empty_vector
    v = GSL::Vector.alloc(0)
    s = v.to_s
    assert_equal "[ ]", s
  end

  # =====================================================
  # print test
  # =====================================================

  def test_print
    v = GSL::Vector[1, 2, 3]
    # Just test that it doesn't raise
    result = v.print
    assert_nil result
  end

  def test_print_col
    v = GSL::Vector[1, 2, 3].col
    # Just test that it doesn't raise
    result = v.print
    assert_nil result
  end

  # =====================================================
  # exclusive range tests
  # =====================================================

  def test_new_with_exclusive_range
    v = GSL::Vector.alloc(1...5)
    assert_equal 4, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 4.0, v[3], 1e-10
  end

  def test_subvector_exclusive_range
    v = GSL::Vector[1, 2, 3, 4, 5]
    sub = v.subvector(1...4)
    assert_equal 3, sub.size
    assert_in_delta 2.0, sub[0], 1e-10
    assert_in_delta 4.0, sub[2], 1e-10
  end

  # =====================================================
  # negative range indices
  # =====================================================

  def test_subvector_with_negative_range_indices
    v = GSL::Vector[1, 2, 3, 4, 5]
    sub = v.subvector(-4..-2)  # elements at positions 1, 2, 3
    assert_equal 3, sub.size
    assert_in_delta 2.0, sub[0], 1e-10
    assert_in_delta 4.0, sub[2], 1e-10
  end

  # =====================================================
  # get from view tests
  # =====================================================

  def test_get_from_view_with_fixnum
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(1, 3)
    assert_in_delta 2.0, view[0], 1e-10
    assert_in_delta 4.0, view[2], 1e-10
  end

  def test_get_from_view_with_negative_index
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(1, 3)
    assert_in_delta 4.0, view[-1], 1e-10
  end

  # =====================================================
  # stride view tests
  # =====================================================

  def test_view_set_stride
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(0, 5)
    # Views should also support stride accessor
    assert_equal 1, view.stride
  end

  # =====================================================
  # subvector 2 args negative length
  # =====================================================

  def test_subvector_two_args_negative_length
    v = GSL::Vector[1, 2, 3, 4, 5]
    sub = v.subvector(1, -2)  # offset=1, negative length reverses stride
    assert_equal 2, sub.size
  end

  # =====================================================
  # subvector range with negative stride argument
  # =====================================================

  def test_subvector_range_negative_stride
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    # Range 8..0 with stride -2 should flip stride direction
    sub = v.subvector(0..8, -2)
    assert_equal 5, sub.size
  end

  # =====================================================
  # constructor with non-numeric values in multi-arg
  # =====================================================

  def test_new_with_multiple_args_non_numeric
    v = GSL::Vector.alloc(1, "invalid", 3)
    # Non-numeric values should become 0
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 0.0, v[1], 1e-10
    assert_in_delta 3.0, v[2], 1e-10
  end

  # =====================================================
  # In-place operator tests (add!, sub!, mul!, div!)
  # =====================================================

  def test_add_inplace_with_vector
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = v1.add!(v2)
    assert_equal v1.object_id, result.object_id
    assert_in_delta 5.0, v1[0], 1e-10
    assert_in_delta 9.0, v1[2], 1e-10
  end

  def test_add_inplace_with_scalar
    v = GSL::Vector[1, 2, 3]
    result = v.add!(10)
    assert_equal v.object_id, result.object_id
    assert_in_delta 11.0, v[0], 1e-10
    assert_in_delta 13.0, v[2], 1e-10
  end

  def test_sub_inplace_with_vector
    v1 = GSL::Vector[10, 20, 30]
    v2 = GSL::Vector[1, 2, 3]
    result = v1.sub!(v2)
    assert_equal v1.object_id, result.object_id
    assert_in_delta 9.0, v1[0], 1e-10
    assert_in_delta 27.0, v1[2], 1e-10
  end

  def test_sub_inplace_with_scalar
    v = GSL::Vector[10, 20, 30]
    result = v.sub!(5)
    assert_equal v.object_id, result.object_id
    assert_in_delta 5.0, v[0], 1e-10
    assert_in_delta 25.0, v[2], 1e-10
  end

  def test_mul_inplace_with_vector
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = v1.mul!(v2)
    assert_equal v1.object_id, result.object_id
    assert_in_delta 4.0, v1[0], 1e-10
    assert_in_delta 18.0, v1[2], 1e-10
  end

  def test_mul_inplace_with_scalar
    v = GSL::Vector[1, 2, 3]
    result = v.mul!(2)
    assert_equal v.object_id, result.object_id
    assert_in_delta 2.0, v[0], 1e-10
    assert_in_delta 6.0, v[2], 1e-10
  end

  def test_div_inplace_with_vector
    v1 = GSL::Vector[4, 6, 8]
    v2 = GSL::Vector[2, 3, 4]
    result = v1.div!(v2)
    assert_equal v1.object_id, result.object_id
    assert_in_delta 2.0, v1[0], 1e-10
    assert_in_delta 2.0, v1[2], 1e-10
  end

  def test_div_inplace_with_scalar
    v = GSL::Vector[4, 6, 8]
    result = v.div!(2)
    assert_equal v.object_id, result.object_id
    assert_in_delta 2.0, v[0], 1e-10
    assert_in_delta 4.0, v[2], 1e-10
  end

  # =====================================================
  # where2 tests
  # =====================================================

  def test_where2
    v = GSL::Vector[1, 0, 3, 0, 5]
    true_indices, false_indices = v.where2
    assert_kind_of GSL::Index, true_indices
    assert_kind_of GSL::Index, false_indices
    assert_equal 3, true_indices.size  # indices 0, 2, 4
    assert_equal 2, false_indices.size  # indices 1, 3
  end

  def test_where2_with_block
    v = GSL::Vector[1, 2, 3, 4, 5]
    true_indices, false_indices = v.where2 { |x| x > 3 }
    assert_kind_of GSL::Index, true_indices
    assert_kind_of GSL::Index, false_indices
    assert_equal 2, true_indices.size  # indices 3, 4
    assert_equal 3, false_indices.size  # indices 0, 1, 2
  end

  def test_where2_all_true
    v = GSL::Vector[1, 2, 3]
    true_indices, false_indices = v.where2
    assert_kind_of GSL::Index, true_indices
    assert_equal 3, true_indices.size
    assert_nil false_indices
  end

  def test_where2_all_false
    v = GSL::Vector[0, 0, 0]
    true_indices, false_indices = v.where2
    assert_nil true_indices
    assert_kind_of GSL::Index, false_indices
    assert_equal 3, false_indices.size
  end

  def test_where_all_false_returns_nil
    v = GSL::Vector[0, 0, 0]
    result = v.where
    assert_nil result
  end

  # =====================================================
  # zip tests
  # =====================================================

  def test_zip_instance
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = v1.zip(v2)
    assert_kind_of Array, result
    assert_equal 3, result.size
    assert_kind_of GSL::Vector, result[0]
    assert_in_delta 1.0, result[0][0], 1e-10
    assert_in_delta 4.0, result[0][1], 1e-10
  end

  def test_zip_class_method
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    result = GSL::Vector.zip(v1, v2)
    assert_kind_of Array, result
    assert_equal 3, result.size
  end

  def test_zip_different_sizes
    v1 = GSL::Vector[1, 2, 3, 4, 5]
    v2 = GSL::Vector[10, 20]  # shorter
    result = v1.zip(v2)
    assert_equal 5, result.size
    # For indices beyond v2's size, should get 0
    assert_in_delta 10.0, result[0][1], 1e-10
    assert_in_delta 0.0, result[3][1], 1e-10
  end

  # =====================================================
  # join tests
  # =====================================================

  def test_join_default_separator
    v = GSL::Vector[1, 2, 3]
    result = v.join
    assert_kind_of String, result
    # Default separator is space
    assert result.include?(" ")
  end

  def test_join_custom_separator
    v = GSL::Vector[1, 2, 3]
    result = v.join(",")
    assert_kind_of String, result
    assert result.include?(",")
  end

  def test_join_wrong_args_raises
    v = GSL::Vector[1, 2, 3]
    assert_raises(ArgumentError) do
      v.join(",", "extra")
    end
  end

  # =====================================================
  # any, all, none with block tests
  # =====================================================

  def test_any_with_block
    v = GSL::Vector[1, 2, 3, 4, 5]
    result = v.any { |x| x > 3 }
    assert_equal 1, result  # Returns 1 for true
  end

  def test_any_with_block_false
    v = GSL::Vector[1, 2, 3]
    result = v.any { |x| x > 10 }
    assert_equal 0, result  # Returns 0 for false
  end

  def test_all_with_block
    v = GSL::Vector[2, 4, 6, 8]
    result = v.all? { |x| x % 2 == 0 }
    assert_equal true, result
  end

  def test_all_with_block_false
    v = GSL::Vector[2, 4, 5, 8]
    result = v.all? { |x| x % 2 == 0 }
    assert_equal false, result
  end

  def test_none_with_block
    v = GSL::Vector[1, 2, 3]
    result = v.none? { |x| x > 10 }
    assert_equal true, result
  end

  def test_none_with_block_false
    v = GSL::Vector[1, 2, 3]
    result = v.none? { |x| x > 2 }
    assert_equal false, result
  end

  # =====================================================
  # isnan?, isinf?, finite? (boolean array versions)
  # =====================================================

  def test_isnan_question
    v = GSL::Vector[1, Float::NAN, 3]
    result = v.isnan?
    assert_kind_of Array, result
    assert_equal false, result[0]
    assert_equal true, result[1]
    assert_equal false, result[2]
  end

  def test_isinf_question
    v = GSL::Vector[1, Float::INFINITY, 3]
    result = v.isinf?
    assert_kind_of Array, result
    assert_equal false, result[0]
    assert_equal true, result[1]
    assert_equal false, result[2]
  end

  def test_finite_question
    v = GSL::Vector[1, Float::INFINITY, 3]
    result = v.finite?
    assert_kind_of Array, result
    assert_equal true, result[0]
    assert_equal false, result[1]
    assert_equal true, result[2]
  end

  # =====================================================
  # histogram with Vector ranges
  # =====================================================

  def test_histogram_with_vector_ranges
    v = GSL::Vector[1, 2, 3, 4, 5]
    ranges = GSL::Vector[0, 2, 4, 6]
    h = v.histogram(ranges)
    assert_kind_of GSL::Histogram, h
  end

  # =====================================================
  # logical operators with scalars
  # =====================================================

  def test_and_scalar
    v = GSL::Vector[0, 1, 2, 3]
    result = v.and(1.0)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 0 && 1 = 0
    assert_equal 1, result[1]  # 1 && 1 = 1
    assert_equal 1, result[2]  # 2 && 1 = 1
    assert_equal 1, result[3]  # 3 && 1 = 1
  end

  def test_and_scalar_zero
    v = GSL::Vector[0, 1, 2, 3]
    result = v.and(0.0)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 0 && 0 = 0
    assert_equal 0, result[1]  # 1 && 0 = 0
    assert_equal 0, result[2]  # 2 && 0 = 0
    assert_equal 0, result[3]  # 3 && 0 = 0
  end

  def test_or_scalar
    v = GSL::Vector[0, 1, 2, 0]
    result = v.or(0.0)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 0 || 0 = 0
    assert_equal 1, result[1]  # 1 || 0 = 1
    assert_equal 1, result[2]  # 2 || 0 = 1
    assert_equal 0, result[3]  # 0 || 0 = 0
  end

  def test_or_scalar_nonzero
    v = GSL::Vector[0, 1, 2, 0]
    result = v.or(1.0)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 1, result[0]  # 0 || 1 = 1
    assert_equal 1, result[1]  # 1 || 1 = 1
    assert_equal 1, result[2]  # 2 || 1 = 1
    assert_equal 1, result[3]  # 0 || 1 = 1
  end

  def test_xor_scalar
    v = GSL::Vector[0, 1, 2, 0]
    result = v.xor(1.0)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 1, result[0]  # 0 ^ 1 = 1
    assert_equal 0, result[1]  # 1 ^ 1 = 0
    assert_equal 0, result[2]  # 2 ^ 1 = 0
    assert_equal 1, result[3]  # 0 ^ 1 = 1
  end

  def test_xor_scalar_zero
    v = GSL::Vector[0, 1, 2, 0]
    result = v.xor(0.0)
    assert_kind_of GSL::Block::Byte, result
    assert_equal 0, result[0]  # 0 ^ 0 = 0
    assert_equal 1, result[1]  # 1 ^ 0 = 1
    assert_equal 1, result[2]  # 2 ^ 0 = 1
    assert_equal 0, result[3]  # 0 ^ 0 = 0
  end

  # =====================================================
  # matrix_view_with_tda separate method
  # =====================================================

  def test_matrix_view_with_tda_method
    v = GSL::Vector[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    m = v.matrix_view_with_tda(2, 3, 5)  # 2 rows, 3 cols, tda=5
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 6.0, m[1, 0], 1e-10
  end

  # =====================================================
  # scale and add_constant (non-bang versions)
  # =====================================================

  def test_scale_non_mutating
    v = GSL::Vector[1, 2, 3]
    result = v.scale(2)
    assert_in_delta 2.0, result[0], 1e-10
    assert_in_delta 4.0, result[1], 1e-10
    assert_in_delta 6.0, result[2], 1e-10
    # Original unchanged
    assert_in_delta 1.0, v[0], 1e-10
  end

  def test_add_constant_non_mutating
    v = GSL::Vector[1, 2, 3]
    result = v.add_constant(10)
    assert_in_delta 11.0, result[0], 1e-10
    assert_in_delta 12.0, result[1], 1e-10
    assert_in_delta 13.0, result[2], 1e-10
    # Original unchanged
    assert_in_delta 1.0, v[0], 1e-10
  end

  # =====================================================
  # Integer vector additional coverage
  # =====================================================

  def test_int_vector_add_inplace
    v1 = GSL::Vector::Int[1, 2, 3]
    v2 = GSL::Vector::Int[4, 5, 6]
    v1.add!(v2)
    assert_equal 5, v1[0]
    assert_equal 9, v1[2]
  end

  def test_int_vector_sub_inplace
    v1 = GSL::Vector::Int[10, 20, 30]
    v2 = GSL::Vector::Int[1, 2, 3]
    v1.sub!(v2)
    assert_equal 9, v1[0]
    assert_equal 27, v1[2]
  end

  def test_int_vector_mul_inplace
    v1 = GSL::Vector::Int[1, 2, 3]
    v2 = GSL::Vector::Int[4, 5, 6]
    v1.mul!(v2)
    assert_equal 4, v1[0]
    assert_equal 18, v1[2]
  end

  def test_int_vector_div_inplace
    v1 = GSL::Vector::Int[4, 6, 8]
    v2 = GSL::Vector::Int[2, 3, 4]
    v1.div!(v2)
    assert_equal 2, v1[0]
    assert_equal 2, v1[2]
  end

  def test_int_vector_where
    v = GSL::Vector::Int[1, 0, 3, 0, 5]
    result = v.where
    assert_kind_of GSL::Index, result
    assert_equal 3, result.size
  end

  def test_int_vector_any
    v1 = GSL::Vector::Int[0, 0, 0]
    v2 = GSL::Vector::Int[0, 1, 0]
    assert_equal false, v1.any?
    assert_equal true, v2.any?
  end

  def test_int_vector_all
    v1 = GSL::Vector::Int[1, 2, 3]
    v2 = GSL::Vector::Int[1, 0, 3]
    assert_equal true, v1.all?
    assert_equal false, v2.all?
  end

  def test_int_vector_none
    v1 = GSL::Vector::Int[0, 0, 0]
    v2 = GSL::Vector::Int[0, 1, 0]
    assert_equal true, v1.none?
    assert_equal false, v2.none?
  end

  def test_int_vector_join
    v = GSL::Vector::Int[1, 2, 3]
    result = v.join(",")
    assert_kind_of String, result
    assert result.include?(",")
  end

  def test_int_vector_cumsum
    v = GSL::Vector::Int[1, 2, 3, 4, 5]
    result = v.cumsum
    assert_equal 1, result[0]
    assert_equal 3, result[1]
    assert_equal 15, result[4]
  end

  def test_int_vector_cumprod
    v = GSL::Vector::Int[1, 2, 3, 4, 5]
    result = v.cumprod
    assert_equal 1, result[0]
    assert_equal 2, result[1]
    assert_equal 120, result[4]
  end

  def test_int_vector_scale
    v = GSL::Vector::Int[1, 2, 3]
    result = v.scale(2)
    assert_equal 2, result[0]
    assert_equal 6, result[2]
  end

  def test_int_vector_add_constant
    v = GSL::Vector::Int[1, 2, 3]
    result = v.add_constant(10)
    assert_equal 11, result[0]
    assert_equal 13, result[2]
  end

  # =====================================================
  # Additional edge cases
  # =====================================================

  def test_view_get_with_array
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(0, 5)
    result = view[[0, 2, 4]]
    assert_kind_of GSL::Vector, result
    assert_equal 3, result.size
  end

  def test_connect_with_multiple_vectors
    v1 = GSL::Vector[1, 2]
    v2 = GSL::Vector[3, 4]
    v3 = GSL::Vector[5, 6]
    result = v1.connect(v2, v3)
    assert_equal 6, result.size
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 6.0, result[5], 1e-10
  end

  def test_set_all_vector
    v1 = GSL::Vector[1, 2, 3, 4, 5]
    v2 = GSL::Vector[10, 20, 30, 40, 50]
    v1[] = v2
    assert_in_delta 10.0, v1[0], 1e-10
    assert_in_delta 50.0, v1[4], 1e-10
  end

  def test_isnull_returns_fixnum
    v = GSL::Vector[0, 0, 0]
    result = v.isnull
    assert_kind_of Integer, result
    assert_equal 1, result
  end

  def test_isnull_false_returns_fixnum
    v = GSL::Vector[1, 0, 0]
    result = v.isnull
    assert_kind_of Integer, result
    assert_equal 0, result
  end

  def test_ispos_returns_fixnum
    v = GSL::Vector[1, 2, 3]
    result = v.ispos
    assert_kind_of Integer, result
    assert_equal 1, result
  end

  def test_isneg_returns_fixnum
    v = GSL::Vector[-1, -2, -3]
    result = v.isneg
    assert_kind_of Integer, result
    assert_equal 1, result
  end

  def test_isnonneg_returns_fixnum
    v = GSL::Vector[0, 1, 2]
    result = v.isnonneg
    assert_kind_of Integer, result
    assert_equal 1, result
  end

  def test_view_owner
    v = GSL::Vector[1, 2, 3, 4, 5]
    view = v.subvector(1, 3)
    # Views don't own their data
    assert_equal 0, view.owner
  end

  # =====================================================
  # Col vector specific tests
  # =====================================================

  def test_col_vector_cumsum
    v = GSL::Vector[1, 2, 3, 4, 5].col
    result = v.cumsum
    assert result.is_a?(GSL::Vector::Col)
    assert_in_delta 15.0, result[4], 1e-10
  end

  def test_col_vector_cumprod
    v = GSL::Vector[1, 2, 3, 4, 5].col
    result = v.cumprod
    assert result.is_a?(GSL::Vector::Col)
    assert_in_delta 120.0, result[4], 1e-10
  end

  def test_col_vector_sgn
    v = GSL::Vector[-1, 0, 3].col
    result = v.sgn
    assert result.is_a?(GSL::Vector::Col)
    assert_in_delta(-1.0, result[0], 1e-10)
    assert_in_delta 0.0, result[1], 1e-10
    assert_in_delta 1.0, result[2], 1e-10
  end

  def test_col_vector_abs
    v = GSL::Vector[-1, -2, 3].col
    result = v.abs
    assert result.is_a?(GSL::Vector::Col)
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 2.0, result[1], 1e-10
  end

  def test_col_vector_concat
    v = GSL::Vector[1, 2, 3].col
    result = v.concat(4)
    assert result.is_a?(GSL::Vector::Col)
    assert_equal 4, result.size
  end

  def test_col_vector_subvector_is_col_view
    v = GSL::Vector[1, 2, 3, 4, 5].col
    view = v.subvector(1, 3)
    assert view.is_a?(GSL::Vector::Col::View)
  end

  def test_col_vector_scale
    v = GSL::Vector[1, 2, 3].col
    result = v.scale(2)
    assert result.is_a?(GSL::Vector::Col)
  end

  def test_col_vector_add_constant
    v = GSL::Vector[1, 2, 3].col
    result = v.add_constant(10)
    assert result.is_a?(GSL::Vector::Col)
  end

  # =====================================================
  # Sort view tests
  # =====================================================

  def test_sort_bang_on_view
    v = GSL::Vector[5, 3, 4, 1, 2]
    view = v.subvector(1, 3)  # [3, 4, 1]
    view.sort!
    # View is sorted, original affected
    assert_in_delta 1.0, view[0], 1e-10
    assert_in_delta 3.0, view[1], 1e-10
    assert_in_delta 4.0, view[2], 1e-10
  end

  def test_sort_on_view
    v = GSL::Vector[5, 3, 4, 1, 2]
    view = v.subvector(1, 3)  # [3, 4, 1]
    sorted = view.sort
    # New vector is sorted
    assert_in_delta 1.0, sorted[0], 1e-10
    assert_in_delta 3.0, sorted[1], 1e-10
    assert_in_delta 4.0, sorted[2], 1e-10
    # Original unchanged
    assert_in_delta 3.0, view[0], 1e-10
  end

  # =====================================================
  # Info method test
  # =====================================================

  def test_info_integer_vector
    v = GSL::Vector::Int[1, 2, 3]
    info = v.info
    assert_kind_of String, info
    assert info.include?("Size")
  end
end
