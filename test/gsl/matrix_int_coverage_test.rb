require 'test_helper'

class MatrixIntCoverageTest < GSL::TestCase
  # ======= Basic constructors =======

  def test_alloc_with_array
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_equal 1, m[0, 0]
    assert_equal 6, m[1, 2]
  end

  # ======= Arithmetic operations =======

  def test_add_fixnum
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    result = m + 5
    assert_equal 6, result[0, 0]
    assert_equal 9, result[1, 1]
  end

  def test_sub_fixnum
    m = GSL::Matrix::Int.alloc([5, 6, 7, 8], 2, 2)
    result = m - 3
    assert_equal 2, result[0, 0]
    assert_equal 5, result[1, 1]
  end

  def test_mul_fixnum
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    result = m.mul(2)
    assert_equal 2, result[0, 0]
    assert_equal 8, result[1, 1]
  end

  def test_div_fixnum
    m = GSL::Matrix::Int.alloc([4, 8, 12, 16], 2, 2)
    result = m / 4
    # Division is element-wise division in integer matrix
    assert result.is_a?(GSL::Matrix::Int)
  end

  def test_add_matrix_int
    m1 = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix::Int.alloc([5, 6, 7, 8], 2, 2)
    result = m1 + m2
    assert_equal 6, result[0, 0]
    assert_equal 12, result[1, 1]
  end

  def test_sub_matrix_int
    m1 = GSL::Matrix::Int.alloc([10, 20, 30, 40], 2, 2)
    m2 = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    result = m1 - m2
    assert_equal 9, result[0, 0]
    assert_equal 36, result[1, 1]
  end

  def test_mul_elements_matrix_int
    m1 = GSL::Matrix::Int.alloc([2, 3, 4, 5], 2, 2)
    m2 = GSL::Matrix::Int.alloc([3, 4, 5, 6], 2, 2)
    result = m1.mul(m2)
    assert_equal 6, result[0, 0]
    assert_equal 30, result[1, 1]
  end

  def test_div_elements_matrix_int
    m1 = GSL::Matrix::Int.alloc([12, 24, 36, 48], 2, 2)
    m2 = GSL::Matrix::Int.alloc([3, 4, 6, 8], 2, 2)
    result = m1 / m2
    assert_equal 4, result[0, 0]
    assert_equal 6, result[1, 1]
  end

  # Test with float (gets converted to int)
  def test_add_float
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    result = m + 2.5  # Gets converted to int
    assert result.is_a?(GSL::Matrix::Int)
  end

  # ======= Matrix multiplication =======

  def test_matrix_mul_matrix_int
    m1 = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m2 = GSL::Matrix::Int.alloc([1, 0, 0, 1], 2, 2)  # Identity
    result = m1 * m2
    assert_equal 1, result[0, 0]
    assert_equal 4, result[1, 1]
  end

  def test_matrix_mul_vector_int_col
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    v = GSL::Vector::Int[1, 1]
    v_col = v.col

    result = m * v_col
    assert result.is_a?(GSL::Vector::Int)
    assert_equal 3, result[0]  # 1+2
    assert_equal 7, result[1]  # 3+4
  end

  def test_matrix_mul_fixnum
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    result = m * 2
    assert_equal 2, result[0, 0]
    assert_equal 8, result[1, 1]
  end

  # Test matrix_mul with wrong type
  def test_matrix_mul_wrong_type
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(TypeError) do
      m * "invalid"
    end
  end

  # ======= Conversion operations =======

  def test_to_f
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    result = m.to_f
    assert result.is_a?(GSL::Matrix)
    assert_in_delta 1.0, result[0, 0], 1e-10
    assert_in_delta 4.0, result[1, 1], 1e-10
  end

  def test_to_i
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    result = m.to_i
    assert_equal m.object_id, result.object_id
  end

  def test_to_complex
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    result = m.to_complex
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
    assert_in_delta 0.0, result[0, 0].imag, 1e-10
    assert_in_delta 4.0, result[1, 1].real, 1e-10
  end

  # ======= Coerce =======

  def test_coerce
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    coerced = m.coerce(5.0)
    assert coerced.is_a?(Array)
    assert_equal 2, coerced.size
    # First element is the coerced value, second is the matrix converted to float
    assert coerced[1].is_a?(GSL::Matrix)
  end

  # ======= Vector multiplication via operation1 =======

  def test_mul_vector_int_col_via_operation1
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    v = GSL::Vector::Int[1, 1]
    v_col = v.col

    # Using mul method (not matrix_mul) should still work with col vector
    result = m.mul(v_col)
    assert result.is_a?(GSL::Vector::Int)
  end

  # Test add with vector column (should raise error)
  def test_add_vector_int_col_error
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    v = GSL::Vector::Int[1, 1]
    v_col = v.col

    assert_raises(RuntimeError) do
      m + v_col
    end
  end

  # ======= Operations with real Matrix (gets converted) =======

  def test_add_real_matrix
    m_int = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    m_real = GSL::Matrix.alloc([5.0, 6.0], [7.0, 8.0])

    result = m_int + m_real
    # Real matrix gets converted to int matrix
    assert result.is_a?(GSL::Matrix::Int)
    assert_equal 6, result[0, 0]
  end

  # ======= Operation with wrong type =======

  def test_operation_wrong_type
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    assert_raises(TypeError) do
      m + "invalid"
    end
  end

  # ======= Boolean status checks =======

  def test_ispos
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    assert_equal 1, m.ispos
    assert_equal true, m.ispos?
  end

  def test_isneg
    m = GSL::Matrix::Int.alloc([-1, -2, -3, -4], 2, 2)
    assert_equal 1, m.isneg
    assert_equal true, m.isneg?
  end

  def test_isnonneg
    m = GSL::Matrix::Int.alloc([0, 1, 2, 3], 2, 2)
    assert_equal 1, m.isnonneg
    assert_equal true, m.isnonneg?
  end

  # ======= Matrix dimension tests =======

  def test_matmult_dimension_check
    m1 = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    m2 = GSL::Matrix::Int.alloc([1, 2, 3, 4, 5, 6], 3, 2)

    # 2x3 * 3x2 = 2x2 (should work)
    result = m1 * m2
    assert_equal 2, result.size1
    assert_equal 2, result.size2
  end
end
