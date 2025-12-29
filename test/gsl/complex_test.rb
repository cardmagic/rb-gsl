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
end
