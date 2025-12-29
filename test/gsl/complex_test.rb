require 'test_helper'

class ComplexTest < GSL::TestCase

  def test_complex
    10.times { |i|
      r = (i - 5.0) * 0.3
      t = 2.0 * GSL::M_PI * i / 5.0

      z = GSL::Complex.polar(r, t)

      assert_rel z.real, r * Math.cos(t), 10 * GSL::DBL_EPSILON,
        'gsl_complex_polar real part at (r=%g,t=%g)' % [r, t]

      assert_rel z.imag, r * Math.sin(t), 10 * GSL::DBL_EPSILON,
        'gsl_complex_polar imag part at (r=%g,t=%g)' % [r, t]
    }
  end
  
  # Test if it is possible to create a GSL::Complex from ::Complex
  def test_rb_complex_creation
    rb_comp = Complex(rand, rand)

    z = GSL::Complex.alloc(rb_comp)

    assert_rel z.real, rb_comp.real, GSL::DBL_EPSILON,
      "gsl_complex real part.  Re(#{rb_comp}) = #{z.real}"
    assert_rel z.imag, rb_comp.imag, GSL::DBL_EPSILON,
      "gsl_complex imag part.  Im(#{rb_comp}) = #{z.imag}"
  end

  # Vector::Complex tests
  def test_vector_complex_alloc
    v = GSL::Vector::Complex.alloc(5)
    assert_equal 5, v.size, "Vector::Complex.alloc creates vector of correct size"
  end

  def test_vector_complex_set_get
    v = GSL::Vector::Complex.alloc(3)
    z = GSL::Complex.alloc(1.0, 2.0)
    v.set(1, z)

    result = v.get(1)
    assert_in_delta 1.0, result.real, 1e-10
    assert_in_delta 2.0, result.imag, 1e-10
  end

  def test_vector_complex_bracket_access
    v = GSL::Vector::Complex.alloc(3)
    z = GSL::Complex.alloc(3.0, 4.0)
    v[0] = z

    result = v[0]
    assert_in_delta 3.0, result.real, 1e-10
    assert_in_delta 4.0, result.imag, 1e-10
  end

  def test_vector_complex_set_all
    v = GSL::Vector::Complex.alloc(3)
    z = GSL::Complex.alloc(1.0, 1.0)
    v.set_all(z)

    3.times do |i|
      assert_in_delta 1.0, v[i].real, 1e-10
      assert_in_delta 1.0, v[i].imag, 1e-10
    end
  end

  def test_vector_complex_set_zero
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v.set_zero

    3.times do |i|
      assert_in_delta 0.0, v[i].real, 1e-10
      assert_in_delta 0.0, v[i].imag, 1e-10
    end
  end

  def test_vector_complex_set_basis
    v = GSL::Vector::Complex.alloc(3)
    v.set_basis(1)

    assert_in_delta 0.0, v[0].real, 1e-10
    assert_in_delta 1.0, v[1].real, 1e-10
    assert_in_delta 0.0, v[2].real, 1e-10
  end

  def test_vector_complex_real
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    v[2] = GSL::Complex.alloc(5.0, 6.0)

    real = v.real
    assert real.is_a?(GSL::Vector::View), "real returns a vector view"
    assert_in_delta 1.0, real[0], 1e-10
    assert_in_delta 3.0, real[1], 1e-10
    assert_in_delta 5.0, real[2], 1e-10
  end

  def test_vector_complex_imag
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    v[2] = GSL::Complex.alloc(5.0, 6.0)

    imag = v.imag
    assert imag.is_a?(GSL::Vector::View), "imag returns a vector view"
    assert_in_delta 2.0, imag[0], 1e-10
    assert_in_delta 4.0, imag[1], 1e-10
    assert_in_delta 6.0, imag[2], 1e-10
  end

  def test_vector_complex_add
    v1 = GSL::Vector::Complex.alloc(2)
    v2 = GSL::Vector::Complex.alloc(2)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)
    v1[1] = GSL::Complex.alloc(3.0, 4.0)
    v2[0] = GSL::Complex.alloc(1.0, 1.0)
    v2[1] = GSL::Complex.alloc(2.0, 2.0)

    result = v1 + v2
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[0].imag, 1e-10
    assert_in_delta 5.0, result[1].real, 1e-10
    assert_in_delta 6.0, result[1].imag, 1e-10
  end

  def test_vector_complex_sub
    v1 = GSL::Vector::Complex.alloc(2)
    v2 = GSL::Vector::Complex.alloc(2)
    v1[0] = GSL::Complex.alloc(3.0, 4.0)
    v1[1] = GSL::Complex.alloc(5.0, 6.0)
    v2[0] = GSL::Complex.alloc(1.0, 1.0)
    v2[1] = GSL::Complex.alloc(2.0, 2.0)

    result = v1 - v2
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[0].imag, 1e-10
    assert_in_delta 3.0, result[1].real, 1e-10
    assert_in_delta 4.0, result[1].imag, 1e-10
  end

  def test_vector_complex_mul_elements
    v1 = GSL::Vector::Complex.alloc(2)
    v2 = GSL::Vector::Complex.alloc(2)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)
    v1[1] = GSL::Complex.alloc(3.0, 0.0)
    v2[0] = GSL::Complex.alloc(2.0, 0.0)
    v2[1] = GSL::Complex.alloc(0.0, 2.0)

    result = v1 * v2
    # (1+2i)*(2+0i) = 2+4i
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 4.0, result[0].imag, 1e-10
    # (3+0i)*(0+2i) = 0+6i
    assert_in_delta 0.0, result[1].real, 1e-10
    assert_in_delta 6.0, result[1].imag, 1e-10
  end

  def test_vector_complex_scale
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    z = GSL::Complex.alloc(2.0, 0.0)

    result = v.scale(z)
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 4.0, result[0].imag, 1e-10
    assert_in_delta 6.0, result[1].real, 1e-10
    assert_in_delta 8.0, result[1].imag, 1e-10
  end

  def test_vector_complex_add_constant
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    z = GSL::Complex.alloc(1.0, 1.0)

    result = v.add_constant(z)
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[0].imag, 1e-10
    assert_in_delta 4.0, result[1].real, 1e-10
    assert_in_delta 5.0, result[1].imag, 1e-10
  end

  def test_vector_complex_clone
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)

    clone = v.clone
    assert_in_delta 1.0, clone[0].real, 1e-10
    assert_in_delta 2.0, clone[0].imag, 1e-10
  end

  def test_vector_complex_conj
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, -4.0)

    conj = v.conj
    assert_in_delta 1.0, conj[0].real, 1e-10
    assert_in_delta -2.0, conj[0].imag, 1e-10
    assert_in_delta 3.0, conj[1].real, 1e-10
    assert_in_delta 4.0, conj[1].imag, 1e-10
  end

  def test_vector_complex_abs
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(3.0, 4.0)  # |z| = 5
    v[1] = GSL::Complex.alloc(0.0, 2.0)  # |z| = 2

    abs = v.abs
    assert abs.is_a?(GSL::Vector), "abs returns a real vector"
    assert_in_delta 5.0, abs[0], 1e-10
    assert_in_delta 2.0, abs[1], 1e-10
  end

  def test_vector_complex_arg
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)  # arg = 0
    v[1] = GSL::Complex.alloc(0.0, 1.0)  # arg = pi/2

    arg = v.arg
    assert arg.is_a?(GSL::Vector), "arg returns a real vector"
    assert_in_delta 0.0, arg[0], 1e-10
    assert_in_delta Math::PI/2, arg[1], 1e-10
  end

  def test_vector_complex_subvector
    v = GSL::Vector::Complex.alloc(5)
    5.times { |i| v[i] = GSL::Complex.alloc(i.to_f, i.to_f * 2) }

    sub = v.subvector(1, 3)
    assert_equal 3, sub.size
    assert_in_delta 1.0, sub[0].real, 1e-10
    assert_in_delta 2.0, sub[1].real, 1e-10
    assert_in_delta 3.0, sub[2].real, 1e-10
  end

  # Matrix::Complex tests
  def test_matrix_complex_alloc
    m = GSL::Matrix::Complex.alloc(3, 4)
    assert_equal 3, m.size1
    assert_equal 4, m.size2
  end

  def test_matrix_complex_set_get
    m = GSL::Matrix::Complex.alloc(2, 2)
    z = GSL::Complex.alloc(1.0, 2.0)
    m.set(0, 1, z)

    result = m.get(0, 1)
    assert_in_delta 1.0, result.real, 1e-10
    assert_in_delta 2.0, result.imag, 1e-10
  end

  def test_matrix_complex_bracket_access
    m = GSL::Matrix::Complex.alloc(2, 2)
    z = GSL::Complex.alloc(3.0, 4.0)
    m[1, 0] = z

    result = m[1, 0]
    assert_in_delta 3.0, result.real, 1e-10
    assert_in_delta 4.0, result.imag, 1e-10
  end

  def test_matrix_complex_set_all
    m = GSL::Matrix::Complex.alloc(2, 2)
    z = GSL::Complex.alloc(1.0, 1.0)
    m.set_all(z)

    2.times do |i|
      2.times do |j|
        assert_in_delta 1.0, m[i, j].real, 1e-10
        assert_in_delta 1.0, m[i, j].imag, 1e-10
      end
    end
  end

  def test_matrix_complex_set_zero
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m.set_zero

    2.times do |i|
      2.times do |j|
        assert_in_delta 0.0, m[i, j].real, 1e-10
        assert_in_delta 0.0, m[i, j].imag, 1e-10
      end
    end
  end

  def test_matrix_complex_set_identity
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_identity

    3.times do |i|
      3.times do |j|
        if i == j
          assert_in_delta 1.0, m[i, j].real, 1e-10
        else
          assert_in_delta 0.0, m[i, j].real, 1e-10
        end
        assert_in_delta 0.0, m[i, j].imag, 1e-10
      end
    end
  end

  def test_matrix_complex_add
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m1[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m2[0, 0] = GSL::Complex.alloc(1.0, 1.0)
    m2[0, 1] = GSL::Complex.alloc(2.0, 2.0)

    result = m1 + m2
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 3.0, result[0, 0].imag, 1e-10
    assert_in_delta 5.0, result[0, 1].real, 1e-10
    assert_in_delta 6.0, result[0, 1].imag, 1e-10
  end

  def test_matrix_complex_sub
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(3.0, 4.0)
    m2[0, 0] = GSL::Complex.alloc(1.0, 1.0)

    result = m1 - m2
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 3.0, result[0, 0].imag, 1e-10
  end

  def test_matrix_complex_mul_elements
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m2[0, 0] = GSL::Complex.alloc(2.0, 0.0)

    result = m1.mul_elements(m2)
    # (1+2i)*(2+0i) = 2+4i
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 4.0, result[0, 0].imag, 1e-10
  end

  def test_matrix_complex_scale
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    z = GSL::Complex.alloc(2.0, 0.0)

    result = m.scale(z)
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 4.0, result[0, 0].imag, 1e-10
    assert_in_delta 6.0, result[0, 1].real, 1e-10
    assert_in_delta 8.0, result[0, 1].imag, 1e-10
  end

  def test_matrix_complex_clone
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    clone = m.clone
    assert_in_delta 1.0, clone[0, 0].real, 1e-10
    assert_in_delta 2.0, clone[0, 0].imag, 1e-10
  end

  def test_matrix_complex_transpose
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m[1, 0] = GSL::Complex.alloc(5.0, 6.0)
    m[1, 1] = GSL::Complex.alloc(7.0, 8.0)

    t = m.transpose
    assert_equal 2, t.size1
    assert_equal 2, t.size2
    assert_in_delta 1.0, t[0, 0].real, 1e-10
    assert_in_delta 5.0, t[0, 1].real, 1e-10
    assert_in_delta 3.0, t[1, 0].real, 1e-10
  end

  def test_matrix_complex_row
    m = GSL::Matrix::Complex.alloc(2, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m[0, 2] = GSL::Complex.alloc(5.0, 6.0)

    row = m.row(0)
    assert_equal 3, row.size
    assert_in_delta 1.0, row[0].real, 1e-10
    assert_in_delta 3.0, row[1].real, 1e-10
    assert_in_delta 5.0, row[2].real, 1e-10
  end

  def test_matrix_complex_col
    m = GSL::Matrix::Complex.alloc(3, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 4.0)
    m[2, 0] = GSL::Complex.alloc(5.0, 6.0)

    col = m.col(0)
    assert_equal 3, col.size
    assert_in_delta 1.0, col[0].real, 1e-10
    assert_in_delta 3.0, col[1].real, 1e-10
    assert_in_delta 5.0, col[2].real, 1e-10
  end

  def test_matrix_complex_diagonal
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_identity

    diag = m.diagonal
    assert_equal 3, diag.size
    3.times { |i| assert_in_delta 1.0, diag[i].real, 1e-10 }
  end

  def test_matrix_complex_conjugate
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, -4.0)

    conj = m.conj
    assert_in_delta 1.0, conj[0, 0].real, 1e-10
    assert_in_delta -2.0, conj[0, 0].imag, 1e-10
    assert_in_delta 3.0, conj[0, 1].real, 1e-10
    assert_in_delta 4.0, conj[0, 1].imag, 1e-10
  end

  def test_matrix_complex_dagger
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m[1, 0] = GSL::Complex.alloc(5.0, 6.0)
    m[1, 1] = GSL::Complex.alloc(7.0, 8.0)

    dag = m.dagger  # conjugate transpose
    assert_in_delta 1.0, dag[0, 0].real, 1e-10
    assert_in_delta -2.0, dag[0, 0].imag, 1e-10
    assert_in_delta 5.0, dag[0, 1].real, 1e-10
    assert_in_delta -6.0, dag[0, 1].imag, 1e-10
    assert_in_delta 3.0, dag[1, 0].real, 1e-10
    assert_in_delta -4.0, dag[1, 0].imag, 1e-10
  end

  def test_matrix_complex_submatrix
    m = GSL::Matrix::Complex.alloc(4, 4)
    4.times do |i|
      4.times do |j|
        m[i, j] = GSL::Complex.alloc(i * 4 + j, 0)
      end
    end

    sub = m.submatrix(1, 1, 2, 2)
    assert_equal 2, sub.size1
    assert_equal 2, sub.size2
    assert_in_delta 5.0, sub[0, 0].real, 1e-10  # m[1,1]
    assert_in_delta 6.0, sub[0, 1].real, 1e-10  # m[1,2]
    assert_in_delta 9.0, sub[1, 0].real, 1e-10  # m[2,1]
  end

  # Additional Matrix::Complex tests for coverage
  def test_matrix_complex_add_constant
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    z = GSL::Complex.alloc(1.0, 1.0)

    result = m.add_constant(z)
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 3.0, result[0, 0].imag, 1e-10
  end

  def test_matrix_complex_div_elements
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(4.0, 0.0)
    m2[0, 0] = GSL::Complex.alloc(2.0, 0.0)

    result = m1.div_elements(m2)
    assert_in_delta 2.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_mul_vector
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(1.0, 0.0)
    v_col = v.col  # Make it a column vector

    result = m * v_col
    assert result.is_a?(GSL::Vector::Complex)
    # First row: 1*1 + 2*1 = 3
    assert_in_delta 3.0, result[0].real, 1e-10
    # Second row: 3*1 + 4*1 = 7
    assert_in_delta 7.0, result[1].real, 1e-10
  end

  def test_matrix_complex_add_real_scalar
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)

    result = m + 1.0
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 2.0, result[0, 0].imag, 1e-10
  end

  def test_matrix_complex_sub_real_scalar
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(3.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(5.0, 4.0)

    result = m - 1.0
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 2.0, result[0, 0].imag, 1e-10
  end

  def test_matrix_complex_mul_real_scalar
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    result = m * 2.0
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 4.0, result[0, 0].imag, 1e-10
  end

  def test_matrix_complex_div_real_scalar
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(4.0, 8.0)

    result = m / 2.0
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 4.0, result[0, 0].imag, 1e-10
  end

  def test_matrix_complex_add_real_matrix
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    m2 = GSL::Matrix.alloc([1.0, 0.0], [0.0, 1.0])
    result = m1 + m2
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 2.0, result[0, 0].imag, 1e-10
  end

  def test_matrix_complex_identity
    m = GSL::Matrix::Complex.identity(3)
    assert_equal 3, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 0.0, m[0, 1].real, 1e-10
    assert_in_delta 1.0, m[1, 1].real, 1e-10
  end

  def test_matrix_complex_eye
    m = GSL::Matrix::Complex.eye(3)
    assert_equal 3, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[2, 2].real, 1e-10
  end

  def test_matrix_complex_swap_rows
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    m.swap_rows(0, 1)
    assert_in_delta 3.0, m[0, 0].real, 1e-10
    assert_in_delta 1.0, m[1, 0].real, 1e-10
  end

  def test_matrix_complex_swap_columns
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    m.swap_columns(0, 1)
    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 1.0, m[0, 1].real, 1e-10
  end

  def test_matrix_complex_swap_rowcol
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_identity

    m.swap_rowcol(0, 1)
    assert_in_delta 0.0, m[0, 0].real, 1e-10
    assert_in_delta 1.0, m[0, 1].real, 1e-10
  end

  # Note: Matrix::Complex isnull? and ispos? don't exist

  # Note: set_row and set_col for Matrix::Complex expect different args

  def test_matrix_complex_trace
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_identity
    m[0, 0] = GSL::Complex.alloc(2.0, 1.0)
    m[1, 1] = GSL::Complex.alloc(3.0, 2.0)
    m[2, 2] = GSL::Complex.alloc(4.0, 3.0)

    tr = m.trace
    assert tr.is_a?(GSL::Complex), "trace returns Complex"
    assert_in_delta 9.0, tr.real, 1e-10  # 2+3+4
    assert_in_delta 6.0, tr.imag, 1e-10  # 1+2+3
  end

  # Note: Matrix::Complex each and collect not defined

  def test_matrix_complex_memcpy
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m1[0, 1] = GSL::Complex.alloc(3.0, 4.0)

    m2 = GSL::Matrix::Complex.alloc(2, 2)
    GSL::Matrix::Complex.memcpy(m2, m1)

    assert_in_delta 1.0, m2[0, 0].real, 1e-10
    assert_in_delta 2.0, m2[0, 0].imag, 1e-10
  end

  # Note: Matrix::Complex doesn't have instance method swap

  def test_matrix_complex_coerce
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    # Test scalar + matrix (coercion)
    result = 1.0 + m
    assert_in_delta 2.0, result[0, 0].real, 1e-10
  end

  # Note: Matrix::Complex doesn't have min/max methods

  def test_matrix_complex_abs
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(3.0, 4.0)  # |z| = 5
    m[0, 1] = GSL::Complex.alloc(0.0, 2.0)  # |z| = 2

    abs = m.abs
    assert abs.is_a?(GSL::Matrix)
    assert_in_delta 5.0, abs[0, 0], 1e-10
    assert_in_delta 2.0, abs[0, 1], 1e-10
  end

  def test_matrix_complex_arg
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)  # arg = 0
    m[0, 1] = GSL::Complex.alloc(0.0, 1.0)  # arg = pi/2

    arg = m.arg
    assert arg.is_a?(GSL::Matrix)
    assert_in_delta 0.0, arg[0, 0], 1e-10
    assert_in_delta Math::PI/2, arg[0, 1], 1e-10
  end

  def test_matrix_complex_sqrt
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(4.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(9.0, 0.0)

    result = m.sqrt
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 3.0, result[0, 1].real, 1e-10
  end

  def test_matrix_complex_exp
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # exp(0) = 1
    m[0, 1] = GSL::Complex.alloc(1.0, 0.0)  # exp(1) = e

    result = m.exp
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
    assert_in_delta Math::E, result[0, 1].real, 1e-10
  end

  def test_matrix_complex_log
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)  # log(1) = 0
    m[0, 1] = GSL::Complex.alloc(Math::E, 0.0)  # log(e) = 1

    result = m.log
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
    assert_in_delta 1.0, result[0, 1].real, 1e-10
  end

  def test_matrix_complex_sin
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # sin(0) = 0
    m[0, 1] = GSL::Complex.alloc(Math::PI/2, 0.0)  # sin(pi/2) = 1

    result = m.sin
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
    assert_in_delta 1.0, result[0, 1].real, 1e-10
  end

  def test_matrix_complex_cos
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # cos(0) = 1
    m[0, 1] = GSL::Complex.alloc(Math::PI, 0.0)  # cos(pi) = -1

    result = m.cos
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
    assert_in_delta -1.0, result[0, 1].real, 1e-10
  end

  # Note: Matrix::Complex pow has different signature

  # Vector::Complex additional tests
  def test_vector_complex_div_elements
    v1 = GSL::Vector::Complex.alloc(2)
    v2 = GSL::Vector::Complex.alloc(2)
    v1[0] = GSL::Complex.alloc(4.0, 0.0)
    v1[1] = GSL::Complex.alloc(6.0, 0.0)
    v2[0] = GSL::Complex.alloc(2.0, 0.0)
    v2[1] = GSL::Complex.alloc(3.0, 0.0)

    result = v1 / v2
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 2.0, result[1].real, 1e-10
  end

  def test_vector_complex_swap
    v1 = GSL::Vector::Complex.alloc(2)
    v2 = GSL::Vector::Complex.alloc(2)
    v1[0] = GSL::Complex.alloc(1.0, 0.0)
    v2[0] = GSL::Complex.alloc(2.0, 0.0)

    v1.swap(v2)
    assert_in_delta 2.0, v1[0].real, 1e-10
    assert_in_delta 1.0, v2[0].real, 1e-10
  end

  def test_vector_complex_swap_elements
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    v.swap_elements(0, 2)
    assert_in_delta 3.0, v[0].real, 1e-10
    assert_in_delta 1.0, v[2].real, 1e-10
  end

  def test_vector_complex_reverse
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    reversed = v.reverse
    assert reversed.is_a?(GSL::Vector::Complex), "reverse returns a vector"
    assert_in_delta 3.0, reversed[0].real, 1e-10
    assert_in_delta 1.0, reversed[2].real, 1e-10
  end

  # Note: Vector::Complex doesn't have isnull? method

  def test_vector_complex_sqrt
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(4.0, 0.0)
    v[1] = GSL::Complex.alloc(9.0, 0.0)

    result = v.sqrt
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[1].real, 1e-10
  end

  def test_vector_complex_exp
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(1.0, 0.0)

    result = v.exp
    assert_in_delta 1.0, result[0].real, 1e-10
    assert_in_delta Math::E, result[1].real, 1e-10
  end

  def test_vector_complex_log
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(Math::E, 0.0)

    result = v.log
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta 1.0, result[1].real, 1e-10
  end

  # Vector::Complex iterator tests
  def test_vector_complex_each
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    sum = 0.0
    v.each { |z| sum += z.real }
    assert_in_delta 6.0, sum, 1e-10
  end

  def test_vector_complex_reverse_each
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    values = []
    v.reverse_each { |z| values << z.real }
    assert_in_delta 3.0, values[0], 1e-10
    assert_in_delta 1.0, values[2], 1e-10
  end

  def test_vector_complex_each_index
    v = GSL::Vector::Complex.alloc(3)
    indices = []
    v.each_index { |i| indices << i }
    assert_equal [0, 1, 2], indices
  end

  def test_vector_complex_reverse_each_index
    v = GSL::Vector::Complex.alloc(3)
    indices = []
    v.reverse_each_index { |i| indices << i }
    assert_equal [2, 1, 0], indices
  end

  def test_vector_complex_collect
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    result = v.collect { |z| GSL::Complex.alloc(z.real * 2, 0.0) }
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 4.0, result[1].real, 1e-10
    assert_in_delta 6.0, result[2].real, 1e-10
  end

  def test_vector_complex_collect_bang
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    v.collect! { |z| GSL::Complex.alloc(z.real * 2, 0.0) }
    assert_in_delta 2.0, v[0].real, 1e-10
    assert_in_delta 4.0, v[1].real, 1e-10
  end

  def test_vector_complex_stride
    v = GSL::Vector::Complex.alloc(3)
    assert_equal 1, v.stride
  end

  def test_vector_complex_owner
    v = GSL::Vector::Complex.alloc(3)
    assert_equal 1, v.owner
  end

  def test_vector_complex_ptr
    v = GSL::Vector::Complex.alloc(3)
    v[1] = GSL::Complex.alloc(5.0, 6.0)

    ptr = v.ptr(1)
    assert ptr.is_a?(GSL::Complex)
    assert_in_delta 5.0, ptr.real, 1e-10
    assert_in_delta 6.0, ptr.imag, 1e-10
  end

  def test_vector_complex_to_a
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)

    arr = v.to_a
    assert arr.is_a?(Array)
    # to_a returns raw data: [re0, im0, re1, im1]
    assert_equal 4, arr.size
    assert_in_delta 1.0, arr[0], 1e-10
    assert_in_delta 2.0, arr[1], 1e-10
    assert_in_delta 3.0, arr[2], 1e-10
    assert_in_delta 4.0, arr[3], 1e-10
  end

  def test_vector_complex_to_s
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)

    str = v.to_s
    assert str.is_a?(String)
    assert str.include?("["), "to_s format includes brackets"
  end

  def test_vector_complex_inspect
    v = GSL::Vector::Complex.alloc(2)
    str = v.inspect
    assert str.is_a?(String)
  end

  def test_vector_complex_negative_index
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    assert_in_delta 3.0, v[-1].real, 1e-10
    assert_in_delta 2.0, v[-2].real, 1e-10
  end

  def test_vector_complex_calloc
    v = GSL::Vector::Complex.calloc(3)
    assert_equal 3, v.size
    assert_in_delta 0.0, v[0].real, 1e-10
    assert_in_delta 0.0, v[0].imag, 1e-10
  end

  def test_vector_complex_set_subvector
    v = GSL::Vector::Complex.alloc(5)
    5.times { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    v2 = GSL::Vector::Complex.alloc(2)
    v2[0] = GSL::Complex.alloc(10.0, 0.0)
    v2[1] = GSL::Complex.alloc(20.0, 0.0)

    v[1..2] = v2
    assert_in_delta 10.0, v[1].real, 1e-10
    assert_in_delta 20.0, v[2].real, 1e-10
  end

  def test_vector_complex_memcpy
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)
    v1[1] = GSL::Complex.alloc(3.0, 4.0)

    v2 = GSL::Vector::Complex.alloc(3)
    GSL::Vector::Complex.memcpy(v2, v1)

    assert_in_delta 1.0, v2[0].real, 1e-10
    assert_in_delta 3.0, v2[1].real, 1e-10
  end

  def test_vector_complex_isnull
    v1 = GSL::Vector::Complex.alloc(3)
    v1.set_zero
    assert v1.isnull, "zero vector should be null"

    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(1.0, 0.0)
    refute v2.isnull, "non-zero vector should not be null"
  end

  def test_vector_complex_add_scalar
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)

    result = v + 1.0
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 2.0, result[0].imag, 1e-10
  end

  def test_vector_complex_sub_scalar
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(3.0, 2.0)
    v[1] = GSL::Complex.alloc(5.0, 4.0)

    result = v - 1.0
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 2.0, result[0].imag, 1e-10
  end

  def test_vector_complex_mul_scalar
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)

    result = v * 2.0
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 4.0, result[0].imag, 1e-10
  end

  def test_vector_complex_div_scalar
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(4.0, 8.0)
    v[1] = GSL::Complex.alloc(6.0, 10.0)

    result = v / 2.0
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 4.0, result[0].imag, 1e-10
  end

  def test_vector_complex_log10
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(100.0, 0.0)
    v[1] = GSL::Complex.alloc(1000.0, 0.0)

    result = v.log10
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[1].real, 1e-10
  end

  def test_vector_complex_sin
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(Math::PI / 2, 0.0)

    result = v.sin
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta 1.0, result[1].real, 1e-10
  end

  def test_vector_complex_cos
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(Math::PI, 0.0)

    result = v.cos
    assert_in_delta 1.0, result[0].real, 1e-10
    assert_in_delta -1.0, result[1].real, 1e-10
  end

  def test_vector_complex_tan
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(Math::PI / 4, 0.0)

    result = v.tan
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta 1.0, result[1].real, 1e-10
  end

  def test_vector_complex_abs2
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(3.0, 4.0)

    result = v.abs2
    assert result.is_a?(GSL::Vector)
    assert_in_delta 25.0, result[0], 1e-10
  end

  def test_vector_complex_logabs
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(Math::E, 0.0)

    result = v.logabs
    assert result.is_a?(GSL::Vector)
    assert_in_delta 1.0, result[0], 1e-10
  end

  def test_vector_complex_indgen
    v = GSL::Vector::Complex.alloc(3)
    v.indgen!

    assert_in_delta 0.0, v[0].real, 1e-10
    assert_in_delta 1.0, v[1].real, 1e-10
    assert_in_delta 2.0, v[2].real, 1e-10
  end

  def test_vector_complex_indgen_with_start_step
    v = GSL::Vector::Complex.alloc(3)
    v.indgen!(10, 2)

    assert_in_delta 10.0, v[0].real, 1e-10
    assert_in_delta 12.0, v[1].real, 1e-10
    assert_in_delta 14.0, v[2].real, 1e-10
  end

  def test_vector_complex_equal
    v1 = GSL::Vector::Complex.alloc(2)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)

    v2 = GSL::Vector::Complex.alloc(2)
    v2[0] = GSL::Complex.alloc(1.0, 2.0)

    assert v1.equal?(v2), "equal vectors should be equal"
  end

  def test_vector_complex_not_equal
    v1 = GSL::Vector::Complex.alloc(2)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)

    v2 = GSL::Vector::Complex.alloc(2)
    v2[0] = GSL::Complex.alloc(3.0, 4.0)

    assert v1.not_equal?(v2), "different vectors should not be equal"
  end

  def test_vector_complex_uplus
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)

    result = +v
    assert_in_delta 1.0, result[0].real, 1e-10
  end

  def test_vector_complex_uminus
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)

    result = -v
    assert_in_delta -1.0, result[0].real, 1e-10
    assert_in_delta -2.0, result[0].imag, 1e-10
  end

  def test_vector_complex_sinh
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.sinh
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_vector_complex_cosh
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.cosh
    assert_in_delta 1.0, result[0].real, 1e-10
  end

  def test_vector_complex_tanh
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.tanh
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_vector_complex_arcsin
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.arcsin
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_vector_complex_arccos
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    result = v.arccos
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_vector_complex_arctan
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.arctan
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  # Additional Matrix::Complex tests for improved coverage

  # Note: Matrix::Complex.isnull? is exposed but named isnull (no question mark)
  def test_matrix_complex_isnull
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1.set_zero
    assert m1.isnull, "zero matrix should be null"

    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m2[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    refute m2.isnull, "non-zero matrix should not be null"
  end

  # Note: set_row takes row index then multiple Complex values
  # It sets columns starting from 0 for that row
  def test_matrix_complex_set_row
    m = GSL::Matrix::Complex.alloc(2, 3)
    z1 = GSL::Complex.alloc(1.0, 2.0)
    z2 = GSL::Complex.alloc(3.0, 4.0)

    m.set_row(0, z1, z2)
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 3.0, m[0, 1].real, 1e-10
  end

  # Note: set_col takes col index then multiple Complex values
  # It sets rows starting from 0 for that column
  def test_matrix_complex_set_col
    m = GSL::Matrix::Complex.alloc(3, 2)
    z1 = GSL::Complex.alloc(1.0, 2.0)
    z2 = GSL::Complex.alloc(3.0, 4.0)

    m.set_col(0, z1, z2)
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 3.0, m[1, 0].real, 1e-10
  end

  def test_matrix_complex_to_a
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m[1, 0] = GSL::Complex.alloc(5.0, 6.0)
    m[1, 1] = GSL::Complex.alloc(7.0, 8.0)

    arr = m.to_a
    assert arr.is_a?(Array), "to_a returns Array"
    assert_equal 2, arr.size
    assert_equal 2, arr[0].size
    assert_in_delta 1.0, arr[0][0].real, 1e-10
    assert_in_delta 7.0, arr[1][1].real, 1e-10
  end

  def test_matrix_complex_ptr
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)

    ptr = m.ptr(0, 1)
    assert ptr.is_a?(GSL::Complex), "ptr returns Complex"
    assert_in_delta 3.0, ptr.real, 1e-10
    assert_in_delta 4.0, ptr.imag, 1e-10
  end

  def test_matrix_complex_to_s
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    str = m.to_s
    assert str.is_a?(String), "to_s returns String"
    assert str.include?("["), "to_s format includes brackets"
  end

  def test_matrix_complex_inspect
    m = GSL::Matrix::Complex.alloc(2, 2)
    str = m.inspect
    assert str.is_a?(String), "inspect returns String"
    assert str.include?("Matrix::Complex"), "inspect includes class name"
  end

  def test_matrix_complex_collect
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    result = m.collect { |z| GSL::Complex.alloc(z.real * 2, z.imag) }
    assert_in_delta 2.0, result[0, 0].real, 1e-10
    assert_in_delta 4.0, result[0, 1].real, 1e-10
  end

  def test_matrix_complex_collect_bang
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)

    m.collect! { |z| GSL::Complex.alloc(z.real * 2, z.imag) }
    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 4.0, m[0, 1].real, 1e-10
  end

  def test_matrix_complex_scale_bang
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)

    m.scale!(2.0)
    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 4.0, m[0, 0].imag, 1e-10
  end

  def test_matrix_complex_matmul
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m1[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m1[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m1[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m2[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m2[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m2[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m2[1, 1] = GSL::Complex.alloc(1.0, 0.0)

    result = m1 * m2
    assert_in_delta 1.0, result[0, 0].real, 1e-10
    assert_in_delta 4.0, result[1, 1].real, 1e-10
  end

  def test_matrix_complex_add_diagonal
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_zero

    m.add_diagonal(GSL::Complex.alloc(2.0, 1.0))
    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 1.0, m[0, 0].imag, 1e-10
    assert_in_delta 2.0, m[1, 1].real, 1e-10
  end

  def test_matrix_complex_set_diagonal
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_zero

    diag = GSL::Vector::Complex.alloc(3)
    diag[0] = GSL::Complex.alloc(1.0, 0.0)
    diag[1] = GSL::Complex.alloc(2.0, 0.0)
    diag[2] = GSL::Complex.alloc(3.0, 0.0)

    m.set_diagonal(diag)
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 2.0, m[1, 1].real, 1e-10
    assert_in_delta 3.0, m[2, 2].real, 1e-10
  end

  def test_matrix_complex_subdiagonal
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_identity

    sub = m.subdiagonal(1)
    assert_equal 2, sub.size
  end

  def test_matrix_complex_superdiagonal
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set_identity

    super_diag = m.superdiagonal(1)
    assert_equal 2, super_diag.size
  end

  def test_matrix_complex_real
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)

    real = m.real
    assert real.is_a?(GSL::Matrix), "real returns real Matrix"
    assert_in_delta 1.0, real[0, 0], 1e-10
    assert_in_delta 3.0, real[0, 1], 1e-10
  end

  def test_matrix_complex_imag
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)

    imag = m.imag
    assert imag.is_a?(GSL::Matrix), "imag returns real Matrix"
    assert_in_delta 2.0, imag[0, 0], 1e-10
    assert_in_delta 4.0, imag[0, 1], 1e-10
  end

  def test_matrix_complex_each_row
    m = GSL::Matrix::Complex.alloc(2, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(2.0, 0.0)

    count = 0
    m.each_row { |row| count += 1 }
    assert_equal 2, count
  end

  def test_matrix_complex_each_col
    m = GSL::Matrix::Complex.alloc(2, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)

    count = 0
    m.each_col { |col| count += 1 }
    assert_equal 3, count
  end

  def test_matrix_complex_size1
    m = GSL::Matrix::Complex.alloc(3, 4)
    assert_equal 3, m.size1
  end

  def test_matrix_complex_size2
    m = GSL::Matrix::Complex.alloc(3, 4)
    assert_equal 4, m.size2
  end

  def test_matrix_complex_shape
    m = GSL::Matrix::Complex.alloc(3, 4)
    shape = m.shape
    assert_equal [3, 4], shape
  end

  def test_matrix_complex_uplus
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    result = +m
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_uminus
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    result = -m
    assert_in_delta -1.0, result[0, 0].real, 1e-10
    assert_in_delta -2.0, result[0, 0].imag, 1e-10
  end

  def test_matrix_complex_abs2
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(3.0, 4.0)  # |z|^2 = 25

    abs2 = m.abs2
    assert abs2.is_a?(GSL::Matrix)
    assert_in_delta 25.0, abs2[0, 0], 1e-10
  end

  def test_matrix_complex_logabs
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(Math::E, 0.0)  # log|e| = 1

    logabs = m.logabs
    assert logabs.is_a?(GSL::Matrix)
    assert_in_delta 1.0, logabs[0, 0], 1e-10
  end

  def test_matrix_complex_log10
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(100.0, 0.0)

    result = m.log10
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 2.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_tan
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # tan(0) = 0

    result = m.tan
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_sec
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # sec(0) = 1

    result = m.sec
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_csc
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(Math::PI/2, 0.0)  # csc(pi/2) = 1

    result = m.csc
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_cot
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(Math::PI/4, 0.0)  # cot(pi/4) = 1

    result = m.cot
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_arcsin
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # arcsin(0) = 0

    result = m.arcsin
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_arccos
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)  # arccos(1) = 0

    result = m.arccos
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_arctan
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # arctan(0) = 0

    result = m.arctan
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_sinh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # sinh(0) = 0

    result = m.sinh
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_cosh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # cosh(0) = 1

    result = m.cosh
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_tanh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # tanh(0) = 0

    result = m.tanh
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_sech
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # sech(0) = 1

    result = m.sech
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_arcsinh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # arcsinh(0) = 0

    result = m.arcsinh
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_arctanh
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)  # arctanh(0) = 0

    result = m.arctanh
    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 0.0, result[0, 0].real, 1e-10
  end

  def test_matrix_complex_indgen
    m = GSL::Matrix::Complex.alloc(2, 3)
    result = m.indgen

    assert_in_delta 0.0, result[0, 0].real, 1e-10
    assert_in_delta 1.0, result[0, 1].real, 1e-10
    assert_in_delta 5.0, result[1, 2].real, 1e-10
  end

  def test_matrix_complex_indgen_with_start_step
    m = GSL::Matrix::Complex.alloc(2, 2)
    result = m.indgen(10, 2)

    assert_in_delta 10.0, result[0, 0].real, 1e-10
    assert_in_delta 12.0, result[0, 1].real, 1e-10
    assert_in_delta 14.0, result[1, 0].real, 1e-10
  end

  def test_matrix_complex_indgen_bang
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.indgen!

    assert_in_delta 0.0, m[0, 0].real, 1e-10
    assert_in_delta 1.0, m[0, 1].real, 1e-10
  end

  def test_matrix_complex_indgen_singleton
    m = GSL::Matrix::Complex.indgen(2, 3)

    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 0.0, m[0, 0].real, 1e-10
    assert_in_delta 5.0, m[1, 2].real, 1e-10
  end

  def test_matrix_complex_equal_method
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m1[0, 1] = GSL::Complex.alloc(3.0, 4.0)

    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m2[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m2[0, 1] = GSL::Complex.alloc(3.0, 4.0)

    assert m1.equal?(m2), "equal matrices should be equal"
  end

  def test_matrix_complex_not_equal
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 2.0)

    m2 = GSL::Matrix::Complex.alloc(2, 2)
    m2[0, 0] = GSL::Complex.alloc(5.0, 6.0)

    assert m1.not_equal?(m2), "different matrices should not be equal"
  end

  def test_matrix_complex_subrow
    m = GSL::Matrix::Complex.alloc(3, 4)
    4.times { |j| m[1, j] = GSL::Complex.alloc(j.to_f, 0.0) }

    sub = m[1, 1..2]
    assert_equal 2, sub.size
    assert_in_delta 1.0, sub[0].real, 1e-10
    assert_in_delta 2.0, sub[1].real, 1e-10
  end

  def test_matrix_complex_get_single_index
    m = GSL::Matrix::Complex.alloc(2, 3)
    m[0, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 2] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)

    # Single index access (row-major order)
    assert_in_delta 3.0, m[3].real, 1e-10
  end

  def test_matrix_complex_get_negative_index
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[1, 1] = GSL::Complex.alloc(5.0, 6.0)

    # Negative index access
    assert_in_delta 5.0, m[-1, -1].real, 1e-10
  end

  def test_matrix_complex_get_array_index
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[1, 0] = GSL::Complex.alloc(7.0, 8.0)

    # Array index access
    result = m[[1, 0]]
    assert_in_delta 7.0, result.real, 1e-10
  end

  # Test Matrix::Complex conjugate! (in-place)
  def test_matrix_complex_conjugate_bang
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, -4.0)

    m.conjugate!
    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta -2.0, m[0, 0].imag, 1e-10
    assert_in_delta 3.0, m[0, 1].real, 1e-10
    assert_in_delta 4.0, m[0, 1].imag, 1e-10
  end

  # Test dagger! (conjugate transpose in-place)
  def test_matrix_complex_dagger_bang
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
    m[0, 1] = GSL::Complex.alloc(3.0, 4.0)
    m[1, 0] = GSL::Complex.alloc(5.0, 6.0)
    m[1, 1] = GSL::Complex.alloc(7.0, 8.0)

    m.dagger!
    # After conjugate transpose: m[0,1] should be old m[1,0] conjugated
    assert_in_delta 5.0, m[0, 1].real, 1e-10
    assert_in_delta -6.0, m[0, 1].imag, 1e-10
  end

  # Note: Matrix::Complex.transpose is the in-place version
  # (unlike Ruby convention - no bang, but modifies in place)
  def test_matrix_complex_transpose_inplace
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(3.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(4.0, 0.0)

    m.transpose
    assert_in_delta 3.0, m[0, 1].real, 1e-10
    assert_in_delta 2.0, m[1, 0].real, 1e-10
  end

  # Test Matrix::Complex multiply with real vector
  def test_matrix_complex_mul_real_vector
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

  # Test Matrix::Complex multiply with real matrix
  def test_matrix_complex_mul_real_matrix
    m1 = GSL::Matrix::Complex.alloc(2, 2)
    m1[0, 0] = GSL::Complex.alloc(1.0, 1.0)
    m1[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m1[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m1[1, 1] = GSL::Complex.alloc(1.0, 1.0)

    m2 = GSL::Matrix[[1.0, 0.0], [0.0, 1.0]]
    result = m1 * m2

    assert result.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, result[0, 0].real, 1e-10
    assert_in_delta 1.0, result[0, 0].imag, 1e-10
  end

  # Test eye with complex diagonal value
  def test_matrix_complex_eye_with_complex
    z = GSL::Complex.alloc(2.0, 3.0)
    m = GSL::Matrix::Complex.eye(3, z)

    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 3.0, m[0, 0].imag, 1e-10
    assert_in_delta 0.0, m[0, 1].real, 1e-10
  end

  # Test eye with array
  def test_matrix_complex_eye_with_array
    m = GSL::Matrix::Complex.eye(3, [2.0, 3.0])

    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 3.0, m[0, 0].imag, 1e-10
  end

  # Test eye with two floats
  def test_matrix_complex_eye_with_two_floats
    m = GSL::Matrix::Complex.eye(3, 2.0, 3.0)

    assert_in_delta 2.0, m[0, 0].real, 1e-10
    assert_in_delta 3.0, m[0, 0].imag, 1e-10
  end

  # Test set_all with array
  def test_matrix_complex_set_all_array
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set_all([3.0, 4.0])

    assert_in_delta 3.0, m[0, 0].real, 1e-10
    assert_in_delta 4.0, m[0, 0].imag, 1e-10
  end

  # Test set_all with float
  def test_matrix_complex_set_all_float
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set_all(5.0)

    assert_in_delta 5.0, m[0, 0].real, 1e-10
    assert_in_delta 0.0, m[0, 0].imag, 1e-10
  end

  # Test add_diagonal with array
  def test_matrix_complex_add_diagonal_array
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set_zero
    m.add_diagonal([1.0, 2.0])

    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 2.0, m[0, 0].imag, 1e-10
  end

  # Test add_diagonal with float
  def test_matrix_complex_add_diagonal_float
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set_zero
    m.add_diagonal(3.0)

    assert_in_delta 3.0, m[0, 0].real, 1e-10
    assert_in_delta 0.0, m[0, 0].imag, 1e-10
  end

  # Test set with range
  def test_matrix_complex_set_range
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0..1] = 1..2

    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 2.0, m[0, 1].real, 1e-10
  end

  # Test set with array of rows
  def test_matrix_complex_set_array_rows
    m = GSL::Matrix::Complex.alloc(2, 2)
    z1 = GSL::Complex.alloc(1.0, 0.0)
    z2 = GSL::Complex.alloc(2.0, 0.0)
    z3 = GSL::Complex.alloc(3.0, 0.0)
    z4 = GSL::Complex.alloc(4.0, 0.0)

    m.set([z1, z2], [z3, z4])

    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 2.0, m[0, 1].real, 1e-10
    assert_in_delta 3.0, m[1, 0].real, 1e-10
    assert_in_delta 4.0, m[1, 1].real, 1e-10
  end
end
