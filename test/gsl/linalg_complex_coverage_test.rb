require 'test_helper'

class LinalgComplexCoverageTest < GSL::TestCase
  def setup
    # Create a 3x3 complex matrix
    @m = GSL::Matrix::Complex.alloc(3, 3)
    @m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    @m[0, 1] = GSL::Complex.alloc(2.0, 1.0)
    @m[0, 2] = GSL::Complex.alloc(3.0, 0.0)
    @m[1, 0] = GSL::Complex.alloc(4.0, -1.0)
    @m[1, 1] = GSL::Complex.alloc(5.0, 0.0)
    @m[1, 2] = GSL::Complex.alloc(6.0, 2.0)
    @m[2, 0] = GSL::Complex.alloc(7.0, 0.0)
    @m[2, 1] = GSL::Complex.alloc(8.0, -2.0)
    @m[2, 2] = GSL::Complex.alloc(9.0, 1.0)
  end

  # ======= LU Decomposition =======

  def test_lu_decomp_bang
    m = @m.clone
    perm, signum = m.LU_decomp!
    assert perm.is_a?(GSL::Permutation)
    assert signum.is_a?(Integer)
  end

  def test_lu_decomp_bang_with_permutation
    m = @m.clone
    perm = GSL::Permutation.alloc(3)
    signum = m.LU_decomp!(perm)
    assert signum.is_a?(Integer)
  end

  def test_lu_decomp
    lu, perm, signum = @m.LU_decomp
    assert lu.is_a?(GSL::Matrix::Complex)
    assert perm.is_a?(GSL::Permutation)
    assert signum.is_a?(Integer)
  end

  def test_lu_decomp_module_method
    lu, perm, signum = GSL::Linalg::Complex::LU.decomp(@m)
    assert lu.is_a?(GSL::Matrix::Complex)
  end

  def test_lu_decomp_bang_module_method
    m = @m.clone
    perm, signum = GSL::Linalg::Complex::LU.decomp!(m)
    assert perm.is_a?(GSL::Permutation)
  end

  def test_lu_decomp_wrong_args
    assert_raises(ArgumentError) do
      @m.LU_decomp!(GSL::Permutation.alloc(3), "extra")
    end
  end

  # ======= LU Solve =======

  def test_lu_solve
    # Create a simple 2x2 system for easier verification
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)

    b = GSL::Vector::Complex.alloc(2)
    b[0] = GSL::Complex.alloc(1.0, 0.0)
    b[1] = GSL::Complex.alloc(2.0, 0.0)

    x = m.LU_solve(b)
    assert x.is_a?(GSL::Vector::Complex)
    assert_equal 2, x.size
    assert_in_delta 1.0, x[0].real, 1e-10
    assert_in_delta 2.0, x[1].real, 1e-10
  end

  def test_lu_solve_with_lu_matrix
    m = @m.clone
    lu, perm, signum = m.LU_decomp

    b = GSL::Vector::Complex.alloc(3)
    b[0] = GSL::Complex.alloc(1.0, 0.0)
    b[1] = GSL::Complex.alloc(2.0, 0.0)
    b[2] = GSL::Complex.alloc(3.0, 0.0)

    x = lu.solve(perm, b)
    assert x.is_a?(GSL::Vector::Complex)
    assert_equal 3, x.size
  end

  def test_lu_solve_with_output_vector
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)
    lu, perm, signum = m.LU_decomp

    b = GSL::Vector::Complex.alloc(2)
    b[0] = GSL::Complex.alloc(1.0, 0.0)
    b[1] = GSL::Complex.alloc(2.0, 0.0)

    x = GSL::Vector::Complex.alloc(2)
    result = lu.solve(perm, b, x)
    assert_in_delta 1.0, x[0].real, 1e-10
  end

  # Note: Module method GSL::Linalg::Complex::LU.solve is tested via
  # instance methods on Matrix::Complex since module version has
  # different expectations

  # ======= LU SVX (solve in place) =======

  def test_lu_svx
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)

    x = GSL::Vector::Complex.alloc(2)
    x[0] = GSL::Complex.alloc(1.0, 0.0)
    x[1] = GSL::Complex.alloc(2.0, 0.0)

    m.LU_svx(x)
    assert_in_delta 1.0, x[0].real, 1e-10
    assert_in_delta 2.0, x[1].real, 1e-10
  end

  def test_lu_svx_with_lu_matrix
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)
    lu, perm, signum = m.LU_decomp

    x = GSL::Vector::Complex.alloc(2)
    x[0] = GSL::Complex.alloc(2.0, 0.0)
    x[1] = GSL::Complex.alloc(4.0, 0.0)

    lu.svx(perm, x)
    assert_in_delta 1.0, x[0].real, 1e-10
    assert_in_delta 2.0, x[1].real, 1e-10
  end

  # Note: Module method GSL::Linalg::Complex::LU.svx is tested via
  # instance methods on Matrix::Complex since module version has
  # different expectations

  # ======= LU Invert =======

  def test_lu_invert
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)

    inv = m.LU_invert
    assert inv.is_a?(GSL::Matrix::Complex)
    assert_in_delta 1.0, inv[0, 0].real, 1e-10
    assert_in_delta 1.0, inv[1, 1].real, 1e-10
  end

  def test_lu_invert_alias
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)

    inv = m.invert
    assert_in_delta 1.0, inv[0, 0].real, 1e-10
  end

  def test_lu_invert_alias_inv
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)

    inv = m.inv
    assert_in_delta 1.0, inv[0, 0].real, 1e-10
  end

  def test_lu_invert_module_method
    m = @m.clone
    inv = GSL::Linalg::Complex::LU.invert(m)
    assert inv.is_a?(GSL::Matrix::Complex)
  end

  def test_lu_invert_with_lu_matrix
    m = @m.clone
    lu, perm, signum = m.LU_decomp
    inv = lu.invert(perm)
    assert inv.is_a?(GSL::Matrix::Complex)
  end

  # ======= LU Determinant =======

  def test_lu_det
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)

    det = m.LU_det
    assert det.is_a?(GSL::Complex)
    assert_in_delta 2.0, det.real, 1e-10
  end

  def test_lu_det_alias
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)

    det = m.det
    assert_in_delta 2.0, det.real, 1e-10
  end

  def test_lu_det_with_lu_matrix
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)
    lu, perm, signum = m.LU_decomp

    # LU matrix det method takes signum directly
    det = lu.det(signum)
    assert_in_delta 2.0, det.real, 1e-10
  end

  def test_lu_det_module_method
    m = @m.clone
    det = GSL::Linalg::Complex::LU.det(m)
    assert det.is_a?(GSL::Complex)
  end

  # ======= LU Log Determinant =======

  def test_lu_lndet
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(Math::E, 0.0)

    lndet = m.LU_lndet
    assert lndet.is_a?(Float)
    assert_in_delta 1.0, lndet, 1e-10
  end

  def test_lu_lndet_alias
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(Math::E, 0.0)

    lndet = m.lndet
    assert_in_delta 1.0, lndet, 1e-10
  end

  def test_lu_lndet_module_method
    m = @m.clone
    lndet = GSL::Linalg::Complex::LU.lndet(m)
    assert lndet.is_a?(Float)
  end

  # ======= LU Sign of Determinant =======

  def test_lu_sgndet
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)

    sgndet = m.LU_sgndet
    assert sgndet.is_a?(GSL::Complex)
  end

  def test_lu_sgndet_alias
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)

    sgndet = m.sgndet
    assert sgndet.is_a?(GSL::Complex)
  end

  def test_lu_sgndet_module_method
    m = @m.clone
    sgndet = GSL::Linalg::Complex::LU.sgndet(m)
    assert sgndet.is_a?(GSL::Complex)
  end

  # ======= Cholesky Decomposition =======

  def test_cholesky_decomp
    # Create a positive definite Hermitian matrix
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(1.0, 1.0)
    m[1, 0] = GSL::Complex.alloc(1.0, -1.0)  # Conjugate of m[0,1]
    m[1, 1] = GSL::Complex.alloc(3.0, 0.0)

    chol = m.cholesky_decomp
    assert chol.is_a?(GSL::Matrix::Complex)
  end

  def test_cholesky_decomp_module_method
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(1.0, 1.0)
    m[1, 0] = GSL::Complex.alloc(1.0, -1.0)
    m[1, 1] = GSL::Complex.alloc(3.0, 0.0)

    chol = GSL::Linalg::Complex::Cholesky.decomp(m)
    assert chol.is_a?(GSL::Matrix::Complex)
  end

  def test_cholesky_solve
    # Create a positive definite Hermitian matrix
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)

    b = GSL::Vector::Complex.alloc(2)
    b[0] = GSL::Complex.alloc(2.0, 0.0)
    b[1] = GSL::Complex.alloc(4.0, 0.0)

    x = m.cholesky_solve(b)
    assert x.is_a?(GSL::Vector::Complex)
    assert_in_delta 1.0, x[0].real, 1e-10
    assert_in_delta 2.0, x[1].real, 1e-10
  end

  def test_cholesky_solve_module_method
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)

    b = GSL::Vector::Complex.alloc(2)
    b[0] = GSL::Complex.alloc(2.0, 0.0)
    b[1] = GSL::Complex.alloc(4.0, 0.0)

    x = GSL::Linalg::Complex::Cholesky.solve(m, b)
    assert x.is_a?(GSL::Vector::Complex)
  end

  def test_cholesky_svx
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)

    x = GSL::Vector::Complex.alloc(2)
    x[0] = GSL::Complex.alloc(2.0, 0.0)
    x[1] = GSL::Complex.alloc(4.0, 0.0)

    m.cholesky_svx(x)
    assert_in_delta 1.0, x[0].real, 1e-10
    assert_in_delta 2.0, x[1].real, 1e-10
  end

  def test_cholesky_svx_module_method
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(2.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)

    x = GSL::Vector::Complex.alloc(2)
    x[0] = GSL::Complex.alloc(2.0, 0.0)
    x[1] = GSL::Complex.alloc(4.0, 0.0)

    GSL::Linalg::Complex::Cholesky.svx(m, x)
    assert_in_delta 1.0, x[0].real, 1e-10
  end

  # ======= Householder Transform =======

  def test_householder_transform
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    tau = v.householder_transform
    assert tau.is_a?(GSL::Complex)
  end

  def test_householder_transform_module_method
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    tau, vec = GSL::Linalg::Complex::Householder.transform(v)
    assert tau.is_a?(GSL::Complex)
  end

  def test_householder_hm
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(0.0, 0.0)
    v[2] = GSL::Complex.alloc(0.0, 0.0)
    tau = GSL::Complex.alloc(0.0, 0.0)

    m = GSL::Matrix::Complex.alloc(3, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)
    m[2, 2] = GSL::Complex.alloc(1.0, 0.0)

    result = GSL::Linalg::Complex::Householder.hm(tau, v, m)
    assert result.is_a?(GSL::Matrix::Complex)
  end

  def test_householder_mh
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(0.0, 0.0)
    v[2] = GSL::Complex.alloc(0.0, 0.0)
    tau = GSL::Complex.alloc(0.0, 0.0)

    m = GSL::Matrix::Complex.alloc(3, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(1.0, 0.0)
    m[2, 2] = GSL::Complex.alloc(1.0, 0.0)

    result = GSL::Linalg::Complex::Householder.mh(tau, v, m)
    assert result.is_a?(GSL::Matrix::Complex)
  end

  def test_householder_hv
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(0.0, 0.0)
    v[2] = GSL::Complex.alloc(0.0, 0.0)
    tau = GSL::Complex.alloc(0.0, 0.0)

    w = GSL::Vector::Complex.alloc(3)
    w[0] = GSL::Complex.alloc(1.0, 0.0)
    w[1] = GSL::Complex.alloc(2.0, 0.0)
    w[2] = GSL::Complex.alloc(3.0, 0.0)

    result = GSL::Linalg::Complex::Householder.hv(tau, v, w)
    assert result.is_a?(GSL::Vector::Complex)
  end

  # ======= Error handling =======

  def test_lu_solve_wrong_args_module
    assert_raises(ArgumentError) do
      GSL::Linalg::Complex::LU.solve
    end
  end

  def test_lu_solve_wrong_args_instance
    m = @m.clone
    lu, perm, signum = m.LU_decomp
    assert_raises(ArgumentError) do
      lu.solve  # No args
    end
  end
end
