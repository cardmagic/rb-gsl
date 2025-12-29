require 'test_helper'

class CoercibleObject
  def initialize(value)
    @value = value
  end

  def coerce(other)
    [CoercibleObject.new(other), self]
  end

  def *(other)
    @value * other.instance_variable_get(:@value)
  end

  def /(other)
    @value.to_f / other.instance_variable_get(:@value)
  end
end

class OperCoverageTest < GSL::TestCase
  def test_numeric_times_vector
    v = GSL::Vector[1, 2, 3]
    result = 2 * v
    assert_equal 2.0, result[0]
    assert_equal 4.0, result[1]
    assert_equal 6.0, result[2]
  end

  def test_numeric_times_matrix
    m = GSL::Matrix[[1, 2], [3, 4]]
    result = 2 * m
    assert_equal 2.0, result[0, 0]
    assert_equal 4.0, result[0, 1]
    assert_equal 6.0, result[1, 0]
    assert_equal 8.0, result[1, 1]
  end

  def test_numeric_div_vector_col
    v = GSL::Vector::Col[1, 2, 2]
    result = 1.0 / v
    assert result.is_a?(GSL::Vector)
  end

  def test_numeric_div_poly
    p = GSL::Poly[1, 2, 3]
    result = 1 / p
    assert result.is_a?(GSL::Rational)
  end

  def test_numeric_times_numeric
    result = 2 * 3
    assert_equal 6, result
  end

  def test_numeric_div_numeric
    result = 6 / 2
    assert_equal 3, result
  end

  def test_numeric_times_complex_vector
    v = GSL::Vector::Complex[GSL::Complex[1, 2], GSL::Complex[3, 4]]
    result = 2 * v
    assert result.is_a?(GSL::Vector::Complex)
  end

  def test_numeric_times_complex_matrix
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, GSL::Complex[1, 0])
    result = 2 * m
    assert result.is_a?(GSL::Matrix::Complex)
  end

  def test_numeric_div_int_vector_col
    v = GSL::Vector::Int::Col[1, 2, 2]
    result = 1.0 / v
    assert result.is_a?(GSL::Vector)
  end

  def test_numeric_times_else_branch
    obj = CoercibleObject.new(3)
    result = 2 * obj
    assert_equal 6, result
  end

  def test_numeric_div_else_branch
    obj = CoercibleObject.new(2)
    result = 6 / obj
    assert_equal 3.0, result
  end
end
