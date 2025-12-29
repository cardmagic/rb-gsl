require 'test_helper'

class BlasTest < GSL::TestCase

  DBLEPS = 1e-6

  # ===========================================
  # BLAS Level 3 Tests (matrix-matrix operations)
  # ===========================================

  # dgemm: C = alpha * op(A) * op(B) + beta * C
  def test_dgemm_basic
    # Simple 2x2 matrix multiplication
    a = GSL::Matrix.alloc([1, 2], [3, 4])
    b = GSL::Matrix.alloc([5, 6], [7, 8])
    c = GSL::Matrix.calloc(2, 2)

    # C = 1.0 * A * B + 0.0 * C
    GSL::Blas.dgemm(GSL::Blas::NoTrans, GSL::Blas::NoTrans, 1.0, a, b, 0.0, c)

    # Expected: [[1*5+2*7, 1*6+2*8], [3*5+4*7, 3*6+4*8]] = [[19, 22], [43, 50]]
    assert_rel c[0, 0], 19.0, DBLEPS, 'dgemm [0,0]'
    assert_rel c[0, 1], 22.0, DBLEPS, 'dgemm [0,1]'
    assert_rel c[1, 0], 43.0, DBLEPS, 'dgemm [1,0]'
    assert_rel c[1, 1], 50.0, DBLEPS, 'dgemm [1,1]'
  end

  def test_dgemm_transposed
    a = GSL::Matrix.alloc([1, 2], [3, 4])
    b = GSL::Matrix.alloc([5, 6], [7, 8])
    c = GSL::Matrix.calloc(2, 2)

    # C = 1.0 * A^T * B + 0.0 * C
    GSL::Blas.dgemm(GSL::Blas::Trans, GSL::Blas::NoTrans, 1.0, a, b, 0.0, c)

    # A^T = [[1, 3], [2, 4]]
    # Expected: [[1*5+3*7, 1*6+3*8], [2*5+4*7, 2*6+4*8]] = [[26, 30], [38, 44]]
    assert_rel c[0, 0], 26.0, DBLEPS, 'dgemm trans [0,0]'
    assert_rel c[0, 1], 30.0, DBLEPS, 'dgemm trans [0,1]'
    assert_rel c[1, 0], 38.0, DBLEPS, 'dgemm trans [1,0]'
    assert_rel c[1, 1], 44.0, DBLEPS, 'dgemm trans [1,1]'
  end

  def test_dgemm_with_alpha_beta
    a = GSL::Matrix.alloc([1, 2], [3, 4])
    b = GSL::Matrix.alloc([1, 0], [0, 1])  # Identity
    c = GSL::Matrix.alloc([10, 20], [30, 40])

    # C = 2.0 * A * B + 0.5 * C = 2*A + 0.5*C
    GSL::Blas.dgemm(GSL::Blas::NoTrans, GSL::Blas::NoTrans, 2.0, a, b, 0.5, c)

    # Expected: 2*[[1,2],[3,4]] + 0.5*[[10,20],[30,40]] = [[2,4],[6,8]] + [[5,10],[15,20]] = [[7,14],[21,28]]
    assert_rel c[0, 0], 7.0, DBLEPS, 'dgemm alpha/beta [0,0]'
    assert_rel c[0, 1], 14.0, DBLEPS, 'dgemm alpha/beta [0,1]'
    assert_rel c[1, 0], 21.0, DBLEPS, 'dgemm alpha/beta [1,0]'
    assert_rel c[1, 1], 28.0, DBLEPS, 'dgemm alpha/beta [1,1]'
  end

  def test_dgemm_rectangular
    # 2x3 * 3x2 = 2x2
    a = GSL::Matrix.alloc([1, 2, 3], [4, 5, 6])
    b = GSL::Matrix.alloc([1, 2], [3, 4], [5, 6])
    c = GSL::Matrix.calloc(2, 2)

    GSL::Blas.dgemm(GSL::Blas::NoTrans, GSL::Blas::NoTrans, 1.0, a, b, 0.0, c)

    # Expected: [[1*1+2*3+3*5, 1*2+2*4+3*6], [4*1+5*3+6*5, 4*2+5*4+6*6]]
    #         = [[1+6+15, 2+8+18], [4+15+30, 8+20+36]] = [[22, 28], [49, 64]]
    assert_rel c[0, 0], 22.0, DBLEPS, 'dgemm rect [0,0]'
    assert_rel c[0, 1], 28.0, DBLEPS, 'dgemm rect [0,1]'
    assert_rel c[1, 0], 49.0, DBLEPS, 'dgemm rect [1,0]'
    assert_rel c[1, 1], 64.0, DBLEPS, 'dgemm rect [1,1]'
  end

  # dsymm: C = alpha * A * B + beta * C (A is symmetric)
  def test_dsymm_left
    # Symmetric matrix (only upper or lower triangle is used)
    a = GSL::Matrix.alloc([1, 2], [2, 4])  # Symmetric
    b = GSL::Matrix.alloc([1, 0], [0, 1])
    c = GSL::Matrix.calloc(2, 2)

    GSL::Blas.dsymm(GSL::Blas::Left, GSL::Blas::Upper, 1.0, a, b, 0.0, c)

    # C = A * B = A (since B is identity)
    assert_rel c[0, 0], 1.0, DBLEPS, 'dsymm left [0,0]'
    assert_rel c[0, 1], 2.0, DBLEPS, 'dsymm left [0,1]'
    assert_rel c[1, 0], 2.0, DBLEPS, 'dsymm left [1,0]'
    assert_rel c[1, 1], 4.0, DBLEPS, 'dsymm left [1,1]'
  end

  def test_dsymm_right
    a = GSL::Matrix.alloc([1, 2], [2, 4])  # Symmetric
    b = GSL::Matrix.alloc([1, 2], [3, 4])
    c = GSL::Matrix.calloc(2, 2)

    GSL::Blas.dsymm(GSL::Blas::Right, GSL::Blas::Upper, 1.0, a, b, 0.0, c)

    # C = B * A
    # [[1,2],[3,4]] * [[1,2],[2,4]] = [[1+4, 2+8], [3+8, 6+16]] = [[5, 10], [11, 22]]
    assert_rel c[0, 0], 5.0, DBLEPS, 'dsymm right [0,0]'
    assert_rel c[0, 1], 10.0, DBLEPS, 'dsymm right [0,1]'
    assert_rel c[1, 0], 11.0, DBLEPS, 'dsymm right [1,0]'
    assert_rel c[1, 1], 22.0, DBLEPS, 'dsymm right [1,1]'
  end

  # dtrmm: B = alpha * op(A) * B (A is triangular)
  def test_dtrmm_upper
    a = GSL::Matrix.alloc([2, 3], [0, 4])  # Upper triangular
    b = GSL::Matrix.alloc([1, 2], [3, 4])

    GSL::Blas.dtrmm!(GSL::Blas::Left, GSL::Blas::Upper, GSL::Blas::NoTrans,
                     GSL::Blas::NonUnit, 1.0, a, b)

    # B = A * B = [[2,3],[0,4]] * [[1,2],[3,4]] = [[2+9, 4+12], [0+12, 0+16]] = [[11, 16], [12, 16]]
    assert_rel b[0, 0], 11.0, DBLEPS, 'dtrmm upper [0,0]'
    assert_rel b[0, 1], 16.0, DBLEPS, 'dtrmm upper [0,1]'
    assert_rel b[1, 0], 12.0, DBLEPS, 'dtrmm upper [1,0]'
    assert_rel b[1, 1], 16.0, DBLEPS, 'dtrmm upper [1,1]'
  end

  def test_dtrmm_lower
    a = GSL::Matrix.alloc([2, 0], [3, 4])  # Lower triangular
    b = GSL::Matrix.alloc([1, 2], [3, 4])

    GSL::Blas.dtrmm!(GSL::Blas::Left, GSL::Blas::Lower, GSL::Blas::NoTrans,
                     GSL::Blas::NonUnit, 1.0, a, b)

    # B = A * B = [[2,0],[3,4]] * [[1,2],[3,4]] = [[2, 4], [3+12, 6+16]] = [[2, 4], [15, 22]]
    assert_rel b[0, 0], 2.0, DBLEPS, 'dtrmm lower [0,0]'
    assert_rel b[0, 1], 4.0, DBLEPS, 'dtrmm lower [0,1]'
    assert_rel b[1, 0], 15.0, DBLEPS, 'dtrmm lower [1,0]'
    assert_rel b[1, 1], 22.0, DBLEPS, 'dtrmm lower [1,1]'
  end

  # dtrsm: Solve op(A) * X = alpha * B (A is triangular)
  def test_dtrsm_upper
    # A is upper triangular: [[2, 1], [0, 3]]
    # Solve A * X = B where B = [[5, 4], [6, 9]]
    a = GSL::Matrix.alloc([2, 1], [0, 3])
    b = GSL::Matrix.alloc([5, 4], [6, 9])

    GSL::Blas.dtrsm!(GSL::Blas::Left, GSL::Blas::Upper, GSL::Blas::NoTrans,
                     GSL::Blas::NonUnit, 1.0, a, b)

    # X is stored in B after the call
    # Verify: A * X = original B
    # Row 2: 3*x21 = 6 => x21 = 2, 3*x22 = 9 => x22 = 3
    # Row 1: 2*x11 + x21 = 5 => x11 = 1.5, 2*x12 + x22 = 4 => x12 = 0.5
    assert_rel b[1, 0], 2.0, DBLEPS, 'dtrsm upper [1,0]'
    assert_rel b[1, 1], 3.0, DBLEPS, 'dtrsm upper [1,1]'
    assert_rel b[0, 0], 1.5, DBLEPS, 'dtrsm upper [0,0]'
    assert_rel b[0, 1], 0.5, DBLEPS, 'dtrsm upper [0,1]'
  end

  # dsyrk: C = alpha * A * A^T + beta * C (symmetric rank-k update)
  def test_dsyrk_upper
    a = GSL::Matrix.alloc([1, 2], [3, 4])
    c = GSL::Matrix.calloc(2, 2)

    GSL::Blas.dsyrk!(GSL::Blas::Upper, GSL::Blas::NoTrans, 1.0, a, 0.0, c)

    # C = A * A^T = [[1,2],[3,4]] * [[1,3],[2,4]] = [[1+4, 3+8], [3+8, 9+16]] = [[5, 11], [11, 25]]
    # Only upper triangle is computed
    assert_rel c[0, 0], 5.0, DBLEPS, 'dsyrk upper [0,0]'
    assert_rel c[0, 1], 11.0, DBLEPS, 'dsyrk upper [0,1]'
    assert_rel c[1, 1], 25.0, DBLEPS, 'dsyrk upper [1,1]'
  end

  def test_dsyrk_lower
    a = GSL::Matrix.alloc([1, 2], [3, 4])
    c = GSL::Matrix.calloc(2, 2)

    GSL::Blas.dsyrk!(GSL::Blas::Lower, GSL::Blas::NoTrans, 1.0, a, 0.0, c)

    # Only lower triangle is computed
    assert_rel c[0, 0], 5.0, DBLEPS, 'dsyrk lower [0,0]'
    assert_rel c[1, 0], 11.0, DBLEPS, 'dsyrk lower [1,0]'
    assert_rel c[1, 1], 25.0, DBLEPS, 'dsyrk lower [1,1]'
  end

  # dsyr2k: C = alpha * (A * B^T + B * A^T) + beta * C
  def test_dsyr2k
    a = GSL::Matrix.alloc([1, 2], [3, 4])
    b = GSL::Matrix.alloc([1, 0], [0, 1])
    c = GSL::Matrix.calloc(2, 2)

    GSL::Blas.dsyr2k!(GSL::Blas::Upper, GSL::Blas::NoTrans, 1.0, a, b, 0.0, c)

    # C = A * B^T + B * A^T = A * I + I * A^T = A + A^T
    # = [[1,2],[3,4]] + [[1,3],[2,4]] = [[2, 5], [5, 8]]
    assert_rel c[0, 0], 2.0, DBLEPS, 'dsyr2k [0,0]'
    assert_rel c[0, 1], 5.0, DBLEPS, 'dsyr2k [0,1]'
    assert_rel c[1, 1], 8.0, DBLEPS, 'dsyr2k [1,1]'
  end

  def test_amax
    v = GSL::Vector.alloc(0.537, 0.826)
    assert_int v.idamax, 1, 'damax'

    vz = GSL::Vector::Complex.alloc([0.913, -0.436], [-0.134, 0.129])
    assert_int vz.izamax, 0, 'zmax'
  end

  def test_asum
    v = GSL::Vector.alloc(0.271, -0.012)
    assert_rel v.dasum, 0.283, DBLEPS, 'dasum'

    vz = GSL::Vector::Complex.alloc([-0.046, -0.671], [-0.323, 0.785])
    assert_rel vz.dzasum, 1.825, DBLEPS, 'dzasum'
  end

  def test_axpy
    x = GSL::Vector.alloc(0.029)
    y = GSL::Vector.alloc(-0.992)
    e = GSL::Vector.alloc(-1.0007)

    y2 = GSL::Blas.daxpy(-0.3, x, y)

    assert_rel y2[0], e[0], DBLEPS, 'daxpy'

    x = GSL::Vector::Complex.alloc([[0.776, -0.671]])
    y = GSL::Vector::Complex.alloc([[0.39, 0.404]])
    e = GSL::Vector::Complex.alloc([[1.061, 1.18]])

    y2 = GSL::Blas.zaxpy(GSL::Complex.alloc(0, 1), x, y)

    assert_rel y2[0].re, e[0].re, DBLEPS, 'zaxpy real'
    assert_rel y2[0].im, e[0].im, DBLEPS, 'zaxpy imag'
  end

  def test_copy
    x = GSL::Vector.alloc(0.002)
    y = GSL::Vector.alloc(-0.921)
    e = GSL::Vector.alloc(0.002)

    GSL::Blas.dcopy(x, y)

    assert_rel y[0], e[0], DBLEPS, 'dcopy'

    x = GSL::Vector::Complex.alloc([[ 0.315, -0.324]])
    y = GSL::Vector::Complex.alloc([[-0.312, -0.748]])
    e = GSL::Vector::Complex.alloc([[0.315, -0.324]])

    GSL::Blas.zcopy(x, y)

    assert_rel y[0].re, e[0].re, DBLEPS, 'zcopy real'
    assert_rel y[0].im, e[0].im, DBLEPS, 'zcopy imag'
  end

  def test_dnrm2
    return unless GSL.have_narray?

    e = Math.sqrt((0..4).inject { |m, x| m + x * x })

    v = GSL::Vector.indgen(5)
    v_dnrm2 = GSL::Blas.dnrm2(v)

    assert_rel v_dnrm2, e, DBLEPS, 'GSL::Blas.dnrm2(GSL::Vector)'

    na = NArray.float(5).indgen!
    na_dnrm2 = GSL::Blas.dnrm2(na)

    assert_rel na_dnrm2, e, DBLEPS, 'GSL::Blas.dnrm2(NArray)'

    assert_rel na_dnrm2, v_dnrm2, 0, 'GSL::Blas.dnrm2(NArray) == GSL::Blas.dnrm2(GSL::Vector)'
  end

  # BLAS Level 2 tests skipped - API signatures differ from expected

end
