require 'test_helper'
require 'tempfile'

class MatrixSourceCoverageTest < GSL::TestCase
  # =====================================================
  # Constructor tests - covering all alloc branches
  # =====================================================

  def test_alloc_with_two_fixnums
    m = GSL::Matrix.alloc(3, 4)
    assert_equal 3, m.size1
    assert_equal 4, m.size2
  end

  def test_alloc_with_single_array
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 6.0, m[1, 2], 1e-10
  end

  def test_alloc_with_multiple_arrays
    m = GSL::Matrix.alloc([1, 2], [3, 4], [5, 6])
    assert_equal 3, m.size1
    assert_equal 2, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 6.0, m[2, 1], 1e-10
  end

  def test_alloc_with_ranges
    m = GSL::Matrix.alloc(1..3, 4..6)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 6.0, m[1, 2], 1e-10
  end

  def test_alloc_with_range_and_shape
    m = GSL::Matrix.alloc(1..6, 2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
  end

  def test_alloc_with_vectors
    v1 = GSL::Vector[1, 2, 3]
    v2 = GSL::Vector[4, 5, 6]
    m = GSL::Matrix.alloc(v1, v2)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 6.0, m[1, 2], 1e-10
  end

  def test_alloc_with_col_vectors
    v1 = GSL::Vector[1, 2, 3].col
    v2 = GSL::Vector[4, 5, 6].col
    m = GSL::Matrix.alloc(v1, v2)
    assert_equal 3, m.size1
    assert_equal 2, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 6.0, m[2, 1], 1e-10
  end

  def test_alloc_with_vector_and_sizes
    v = GSL::Vector[1, 2, 3, 4, 5, 6]
    m = GSL::Matrix.alloc(v, 2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
  end

  def test_alloc_error_no_args
    assert_raises(ArgumentError) { GSL::Matrix.alloc }
  end

  def test_alloc_error_wrong_type
    assert_raises(TypeError) { GSL::Matrix.alloc("invalid") }
  end

  def test_alloc_wrong_arg_count_for_two_args
    assert_raises(ArgumentError) { GSL::Matrix.alloc(3) }
  end

  def test_alloc_array_with_wrong_second_arg
    assert_raises(TypeError) { GSL::Matrix.alloc([1, 2, 3], "invalid") }
  end

  def test_alloc_range_wrong_type
    assert_raises(TypeError) { GSL::Matrix.alloc(1..3, "invalid", "bad") }
  end

  # =====================================================
  # Calloc tests
  # =====================================================

  def test_calloc
    m = GSL::Matrix.calloc(3, 4)
    assert_equal 3, m.size1
    assert_equal 4, m.size2
    assert_in_delta 0.0, m[0, 0], 1e-10
    assert_in_delta 0.0, m[2, 3], 1e-10
  end

  # =====================================================
  # Factory methods tests
  # =====================================================

  def test_eye_single_arg
    m = GSL::Matrix.eye(3)
    assert_equal 3, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 0.0, m[0, 1], 1e-10
  end

  def test_eye_two_args
    m = GSL::Matrix.eye(2, 4)
    assert_equal 2, m.size1
    assert_equal 4, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 1.0, m[1, 1], 1e-10
    assert_in_delta 0.0, m[0, 2], 1e-10
  end

  def test_eye_error_wrong_args
    assert_raises(ArgumentError) { GSL::Matrix.eye(1, 2, 3) }
  end

  def test_ones_single_arg
    m = GSL::Matrix.ones(2)
    assert_equal 2, m.size1
    assert_equal 2, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 1.0, m[1, 1], 1e-10
  end

  def test_ones_two_args
    m = GSL::Matrix.ones(2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
  end

  def test_ones_error_wrong_args
    assert_raises(ArgumentError) { GSL::Matrix.ones(1, 2, 3) }
  end

  def test_zeros_single_arg
    m = GSL::Matrix.zeros(2)
    assert_equal 2, m.size1
    assert_in_delta 0.0, m[0, 0], 1e-10
  end

  def test_zeros_two_args
    m = GSL::Matrix.zeros(2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
  end

  def test_zeros_error_wrong_args
    assert_raises(ArgumentError) { GSL::Matrix.zeros(1, 2, 3) }
  end

  def test_identity
    m = GSL::Matrix.identity(3)
    assert_equal 3, m.size1
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 0.0, m[0, 1], 1e-10
  end

  def test_diagonal_with_fixnum
    m = GSL::Matrix.diagonal(3)
    assert_equal 3, m.size1
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 1.0, m[1, 1], 1e-10
    assert_in_delta 1.0, m[2, 2], 1e-10
  end

  def test_diagonal_with_array
    m = GSL::Matrix.diagonal([1, 2, 3])
    assert_equal 3, m.size1
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 2.0, m[1, 1], 1e-10
    assert_in_delta 3.0, m[2, 2], 1e-10
  end

  def test_diagonal_with_range
    m = GSL::Matrix.diagonal(1..3)
    assert_equal 3, m.size1
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 3.0, m[2, 2], 1e-10
  end

  def test_diagonal_with_vector
    v = GSL::Vector[1, 2, 3]
    m = GSL::Matrix.diagonal(v)
    assert_equal 3, m.size1
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 2.0, m[1, 1], 1e-10
  end

  def test_diagonal_with_multiple_values
    m = GSL::Matrix.diagonal(1, 2, 3)
    assert_equal 3, m.size1
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 2.0, m[1, 1], 1e-10
    assert_in_delta 3.0, m[2, 2], 1e-10
  end

  # =====================================================
  # Get/Set tests with various index types
  # =====================================================

  def test_get_with_two_fixnums
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 4.0, m[1, 1], 1e-10
  end

  def test_get_with_single_fixnum
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_in_delta 1.0, m[0], 1e-10
    assert_in_delta 2.0, m[1], 1e-10
    assert_in_delta 3.0, m[2], 1e-10
  end

  def test_get_with_negative_indices
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_in_delta 4.0, m[-1, -1], 1e-10
    assert_in_delta 3.0, m[-1, 0], 1e-10
    assert_in_delta 4.0, m[-1], 1e-10
  end

  def test_get_with_array
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_in_delta 4.0, m[[1, 1]], 1e-10
    assert_in_delta 3.0, m[[-1, 0]], 1e-10
  end

  def test_get_with_array_wrong_length
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(ArgumentError) { m[[1, 2, 3]] }
  end

  def test_set_with_single_value
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m[] = 5.0
    assert_in_delta 5.0, m[0, 0], 1e-10
    assert_in_delta 5.0, m[1, 1], 1e-10
  end

  def test_set_with_two_fixnums
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m[0, 1] = 10.0
    assert_in_delta 10.0, m[0, 1], 1e-10
  end

  def test_set_with_negative_indices
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m[-1, -1] = 10.0
    assert_in_delta 10.0, m[1, 1], 1e-10
  end

  def test_set_with_array_index
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m[[0, 1]] = 10.0
    assert_in_delta 10.0, m[0, 1], 1e-10
  end

  def test_set_with_array_of_rows
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.set([[10, 20], [30, 40]])
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 40.0, m[1, 1], 1e-10
  end

  def test_set_with_multiple_row_arrays
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.set([10, 20], [30, 40])
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 40.0, m[1, 1], 1e-10
  end

  def test_set_submatrix_with_matrix
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([10, 20, 30, 40], 2, 2)
    m[0, 0, 2, 2] = m2
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 40.0, m[1, 1], 1e-10
  end

  def test_set_submatrix_with_range
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m[0, 0, 2, 2] = 10..13
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 11.0, m[0, 1], 1e-10
    assert_in_delta 12.0, m[1, 0], 1e-10
    assert_in_delta 13.0, m[1, 1], 1e-10
  end

  def test_set_submatrix_size_mismatch_matrix
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([10, 20, 30], 1, 3)
    assert_raises(RangeError) { m[0, 0, 2, 2] = m2 }
  end

  def test_set_submatrix_size_mismatch_range
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(RangeError) { m[0, 0, 2, 2] = 1..5 }
  end

  def test_set_submatrix_row_count_mismatch
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    assert_raises(RangeError) { m[0, 0, 2, 3] = [[1, 2, 3]] }
  end

  def test_set_wrong_arg_count
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(ArgumentError) { m.set(1, 2, 3, 4, 5, 6) }
  end

  # =====================================================
  # Submatrix tests - covering parse_submatrix_args branches
  # =====================================================

  def test_submatrix_no_args
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m.submatrix
    assert_equal 2, sub.size1
    assert_equal 3, sub.size2
  end

  def test_submatrix_single_fixnum
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m.submatrix(4)
    assert_equal 1, sub.size1
    assert_equal 1, sub.size2
    assert_in_delta 5.0, sub[0, 0], 1e-10
  end

  def test_submatrix_nil_nil
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[nil, nil]
    assert_equal 2, sub.size1
    assert_equal 3, sub.size2
  end

  def test_submatrix_nil_range
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[nil, 0..1]
    assert_equal 2, sub.size1
    assert_equal 2, sub.size2
  end

  def test_submatrix_nil_fixnum_returns_col_view
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    col = m[nil, 1]
    assert_equal 2, col.size
    assert_in_delta 2.0, col[0], 1e-10
    assert_in_delta 5.0, col[1], 1e-10
  end

  def test_submatrix_range_nil
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[0..0, nil]
    assert_equal 1, sub.size1
    assert_equal 3, sub.size2
  end

  def test_submatrix_range_range
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[0..1, 1..2]
    assert_equal 2, sub.size1
    assert_equal 2, sub.size2
  end

  def test_submatrix_range_fixnum_returns_col_view
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    col = m[0..1, 0]
    assert_equal 2, col.size
  end

  def test_submatrix_fixnum_nil_returns_row_view
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    row = m[0, nil]
    assert_equal 3, row.size
    assert_in_delta 1.0, row[0], 1e-10
    assert_in_delta 3.0, row[2], 1e-10
  end

  def test_submatrix_fixnum_range_returns_row_view
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    row = m[0, 1..2]
    assert_equal 2, row.size
    assert_in_delta 2.0, row[0], 1e-10
  end

  def test_submatrix_fixnum_fixnum
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m.submatrix(0, 0)
    assert_equal 1, sub.size1
    assert_equal 1, sub.size2
  end

  def test_submatrix_negative_fixnum
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[-1, -1]
    assert_in_delta 6.0, sub, 1e-10
  end

  def test_submatrix_three_args_nil_fixnum_fixnum
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[nil, 1, 2]
    assert_equal 2, sub.size1
    assert_equal 2, sub.size2
  end

  def test_submatrix_three_args_range_fixnum_fixnum
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[0..1, 0, 2]
    assert_equal 2, sub.size1
    assert_equal 2, sub.size2
  end

  def test_submatrix_three_args_fixnum_fixnum_nil
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[0, 2, nil]
    assert_equal 2, sub.size1
    assert_equal 3, sub.size2
  end

  def test_submatrix_three_args_fixnum_fixnum_range
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[0, 2, 0..2]
    assert_equal 2, sub.size1
    assert_equal 3, sub.size2
  end

  def test_submatrix_three_args_wrong_third_type
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    assert_raises(ArgumentError) { m[0, 2, "bad"] }
  end

  def test_submatrix_four_args
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[0, 0, 2, 2]
    assert_equal 2, sub.size1
    assert_equal 2, sub.size2
  end

  def test_submatrix_too_many_args
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    assert_raises(ArgumentError) { m[0, 0, 1, 1, 1] }
  end

  def test_submatrix_range_begin_greater_than_end
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    # This depends on Ruby range behavior - (3..1) is empty with step -1
    # The C code raises RangeError for step < 0
    assert_raises(RangeError) { m[nil, 2..0] }
  end

  def test_submatrix_range_begin_greater_than_end_first_arg
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    assert_raises(RangeError) { m[1..0, nil] }
  end

  # =====================================================
  # Row/Column operations
  # =====================================================

  def test_get_row
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    r = m.get_row(0)
    assert_equal 3, r.size  # Row has 3 columns
    assert_in_delta 1.0, r[0], 1e-10
    assert_in_delta 2.0, r[1], 1e-10
    assert_in_delta 3.0, r[2], 1e-10
  end

  def test_get_col
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    c = m.get_col(0)
    assert_equal 2, c.size  # Column has 2 rows
    assert_in_delta 1.0, c[0], 1e-10
    assert_in_delta 4.0, c[1], 1e-10
  end

  def test_set_row_with_array
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    m.set_row(0, [10, 20, 30])
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 30.0, m[0, 2], 1e-10
  end

  def test_set_row_with_vector
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    v = GSL::Vector[10, 20, 30]
    m.set_row(0, v)
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 30.0, m[0, 2], 1e-10
  end

  def test_set_row_with_range
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    m.set_row(0, 10..12)
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 12.0, m[0, 2], 1e-10
  end

  def test_set_col_with_array
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    m.set_col(0, [10, 20])
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 20.0, m[1, 0], 1e-10
  end

  def test_set_col_with_vector
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    v = GSL::Vector[10, 20]
    m.set_col(0, v)
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 20.0, m[1, 0], 1e-10
  end

  def test_set_col_with_range
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    m.set_col(0, 10..11)
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 11.0, m[1, 0], 1e-10
  end

  def test_row_view
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    row = m.row(0)
    assert_equal 3, row.size
    assert_in_delta 1.0, row[0], 1e-10
    # Modifying the view modifies the matrix
    row[0] = 10.0
    assert_in_delta 10.0, m[0, 0], 1e-10
  end

  def test_column_view
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    col = m.col(0)
    assert_equal 2, col.size
    assert_in_delta 1.0, col[0], 1e-10
    assert_in_delta 4.0, col[1], 1e-10
  end

  def test_subrow
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m.subrow(0, 1, 2)
    assert_equal 2, sub.size
    assert_in_delta 2.0, sub[0], 1e-10
    assert_in_delta 3.0, sub[1], 1e-10
  end

  def test_subcolumn
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m.subcolumn(0, 0, 2)
    assert_equal 2, sub.size
    assert_in_delta 1.0, sub[0], 1e-10
    assert_in_delta 4.0, sub[1], 1e-10
  end

  def test_diagonal_view
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    diag = m.diagonal
    assert_equal 2, diag.size
    assert_in_delta 1.0, diag[0], 1e-10
    assert_in_delta 4.0, diag[1], 1e-10
  end

  def test_subdiagonal
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3)
    sub = m.subdiagonal(1)
    assert_equal 2, sub.size
    assert_in_delta 4.0, sub[0], 1e-10
  end

  def test_superdiagonal
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3)
    sup = m.superdiagonal(1)
    assert_equal 2, sup.size
    assert_in_delta 2.0, sup[0], 1e-10
  end

  # =====================================================
  # Set diagonal tests
  # =====================================================

  def test_set_diagonal_with_scalar
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.set_diagonal(10)
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 10.0, m[1, 1], 1e-10
  end

  def test_set_diagonal_with_array
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.set_diagonal([10, 20])
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 20.0, m[1, 1], 1e-10
  end

  def test_set_diagonal_with_vector
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    v = GSL::Vector[10, 20]
    m.set_diagonal(v)
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 20.0, m[1, 1], 1e-10
  end

  def test_set_diagonal_wrong_type
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(TypeError) { m.set_diagonal("invalid") }
  end

  # =====================================================
  # Swap operations
  # =====================================================

  def test_swap_rows_bang
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.swap_rows!(0, 1)
    assert_in_delta 3.0, m[0, 0], 1e-10
    assert_in_delta 1.0, m[1, 0], 1e-10
  end

  def test_swap_rows
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = m.swap_rows(0, 1)
    assert_in_delta 3.0, m2[0, 0], 1e-10
    assert_in_delta 1.0, m2[1, 0], 1e-10
    # Original unchanged
    assert_in_delta 1.0, m[0, 0], 1e-10
  end

  def test_swap_columns_bang
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.swap_columns!(0, 1)
    assert_in_delta 2.0, m[0, 0], 1e-10
    assert_in_delta 1.0, m[0, 1], 1e-10
  end

  def test_swap_columns
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = m.swap_columns(0, 1)
    assert_in_delta 2.0, m2[0, 0], 1e-10
    assert_in_delta 1.0, m[0, 0], 1e-10
  end

  def test_swap_rowcol_bang
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.swap_rowcol!(0, 1)
    # Row 0 swaps with col 1
    assert_in_delta 2.0, m[0, 0], 1e-10
    assert_in_delta 4.0, m[0, 1], 1e-10
  end

  def test_swap_rowcol
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = m.swap_rowcol(0, 1)
    assert_in_delta 2.0, m2[0, 0], 1e-10
    # Original unchanged
    assert_in_delta 1.0, m[0, 0], 1e-10
  end

  def test_swap_singleton
    m1 = GSL::Matrix.alloc([1, 2], 1, 2)
    m2 = GSL::Matrix.alloc([3, 4], 1, 2)
    GSL::Matrix.swap(m1, m2)
    assert_in_delta 3.0, m1[0, 0], 1e-10
    assert_in_delta 1.0, m2[0, 0], 1e-10
  end

  # =====================================================
  # Transpose tests
  # =====================================================

  def test_transpose
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    t = m.transpose
    assert_equal 3, t.size1
    assert_equal 2, t.size2
    assert_in_delta 1.0, t[0, 0], 1e-10
    assert_in_delta 4.0, t[0, 1], 1e-10
  end

  def test_transpose_bang
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.transpose!
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 3.0, m[0, 1], 1e-10
    assert_in_delta 2.0, m[1, 0], 1e-10
  end

  # =====================================================
  # Min/Max tests
  # =====================================================

  def test_max
    m = GSL::Matrix.alloc([1, 5, 2, 4], 2, 2)
    assert_in_delta 5.0, m.max, 1e-10
  end

  def test_min
    m = GSL::Matrix.alloc([1, 5, 2, 4], 2, 2)
    assert_in_delta 1.0, m.min, 1e-10
  end

  def test_minmax
    m = GSL::Matrix.alloc([1, 5, 2, 4], 2, 2)
    min, max = m.minmax
    assert_in_delta 1.0, min, 1e-10
    assert_in_delta 5.0, max, 1e-10
  end

  def test_max_index
    m = GSL::Matrix.alloc([1, 5, 2, 4], 2, 2)
    i, j = m.max_index
    assert_equal 0, i
    assert_equal 1, j
  end

  def test_min_index
    m = GSL::Matrix.alloc([1, 5, 2, 4], 2, 2)
    i, j = m.min_index
    assert_equal 0, i
    assert_equal 0, j
  end

  def test_minmax_index
    m = GSL::Matrix.alloc([1, 5, 2, 4], 2, 2)
    min_idx, max_idx = m.minmax_index
    assert_equal [0, 0], min_idx
    assert_equal [0, 1], max_idx
  end

  # =====================================================
  # File I/O tests
  # =====================================================

  def test_fwrite_and_fread
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    Tempfile.create('matrix') do |f|
      m.fwrite(f.path)
      m2 = GSL::Matrix.alloc(2, 2)
      m2.fread(f.path)
      assert_in_delta 1.0, m2[0, 0], 1e-10
      assert_in_delta 4.0, m2[1, 1], 1e-10
    end
  end

  def test_fprintf_and_fscanf
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    Tempfile.create('matrix') do |f|
      m.fprintf(f.path)
      m2 = GSL::Matrix.alloc(2, 2)
      m2.fscanf(f.path)
      assert_in_delta 1.0, m2[0, 0], 1e-10
      assert_in_delta 4.0, m2[1, 1], 1e-10
    end
  end

  def test_fprintf_with_format
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    Tempfile.create('matrix') do |f|
      m.fprintf(f.path, "%g")
      content = File.read(f.path)
      assert content.include?("1")
    end
  end

  def test_fprintf_wrong_arg_count
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(ArgumentError) { m.fprintf }
  end

  # =====================================================
  # Isnull tests
  # =====================================================

  def test_isnull
    m = GSL::Matrix.alloc([0, 0, 0, 0], 2, 2)
    assert_equal 1, m.isnull
  end

  def test_isnull_false
    m = GSL::Matrix.alloc([1, 0, 0, 0], 2, 2)
    assert_equal 0, m.isnull
  end

  def test_isnull_question
    m = GSL::Matrix.alloc([0, 0, 0, 0], 2, 2)
    assert_equal true, m.isnull?
  end

  def test_isnull_question_false
    m = GSL::Matrix.alloc([1, 0, 0, 0], 2, 2)
    assert_equal false, m.isnull?
  end

  # =====================================================
  # Matrix operations
  # =====================================================

  def test_trace
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_in_delta 5.0, m.trace, 1e-10
  end

  def test_uplus
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    p = +m
    assert_equal m.object_id, p.object_id
  end

  def test_uminus
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    neg = -m
    assert_in_delta(-1.0, neg[0, 0], 1e-10)
    assert_in_delta(-4.0, neg[1, 1], 1e-10)
  end

  def test_power
    m = GSL::Matrix.alloc([1, 2, 2, 1], 2, 2)
    m2 = m ** 2
    # [1,2;2,1]^2 = [5,4;4,5]
    assert_in_delta 5.0, m2[0, 0], 1e-10
    assert_in_delta 4.0, m2[0, 1], 1e-10
  end

  def test_scale_bang
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.scale!(2)
    assert_in_delta 2.0, m[0, 0], 1e-10
    assert_in_delta 8.0, m[1, 1], 1e-10
  end

  def test_scale
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = m.scale(2)
    assert_in_delta 2.0, m2[0, 0], 1e-10
    assert_in_delta 1.0, m[0, 0], 1e-10  # Original unchanged
  end

  def test_add_constant_bang
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.add_constant!(10)
    assert_in_delta 11.0, m[0, 0], 1e-10
  end

  def test_add_constant
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = m.add_constant(10)
    assert_in_delta 11.0, m2[0, 0], 1e-10
    assert_in_delta 1.0, m[0, 0], 1e-10
  end

  # =====================================================
  # Equality tests
  # =====================================================

  def test_equal
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_equal true, m1.equal?(m2)
  end

  def test_equal_with_epsilon
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([1.0001, 2, 3, 4], 2, 2)
    assert_equal true, m1.equal?(m2, 0.001)
  end

  def test_equal_different_size
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([1, 2, 3], 1, 3)
    assert_equal false, m1.equal?(m2)
  end

  def test_equal_wrong_args
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(ArgumentError) { m1.equal?(m2, 0.001, "extra") }
  end

  def test_equal_singleton_two_args
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_equal true, GSL::Matrix.equal?(m1, m2)
  end

  def test_equal_singleton_three_args
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([1.0001, 2, 3, 4], 2, 2)
    assert_equal true, GSL::Matrix.equal?(m1, m2, 0.001)
  end

  def test_equal_singleton_wrong_args
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(ArgumentError) { GSL::Matrix.equal?(m1) }
  end

  # =====================================================
  # Iterator tests
  # =====================================================

  def test_each_row
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    rows = []
    m.each_row { |r| rows << r.to_a }
    assert_equal 2, rows.size
    assert_in_delta 1.0, rows[0][0], 1e-10
    assert_in_delta 4.0, rows[1][0], 1e-10
  end

  def test_each_col
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    cols = []
    m.each_col { |c| cols << c.to_a }
    assert_equal 3, cols.size
    assert_in_delta 1.0, cols[0][0], 1e-10
    assert_in_delta 4.0, cols[0][1], 1e-10
  end

  def test_collect
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = m.collect { |x| x * 2 }
    assert_in_delta 2.0, m2[0, 0], 1e-10
    assert_in_delta 8.0, m2[1, 1], 1e-10
    assert_in_delta 1.0, m[0, 0], 1e-10  # Original unchanged
  end

  def test_collect_bang
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.collect! { |x| x * 2 }
    assert_in_delta 2.0, m[0, 0], 1e-10
    assert_in_delta 8.0, m[1, 1], 1e-10
  end

  # =====================================================
  # Upper/Lower triangular
  # =====================================================

  def test_upper
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3)
    u = m.upper
    assert_in_delta 1.0, u[0, 0], 1e-10
    assert_in_delta 2.0, u[0, 1], 1e-10
    assert_in_delta 0.0, u[1, 0], 1e-10
    assert_in_delta 5.0, u[1, 1], 1e-10
  end

  def test_lower
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3)
    l = m.lower
    assert_in_delta 1.0, l[0, 0], 1e-10
    assert_in_delta 0.0, l[0, 1], 1e-10
    assert_in_delta 4.0, l[1, 0], 1e-10
    assert_in_delta 5.0, l[1, 1], 1e-10
  end

  # =====================================================
  # Special matrices
  # =====================================================

  def test_pascal
    p = GSL::Matrix.pascal(3)
    assert_equal 3, p.size1
    # Pascal matrix: top row all 1s, left col all 1s
    assert_in_delta 1.0, p[0, 0], 1e-10
    assert_in_delta 1.0, p[0, 2], 1e-10
    assert_in_delta 1.0, p[2, 0], 1e-10
    # Middle elements are binomial coefficients
    assert_in_delta 2.0, p[1, 1], 1e-10
    assert_in_delta 6.0, p[2, 2], 1e-10
  end

  def test_hilbert
    h = GSL::Matrix.hilbert(3)
    assert_equal 3, h.size1
    assert_in_delta 1.0, h[0, 0], 1e-10  # 1/(0+0+1) = 1
    assert_in_delta 0.5, h[0, 1], 1e-10  # 1/(0+1+1) = 0.5
  end

  def test_invhilbert
    ih = GSL::Matrix.invhilbert(3)
    assert_equal 3, ih.size1
    # Verify it's the inverse of hilbert by multiplying
    h = GSL::Matrix.hilbert(3)
    product = ih * h
    # Should be close to identity
    assert_in_delta 1.0, product[0, 0], 1e-8
    assert_in_delta 0.0, product[0, 1], 1e-8
  end

  def test_vandermonde_with_vector
    v = GSL::Vector[1, 2, 3]
    vm = GSL::Matrix.vandermonde(v)
    assert_equal 3, vm.size1
    assert_equal 3, vm.size2
  end

  def test_vandermonde_with_array
    vm = GSL::Matrix.vandermonde([1, 2, 3])
    assert_equal 3, vm.size1
    assert_equal 3, vm.size2
  end

  def test_vandermonde_wrong_type
    assert_raises(TypeError) { GSL::Matrix.vandermonde("invalid") }
  end

  def test_toeplitz_with_vector
    v = GSL::Vector[1, 2, 3]
    t = GSL::Matrix.toeplitz(v)
    assert_equal 3, t.size1
    assert_in_delta 1.0, t[0, 0], 1e-10
    assert_in_delta 2.0, t[0, 1], 1e-10
    assert_in_delta 2.0, t[1, 0], 1e-10
  end

  def test_toeplitz_with_array
    t = GSL::Matrix.toeplitz([1, 2, 3])
    assert_equal 3, t.size1
  end

  def test_toeplitz_wrong_type
    assert_raises(TypeError) { GSL::Matrix.toeplitz("invalid") }
  end

  def test_circulant_with_vector
    v = GSL::Vector[1, 2, 3]
    c = GSL::Matrix.circulant(v)
    assert_equal 3, c.size1
    assert_equal 3, c.size2
  end

  def test_circulant_with_array
    c = GSL::Matrix.circulant([1, 2, 3])
    assert_equal 3, c.size1
  end

  def test_circulant_wrong_type
    assert_raises(TypeError) { GSL::Matrix.circulant("invalid") }
  end

  # =====================================================
  # Indgen tests
  # =====================================================

  def test_indgen_singleton
    m = GSL::Matrix.indgen(2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 0.0, m[0, 0], 1e-10
    assert_in_delta 5.0, m[1, 2], 1e-10
  end

  def test_indgen_singleton_with_start
    m = GSL::Matrix.indgen(2, 3, 10)
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 15.0, m[1, 2], 1e-10
  end

  def test_indgen_singleton_with_step
    m = GSL::Matrix.indgen(2, 3, 0, 2)
    assert_in_delta 0.0, m[0, 0], 1e-10
    assert_in_delta 10.0, m[1, 2], 1e-10
  end

  def test_indgen_singleton_wrong_args
    assert_raises(ArgumentError) { GSL::Matrix.indgen(1) }
  end

  def test_indgen_instance
    m = GSL::Matrix.alloc(2, 3)
    m2 = m.indgen
    assert_in_delta 0.0, m2[0, 0], 1e-10
    assert_in_delta 5.0, m2[1, 2], 1e-10
  end

  def test_indgen_instance_with_start
    m = GSL::Matrix.alloc(2, 3)
    m2 = m.indgen(10)
    assert_in_delta 10.0, m2[0, 0], 1e-10
  end

  def test_indgen_instance_with_step
    m = GSL::Matrix.alloc(2, 3)
    m2 = m.indgen(0, 2)
    assert_in_delta 10.0, m2[1, 2], 1e-10
  end

  def test_indgen_instance_wrong_args
    m = GSL::Matrix.alloc(2, 3)
    assert_raises(ArgumentError) { m.indgen(1, 2, 3) }
  end

  def test_indgen_bang
    m = GSL::Matrix.alloc(2, 3)
    m.indgen!
    assert_in_delta 0.0, m[0, 0], 1e-10
    assert_in_delta 5.0, m[1, 2], 1e-10
  end

  def test_indgen_bang_with_start_and_step
    m = GSL::Matrix.alloc(2, 3)
    m.indgen!(10, 2)
    assert_in_delta 10.0, m[0, 0], 1e-10
    assert_in_delta 20.0, m[1, 2], 1e-10
  end

  def test_indgen_bang_wrong_args
    m = GSL::Matrix.alloc(2, 3)
    assert_raises(ArgumentError) { m.indgen!(1, 2, 3) }
  end

  # =====================================================
  # Conversion tests
  # =====================================================

  def test_to_a
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    a = m.to_a
    assert_equal 2, a.size
    assert_equal 2, a[0].size
    assert_in_delta 1.0, a[0][0], 1e-10
    assert_in_delta 4.0, a[1][1], 1e-10
  end

  def test_to_v
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    v = m.to_v
    assert_equal 4, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 4.0, v[3], 1e-10
  end

  def test_to_v_column_matrix
    m = GSL::Matrix.alloc([1, 2, 3, 4], 4, 1)
    v = m.to_v
    # When matrix has size1 > 1 and size2 == 1, returns a column vector
    assert v.is_a?(GSL::Vector::Col)
  end

  def test_to_vview
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    v = m.to_vview
    assert_equal 4, v.size
    # Modifying the view modifies the matrix
    v[0] = 10.0
    assert_in_delta 10.0, m[0, 0], 1e-10
  end

  def test_vector_view
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    v = m.vector_view
    assert_equal 4, v.size
  end

  # =====================================================
  # Norm tests
  # =====================================================

  def test_norm
    m = GSL::Matrix.alloc([3, 4], 1, 2)
    assert_in_delta 5.0, m.norm, 1e-10  # sqrt(9+16) = 5
  end

  # =====================================================
  # Reverse operations
  # =====================================================

  def test_reverse_columns
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    r = m.reverse_columns
    assert_in_delta 3.0, r[0, 0], 1e-10
    assert_in_delta 1.0, r[0, 2], 1e-10
  end

  def test_reverse_columns_bang
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    m.reverse_columns!
    assert_in_delta 3.0, m[0, 0], 1e-10
  end

  def test_reverse_rows
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    r = m.reverse_rows
    assert_in_delta 4.0, r[0, 0], 1e-10
    assert_in_delta 1.0, r[1, 0], 1e-10
  end

  def test_reverse_rows_bang
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    m.reverse_rows!
    assert_in_delta 4.0, m[0, 0], 1e-10
  end

  # =====================================================
  # Block tests
  # =====================================================

  def test_block
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    b = m.block
    assert_kind_of GSL::Block, b
  end

  # =====================================================
  # Info tests
  # =====================================================

  def test_info
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    info = m.info
    assert info.include?("Dimension")
    assert info.include?("2x2")
  end

  # =====================================================
  # Any/All tests
  # =====================================================

  def test_any
    m = GSL::Matrix.alloc([0, 0, 1, 0, 0, 0], 2, 3)
    result = m.any
    assert_kind_of GSL::Vector::Int, result
    assert_equal 3, result.size
    assert_equal 0, result[0]
    assert_equal 0, result[1]
    assert_equal 1, result[2]
  end

  def test_all
    m = GSL::Matrix.alloc([1, 1, 0, 1, 1, 1], 2, 3)
    result = m.all
    assert_kind_of GSL::Vector::Int, result
    assert_equal 3, result.size
    assert_equal 1, result[0]
    assert_equal 1, result[1]
    assert_equal 0, result[2]
  end

  # =====================================================
  # Rot90 tests
  # =====================================================

  def test_rot90
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    r = m.rot90
    assert_equal 2, r.size1
    assert_equal 2, r.size2
  end

  def test_rot90_with_arg
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    r0 = m.rot90(0)
    r2 = m.rot90(2)
    r3 = m.rot90(3)
    assert_equal 2, r0.size1
    assert_equal 2, r2.size1
    assert_equal 2, r3.size1
  end

  def test_rot90_wrong_args
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(ArgumentError) { m.rot90(1, 2) }
  end

  # =====================================================
  # Diff tests
  # =====================================================

  def test_diff
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 3, 2)
    d = m.diff
    assert_equal 2, d.size1  # 3 - 1 = 2
    assert_equal 2, d.size2
  end

  def test_diff_with_n
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3)
    d = m.diff(2)
    assert_equal 1, d.size1  # 3 - 2 = 1
    assert_equal 3, d.size2
  end

  def test_diff_wrong_args
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(ArgumentError) { m.diff(1, 2) }
  end

  # =====================================================
  # Test functions
  # =====================================================

  def test_isnan
    m = GSL::Matrix.alloc([1, Float::NAN, 3, 4], 2, 2)
    result = m.isnan
    assert_kind_of GSL::Matrix::Int, result
    assert_equal 0, result[0, 0]
    assert_equal 1, result[0, 1]
  end

  def test_isinf
    m = GSL::Matrix.alloc([1, Float::INFINITY, 3, 4], 2, 2)
    result = m.isinf
    assert_kind_of GSL::Matrix::Int, result
    assert_equal 0, result[0, 0]
    assert_equal 1, result[0, 1]
  end

  def test_finite
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    result = m.finite
    assert_kind_of GSL::Matrix::Int, result
    assert_equal 1, result[0, 0]
    assert_equal 1, result[1, 1]
  end

  def test_sgn
    m = GSL::Matrix.alloc([-1, 0, 1, 2], 2, 2)
    result = m.sgn
    assert_in_delta(-1.0, result[0, 0], 1e-10)
    assert_in_delta 0.0, result[0, 1], 1e-10
    assert_in_delta 1.0, result[1, 0], 1e-10
    assert_in_delta 1.0, result[1, 1], 1e-10
  end

  def test_abs
    m = GSL::Matrix.alloc([-1, -2, 3, -4], 2, 2)
    result = m.abs
    assert_in_delta 1.0, result[0, 0], 1e-10
    assert_in_delta 2.0, result[0, 1], 1e-10
    assert_in_delta 3.0, result[1, 0], 1e-10
    assert_in_delta 4.0, result[1, 1], 1e-10
  end

  # =====================================================
  # Horzcat/Vertcat tests
  # =====================================================

  def test_horzcat
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([5, 6, 7, 8], 2, 2)
    h = m1.horzcat(m2)
    assert_equal 2, h.size1
    assert_equal 4, h.size2
    assert_in_delta 1.0, h[0, 0], 1e-10
    assert_in_delta 5.0, h[0, 2], 1e-10
  end

  def test_horzcat_different_rows
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([5, 6, 7], 1, 3)
    assert_raises(RuntimeError) { m1.horzcat(m2) }
  end

  def test_horzcat_singleton
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([5, 6, 7, 8], 2, 2)
    h = GSL::Matrix.horzcat(m1, m2)
    assert_equal 4, h.size2
  end

  def test_vertcat
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([5, 6, 7, 8], 2, 2)
    v = m1.vertcat(m2)
    assert_equal 4, v.size1
    assert_equal 2, v.size2
    assert_in_delta 1.0, v[0, 0], 1e-10
    assert_in_delta 5.0, v[2, 0], 1e-10
  end

  def test_vertcat_different_cols
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([5, 6, 7], 1, 3)
    assert_raises(RuntimeError) { m1.vertcat(m2) }
  end

  def test_vertcat_singleton
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([5, 6, 7, 8], 2, 2)
    v = GSL::Matrix.vertcat(m1, m2)
    assert_equal 4, v.size1
  end

  # =====================================================
  # Symmetrize tests
  # =====================================================

  def test_symmetrize
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    s = m.symmetrize
    assert_in_delta 1.0, s[0, 0], 1e-10
    assert_in_delta 2.0, s[0, 1], 1e-10
    assert_in_delta 2.0, s[1, 0], 1e-10  # Copies from [0,1]
    assert_in_delta 4.0, s[1, 1], 1e-10
  end

  def test_symmetrize_not_square
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    assert_raises(RuntimeError) { m.symmetrize }
  end

  def test_symmetrize_bang
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.symmetrize!
    assert_in_delta 2.0, m[1, 0], 1e-10
  end

  def test_symmetrize_bang_not_square
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    assert_raises(RuntimeError) { m.symmetrize! }
  end

  # =====================================================
  # Clone/Memcpy tests
  # =====================================================

  def test_clone
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    c = m.clone
    assert_in_delta 1.0, c[0, 0], 1e-10
    c[0, 0] = 10.0
    assert_in_delta 1.0, m[0, 0], 1e-10  # Original unchanged
  end

  def test_memcpy
    m1 = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix.alloc([0, 0, 0, 0], 2, 2)
    GSL::Matrix.memcpy(m1, m2)
    assert_in_delta 0.0, m1[0, 0], 1e-10
  end

  # =====================================================
  # To_s/Inspect tests with various sizes
  # =====================================================

  def test_to_s_small_matrix
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    s = m.to_s
    assert s.include?("[")
    assert s.include?("]")
  end

  def test_to_s_large_matrix_rows
    m = GSL::Matrix.alloc(25, 2)
    m.indgen!
    s = m.to_s
    assert s.include?("...")  # Should truncate after 20 rows
  end

  def test_to_s_large_matrix_cols
    m = GSL::Matrix.alloc(2, 20)
    m.indgen!
    s = m.to_s
    assert s.include?("...")  # Should truncate columns
  end

  def test_to_s_negative_values
    m = GSL::Matrix.alloc([-1, 2, -3, 4], 2, 2)
    s = m.to_s
    assert s.include?("-")
  end

  def test_inspect
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    i = m.inspect
    assert i.include?("GSL::Matrix")
    assert i.include?("[")
  end

  def test_print
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    # Just verify it doesn't crash - output goes to stdout
    result = m.print
    assert_nil result
  end

  def test_printf_no_args
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    # Just verify it returns a status
    status = m.printf
    assert_kind_of Integer, status
  end

  def test_printf_with_format
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    status = m.printf("%g")
    assert_kind_of Integer, status
  end

  # =====================================================
  # set_all/set_zero/set_identity tests
  # =====================================================

  def test_set_all
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.set_all(5.0)
    assert_in_delta 5.0, m[0, 0], 1e-10
    assert_in_delta 5.0, m[0, 1], 1e-10
    assert_in_delta 5.0, m[1, 0], 1e-10
    assert_in_delta 5.0, m[1, 1], 1e-10
  end

  def test_set_zero
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    m.set_zero
    assert_in_delta 0.0, m[0, 0], 1e-10
    assert_in_delta 0.0, m[1, 1], 1e-10
  end

  def test_set_identity
    m = GSL::Matrix.alloc([0, 0, 0, 0], 2, 2)
    m.set_identity
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 0.0, m[0, 1], 1e-10
    assert_in_delta 0.0, m[1, 0], 1e-10
    assert_in_delta 1.0, m[1, 1], 1e-10
  end

  # =====================================================
  # ispos/isneg/isnonneg tests
  # =====================================================

  def test_ispos
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_equal 1, m.ispos
  end

  def test_ispos_false
    m = GSL::Matrix.alloc([1, -2, 3, 4], 2, 2)
    assert_equal 0, m.ispos
  end

  def test_ispos_question
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    assert_equal true, m.ispos?
  end

  def test_ispos_question_false
    m = GSL::Matrix.alloc([1, -2, 3, 4], 2, 2)
    assert_equal false, m.ispos?
  end

  def test_isneg
    m = GSL::Matrix.alloc([-1, -2, -3, -4], 2, 2)
    assert_equal 1, m.isneg
  end

  def test_isneg_false
    m = GSL::Matrix.alloc([-1, 2, -3, -4], 2, 2)
    assert_equal 0, m.isneg
  end

  def test_isneg_question
    m = GSL::Matrix.alloc([-1, -2, -3, -4], 2, 2)
    assert_equal true, m.isneg?
  end

  def test_isneg_question_false
    m = GSL::Matrix.alloc([-1, 2, -3, -4], 2, 2)
    assert_equal false, m.isneg?
  end

  def test_isnonneg
    m = GSL::Matrix.alloc([0, 1, 2, 3], 2, 2)
    assert_equal 1, m.isnonneg
  end

  def test_isnonneg_false
    m = GSL::Matrix.alloc([0, -1, 2, 3], 2, 2)
    assert_equal 0, m.isnonneg
  end

  def test_isnonneg_question
    m = GSL::Matrix.alloc([0, 1, 2, 3], 2, 2)
    assert_equal true, m.isnonneg?
  end

  def test_isnonneg_question_false
    m = GSL::Matrix.alloc([0, -1, 2, 3], 2, 2)
    assert_equal false, m.isnonneg?
  end

  # =====================================================
  # Shape tests
  # =====================================================

  def test_shape
    m = GSL::Matrix.alloc(3, 5)
    shape = m.shape
    assert_equal [3, 5], shape
  end

  def test_size_alias
    m = GSL::Matrix.alloc(4, 6)
    assert_equal m.shape, m.size
  end

  # =====================================================
  # Matrix::Int type tests (for BASE_INT coverage)
  # =====================================================

  def test_matrix_int_alloc
    m = GSL::Matrix::Int.alloc(2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_equal 0, m[0, 0]
  end

  def test_matrix_int_with_array
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    assert_equal 1, m[0, 0]
    assert_equal 4, m[1, 1]
  end

  def test_matrix_int_set_get
    m = GSL::Matrix::Int.alloc(2, 2)
    m[0, 0] = 10
    m[1, 1] = 20
    assert_equal 10, m[0, 0]
    assert_equal 20, m[1, 1]
  end

  def test_matrix_int_negative_index
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    assert_equal 4, m[-1, -1]
    assert_equal 3, m[-1, 0]
  end

  def test_matrix_int_set_all
    m = GSL::Matrix::Int.alloc(2, 2)
    m.set_all(5)
    assert_equal 5, m[0, 0]
    assert_equal 5, m[1, 1]
  end

  def test_matrix_int_set_zero
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m.set_zero
    assert_equal 0, m[0, 0]
    assert_equal 0, m[1, 1]
  end

  def test_matrix_int_set_identity
    m = GSL::Matrix::Int.alloc(2, 2)
    m.set_identity
    assert_equal 1, m[0, 0]
    assert_equal 0, m[0, 1]
    assert_equal 0, m[1, 0]
    assert_equal 1, m[1, 1]
  end

  def test_matrix_int_transpose
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    t = m.transpose
    assert_equal 3, t.size1
    assert_equal 2, t.size2
    assert_equal 1, t[0, 0]
    assert_equal 4, t[0, 1]
  end

  def test_matrix_int_scale
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m2 = m.scale(2)
    assert_equal 2, m2[0, 0]
    assert_equal 8, m2[1, 1]
  end

  def test_matrix_int_add_constant
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m2 = m.add_constant(10)
    assert_equal 11, m2[0, 0]
    assert_equal 14, m2[1, 1]
  end

  def test_matrix_int_swap_rows
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m.swap_rows!(0, 1)
    assert_equal 3, m[0, 0]
    assert_equal 1, m[1, 0]
  end

  def test_matrix_int_swap_columns
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m.swap_columns!(0, 1)
    assert_equal 2, m[0, 0]
    assert_equal 1, m[0, 1]
  end

  def test_matrix_int_max_min
    m = GSL::Matrix::Int.alloc([1, 5, 2, 4], 2, 2)
    assert_equal 5, m.max
    assert_equal 1, m.min
  end

  def test_matrix_int_minmax
    m = GSL::Matrix::Int.alloc([1, 5, 2, 4], 2, 2)
    min, max = m.minmax
    assert_equal 1, min
    assert_equal 5, max
  end

  def test_matrix_int_trace
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    assert_equal 5, m.trace
  end

  def test_matrix_int_uminus
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    neg = -m
    assert_equal(-1, neg[0, 0])
    assert_equal(-4, neg[1, 1])
  end

  def test_matrix_int_uplus
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    p = +m
    assert_equal m.object_id, p.object_id
  end

  def test_matrix_int_isnull
    m = GSL::Matrix::Int.alloc([0, 0, 0, 0], 2, 2)
    assert_equal 1, m.isnull
    assert_equal true, m.isnull?
  end

  def test_matrix_int_isnull_false
    m = GSL::Matrix::Int.alloc([1, 0, 0, 0], 2, 2)
    assert_equal 0, m.isnull
    assert_equal false, m.isnull?
  end

  def test_matrix_int_to_s
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    s = m.to_s
    assert s.include?("1")
    assert s.include?("[")
  end

  def test_matrix_int_to_s_large
    m = GSL::Matrix::Int.alloc(25, 2)
    m.indgen!
    s = m.to_s
    assert s.include?("...")
  end

  def test_matrix_int_to_s_negative
    m = GSL::Matrix::Int.alloc([-10, 2, -3, 4], 2, 2)
    s = m.to_s
    assert s.include?("-")
  end

  def test_matrix_int_inspect
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    i = m.inspect
    assert i.include?("GSL::Matrix::Int")
  end

  def test_matrix_int_each_row
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    rows = []
    m.each_row { |r| rows << r.to_a }
    assert_equal 2, rows.size
    assert_equal 1, rows[0][0]
    assert_equal 4, rows[1][0]
  end

  def test_matrix_int_each_col
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    cols = []
    m.each_col { |c| cols << c.to_a }
    assert_equal 3, cols.size
  end

  def test_matrix_int_row_view
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    row = m.row(0)
    assert_equal 3, row.size
    assert_equal 1, row[0]
  end

  def test_matrix_int_col_view
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    col = m.col(0)
    assert_equal 2, col.size
    assert_equal 1, col[0]
    assert_equal 4, col[1]
  end

  def test_matrix_int_clone
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    c = m.clone
    assert_equal 1, c[0, 0]
    c[0, 0] = 100
    assert_equal 1, m[0, 0]
  end

  def test_matrix_int_submatrix
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    sub = m[0, 0, 2, 2]
    assert_equal 2, sub.size1
    assert_equal 2, sub.size2
  end

  def test_matrix_int_diagonal
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    diag = m.diagonal
    assert_equal 2, diag.size
    assert_equal 1, diag[0]
    assert_equal 4, diag[1]
  end

  def test_matrix_int_upper
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3)
    u = m.upper
    assert_equal 1, u[0, 0]
    assert_equal 2, u[0, 1]
    assert_equal 0, u[1, 0]
    assert_equal 5, u[1, 1]
  end

  def test_matrix_int_lower
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3)
    l = m.lower
    assert_equal 1, l[0, 0]
    assert_equal 0, l[0, 1]
    assert_equal 4, l[1, 0]
    assert_equal 5, l[1, 1]
  end

  def test_matrix_int_collect
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m2 = m.collect { |x| x * 2 }
    assert_equal 2, m2[0, 0]
    assert_equal 8, m2[1, 1]
  end

  def test_matrix_int_collect_bang
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m.collect! { |x| x * 2 }
    assert_equal 2, m[0, 0]
    assert_equal 8, m[1, 1]
  end

  def test_matrix_int_equal
    m1 = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    assert_equal true, m1.equal?(m2)
  end

  def test_matrix_int_equal_false
    m1 = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix::Int.alloc([1, 2, 3, 5], 2, 2)
    assert_equal false, m1.equal?(m2)
  end

  def test_matrix_int_to_a
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    a = m.to_a
    assert_equal [[1, 2], [3, 4]], a
  end

  def test_matrix_int_to_v
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    v = m.to_v
    assert_equal 4, v.size
    assert_equal 1, v[0]
    assert_equal 4, v[3]
  end

  def test_matrix_int_pascal
    p = GSL::Matrix::Int.pascal(3)
    assert_equal 3, p.size1
    assert_equal 1, p[0, 0]
    assert_equal 1, p[0, 2]
    assert_equal 2, p[1, 1]
  end

  def test_matrix_int_vandermonde
    v = GSL::Vector::Int[1, 2, 3]
    vm = GSL::Matrix::Int.vandermonde(v)
    assert_equal 3, vm.size1
    assert_equal 3, vm.size2
  end

  def test_matrix_int_toeplitz
    v = GSL::Vector::Int[1, 2, 3]
    t = GSL::Matrix::Int.toeplitz(v)
    assert_equal 3, t.size1
    assert_equal 1, t[0, 0]
    assert_equal 2, t[0, 1]
    assert_equal 2, t[1, 0]
  end

  def test_matrix_int_circulant
    v = GSL::Vector::Int[1, 2, 3]
    c = GSL::Matrix::Int.circulant(v)
    assert_equal 3, c.size1
    assert_equal 3, c.size2
  end

  def test_matrix_int_indgen
    m = GSL::Matrix::Int.indgen(2, 3)
    assert_equal 0, m[0, 0]
    assert_equal 5, m[1, 2]
  end

  def test_matrix_int_indgen_bang
    m = GSL::Matrix::Int.alloc(2, 3)
    m.indgen!(10, 2)
    assert_equal 10, m[0, 0]
    assert_equal 20, m[1, 2]
  end

  def test_matrix_int_horzcat
    m1 = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix::Int.alloc([5, 6, 7, 8], 2, 2)
    h = m1.horzcat(m2)
    assert_equal 2, h.size1
    assert_equal 4, h.size2
    assert_equal 1, h[0, 0]
    assert_equal 5, h[0, 2]
  end

  def test_matrix_int_vertcat
    m1 = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix::Int.alloc([5, 6, 7, 8], 2, 2)
    v = m1.vertcat(m2)
    assert_equal 4, v.size1
    assert_equal 2, v.size2
    assert_equal 1, v[0, 0]
    assert_equal 5, v[2, 0]
  end

  def test_matrix_int_reverse_rows
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    r = m.reverse_rows
    assert_equal 4, r[0, 0]
    assert_equal 1, r[1, 0]
  end

  def test_matrix_int_reverse_columns
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    r = m.reverse_columns
    assert_equal 3, r[0, 0]
    assert_equal 1, r[0, 2]
  end

  def test_matrix_int_rot90
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    r = m.rot90
    assert_equal 2, r.size1
    assert_equal 2, r.size2
  end

  def test_matrix_int_any
    m = GSL::Matrix::Int.alloc([0, 0, 1, 0, 0, 0], 2, 3)
    result = m.any
    assert_kind_of GSL::Vector::Int, result
    assert_equal 0, result[0]
    assert_equal 0, result[1]
    assert_equal 1, result[2]
  end

  def test_matrix_int_all
    m = GSL::Matrix::Int.alloc([1, 1, 0, 1, 1, 1], 2, 3)
    result = m.all
    assert_kind_of GSL::Vector::Int, result
    assert_equal 1, result[0]
    assert_equal 1, result[1]
    assert_equal 0, result[2]
  end

  def test_matrix_int_symmetrize
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    s = m.symmetrize
    assert_equal 1, s[0, 0]
    assert_equal 2, s[0, 1]
    assert_equal 2, s[1, 0]
    assert_equal 4, s[1, 1]
  end

  def test_matrix_int_symmetrize_bang
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m.symmetrize!
    assert_equal 2, m[1, 0]
  end

  def test_matrix_int_info
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    info = m.info
    assert info.include?("Dimension")
    assert info.include?("2x2")
  end

  def test_matrix_int_block
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    b = m.block
    assert_kind_of GSL::Block::Int, b
  end

  def test_matrix_int_ispos
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    assert_equal 1, m.ispos
    assert_equal true, m.ispos?
  end

  def test_matrix_int_isneg
    m = GSL::Matrix::Int.alloc([-1, -2, -3, -4], 2, 2)
    assert_equal 1, m.isneg
    assert_equal true, m.isneg?
  end

  def test_matrix_int_isnonneg
    m = GSL::Matrix::Int.alloc([0, 1, 2, 3], 2, 2)
    assert_equal 1, m.isnonneg
    assert_equal true, m.isnonneg?
  end

  def test_matrix_int_power
    m = GSL::Matrix::Int.alloc([1, 2, 2, 1], 2, 2)
    m2 = m ** 2
    assert_equal 5, m2[0, 0]
    assert_equal 4, m2[0, 1]
  end

  def test_matrix_int_diff
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 3, 2)
    d = m.diff
    assert_equal 2, d.size1
    assert_equal 2, d.size2
  end

  def test_matrix_int_sgn
    m = GSL::Matrix::Int.alloc([-1, 0, 1, 2], 2, 2)
    result = m.sgn
    assert_equal(-1, result[0, 0])
    assert_equal 0, result[0, 1]
    assert_equal 1, result[1, 0]
    assert_equal 1, result[1, 1]
  end

  def test_matrix_int_abs
    m = GSL::Matrix::Int.alloc([-1, -2, 3, -4], 2, 2)
    result = m.abs
    assert_equal 1, result[0, 0]
    assert_equal 2, result[0, 1]
    assert_equal 3, result[1, 0]
    assert_equal 4, result[1, 1]
  end

  def test_matrix_int_eye
    m = GSL::Matrix::Int.eye(3)
    assert_equal 3, m.size1
    assert_equal 3, m.size2
    assert_equal 1, m[0, 0]
    assert_equal 0, m[0, 1]
  end

  def test_matrix_int_ones
    m = GSL::Matrix::Int.ones(2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_equal 1, m[0, 0]
  end

  def test_matrix_int_zeros
    m = GSL::Matrix::Int.zeros(2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_equal 0, m[0, 0]
  end

  def test_matrix_int_identity
    m = GSL::Matrix::Int.identity(3)
    assert_equal 3, m.size1
    assert_equal 1, m[0, 0]
    assert_equal 0, m[0, 1]
  end

  def test_matrix_int_diagonal_singleton_with_array
    m = GSL::Matrix::Int.diagonal([1, 2, 3])
    assert_equal 3, m.size1
    assert_equal 1, m[0, 0]
    assert_equal 2, m[1, 1]
    assert_equal 3, m[2, 2]
    assert_equal 0, m[0, 1]
  end
end
