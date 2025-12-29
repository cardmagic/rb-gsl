require 'test_helper'

class MatrixComplexCoverageTest < GSL::TestCase
  # ======= Arithmetic operations with different operand types =======

  # Test add with complex matrix (matrix_complex + matrix_complex)
  def test_add_complex_matrix
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m1[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m1[1, 0] = GSL::Complex.alloc(5.0, 6.0)
    m1[1, 1] = GSL::Complex.alloc(7.0, 8.0)

    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m2[0, 0] = GSL::Complex.alloc(1.0, 1.0)
    m2[0, 1] = GSL::Complex.alloc(2.0, 2.0)
    m2[1, 0] = GSL::Complex.alloc(3.0, 3.0)
    m2[1, 1] = GSL::Complex.alloc(4.0, 4.0)

    result = m1 + m2
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 3.0, result[0, 0].imag, 1e-10
  end

  # Test sub with complex matrix
  def test_sub_complex_matrix
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(5.0, 5.0)
    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m2[0, 0] = GSL::Complex.alloc(3.0, 2.0)

    result = m1 - m2
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 3.0, result[0, 0].imag, 1e-10
  end

  # Test div_elements with complex matrix
  def test_div_elements_complex_matrix
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(6.0, 8.0)
    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m2[0, 0] = GSL::Complex.alloc(2.0, 0.0)

    result = m1.div_elements(m2)
    assert_in_delta 3.0, result[0, 0].real, 1e-10
    assert_in_delta 4.0, result[0, 0].imag, 1e-10
  end

  # Test add with GSL::Complex scalar
  def test_add_complex_scalar
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    z = GSL::Complex.alloc(3.0, 4.0)

    result = m + z
    assert_in_delta 4.0, result[0, 0].real, 1e-10
    assert_in_delta 6.0, result[0, 0].imag, 1e-10
  end

  # Test sub with GSL::Complex scalar
  def test_sub_complex_scalar
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(5.0, 7.0)
    z = GSL::Complex.alloc(2.0, 3.0)

    result = m - z
    assert_in_delta 3.0, result[0, 0].real, 1e-10
    assert_in_delta 4.0, result[0, 0].imag, 1e-10
  end

  # Test mul with GSL::Complex scalar
  def test_mul_complex_scalar
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 3.0)
    z = GSL::Complex.alloc(2.0, 0.0)

    result = m.mul_elements(z)
    assert_in_delta 4.0, result[0, 0].real, 1e-10
    assert_in_delta 6.0, result[0, 0].imag, 1e-10
  end

  # Test div with GSL::Complex scalar
  def test_div_complex_scalar
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(4.0, 6.0)
    z = GSL::Complex.alloc(2.0, 0.0)

    result = m.div_elements(z)
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 3.0, result[0, 0].imag, 1e-10
  end

  # Test sub with numeric (triggers add_constant with negative)
  def test_sub_numeric
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(5.0, 3.0)

    result = m - 2
    assert_in_delta 3.0, result[0, 0].real, 1e-10
    assert_in_delta 3.0, result[0, 0].imag, 1e-10
  end

  # Test div with numeric (triggers scale with inverse)
  def test_div_numeric
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(4.0, 6.0)

    result = m / 2
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 3.0, result[0, 0].imag, 1e-10
  end

  # Test mul with real GSL::Vector
  def test_mul_real_vector
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    v = GSL::Vector[1.0, 1.0]
    result = m * v

    assert result.is_a?(GSL::Vector::Complex)
    assert_in_delta 3.0, result[0].real, 1e-10  # 1+2
    assert_in_delta 7.0, result[1].real, 1e-10  # 3+4
  end

  # Test mul with Vector::Complex::Col
  def test_mul_vector_complex_col
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(1.0, 0.0)
    v_col = v.col

    result = m * v_col
    assert result.is_a?(GSL::Vector::Complex)
    assert_in_delta 3.0, result[0].real, 1e-10
    assert_in_delta 7.0, result[1].real, 1e-10
  end

  # Test mul_elements with row Vector (should raise error)
  def test_mul_elements_row_vector_error
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set_zero
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)

    # Row vector (not col) should fail for mul, but the error depends on operation
    # For non-mul operations it should raise error
    assert_raises(TypeError) do
      m.mul_elements(v)  # Row vector not supported for mul_elements
    end
  end

  # Test add with row Vector::Complex (should raise error)
  def test_add_vector_complex_error
    m = GSL::Matrix::Complex.alloc(2, 2)
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v_col = v.col

    # Add is not defined for Vector::Complex
    assert_raises(RuntimeError) do
      m + v_col
    end
  end

  # Test sub with Vector::Complex (should raise error)
  def test_sub_vector_complex_error
    m = GSL::Matrix::Complex.alloc(2, 2)
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v_col = v.col

    assert_raises(RuntimeError) do
      m - v_col
    end
  end

  # Test div with Vector::Complex (should raise error)
  def test_div_vector_complex_error
    m = GSL::Matrix::Complex.alloc(2, 2)
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v_col = v.col

    assert_raises(RuntimeError) do
      m / v_col
    end
  end

  # Test mul with real vector - GSL::Vector operations
  def test_add_real_vector_error
    m = GSL::Matrix::Complex.alloc(2, 2)
    v = GSL::Vector[1.0, 2.0]

    # Add is not defined for GSL::Vector
    assert_raises(RuntimeError) do
      m + v
    end
  end

  # Test sub with real vector (should raise error)
  def test_sub_real_vector_error
    m = GSL::Matrix::Complex.alloc(2, 2)
    v = GSL::Vector[1.0, 2.0]

    assert_raises(RuntimeError) do
      m - v
    end
  end

  # Test div with real vector (should raise error)
  def test_div_real_vector_error
    m = GSL::Matrix::Complex.alloc(2, 2)
    v = GSL::Vector[1.0, 2.0]

    assert_raises(RuntimeError) do
      m / v
    end
  end

  # ======= Constructor variations =======

  # Test eye with single argument (default value)
  def test_eye_single_arg
    m = GSL::Matrix::Complex.eye(3)
    # Should create identity with 1+0i on diagonal
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 0.0, m[0, 0].imag, 1e-10
    assert_in_delta 0.0, m[0, 1].real, 1e-10
  end

  # Test eye with numeric second argument
  def test_eye_numeric_arg
    m = GSL::Matrix::Complex.eye(3, 5.0)
    assert_in_delta 5.0, m[0, 0].real, 1e-10
    assert_in_delta 0.0, m[0, 0].imag, 1e-10
  end

  # Test eye with bignum
  def test_eye_bignum
    big = 2**62  # Large number that could be bignum
    m = GSL::Matrix::Complex.eye(2, big.to_f)
    assert_in_delta big.to_f, m[0, 0].real, 1e5
  end

  # Test identity (alias for eye)
  def test_identity_method
    m = GSL::Matrix::Complex.identity(3)
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 1.0, m[1, 1].real, 1e-10
    assert_in_delta 1.0, m[2, 2].real, 1e-10
    assert_in_delta 0.0, m[0, 1].real, 1e-10
  end

  # ======= Set operations =======

  # Test set_all with array [real, imag]
  def test_set_all_array
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set_all([3.0, 4.0])
    assert_in_delta 3.0, m[0, 0].real, 1e-10
    assert_in_delta 4.0, m[0, 0].imag, 1e-10
  end

  # Test set with array of rows
  def test_set_array_rows
    m = GSL::Matrix::Complex.alloc(2, 2)
    z1 = GSL::Complex.alloc(1.0, 2.0)
    z2 = GSL::Complex.alloc(3.0, 4.0)
    z3 = GSL::Complex.alloc(5.0, 6.0)
    z4 = GSL::Complex.alloc(7.0, 8.0)

    m.set([z1, z2], [z3, z4])
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 3.0, m[0, 1].real, 1e-10
    assert_in_delta 5.0, m[1, 0].real, 1e-10
    assert_in_delta 7.0, m[1, 1].real, 1e-10
  end

  # Test set with negative indices
  def test_set_negative_indices
    m = GSL::Matrix::Complex.alloc(3, 3)
    z = GSL::Complex.alloc(5.0, 6.0)
    m[-1, -1] = z  # Should be [2, 2]
    assert_in_delta 5.0, m[2, 2].real, 1e-10
    assert_in_delta 6.0, m[2, 2].imag, 1e-10
  end

  # Test get with negative indices
  def test_get_negative_indices
    m = GSL::Matrix::Complex.alloc(3, 3)
    m[2, 2] = GSL::Complex.alloc(5.0, 6.0)
    z = m[-1, -1]
    assert_in_delta 5.0, z.real, 1e-10
    assert_in_delta 6.0, z.imag, 1e-10
  end

  # Test get with single index (linear access)
  def test_get_single_index
    m = GSL::Matrix::Complex.alloc(2, 3)
    m[1, 2] = GSL::Complex.alloc(42.0, 0.0)  # Row 1, col 2 = index 5
    z = m[5]
    assert_in_delta 42.0, z.real, 1e-10
  end

  # Test get with single negative index
  def test_get_single_negative_index
    m = GSL::Matrix::Complex.alloc(2, 3)
    m[1, 2] = GSL::Complex.alloc(42.0, 0.0)  # Last element
    z = m[-1]
    assert_in_delta 42.0, z.real, 1e-10
  end

  # Test set with submatrix assignment
  def test_set_submatrix_assignment
    m = GSL::Matrix::Complex.alloc(4, 4)
    m.set_zero

    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m2[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m2[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m2[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m2[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    # Assign 2x2 submatrix using range notation
    m[1..2, 1..2] = m2
    assert_in_delta 1.0, m[1, 1].real, 1e-10
    assert_in_delta 4.0, m[2, 2].real, 1e-10
  end

  # Test set with array for submatrix
  def test_set_submatrix_array
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_zero

    z1 = GSL::Complex.alloc(1.0, 0.0)
    z2 = GSL::Complex.alloc(2.0, 0.0)

    # Assign single row
    m[0, 0, 1, 2] = [z1, z2]
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 2.0, m[0, 1].real, 1e-10
  end

  # Test set with range
  def test_set_submatrix_range
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_zero

    # Assign range to submatrix
    m[0, 0, 1, 3] = 1..3
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 2.0, m[0, 1].real, 1e-10
    assert_in_delta 3.0, m[0, 2].real, 1e-10
  end

  # Test set_row with array conversion
  def test_set_row_array_conversion
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set_row(0, [1.0, 2.0], [3.0, 4.0])  # Using [real, imag] arrays
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 2.0, m[0, 0].imag, 1e-10
  end

  # Test set_col with array conversion
  def test_set_col_array_conversion
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set_col(0, [1.0, 2.0], [3.0, 4.0])
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 2.0, m[0, 0].imag, 1e-10
    assert_in_delta 3.0, m[1, 0].real, 1e-10
    assert_in_delta 4.0, m[1, 0].imag, 1e-10
  end

  # ======= Row/Column/Diagonal operations =======

  # Test subdiagonal
  def test_subdiagonal
    m = GSL::Matrix::Complex.alloc(4, 4)
    m.indgen!
    sd = m.subdiagonal(1)
    assert sd.is_a?(GSL::Vector::Complex) || sd.is_a?(GSL::Vector::Complex::View)
    # Subdiagonal k=1 is elements [1,0], [2,1], [3,2]
    assert_in_delta 4.0, sd[0].real, 1e-10  # Element at [1,0]
  end

  # Test superdiagonal
  def test_superdiagonal
    m = GSL::Matrix::Complex.alloc(4, 4)
    m.indgen!
    sd = m.superdiagonal(1)
    assert sd.is_a?(GSL::Vector::Complex) || sd.is_a?(GSL::Vector::Complex::View)
    # Superdiagonal k=1 is elements [0,1], [1,2], [2,3]
    assert_in_delta 1.0, sd[0].real, 1e-10  # Element at [0,1]
  end

  # Test set_diagonal with vector
  def test_set_diagonal_vector
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_zero

    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    m.set_diagonal(v)
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 2.0, m[1, 1].real, 1e-10
    assert_in_delta 3.0, m[2, 2].real, 1e-10
  end

  # ======= Add diagonal operations =======

  # Test add_diagonal with array
  def test_add_diagonal_array
    m = GSL::Matrix::Complex.eye(3)
    m.add_diagonal([2.0, 3.0])
    assert_in_delta 3.0, m[0, 0].real, 1e-10
    assert_in_delta 3.0, m[0, 0].imag, 1e-10
  end

  # Test add_diagonal with bignum
  def test_add_diagonal_bignum
    m = GSL::Matrix::Complex.eye(3)
    m.add_diagonal(2**40)  # Bignum
    assert m[0, 0].real > 1e10, "Added large number to diagonal"
  end

  # ======= Coerce operations =======

  # Test coerce with real matrix
  def test_coerce_real_matrix
    mc = GSL::Matrix::Complex.alloc(2, 2)
    mc[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    mr = GSL::Matrix.alloc([5.0, 6.0], [7.0, 8.0])

    coerced = mc.coerce(mr)
    assert coerced.is_a?(Array)
    assert_equal 2, coerced.size
    assert coerced[0].is_a?(GSL::Matrix::Complex)
  end

  # Test coerce with float
  def test_coerce_float
    mc = GSL::Matrix::Complex.alloc(2, 2)
    mc[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    coerced = mc.coerce(3.0)
    assert coerced.is_a?(Array)
    assert coerced[0].is_a?(GSL::Matrix::Complex)
    # The coerced matrix should have 3.0 in all elements
    assert_in_delta 3.0, coerced[0][0, 0].real, 1e-10
  end

  # Test coerce with bignum
  def test_coerce_bignum
    mc = GSL::Matrix::Complex.alloc(2, 2)
    coerced = mc.coerce(2**40)
    assert coerced.is_a?(Array)
  end

  # ======= Matrix multiplication =======

  # Test mul with real matrix
  def test_mul_real_matrix
    mc = GSL::Matrix::Complex.alloc(2, 2)
    mc[0, 0] = GSL::Complex.alloc(1.0, 1.0)
    mc[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    mc[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    mc[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    mr = GSL::Matrix.alloc([1.0, 0.0], [0.0, 1.0])  # Identity
    result = mc * mr

    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
    assert_in_delta 1.0, result[0, 0].imag, 1e-10
  end

  # Test mul! (in-place multiplication)
  def test_mul_bang
    mc = GSL::Matrix::Complex.alloc(2, 2)
    mc[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    mc[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    mc[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    mc[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    mc2 = GSL::Matrix::Complex.alloc(2, 2)
    mc2[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    mc2[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    mc2[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    mc2[1, 1] = GSL::Complex.alloc(1.0, 0.0)

    result = mc.mul!(mc2)
    assert_equal mc.object_id, result.object_id
  end

  # Test mul! with real matrix
  def test_mul_bang_real_matrix
    mc = GSL::Matrix::Complex.alloc(2, 2)
    mc[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    mc[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    mc[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    mc[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    mr = GSL::Matrix.alloc([1.0, 0.0], [0.0, 1.0])  # Identity
    result = mc.mul!(mr)
    assert_equal mc.object_id, result.object_id
  end

  # ======= Scale operations =======

  # Test scale! with complex
  def test_scale_bang_complex
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 3.0)
    z = GSL::Complex.alloc(2.0, 0.0)

    result = m.scale!(z)
    assert_equal m.object_id, result.object_id
    assert_in_delta 4.0, m[0, 0].real, 1e-10
    assert_in_delta 6.0, m[0, 0].imag, 1e-10
  end

  # Test scale! with float
  def test_scale_bang_float
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 3.0)

    m.scale!(2.0)
    assert_in_delta 4.0, m[0, 0].real, 1e-10
    assert_in_delta 6.0, m[0, 0].imag, 1e-10
  end

  # ======= Iteration operations =======

  # Test each_row
  def test_each_row
    m = GSL::Matrix::Complex.alloc(3, 2)
    m.indgen!

    count = 0
    m.each_row do |row|
      assert row.is_a?(GSL::Vector::Complex) || row.is_a?(GSL::Vector::Complex::View)
      count += 1
    end
    assert_equal 3, count
  end

  # Test each_col
  def test_each_col
    m = GSL::Matrix::Complex.alloc(3, 2)
    m.indgen!

    count = 0
    m.each_col do |col|
      assert col.is_a?(GSL::Vector::Complex) || col.is_a?(GSL::Vector::Complex::View)
      count += 1
    end
    assert_equal 2, count
  end

  # Test collect (map)
  def test_collect
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    result = m.collect { |z| GSL::Complex.alloc(z.real * 2, z.imag) }
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 4.0, result[0, 1].real, 1e-10
    # Original unchanged
    assert_in_delta 1.0, m[0, 0].real, 1e-10
  end

  # Test collect! (map!)
  def test_collect_bang
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    m.collect! { |z| GSL::Complex.alloc(z.real * 2, z.imag) }
    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 4.0, m[0, 1].real, 1e-10
  end

  # ======= Conversion operations =======

  # Test to_a
  def test_to_a
    m = GSL::Matrix::Complex.alloc(2, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[1, 2] = GSL::Complex.alloc(3.0, 4.0)

    a = m.to_a
    assert a.is_a?(Array)
    assert_equal 2, a.size
    assert_equal 3, a[0].size
    assert_in_delta 1.0, a[0][0].real, 1e-10
  end

  # ======= Unary operations =======

  # Test unary plus
  def test_unary_plus
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    result = +m
    assert_equal m.object_id, result.object_id
  end

  # Test unary minus
  def test_unary_minus
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    result = -m
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta(-1.0, result[0, 0].real, 1e-10)
    assert_in_delta(-2.0, result[0, 0].imag, 1e-10)
  end

  # ======= Complex math operations =======

  # Test logabs
  def test_logabs
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(Math::E, 0.0)
    m[0, 1] = GSL::Complex.alloc(Math::E**2, 0.0)

    result = m.logabs
    assert result.is_a?(GSL::Matrix)
    assert_in_delta 1.0, result[0, 0], 1e-10
    assert_in_delta 2.0, result[0, 1], 1e-10
  end

  # Test sec
  def test_sec
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)
    result = m.sec
    assert result.is_a?(GSL::Matrix::Complex)
    # sec(0) = 1
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  # Test csc
  def test_csc
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(Math::PI / 2, 0.0)
    result = m.csc
    assert result.is_a?(GSL::Matrix::Complex)
    # csc(pi/2) = 1
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  # Test cot
  def test_cot
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(Math::PI / 4, 0.0)
    result = m.cot
    assert result.is_a?(GSL::Matrix::Complex)
    # cot(pi/4) = 1
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  # Test arcsin
  def test_arcsin
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.5, 0.0)
    result = m.arcsin
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta Math.asin(0.5), result[0, 0].real, 1e-10
  end

  # Test arccos
  def test_arccos
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.5, 0.0)
    result = m.arccos
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta Math.acos(0.5), result[0, 0].real, 1e-10
  end

  # Test arctan
  def test_arctan
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    result = m.arctan
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta Math::PI / 4, result[0, 0].real, 1e-10
  end

  # Test arcsec
  def test_arcsec
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    result = m.arcsec
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # Test arccsc
  def test_arccsc
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    result = m.arccsc
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # Test arccot
  def test_arccot
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    result = m.arccot
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # Test sech
  def test_sech
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)
    result = m.sech
    assert result.is_a?(GSL::Matrix::Complex)
    # sech(0) = 1
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  # Test csch
  def test_csch
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    result = m.csch
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # Test coth
  def test_coth
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    result = m.coth
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # Test arcsinh
  def test_arcsinh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.5, 0.0)
    result = m.arcsinh
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # Test arccosh
  def test_arccosh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    result = m.arccosh
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # Test arctanh
  def test_arctanh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.5, 0.0)
    result = m.arctanh
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # Test arcsech
  def test_arcsech
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.5, 0.0)
    result = m.arcsech
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # Test arccsch
  def test_arccsch
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    result = m.arccsch
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # Test arccoth
  def test_arccoth
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    result = m.arccoth
    assert result.is_a?(GSL::Matrix::Complex)
  end

  # ======= Indgen operations =======

  # Test indgen (instance method) with start
  def test_indgen_instance_with_start
    m = GSL::Matrix::Complex.alloc(2, 2)
    result = m.indgen(10)
    assert_in_delta 10.0, result[0, 0].real, 1e-10
    assert_in_delta 11.0, result[0, 1].real, 1e-10
    # Original unchanged
    assert_in_delta 0.0, m[0, 0].real, 1e-10
  end

  # Test indgen (instance method) with start and step
  def test_indgen_instance_with_start_step
    m = GSL::Matrix::Complex.alloc(2, 2)
    result = m.indgen(10, 5)
    assert_in_delta 10.0, result[0, 0].real, 1e-10
    assert_in_delta 15.0, result[0, 1].real, 1e-10
    assert_in_delta 20.0, result[1, 0].real, 1e-10
    assert_in_delta 25.0, result[1, 1].real, 1e-10
  end

  # Test indgen! (instance method) with start
  def test_indgen_bang_with_start
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.indgen!(10)
    assert_in_delta 10.0, m[0, 0].real, 1e-10
    assert_in_delta 11.0, m[0, 1].real, 1e-10
  end

  # Test indgen! (instance method) with start and step
  def test_indgen_bang_with_start_step
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.indgen!(10, 5)
    assert_in_delta 10.0, m[0, 0].real, 1e-10
    assert_in_delta 15.0, m[0, 1].real, 1e-10
  end

  # Test singleton indgen with start
  def test_indgen_singleton_with_start
    m = GSL::Matrix::Complex.indgen(2, 3, 10)
    assert_in_delta 10.0, m[0, 0].real, 1e-10
    assert_in_delta 11.0, m[0, 1].real, 1e-10
    assert_in_delta 12.0, m[0, 2].real, 1e-10
  end

  # Test singleton indgen with start and step
  def test_indgen_singleton_with_start_step
    m = GSL::Matrix::Complex.indgen(2, 3, 10, 2)
    assert_in_delta 10.0, m[0, 0].real, 1e-10
    assert_in_delta 12.0, m[0, 1].real, 1e-10
    assert_in_delta 14.0, m[0, 2].real, 1e-10
  end

  # ======= Equality operations =======

  # Test equal? with epsilon
  def test_equal_with_epsilon
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m2[0, 0] = GSL::Complex.alloc(1.000001, 2.000001)

    assert m1.equal?(m2, 1e-5)
    refute m1.equal?(m2, 1e-10)
  end

  # Test not_equal? with epsilon
  def test_not_equal_with_epsilon
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m2[0, 0] = GSL::Complex.alloc(1.000001, 2.000001)

    refute m1.not_equal?(m2, 1e-5)
    assert m1.not_equal?(m2, 1e-10)
  end

  # Test equal? with different sizes
  def test_equal_different_sizes
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m2 = GSL::Matrix::Complex.alloc(3, 3)

    refute m1 == m2
  end

  # ======= Swap operations =======

  # Test swap_rows
  def test_swap_rows
    m = GSL::Matrix::Complex.alloc(3, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    m.swap_rows(0, 1)
    assert_in_delta 3.0, m[0, 0].real, 1e-10
    assert_in_delta 1.0, m[1, 0].real, 1e-10
  end

  # Test swap_columns
  def test_swap_columns
    m = GSL::Matrix::Complex.alloc(2, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)

    m.swap_columns(0, 1)
    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 1.0, m[0, 1].real, 1e-10
  end

  # Test swap_rowcol - just verify it runs without error
  def test_swap_rowcol
    m = GSL::Matrix::Complex.alloc(3, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    # swap_rowcol swaps row i with column j in a square matrix
    result = m.swap_rowcol(0, 1)
    # Just verify it returns the matrix (mutated in place)
    assert_equal m.object_id, result.object_id
  end

  # ======= I/O operations =======

  # Test ptr
  def test_ptr
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[1, 1] = GSL::Complex.alloc(5.0, 6.0)

    p = m.ptr(1, 1)
    assert p.is_a?(GSL::Complex)
    assert_in_delta 5.0, p.real, 1e-10
  end

  # Test to_s with large matrix (truncation)
  def test_to_s_truncation
    m = GSL::Matrix::Complex.alloc(10, 10)
    m.indgen!
    s = m.to_s(3, 3)
    assert s.include?("..."), "Large matrix should be truncated"
  end

  # Test to_s with empty matrix
  def test_to_s_empty
    m = GSL::Matrix::Complex.alloc(0, 0)
    s = m.to_s
    assert_equal "[ ]", s
  end

  # ======= Clone/Dup =======

  # Test clone
  def test_clone
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    m2 = m.clone
    refute_equal m.object_id, m2.object_id
    assert_in_delta 1.0, m2[0, 0].real, 1e-10
    assert_in_delta 2.0, m2[0, 0].imag, 1e-10

    # Modify clone, original unchanged
    m2[0, 0] = GSL::Complex.alloc(10.0, 0.0)
    assert_in_delta 1.0, m[0, 0].real, 1e-10
  end

  # ======= Submatrix/View operations =======

  # Test submatrix returning row view
  def test_submatrix_row_view
    m = GSL::Matrix::Complex.alloc(3, 4)
    m.indgen!

    # Get row 1, all columns
    v = m[1, nil]
    assert v.is_a?(GSL::Vector::Complex) || v.is_a?(GSL::Vector::Complex::View)
    assert_in_delta 4.0, v[0].real, 1e-10  # Element at [1,0]
  end

  # Test submatrix returning column view
  def test_submatrix_column_view
    m = GSL::Matrix::Complex.alloc(4, 3)
    m.indgen!

    # Get all rows, col 1
    v = m[nil, 1]
    assert v.is_a?(GSL::Vector::Complex) || v.is_a?(GSL::Vector::Complex::View)
    assert_in_delta 1.0, v[0].real, 1e-10  # Element at [0,1]
  end

  # ======= Error path tests =======

  # Test range mismatch error
  def test_set_range_mismatch
    m = GSL::Matrix::Complex.alloc(3, 3)
    assert_raises(RangeError) do
      m[0, 0, 1, 2] = 1..5  # Size mismatch: 1x2=2 != 5
    end
  end

  # Test row count mismatch error
  def test_set_row_count_mismatch
    m = GSL::Matrix::Complex.alloc(3, 3)
    z1 = GSL::Complex.alloc(1.0, 0.0)
    z2 = GSL::Complex.alloc(2.0, 0.0)

    assert_raises(RangeError) do
      # Trying to set 3 rows but only providing 2
      m[0, 0, 3, 2] = [[z1, z2], [z1, z2]]
    end
  end

  # Test submatrix size mismatch
  def test_set_submatrix_size_mismatch
    m = GSL::Matrix::Complex.alloc(4, 4)
    m2 = GSL::Matrix::Complex.alloc(3, 3)

    assert_raises(RangeError) do
      m[0, 0, 2, 2] = m2  # 2x2 region != 3x3 matrix
    end
  end
end
