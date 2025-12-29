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

  # ======= Additional coverage tests =======

  # Test eye with Array [real, imag] argument
  def test_eye_array_arg
    m = GSL::Matrix::Complex.eye(3, [2.0, 3.0])
    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 3.0, m[0, 0].imag, 1e-10
    assert_in_delta 0.0, m[0, 1].real, 1e-10
  end

  # Test eye with 3 arguments (n, real, imag)
  def test_eye_three_args
    m = GSL::Matrix::Complex.eye(3, 2.0, 3.0)
    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 3.0, m[0, 0].imag, 1e-10
    assert_in_delta 2.0, m[1, 1].real, 1e-10
    assert_in_delta 3.0, m[1, 1].imag, 1e-10
  end

  # Test eye with Complex argument
  def test_eye_complex_arg
    z = GSL::Complex.alloc(5.0, 7.0)
    m = GSL::Matrix::Complex.eye(3, z)
    assert_in_delta 5.0, m[0, 0].real, 1e-10
    assert_in_delta 7.0, m[0, 0].imag, 1e-10
  end

  # Test eye with wrong argument type (should raise)
  def test_eye_wrong_arg_type
    assert_raises(TypeError) do
      GSL::Matrix::Complex.eye(3, "wrong")
    end
  end

  # Test eye with wrong number of arguments
  def test_eye_wrong_argc
    assert_raises(ArgumentError) do
      GSL::Matrix::Complex.eye(3, 1.0, 2.0, 3.0, 4.0)
    end
  end

  # Test eye with array too short
  def test_eye_array_too_short
    assert_raises(ArgumentError) do
      GSL::Matrix::Complex.eye(3, [1.0])  # Need 2 elements
    end
  end

  # Test set_all with wrong argument type
  def test_set_all_wrong_type
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(TypeError) do
      m.set_all("wrong")
    end
  end

  # Test set with wrong number of arguments
  def test_set_wrong_argc
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(ArgumentError) do
      m.set(1, 2, 3, 4, 5, 6)  # Too many args
    end
  end

  # Test set_row with wrong number of arguments
  def test_set_row_wrong_argc
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(ArgumentError) do
      m.set_row(0)  # Need at least 2 args
    end
  end

  # Test set_col with wrong number of arguments
  def test_set_col_wrong_argc
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(ArgumentError) do
      m.set_col(0)  # Need at least 2 args
    end
  end

  # Test get with array of wrong length
  def test_get_array_wrong_length
    m = GSL::Matrix::Complex.alloc(3, 3)
    assert_raises(ArgumentError) do
      m[[1, 2, 3]]  # Array index must have length 2
    end
  end

  # ======= Arithmetic with real Matrix =======

  # Test add with real GSL::Matrix
  def test_add_real_matrix
    mc = GSL::Matrix::Complex.alloc(2, 2)
    mc[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    mc[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    mc[1, 0] = GSL::Complex.alloc(5.0, 6.0)
    mc[1, 1] = GSL::Complex.alloc(7.0, 8.0)

    mr = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])
    result = mc + mr

    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 2.0, result[0, 0].real, 1e-10  # 1+1
    assert_in_delta 2.0, result[0, 0].imag, 1e-10  # imag unchanged
    assert_in_delta 5.0, result[0, 1].real, 1e-10  # 3+2
  end

  # Test sub with real GSL::Matrix
  def test_sub_real_matrix
    mc = GSL::Matrix::Complex.alloc(2, 2)
    mc[0, 0] = GSL::Complex.alloc(5.0, 2.0)

    mr = GSL::Matrix.alloc([2.0, 1.0], [1.0, 1.0])
    result = mc - mr

    assert_in_delta 3.0, result[0, 0].real, 1e-10
    assert_in_delta 2.0, result[0, 0].imag, 1e-10
  end

  # Test mul_elements with real GSL::Matrix
  def test_mul_elements_real_matrix
    mc = GSL::Matrix::Complex.alloc(2, 2)
    mc[0, 0] = GSL::Complex.alloc(2.0, 3.0)

    mr = GSL::Matrix.alloc([2.0, 1.0], [1.0, 1.0])
    result = mc.mul_elements(mr)

    assert_in_delta 4.0, result[0, 0].real, 1e-10
    assert_in_delta 6.0, result[0, 0].imag, 1e-10
  end

  # Test div_elements with real GSL::Matrix
  def test_div_elements_real_matrix
    mc = GSL::Matrix::Complex.alloc(2, 2)
    mc[0, 0] = GSL::Complex.alloc(4.0, 6.0)

    mr = GSL::Matrix.alloc([2.0, 1.0], [1.0, 1.0])
    result = mc.div_elements(mr)

    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 3.0, result[0, 0].imag, 1e-10
  end

  # Test wrong type in arithmetics
  def test_arithmetics_wrong_type
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(TypeError) do
      m + "string"
    end
  end

  # ======= Conjugate/Dagger operations =======

  # Test conjugate! (in-place)
  def test_conjugate_bang
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)

    result = m.conjugate!
    assert_equal m.object_id, result.object_id
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta(-2.0, m[0, 0].imag, 1e-10)
    assert_in_delta 3.0, m[0, 1].real, 1e-10
    assert_in_delta(-4.0, m[0, 1].imag, 1e-10)
  end

  # Test dagger! (conjugate transpose in-place)
  def test_dagger_bang
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m[1, 0] = GSL::Complex.alloc(5.0, 6.0)
    m[1, 1] = GSL::Complex.alloc(7.0, 8.0)

    result = m.dagger!
    assert_equal m.object_id, result.object_id
    # After transpose and conjugate: [0,1] and [1,0] swap with conjugate
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta(-2.0, m[0, 0].imag, 1e-10)
    assert_in_delta 5.0, m[0, 1].real, 1e-10
    assert_in_delta(-6.0, m[0, 1].imag, 1e-10)
  end

  # Test dagger (non-mutating)
  def test_dagger
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m[1, 0] = GSL::Complex.alloc(5.0, 6.0)
    m[1, 1] = GSL::Complex.alloc(7.0, 8.0)

    result = m.dagger
    refute_equal m.object_id, result.object_id

    # Original unchanged
    assert_in_delta 2.0, m[0, 0].imag, 1e-10
    # Result has conjugate transpose
    assert_in_delta(-2.0, result[0, 0].imag, 1e-10)
    assert_in_delta 5.0, result[0, 1].real, 1e-10
    assert_in_delta(-6.0, result[0, 1].imag, 1e-10)
  end

  # ======= Transpose and isnull =======

  # Test transpose
  def test_transpose
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    result = m.transpose
    assert_equal m.object_id, result.object_id
    assert_in_delta 2.0, m[1, 0].real, 1e-10
    assert_in_delta 3.0, m[0, 1].real, 1e-10
  end

  # Test isnull with zero matrix
  def test_isnull_true
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set_zero
    assert m.isnull
  end

  # Test isnull with non-zero matrix
  def test_isnull_false
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    refute m.isnull
  end

  # ======= Trace =======

  # Test trace
  def test_trace
    m = GSL::Matrix::Complex.alloc(3, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[1, 1] = GSL::Complex.alloc(3.0, 4.0)
    m[2, 2] = GSL::Complex.alloc(5.0, 6.0)

    tr = m.trace
    assert tr.is_a?(GSL::Complex)
    assert_in_delta 9.0, tr.real, 1e-10   # 1+3+5
    assert_in_delta 12.0, tr.imag, 1e-10  # 2+4+6
  end

  # ======= Real and Imag extraction =======

  # Test real extraction
  def test_real
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m[1, 0] = GSL::Complex.alloc(5.0, 6.0)
    m[1, 1] = GSL::Complex.alloc(7.0, 8.0)

    r = m.real
    assert r.is_a?(GSL::Matrix)
    assert_in_delta 1.0, r[0, 0], 1e-10
    assert_in_delta 3.0, r[0, 1], 1e-10
    assert_in_delta 5.0, r[1, 0], 1e-10
    assert_in_delta 7.0, r[1, 1], 1e-10
  end

  # Test imag extraction
  def test_imag
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m[1, 0] = GSL::Complex.alloc(5.0, 6.0)
    m[1, 1] = GSL::Complex.alloc(7.0, 8.0)

    i = m.imag
    assert i.is_a?(GSL::Matrix)
    assert_in_delta 2.0, i[0, 0], 1e-10
    assert_in_delta 4.0, i[0, 1], 1e-10
    assert_in_delta 6.0, i[1, 0], 1e-10
    assert_in_delta 8.0, i[1, 1], 1e-10
  end

  # ======= Size accessors =======

  # Test size1 and size2
  def test_size_accessors
    m = GSL::Matrix::Complex.alloc(3, 5)
    assert_equal 3, m.size1
    assert_equal 5, m.size2
    assert_equal [3, 5], m.shape
    assert_equal [3, 5], m.size
  end

  # ======= Memcpy singleton =======

  # Test Matrix::Complex.memcpy
  def test_memcpy_singleton
    src = GSL::Matrix::Complex.alloc(2, 2)
    src[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    src[1, 1] = GSL::Complex.alloc(3.0, 4.0)

    dst = GSL::Matrix::Complex.alloc(2, 2)
    result = GSL::Matrix::Complex.memcpy(dst, src)

    assert_equal dst.object_id, result.object_id
    assert_in_delta 1.0, dst[0, 0].real, 1e-10
    assert_in_delta 2.0, dst[0, 0].imag, 1e-10
    assert_in_delta 3.0, dst[1, 1].real, 1e-10
    assert_in_delta 4.0, dst[1, 1].imag, 1e-10
  end

  # ======= More math operations =======

  # Test arg (phase/angle)
  def test_arg
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 1.0)  # arg = pi/4
    m[0, 1] = GSL::Complex.alloc(0.0, 1.0)  # arg = pi/2
    m[1, 0] = GSL::Complex.alloc(1.0, 0.0)  # arg = 0
    m[1, 1] = GSL::Complex.alloc(-1.0, 0.0) # arg = pi

    result = m.arg
    assert result.is_a?(GSL::Matrix)
    assert_in_delta Math::PI / 4, result[0, 0], 1e-10
    assert_in_delta Math::PI / 2, result[0, 1], 1e-10
    assert_in_delta 0.0, result[1, 0], 1e-10
    assert_in_delta Math::PI, result[1, 1], 1e-10
  end

  # Test abs (magnitude)
  def test_abs
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(3.0, 4.0)  # |z| = 5
    m[0, 1] = GSL::Complex.alloc(1.0, 0.0)  # |z| = 1
    m[1, 0] = GSL::Complex.alloc(0.0, 2.0)  # |z| = 2
    m[1, 1] = GSL::Complex.alloc(0.0, 0.0)  # |z| = 0

    result = m.abs
    assert result.is_a?(GSL::Matrix)
    assert_in_delta 5.0, result[0, 0], 1e-10
    assert_in_delta 1.0, result[0, 1], 1e-10
    assert_in_delta 2.0, result[1, 0], 1e-10
    assert_in_delta 0.0, result[1, 1], 1e-10
  end

  # Test abs2 (squared magnitude)
  def test_abs2
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(3.0, 4.0)  # |z|^2 = 25

    result = m.abs2
    assert result.is_a?(GSL::Matrix)
    assert_in_delta 25.0, result[0, 0], 1e-10
  end

  # Test sqrt
  def test_sqrt
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(4.0, 0.0)  # sqrt = 2+0i

    result = m.sqrt
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 0.0, result[0, 0].imag, 1e-10
  end

  # Test exp
  def test_exp
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # exp(0) = 1

    result = m.exp
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
    assert_in_delta 0.0, result[0, 0].imag, 1e-10
  end

  # Test log
  def test_log
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(Math::E, 0.0)  # log(e) = 1

    result = m.log
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
    assert_in_delta 0.0, result[0, 0].imag, 1e-10
  end

  # Test log10
  def test_log10
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(100.0, 0.0)  # log10(100) = 2

    result = m.log10
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 0.0, result[0, 0].imag, 1e-10
  end

  # Test sin
  def test_sin
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # sin(0) = 0

    result = m.sin
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  # Test cos
  def test_cos
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # cos(0) = 1

    result = m.cos
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  # Test tan
  def test_tan
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # tan(0) = 0

    result = m.tan
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  # Test sinh
  def test_sinh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # sinh(0) = 0

    result = m.sinh
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  # Test cosh
  def test_cosh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # cosh(0) = 1

    result = m.cosh
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  # Test tanh
  def test_tanh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # tanh(0) = 0

    result = m.tanh
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  # ======= I/O operations =======

  # Test fwrite and fread
  def test_fwrite_fread
    m = GSL::Matrix::Complex.alloc(2, 3)
    m[0, 0] = GSL::Complex.alloc(1.1, 2.2)
    m[0, 1] = GSL::Complex.alloc(3.3, 4.4)
    m[1, 2] = GSL::Complex.alloc(5.5, 6.6)

    require 'tempfile'
    tmpfile = Tempfile.new(['matrix_complex', '.bin'])
    begin
      # Write
      status = m.fwrite(tmpfile.path)
      assert_equal 0, status

      # Read into new matrix
      m2 = GSL::Matrix::Complex.alloc(2, 3)
      status = m2.fread(tmpfile.path)
      assert_equal 0, status

      assert_in_delta 1.1, m2[0, 0].real, 1e-10
      assert_in_delta 2.2, m2[0, 0].imag, 1e-10
      assert_in_delta 3.3, m2[0, 1].real, 1e-10
      assert_in_delta 5.5, m2[1, 2].real, 1e-10
    ensure
      tmpfile.close
      tmpfile.unlink
    end
  end

  # Test fprintf and fscanf
  def test_fprintf_fscanf
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.5, 2.5)
    m[0, 1] = GSL::Complex.alloc(3.5, 4.5)
    m[1, 0] = GSL::Complex.alloc(5.5, 6.5)
    m[1, 1] = GSL::Complex.alloc(7.5, 8.5)

    require 'tempfile'
    tmpfile = Tempfile.new(['matrix_complex', '.txt'])
    begin
      # Write with format
      status = m.fprintf(tmpfile.path, "%.6f")
      assert_equal 0, status

      # Read back
      m2 = GSL::Matrix::Complex.alloc(2, 2)
      status = m2.fscanf(tmpfile.path)
      assert_equal 0, status

      assert_in_delta 1.5, m2[0, 0].real, 1e-5
      assert_in_delta 2.5, m2[0, 0].imag, 1e-5
    ensure
      tmpfile.close
      tmpfile.unlink
    end
  end

  # Test fprintf with wrong argc
  def test_fprintf_wrong_argc
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(ArgumentError) do
      m.fprintf("file", "fmt", "extra")
    end
  end

  # Test to_s with too many args
  def test_to_s_wrong_argc
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(ArgumentError) do
      m.to_s(1, 2, 3)
    end
  end

  # Test inspect
  def test_inspect
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    s = m.inspect
    assert s.include?("Matrix::Complex")
    assert s.include?("[2,2]")
  end

  # Test printf with format
  def test_printf_with_format
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    # Just make sure it doesn't crash
    # stdout capture is tricky in tests, so just verify return value
    status = m.printf("%.2f")
    assert_equal 0, status
  end

  # Test printf without format
  def test_printf_no_format
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    status = m.printf
    assert_equal 0, status
  end

  # Test print
  def test_print
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    result = m.print
    assert_equal m.object_id, result.object_id
  end

  # ======= Additional row/col/diagonal operations =======

  # Test row and column accessors
  def test_row_accessor
    m = GSL::Matrix::Complex.alloc(3, 4)
    m.indgen!
    row = m.row(1)
    assert row.is_a?(GSL::Vector::Complex) || row.is_a?(GSL::Vector::Complex::View)
    assert_in_delta 4.0, row[0].real, 1e-10  # Row 1, element 0
  end

  # Test column accessor
  def test_column_accessor
    m = GSL::Matrix::Complex.alloc(3, 4)
    m.indgen!
    col = m.column(2)
    assert col.is_a?(GSL::Vector::Complex) || col.is_a?(GSL::Vector::Complex::View)
    assert_in_delta 2.0, col[0].real, 1e-10  # Column 2, row 0
  end

  # Test diagonal accessor
  def test_diagonal_accessor
    m = GSL::Matrix::Complex.alloc(3, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[2, 2] = GSL::Complex.alloc(3.0, 0.0)

    diag = m.diagonal
    assert diag.is_a?(GSL::Vector::Complex) || diag.is_a?(GSL::Vector::Complex::View)
    assert_in_delta 1.0, diag[0].real, 1e-10
    assert_in_delta 2.0, diag[1].real, 1e-10
    assert_in_delta 3.0, diag[2].real, 1e-10
  end

  # Test set_diagonal with wrong type
  def test_set_diagonal_wrong_type
    m = GSL::Matrix::Complex.alloc(3, 3)
    assert_raises(TypeError) do
      m.set_diagonal("wrong")
    end
  end

  # ======= Add diagonal with Complex =======

  # Test add_diagonal with GSL::Complex
  def test_add_diagonal_complex
    m = GSL::Matrix::Complex.eye(3)
    z = GSL::Complex.alloc(2.0, 3.0)
    m.add_diagonal(z)
    assert_in_delta 3.0, m[0, 0].real, 1e-10
    assert_in_delta 3.0, m[0, 0].imag, 1e-10
  end

  # Test add_diagonal with wrong type
  def test_add_diagonal_wrong_type
    m = GSL::Matrix::Complex.eye(3)
    assert_raises(TypeError) do
      m.add_diagonal("wrong")
    end
  end

  # ======= Coerce operations =======

  # Test coerce with wrong type
  def test_coerce_wrong_type
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(TypeError) do
      m.coerce("string")
    end
  end

  # ======= Mul variants =======

  # Test mul with BLAS (Vector multiplication)
  def test_mul_complex_vector_blas
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)

    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(2.0, 3.0)
    v[1] = GSL::Complex.alloc(4.0, 5.0)

    # This should use gsl_blas_zgemv
    result = m * v
    assert result.is_a?(GSL::Vector::Complex)
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[0].imag, 1e-10
  end

  # Test indgen wrong argc
  def test_indgen_wrong_argc
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(ArgumentError) do
      m.indgen(1, 2, 3)  # Too many args for instance method
    end
  end

  # Test indgen! wrong argc
  def test_indgen_bang_wrong_argc
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(ArgumentError) do
      m.indgen!(1, 2, 3)  # Too many args
    end
  end

  # Test singleton indgen wrong argc
  def test_indgen_singleton_wrong_argc
    assert_raises(ArgumentError) do
      GSL::Matrix::Complex.indgen(2)  # Need at least 2 args
    end
  end

  # Test equal? wrong argc
  def test_equal_wrong_argc
    m = GSL::Matrix::Complex.alloc(2, 2)
    assert_raises(ArgumentError) do
      m.equal?(m, 1e-10, "extra")
    end
  end
end
