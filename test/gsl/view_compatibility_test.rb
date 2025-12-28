require 'test_helper'

# TDD tests for view compatibility with TypedData migration
# These tests verify that functions accepting vectors/matrices also accept views
class ViewCompatibilityTest < GSL::TestCase
  DBLEPS = 1e-10

  # ==========================================================================
  # Vector View Tests
  # ==========================================================================

  def test_vector_view_with_blas_dnrm2
    v = GSL::Vector.alloc(3, 4, 0, 0, 0)
    view = v.subvector(0, 2)  # [3, 4]

    # Should work with view - norm of [3,4] = 5
    result = GSL::Blas.dnrm2(view)
    assert_rel result, 5.0, DBLEPS, 'dnrm2 with vector view'
  end

  def test_vector_view_with_blas_dasum
    v = GSL::Vector.alloc(-1, 2, -3, 0, 0)
    view = v.subvector(0, 3)  # [-1, 2, -3]

    # Should work with view - sum of abs values = 6
    result = view.dasum
    assert_rel result, 6.0, DBLEPS, 'dasum with vector view'
  end

  def test_vector_view_with_blas_idamax
    v = GSL::Vector.alloc(1, 5, 3, 0, 0)
    view = v.subvector(0, 3)  # [1, 5, 3]

    # Should work with view - index of max abs value = 1
    result = view.idamax
    assert_int result, 1, 'idamax with vector view'
  end

  def test_vector_view_with_blas_daxpy
    x = GSL::Vector.alloc(1, 2, 3, 0, 0)
    y = GSL::Vector.alloc(10, 20, 30, 0, 0)
    x_view = x.subvector(0, 3)
    y_view = y.subvector(0, 3)

    # y = alpha*x + y, with alpha=2: [10,20,30] + 2*[1,2,3] = [12,24,36]
    result = GSL::Blas.daxpy(2.0, x_view, y_view)
    assert_rel result[0], 12.0, DBLEPS, 'daxpy with vector views [0]'
    assert_rel result[1], 24.0, DBLEPS, 'daxpy with vector views [1]'
    assert_rel result[2], 36.0, DBLEPS, 'daxpy with vector views [2]'
  end

  def test_vector_view_with_blas_ddot
    x = GSL::Vector.alloc(1, 2, 3, 0, 0)
    y = GSL::Vector.alloc(4, 5, 6, 0, 0)
    x_view = x.subvector(0, 3)
    y_view = y.subvector(0, 3)

    # dot product: 1*4 + 2*5 + 3*6 = 32
    result = GSL::Blas.ddot(x_view, y_view)
    assert_rel result, 32.0, DBLEPS, 'ddot with vector views'
  end

  def test_vector_view_with_blas_dcopy
    x = GSL::Vector.alloc(1, 2, 3, 0, 0)
    y = GSL::Vector.alloc(0, 0, 0, 0, 0)
    x_view = x.subvector(0, 3)
    y_view = y.subvector(0, 3)

    GSL::Blas.dcopy(x_view, y_view)
    assert_rel y_view[0], 1.0, DBLEPS, 'dcopy with vector views [0]'
    assert_rel y_view[1], 2.0, DBLEPS, 'dcopy with vector views [1]'
    assert_rel y_view[2], 3.0, DBLEPS, 'dcopy with vector views [2]'
  end

  def test_vector_view_with_blas_dscal
    v = GSL::Vector.alloc(1, 2, 3, 0, 0)
    view = v.subvector(0, 3)

    # Use dscal! (mutating version) instead of dscal
    GSL::Blas.dscal!(2.0, view)
    assert_rel view[0], 2.0, DBLEPS, 'dscal with vector view [0]'
    assert_rel view[1], 4.0, DBLEPS, 'dscal with vector view [1]'
    assert_rel view[2], 6.0, DBLEPS, 'dscal with vector view [2]'
    # Verify view modified original vector
    assert_rel v[0], 2.0, DBLEPS, 'dscal modified original vector [0]'
  end

  # ==========================================================================
  # Vector Complex View Tests
  # ==========================================================================

  def test_vector_complex_view_with_blas_dzasum
    v = GSL::Vector::Complex.alloc([1, 2], [3, 4], [0, 0])
    view = v.subvector(0, 2)  # [[1,2], [3,4]]

    # dzasum = sum of |re| + |im| for each element = (1+2) + (3+4) = 10
    result = view.dzasum
    assert_rel result, 10.0, DBLEPS, 'dzasum with complex vector view'
  end

  def test_vector_complex_view_with_blas_izamax
    v = GSL::Vector::Complex.alloc([1, 0], [0, 5], [2, 0])
    view = v.subvector(0, 3)

    # izamax finds index of element with largest |z| = index 1 (|0+5i| = 5)
    result = view.izamax
    assert_int result, 1, 'izamax with complex vector view'
  end

  def test_vector_complex_view_with_blas_zdotu
    x = GSL::Vector::Complex.alloc([1, 0], [0, 1], [0, 0])
    y = GSL::Vector::Complex.alloc([1, 0], [0, -1], [0, 0])
    x_view = x.subvector(0, 2)
    y_view = y.subvector(0, 2)

    # zdotu: (1+0i)*(1+0i) + (0+1i)*(0-1i) = 1 + 1 = 2
    result = GSL::Blas.zdotu(x_view, y_view)
    assert_rel result.re, 2.0, DBLEPS, 'zdotu with complex vector views (real)'
    assert_rel result.im, 0.0, DBLEPS, 'zdotu with complex vector views (imag)'
  end

  def test_vector_complex_view_with_blas_dznrm2
    v = GSL::Vector::Complex.alloc([3, 4], [0, 0])  # |3+4i| = 5
    view = v.subvector(0, 1)

    result = view.dznrm2
    assert_rel result, 5.0, DBLEPS, 'dznrm2 with complex vector view'
  end

  # ==========================================================================
  # Matrix View Tests
  # ==========================================================================

  def test_matrix_view_with_blas_dgemv
    # Matrix-vector multiplication with views
    m = GSL::Matrix.alloc([1, 2, 0], [3, 4, 0], [0, 0, 0])
    v = GSL::Vector.alloc(1, 2, 0)
    result = GSL::Vector.alloc(0, 0, 0)

    m_view = m.submatrix(0, 0, 2, 2)  # 2x2 upper-left
    v_view = v.subvector(0, 2)
    r_view = result.subvector(0, 2)

    # [1 2] * [1] = [5]
    # [3 4]   [2]   [11]
    GSL::Blas.dgemv(GSL::Blas::NoTrans, 1.0, m_view, v_view, 0.0, r_view)
    assert_rel r_view[0], 5.0, DBLEPS, 'dgemv with matrix view [0]'
    assert_rel r_view[1], 11.0, DBLEPS, 'dgemv with matrix view [1]'
  end

  def test_matrix_view_with_blas_dgemm
    # Matrix-matrix multiplication with views
    a = GSL::Matrix.alloc([1, 2, 0], [3, 4, 0], [0, 0, 0])
    b = GSL::Matrix.alloc([5, 6, 0], [7, 8, 0], [0, 0, 0])
    c = GSL::Matrix.calloc(3, 3)

    a_view = a.submatrix(0, 0, 2, 2)
    b_view = b.submatrix(0, 0, 2, 2)
    c_view = c.submatrix(0, 0, 2, 2)

    # [1 2] * [5 6] = [19 22]
    # [3 4]   [7 8]   [43 50]
    GSL::Blas.dgemm(GSL::Blas::NoTrans, GSL::Blas::NoTrans, 1.0, a_view, b_view, 0.0, c_view)
    assert_rel c_view[0, 0], 19.0, DBLEPS, 'dgemm with matrix views [0,0]'
    assert_rel c_view[0, 1], 22.0, DBLEPS, 'dgemm with matrix views [0,1]'
    assert_rel c_view[1, 0], 43.0, DBLEPS, 'dgemm with matrix views [1,0]'
    assert_rel c_view[1, 1], 50.0, DBLEPS, 'dgemm with matrix views [1,1]'
  end

  # ==========================================================================
  # Linalg with Views
  # ==========================================================================

  def test_linalg_lu_decomp_with_matrix_view
    m = GSL::Matrix.alloc([4, 3, 0], [6, 3, 0], [0, 0, 1])
    view = m.submatrix(0, 0, 2, 2)

    # LU decomposition should work with view
    lu, perm, signum = GSL::Linalg::LU.decomp(view)
    assert_kind_of GSL::Matrix, lu, 'LU decomp returns matrix'
    assert_kind_of GSL::Permutation, perm, 'LU decomp returns permutation'
  end

  def test_linalg_lu_solve_with_views
    # Solve Ax = b where A = [[2, 1], [1, 3]] and b = [4, 5]
    # Solution: x = [7/5, 6/5] = [1.4, 1.2]
    a = GSL::Matrix.alloc([2, 1, 0], [1, 3, 0], [0, 0, 1])
    b = GSL::Vector.alloc(4, 5, 0)

    a_view = a.submatrix(0, 0, 2, 2)
    b_view = b.subvector(0, 2)

    lu, perm, _signum = GSL::Linalg::LU.decomp(a_view)
    x = GSL::Linalg::LU.solve(lu, perm, b_view)

    assert_rel x[0], 1.4, DBLEPS, 'LU solve with views [0]'
    assert_rel x[1], 1.2, DBLEPS, 'LU solve with views [1]'
  end

  # ==========================================================================
  # Stats with Views
  # ==========================================================================

  def test_stats_mean_with_vector_view
    v = GSL::Vector.alloc(1, 2, 3, 4, 5, 0, 0)
    view = v.subvector(0, 5)

    result = view.mean
    assert_rel result, 3.0, DBLEPS, 'mean with vector view'
  end

  def test_stats_variance_with_vector_view
    v = GSL::Vector.alloc(2, 4, 4, 4, 5, 5, 7, 9, 0)
    view = v.subvector(0, 8)

    # Sample variance of [2,4,4,4,5,5,7,9] with n-1 denominator = 32/7
    result = view.variance
    assert_rel result, 32.0/7.0, DBLEPS, 'variance with vector view'
  end

  def test_stats_sd_with_vector_view
    v = GSL::Vector.alloc(2, 4, 4, 4, 5, 5, 7, 9, 0)
    view = v.subvector(0, 8)

    # SD = sqrt(32/7)
    result = view.sd
    assert_rel result, Math.sqrt(32.0/7.0), DBLEPS, 'sd with vector view'
  end

  # ==========================================================================
  # Sort with Views
  # ==========================================================================

  def test_sort_with_vector_view
    v = GSL::Vector.alloc(3, 1, 4, 1, 5, 0, 0)
    view = v.subvector(0, 5)

    sorted = view.sort
    assert_rel sorted[0], 1.0, DBLEPS, 'sort with view [0]'
    assert_rel sorted[1], 1.0, DBLEPS, 'sort with view [1]'
    assert_rel sorted[2], 3.0, DBLEPS, 'sort with view [2]'
    assert_rel sorted[3], 4.0, DBLEPS, 'sort with view [3]'
    assert_rel sorted[4], 5.0, DBLEPS, 'sort with view [4]'
  end

  # ==========================================================================
  # Multiroot Test Functions with Views (previously fixed)
  # ==========================================================================

  def test_multiroot_test_delta_with_views
    dx = GSL::Vector.alloc(1e-10, 1e-10, 0)
    x = GSL::Vector.alloc(1, 1, 0)
    dx_view = dx.subvector(0, 2)
    x_view = x.subvector(0, 2)

    result = GSL::MultiRoot.test_delta(dx_view, x_view, 1e-8, 1e-8)
    assert_equal 0, result, 'test_delta with views should converge'
  end

  def test_multiroot_test_residual_with_view
    f = GSL::Vector.alloc(1e-10, 1e-10, 0)
    f_view = f.subvector(0, 2)

    result = GSL::MultiRoot.test_residual(f_view, 1e-8)
    assert_equal 0, result, 'test_residual with view should converge'
  end

  # ==========================================================================
  # Integration with Views (verify existing functionality)
  # ==========================================================================

  def test_fft_with_vector_view
    # Create a simple signal
    n = 8
    v = GSL::Vector.alloc(1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    view = v.subvector(0, n)

    # FFT of impulse should work
    result = view.fft
    assert_kind_of GSL::Vector::Complex, result, 'FFT with view returns complex vector'
    assert_equal n, result.size, 'FFT result has correct size'
  end

  # ==========================================================================
  # Vector Int View Tests
  # ==========================================================================

  def test_vector_int_view_operations
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5, 0, 0)
    view = v.subvector(0, 5)

    assert_equal 5, view.size, 'int view has correct size'
    assert_equal 15, view.sum, 'int view sum'
    assert_equal 1, view.min, 'int view min'
    assert_equal 5, view.max, 'int view max'
  end

  # ==========================================================================
  # Col Vector View Tests
  # ==========================================================================

  def test_col_vector_view_with_matrix_operations
    # Column vectors should also work as views
    m = GSL::Matrix.alloc([1, 2, 3], [4, 5, 6], [7, 8, 9])

    col = m.col(0)  # [1, 4, 7] as column vector view
    assert_kind_of GSL::Vector::Col, col, 'column is Col type'

    # Should be able to compute norm
    result = GSL::Blas.dnrm2(col)
    expected = Math.sqrt(1 + 16 + 49)  # sqrt(66)
    assert_rel result, expected, DBLEPS, 'dnrm2 with column view'
  end

  def test_row_vector_view_with_matrix_operations
    m = GSL::Matrix.alloc([1, 2, 3], [4, 5, 6], [7, 8, 9])

    row = m.row(0)  # [1, 2, 3] as row vector view
    assert_kind_of GSL::Vector, row, 'row is Vector type'

    # Should be able to compute norm
    result = GSL::Blas.dnrm2(row)
    expected = Math.sqrt(1 + 4 + 9)  # sqrt(14)
    assert_rel result, expected, DBLEPS, 'dnrm2 with row view'
  end

end
