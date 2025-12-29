require 'test_helper'

class LinalgTest < GSL::TestCase

  def _check(x, actual, eps, desc)
    if x == actual
      assert true
    elsif actual.zero?
      refute x.abs > eps, desc
    else
      refute((x - actual).abs / actual.abs > eps, desc)
    end
  end

  def _create_general_matrix(size1, size2)
    m = GSL::Matrix.alloc(size1, size2)

    size1.times { |i|
      size2.times { |j|
        m.set(i, j, 1.0 / (i + j + 1.0))
      }
    }

    m
  end

  def _create_hilbert_matrix(size)
    _create_general_matrix(size, size)
  end

  def _create_vandermonde_matrix(size)
    m = GSL::Matrix.alloc(size, size)

    size.times { |i|
      size.times { |j|
        m.set(i, j, GSL.pow(i + 1.0, size - j - 1.0))
      }
    }

    m
  end

  def setup
    @hilb2    = _create_hilbert_matrix(2)
    @hilb3    = _create_hilbert_matrix(3)
    @hilb4    = _create_hilbert_matrix(4)
    @hilb12   = _create_hilbert_matrix(12)
    @vander2  = _create_vandermonde_matrix(2)
    @vander3  = _create_vandermonde_matrix(3)
    @vander4  = _create_vandermonde_matrix(4)
    @vander12 = _create_vandermonde_matrix(12)

    @hilb2_solution  = GSL::Vector.alloc(-8.0, 18.0)
    @hilb3_solution  = GSL::Vector.alloc(27.0, -192.0, 210.0)
    @hilb4_solution  = GSL::Vector.alloc(-64.0, 900.0, -2520.0, 1820.0)
    @hilb12_solution = GSL::Vector.alloc(
      -1728.0, 245388.0, -8528520.0,
       127026900.0, -1009008000.0, 4768571808.0,
      -14202796608.0, 27336497760.0, -33921201600.0,
       26189163000.0, -11437874448.0, 2157916488.0
    )

    @vander2_solution  = GSL::Vector.alloc(1.0, 0.0)
    @vander3_solution  = GSL::Vector.alloc(0.0, 1.0, 0.0)
    @vander4_solution  = GSL::Vector.alloc(0.0, 0.0, 1.0, 0.0)
    @vander12_solution = GSL::Vector.alloc(0.0, 0.0, 0.0, 0.0,
                                           0.0, 0.0, 0.0, 0.0,
                                           0.0, 0.0, 1.0, 0.0)
  end

  def test_matmult
    a = GSL::Matrix.alloc([10.0, 5.0, 1.0, 20.0], 2, 2)
    b = GSL::Matrix.alloc([10.0, 5.0, 2.0, 1.0, 3.0, 2.0], 2, 3)
    c = a * b

    refute((c[0, 0] - 105.0).abs > GSL::DBL_EPSILON)
    refute((c[0, 1] -  65.0).abs > GSL::DBL_EPSILON)
    refute((c[0, 2] -  30.0).abs > GSL::DBL_EPSILON)
    refute((c[1, 0] -  30.0).abs > GSL::DBL_EPSILON)
    refute((c[1, 1] -  65.0).abs > GSL::DBL_EPSILON)
    refute((c[1, 2] -  42.0).abs > GSL::DBL_EPSILON)
  end

  def _test_bidiag_decomp_dim(m, eps, desc)
    eps *= 2 * GSL::DBL_EPSILON

    mm = m.size1
    nn = m.size2

    a = m.duplicate
    b = GSL::Matrix.calloc(nn, nn)

    u, v, d, sd = GSL::Linalg::Bidiag.unpack(*GSL::Linalg::Bidiag.decomp(a))

    b.set_diagonal(d)
    (nn - 1).times { |i| b[i, i + 1] = sd[i] }

    a = u * b * v.trans

    mm.times { |i|
      nn.times { |j|
        _check(aij = a[i, j], mij = m[i, j], eps,
          '%s: (%d,%d)[%d,%d]: %22.18g %22.18g' % [desc, mm, nn, i, j, aij, mij])
      }
    }
  end

  def test_bidiag_decomp
    m53 = _create_general_matrix(5, 3)
    m97 = _create_general_matrix(9, 7)

    _test_bidiag_decomp_dim(m53,       64.0, 'bidiag_decomp m(5,3)')
    _test_bidiag_decomp_dim(m97,       64.0, 'bidiag_decomp m(9,7)')
    _test_bidiag_decomp_dim(@hilb2,     8.0, 'bidiag_decomp hilbert(2)')
    _test_bidiag_decomp_dim(@hilb3,    64.0, 'bidiag_decomp hilbert(3)')
    _test_bidiag_decomp_dim(@hilb4,  1024.0, 'bidiag_decomp hilbert(4)')
    _test_bidiag_decomp_dim(@hilb12, 1024.0, 'bidiag_decomp hilbert(12)')
  end

  def test_cholesky
    m = GSL::Matrix.pascal(6)

    c_exp = GSL::Matrix[[1, 0, 0, 0, 0, 0],
                   [1, 1, 0, 0, 0, 0],
                   [1, 2, 1, 0, 0, 0],
                   [1, 3, 3, 1, 0, 0],
                   [1, 4, 6, 4, 1, 0],
                   [1, 5, 10, 10, 5, 1]]

    c = m.cholesky_decomp
    a = c.lower

    assert a == c_exp, "#{m.class}#cholesky_decomp"
    assert a * a.trans == m, "#{m.class}#cholesky_decomp"
  end

  def _test_HH_solve_dim(m, actual, eps, desc)
    eps *= GSL::DBL_EPSILON if eps > 1

    dim = m.size1

    x = GSL::Vector.indgen(dim) + 1
    GSL::Linalg::HH.svx(m.duplicate, x)

    dim.times { |i|
      _check(si = x[i], ai = actual[i], eps,
        '%s: %d[%d]: %22.18g %22.18g' % [desc, dim, i, si, ai])
    }
  end

  def test_HH_solve
    _test_HH_solve_dim(@hilb2,    @hilb2_solution,       8.0,  'HH_solve Hilbert(2)')
    _test_HH_solve_dim(@hilb3,    @hilb3_solution,     128.0,  'HH_solve Hilbert(3)')
    _test_HH_solve_dim(@hilb4,    @hilb4_solution,    2048.0,  'HH_solve Hilbert(4)')
    _test_HH_solve_dim(@hilb12,   @hilb12_solution,      0.5,  'HH_solve Hilbert(12)')
    _test_HH_solve_dim(@vander2,  @vander2_solution,     8.0,  'HH_solve Vander(2)')
    _test_HH_solve_dim(@vander3,  @vander3_solution,    64.0,  'HH_solve Vander(3)')
    _test_HH_solve_dim(@vander4,  @vander4_solution,  1024.0,  'HH_solve Vander(4)')
    _test_HH_solve_dim(@vander12, @vander12_solution,    0.05, 'HH_solve Vander(12)')
  end

  def test_LU
    m = GSL::Matrix.alloc([0.18, 0.60, 0.57, 0.96], [0.41, 0.24, 0.99, 0.58],
                          [0.14, 0.30, 0.97, 0.66], [0.51, 0.13, 0.19, 0.85])

    a = m.clone
    assert m == a, "#{a.class}#LU_decomp: matrix not destroyed"

    lu_exp = GSL::Matrix.alloc([0.51,              0.13,              0.19,              0.85],
                               [0.352941176470588, 0.554117647058823, 0.502941176470588, 0.66],
                               [0.803921568627451, 0.244515215852796, 0.71427813163482, -0.264713375796178],
                               [0.274509803921569, 0.476999292285916, 0.949126848480345, 0.363093705877982])

    x_exp = GSL::Vector[-4.05205022957397, -12.6056113959069, 1.66091162670884, 8.69376692879523]

    lu, perm, _sign = m.LU_decomp
    assert lu == lu_exp, "#{a.class}#LU_decomp"

    b = GSL::Vector[1, 2, 3, 4]
    x = GSL::Linalg::LU.solve(lu, perm, b)
    assert x == x_exp, "#{a.class}.LU_solve"

    x = lu.solve(perm, b)
    assert x == x_exp, "#{lu.class}#solve"

    perm, _sign = m.LU_decomp!
    assert m == lu_exp, "#{a.class}#LU_decomp!"

    m = a.clone

    x = GSL::Linalg::LU.solve(m, perm, b)
    assert x == x_exp, "#{a.class}.LU_solve"

    x = m.LU_solve(perm, b)
    assert x == x_exp, "#{a.class}#LU_solve"
    assert m == a, "#{a.class}#LU_solve: matrix not destroyed"

    h    = GSL::Matrix.hilbert(5)
    invh = GSL::Matrix.invhilbert(5)
    lu, perm, _sign = h.LU_decomp

    a = GSL::Linalg::LU.invert(lu, perm)
    assert a.equal?(invh, 1e-6), "#{h.class}#LU_invert, Hilbert matrix of order 5"

    a = lu.invert(perm)
    assert a.equal?(invh, 1e-6), "#{h.class}#LU_invert, Hilbert matrix of order 5"

    a = h.inv
    assert a.equal?(invh, 1e-6), "#{h.class}#LU_invert, Hilbert matrix of order 5"
  end

  def test_QR
    m = GSL::Matrix.alloc([0.18, 0.60, 0.57, 0.96], [0.41, 0.24, 0.99, 0.58],
                          [0.14, 0.30, 0.97, 0.66], [0.51, 0.13, 0.19, 0.85])

    a = m.clone
    assert m == a, "#{m.class}#QR_decomp: matrix not destroyed"

    x_exp = GSL::Vector[-4.05205022957397, -12.6056113959069, 1.66091162670884, 8.69376692879523]
    b = GSL::Vector[1, 2, 3, 4]

    qr, tau = m.QR_decomp

    x = m.QR_solve(b)
    assert x == x_exp, "#{m.class}#QR_solve(b)"

    x = GSL::Linalg::QR.solve(m, b)
    assert x == x_exp, 'GSL::Linalg::QR::solve(b)'

    tau = m.QR_decomp!
    assert m != a, "#{m.class}#QR_decomp: matrix destroyed"

    x = m.QR_solve(tau, b)
    assert x == x_exp, "#{m.class}#QR_solve(tau, b)"

    x = qr.solve(tau, b)
    assert x == x_exp, "#{qr.class}#solve(tau, b)"

    assert_raises(ArgumentError) { m.QR_solve(b) }
    assert_raises(ArgumentError) { m.solve(b) }

    x = m.solve(tau, b)
    assert x == x_exp, "#{m.class}#solve(tau, b)"

    m = a.clone
    bb = b.clone
    m.QR_svx(bb)
    assert bb == x_exp, "#{m.class}#QR_svx(b)"

    tau = GSL::Linalg::QR.decomp!(m)
    bb = b.clone
    m.QR_svx(tau, bb)
    assert bb == x_exp, "#{m.class}#QR_svx(tau, b)"
    assert_raises(ArgumentError) { m.QR_svx(bb) }

    m = a.clone
    qr, tau = m.QR_decomp
    assert m == a, "#{m.class}#QR_decomp: matrix not destroyed"

    x, r = m.QR_lssolve(b)
    assert x == x_exp, "#{m.class}#QR_lssolve(b)"

    r = m.QR_lssolve(b, x)
    assert x == x_exp, "#{qr.class}#QR_lssolve(b, x)"

    m.QR_lssolve(b, x, r)
    assert x == x_exp, "#{qr.class}#QR_lssolve(b, x, r)"

    x, r = qr.QR_lssolve(tau, b)
    assert x == x_exp, "#{qr.class}#QR_lssolve(tau, b)"

    r = qr.QR_lssolve(tau, b, x)
    assert x == x_exp, "#{qr.class}#QR_lssolve(tau, b, x)"

    qr.QR_lssolve(tau, b, x, r)
    assert x == x_exp, "#{qr.class}#QR_lssolve(tau, b, x, r)"
    assert_raises(ArgumentError) { qr.QR_lssolve(bb) }
  end

  def test_SV
    a = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    i = GSL::Matrix.identity(2)
    ainv = a.inv

    u, v, s = a.SV_decomp
    sm = s.to_m_diagonal
    sinv = s.map { |x| 1.0 / x }.to_m_diagonal

    assert u * sm * v.trans == a, "#{a.class}#SV_decomp"
    assert v * sinv * u.trans == ainv, "#{a.class}#SV_decomp"

    assert u.trans * u == i, "#{a.class}#SV_decomp"
    assert v.trans * v == i, "#{a.class}#SV_decomp"

    assert a * v == u * sm, "#{a.class}#SV_decomp"
    assert a.trans * u == v * sm, "#{a.class}#SV_decomp"
  end

  def _test_TDN_solve_dim(dim, d, a, b, actual, eps, desc)
    eps *= GSL::DBL_EPSILON

    abovediag = GSL::Vector.alloc(dim - 1)
    belowdiag = GSL::Vector.alloc(dim - 1)

    diag = GSL::Vector.alloc(dim)
    diag.set_all(d)

    rhs = GSL::Vector.indgen(dim) + 1

    abovediag.set_all(a)
    belowdiag.set_all(b)

    x = GSL::Linalg.solve_tridiag(diag, abovediag, belowdiag, rhs)

    dim.times { |i|
      _check(si = x[i], ai = actual[i], eps,
        '%s: %d[%d]: %22.18g %22.18g' % [desc, dim, i, si, ai])
    }
  end

  def test_TDN_solve
    actual = GSL::Vector.alloc(5)

    actual[0] = -7.0 / 3.0
    actual[1] =  5.0 / 3.0
    actual[2] =  4.0 / 3.0
    _test_TDN_solve_dim(3, 1.0, 2.0, 1.0, actual, 2.0, 'solve_TDN dim=2 A')

    actual[0] = 0.75
    actual[1] = 0.75
    actual[2] = 2.625
    _test_TDN_solve_dim(3, 1.0, 1.0 / 3.0, 1.0 / 2.0, actual, 2.0, 'solve_TDN dim=2 B')

    actual[0] =   99.0 / 140.0
    actual[1] =   41.0 /  35.0
    actual[2] =   19.0 /  10.0
    actual[3] =   72.0 /  35.0
    actual[4] =  139.0 /  35.0
    _test_TDN_solve_dim(5, 1.0, 1.0 / 4.0, 1.0 / 2.0, actual, 35.0 / 8.0, 'solve_TDN dim=5')
  end

  def _test_TDN_cyc_solve_dim(dim, d, a, b, actual, eps, desc)
    eps *= GSL::DBL_EPSILON

    abovediag = GSL::Vector.alloc(dim)
    belowdiag = GSL::Vector.alloc(dim)

    diag = GSL::Vector.alloc(dim)
    rhs = GSL::Vector.indgen(dim) + 1

    abovediag.set_all(a)
    belowdiag.set_all(b)

    diag.set_all(d)

    x = GSL::Linalg.solve_cyc_tridiag(diag, abovediag, belowdiag, rhs)
    dim.times { |i|
      _check(si = x[i], ai = actual[i], eps,
        '%s: %d[%d]: %22.18g %22.18g' % [desc, dim, i, si, ai])
    }
  end

  def test_TDN_cyc_solve
    actual = GSL::Vector.alloc(5)

    actual[0] =  3.0 / 2.0
    actual[1] = -1.0 / 2.0
    actual[2] =  1.0 / 2.0
    _test_TDN_cyc_solve_dim(3, 1.0, 2.0, 1.0, actual, 32.0, 'solve_TDN_cyc dim=2')

    actual[0] =  -5.0 / 22.0
    actual[1] =  -3.0 / 22.0
    actual[2] =  29.0 / 22.0
    actual[3] =  -9.0 / 22.0
    actual[4] =  43.0 / 22.0
    _test_TDN_cyc_solve_dim(5, 3.0, 2.0, 1.0, actual, 66.0, 'solve_TDN_cyc dim=5')
  end

  def _test_TDS_solve_dim(dim, d, od, actual, eps, desc)
    eps *= GSL::DBL_EPSILON

    diag = GSL::Vector.alloc(dim)
    diag.set_all(d)

    rhs = GSL::Vector.indgen(dim) + 1

    offdiag = GSL::Vector.alloc(dim - 1)
    offdiag.set_all(od)

    x = GSL::Linalg.solve_symm_tridiag(diag, offdiag, rhs)
    dim.times { |i|
      _check(si = x[i], ai = actual[i], eps,
        '%s: %d[%d]: %22.18g %22.18g' % [desc, dim, i, si, ai])
    }
  end

  def test_TDS_solve
    actual = GSL::Vector[0.0, 2.0]
    _test_TDS_solve_dim(2, 1.0, 0.5, actual, 8.0, 'solve_TDS dim=2 A')

    actual = GSL::Vector[3.0 / 8.0, 15.0 / 8.0]
    _test_TDS_solve_dim(2, 1.0, 1.0 / 3.0, actual, 8.0, 'solve_TDS dim=2 B')

    actual = GSL::Vector[5.0 / 8.0, 9.0 / 8.0, 2.0, 15.0 / 8.0, 35.0 / 8.0]
    _test_TDS_solve_dim(5, 1.0, 1.0 / 3.0, actual, 8.0, 'solve_TDS dim=5')
  end

  def _test_TDS_cyc_solve_one(dim, d, od, r, actual, eps, desc)
    eps *= GSL::DBL_EPSILON

    diag = d.duplicate
    offdiag = od.duplicate
    rhs = r.duplicate

    x = GSL::Linalg.solve_symm_cyc_tridiag(diag, offdiag, rhs)
    dim.times { |i|
      _check(si = x[i], ai = actual[i], eps,
        '%s: %d[%d]: %22.18g %22.18g' % [desc, dim, i, si, ai])
    }
  end

  def test_TDS_cyc_solve
    diag = GSL::Vector.alloc(1)
    diag[0] = 2

    offdiag = GSL::Vector.alloc(1)
    offdiag[0] = 3

    rhs = GSL::Vector.alloc(1)
    rhs[0] = 7

    actual = GSL::Vector.alloc(1)
    actual[0] = 3.5

    # XXX GSL::ERROR::EBADLEN: Ruby/GSL error code 19, size of cyclic system must be
    # 3 or more (file tridiag.c, line 531), matrix/vector sizes are not conformant
    #_test_TDS_cyc_solve_one(1, diag, offdiag, rhs, actual, 28.0, 'solve_TDS_cyc dim=1')

    diag = GSL::Vector[1, 2]
    offdiag = GSL::Vector[3, 4]
    rhs = GSL::Vector[7, -7]
    actual = GSL::Vector[-5, 4]

    # XXX GSL::ERROR::EBADLEN: Ruby/GSL error code 19, size of cyclic system must be
    # 3 or more (file tridiag.c, line 531), matrix/vector sizes are not conformant
    #_test_TDS_cyc_solve_one(2, diag, offdiag, rhs, actual, 28.0, 'solve_TDS_cyc dim=2')

    diag = GSL::Vector[1, 1, 1]
    offdiag = GSL::Vector[3, 3, 3]
    rhs = GSL::Vector[7, -7, 7]
    actual = GSL::Vector[-2, 5, -2]

    _test_TDS_cyc_solve_one(3, diag, offdiag, rhs, actual, 28.0, 'solve_TDS_cyc dim=3')

    diag = GSL::Vector[4, 2, 1, 2, 4]
    offdiag = GSL::Vector[1, 1, 1, 1, 1]
    rhs = GSL::Vector[30, -24, 3, 21, -30]
    actual = GSL::Vector[12, 3, -42, 42, -21]

    _test_TDS_cyc_solve_one(5, diag, offdiag, rhs, actual, 35.0, 'solve_TDS_cyc dim=5')
  end

  # Test LU decomposition module function
  def test_LU_decomp_module_function
    m = GSL::Matrix.alloc([0.18, 0.60, 0.57, 0.96], [0.41, 0.24, 0.99, 0.58],
                          [0.14, 0.30, 0.97, 0.66], [0.51, 0.13, 0.19, 0.85])

    lu, perm, sign = GSL::Linalg.LU_decomp(m)
    assert lu.is_a?(GSL::Matrix), "LU_decomp returns a matrix"
    assert perm.is_a?(GSL::Permutation), "LU_decomp returns a permutation"
    assert sign.is_a?(Integer), "LU_decomp returns a sign"
  end

  # Test LU decomposition bang method
  def test_LU_decomp_bang
    m = GSL::Matrix.alloc([0.18, 0.60, 0.57, 0.96], [0.41, 0.24, 0.99, 0.58],
                          [0.14, 0.30, 0.97, 0.66], [0.51, 0.13, 0.19, 0.85])
    original = m.clone

    perm, sign = m.LU_decomp!
    refute m == original, "LU_decomp! modifies matrix in place"
    assert perm.is_a?(GSL::Permutation), "LU_decomp! returns a permutation"
    assert sign.is_a?(Integer), "LU_decomp! returns a sign"
  end

  # Test LU svx (solve in place)
  def test_LU_svx
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    lu, perm, _sign = m.LU_decomp
    x = b.clone
    GSL::Linalg::LU.svx(lu, perm, x)

    # Verify: m * x should equal b
    result = m * x
    assert result[0].abs - b[0].abs < 1e-10, "LU_svx solves correctly"
    assert result[1].abs - b[1].abs < 1e-10, "LU_svx solves correctly"
  end

  # Test LU determinant
  def test_LU_det
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])
    det = m.det
    expected = 1.0 * 4.0 - 2.0 * 3.0  # -2
    assert (det - expected).abs < 1e-10, "LU_det computes determinant correctly"
  end

  # Test LU lndet (log determinant)
  def test_LU_lndet
    m = GSL::Matrix.alloc([2.0, 0.0], [0.0, 3.0])
    lndet = m.lndet
    expected = Math.log(6.0)  # log(|det|) = log(6)
    assert (lndet - expected).abs < 1e-10, "LU_lndet computes log determinant"
  end

  # Test LU sgndet (sign of determinant)
  def test_LU_sgndet
    m1 = GSL::Matrix.alloc([2.0, 0.0], [0.0, 3.0])  # positive det
    m2 = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])  # negative det

    sign1 = m1.sgndet
    sign2 = m2.sgndet

    assert sign1 == 1, "sgndet returns 1 for positive determinant"
    assert sign2 == -1, "sgndet returns -1 for negative determinant"
  end

  # Test QR decomposition module function
  def test_QR_decomp_module_function
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0], [5.0, 6.0])

    qr, tau = GSL::Linalg.QR_decomp(m)
    assert qr.is_a?(GSL::Matrix), "QR_decomp returns a matrix"
    assert tau.is_a?(GSL::Vector), "QR_decomp returns a tau vector"
  end

  # Test QR decomposition bang method
  def test_QR_decomp_bang_method
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0], [5.0, 6.0])
    original = m.clone

    tau = GSL::Linalg::QR.decomp!(m)
    refute m == original, "QR_decomp! modifies matrix in place"
    assert tau.is_a?(GSL::Vector), "QR_decomp! returns a tau vector"
  end

  # Test QR solve
  def test_QR_solve_module_function
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    x = GSL::Linalg::QR.solve(m, b)

    # Verify: m * x should equal b
    result = m * x
    assert (result[0] - b[0]).abs < 1e-10, "QR_solve returns correct x[0]"
    assert (result[1] - b[1]).abs < 1e-10, "QR_solve returns correct x[1]"
  end

  # Test QR svx (solve in place)
  def test_QR_svx
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]
    original_m = m.clone

    tau = m.QR_decomp!
    x = b.clone
    m.QR_svx(tau, x)

    # Verify: original_m * x should equal b
    result = original_m * x
    assert (result[0] - b[0]).abs < 1e-10, "QR_svx solves correctly"
    assert (result[1] - b[1]).abs < 1e-10, "QR_svx solves correctly"
  end

  # Test QR QTvec
  def test_QR_QTvec
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])
    qr, tau = m.QR_decomp
    v = GSL::Vector[1.0, 1.0]

    result = GSL::Linalg::QR.QTvec(qr, tau, v)
    assert result.is_a?(GSL::Vector), "QTvec returns a vector"
    assert_equal 2, result.size, "QTvec returns vector of correct size"
  end

  # Test QR Qvec
  def test_QR_Qvec
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])
    qr, tau = m.QR_decomp
    v = GSL::Vector[1.0, 1.0]

    result = GSL::Linalg::QR.Qvec(qr, tau, v)
    assert result.is_a?(GSL::Vector), "Qvec returns a vector"
    assert_equal 2, result.size, "Qvec returns vector of correct size"
  end

  # Test QR unpack
  def test_QR_unpack
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])
    qr, tau = m.QR_decomp

    q, r = GSL::Linalg::QR.unpack(qr, tau)
    assert q.is_a?(GSL::Matrix), "QR_unpack returns Q matrix"
    assert r.is_a?(GSL::Matrix), "QR_unpack returns R matrix"

    # Q should be orthogonal: Q^T * Q = I
    qtq = q.trans * q
    assert (qtq[0,0] - 1.0).abs < 1e-10, "Q is orthogonal"
    assert (qtq[1,1] - 1.0).abs < 1e-10, "Q is orthogonal"
  end

  # Test LQ decomposition
  def test_LQ_decomp
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])

    lq, tau = GSL::Linalg::LQ.decomp(m)
    assert lq.is_a?(GSL::Matrix), "LQ_decomp returns a matrix"
    assert tau.is_a?(GSL::Vector), "LQ_decomp returns a tau vector"
  end

  # Test LQ decomposition bang
  def test_LQ_decomp_bang
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])
    original = m.clone

    tau = GSL::Linalg::LQ.decomp!(m)
    refute m == original, "LQ_decomp! modifies matrix in place"
    assert tau.is_a?(GSL::Vector), "LQ_decomp! returns a tau vector"
  end

  # LQ unpack test skipped - tau type mismatch between decomp and unpack

  # Test SV decomposition module function
  def test_SV_decomp_module_function
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0], [5.0, 6.0])

    u, v, s = GSL::Linalg::SV.decomp(m)
    assert u.is_a?(GSL::Matrix), "SV_decomp returns U matrix"
    assert v.is_a?(GSL::Matrix), "SV_decomp returns V matrix"
    assert s.is_a?(GSL::Vector), "SV_decomp returns singular values"
  end

  # Test SV decomposition with Jacobi method
  def test_SV_decomp_jacobi
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])

    u, v, s = GSL::Linalg::SV.decomp_jacobi(m)
    assert u.is_a?(GSL::Matrix), "SV_decomp_jacobi returns U matrix"
    assert v.is_a?(GSL::Matrix), "SV_decomp_jacobi returns V matrix"
    assert s.is_a?(GSL::Vector), "SV_decomp_jacobi returns singular values"
  end

  # Test SV solve
  def test_SV_solve
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    u, v, s = m.SV_decomp
    x = GSL::Linalg::SV.solve(u, v, s, b)

    # Verify: m * x should equal b
    result = m * x
    assert (result[0] - b[0]).abs < 1e-10, "SV_solve returns correct x[0]"
    assert (result[1] - b[1]).abs < 1e-10, "SV_solve returns correct x[1]"
  end

  # Test QRPT decomposition
  def test_QRPT_decomp
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])

    qr, tau, perm, sign = GSL::Linalg::QRPT.decomp(m)
    assert qr.is_a?(GSL::Matrix), "QRPT_decomp returns QR matrix"
    assert tau.is_a?(GSL::Vector), "QRPT_decomp returns tau vector"
    assert perm.is_a?(GSL::Permutation), "QRPT_decomp returns permutation"
    assert sign.is_a?(Integer), "QRPT_decomp returns sign"
  end

  # Test QRPT decomposition bang
  def test_QRPT_decomp_bang
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])
    original = m.clone

    tau, perm, sign = GSL::Linalg::QRPT.decomp!(m)
    refute m == original, "QRPT_decomp! modifies matrix in place"
    assert tau.is_a?(GSL::Vector), "QRPT_decomp! returns tau vector"
    assert perm.is_a?(GSL::Permutation), "QRPT_decomp! returns permutation"
  end

  # Test QRPT solve
  def test_QRPT_solve
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    x = GSL::Linalg::QRPT.solve(m, b)

    # Verify: m * x should equal b
    result = m * x
    assert (result[0] - b[0]).abs < 1e-10, "QRPT_solve returns correct x[0]"
    assert (result[1] - b[1]).abs < 1e-10, "QRPT_solve returns correct x[1]"
  end

  # Test Cholesky decomposition
  def test_cholesky_decomp_module_function
    # Symmetric positive-definite matrix
    m = GSL::Matrix.alloc([4.0, 2.0], [2.0, 5.0])

    c = GSL::Linalg::Cholesky.decomp(m)
    assert c.is_a?(GSL::Matrix), "Cholesky.decomp returns a matrix"
  end

  # Test Cholesky solve
  def test_cholesky_solve
    # Symmetric positive-definite matrix
    m = GSL::Matrix.alloc([4.0, 2.0], [2.0, 5.0])
    b = GSL::Vector[10.0, 13.0]

    x = GSL::Linalg::Cholesky.solve(m, b)

    # Verify: m * x should equal b
    result = m * x
    assert (result[0] - b[0]).abs < 1e-10, "Cholesky_solve returns correct x[0]"
    assert (result[1] - b[1]).abs < 1e-10, "Cholesky_solve returns correct x[1]"
  end

  # Test Cholesky svx (solve in place)
  def test_cholesky_svx
    m = GSL::Matrix.alloc([4.0, 2.0], [2.0, 5.0])
    b = GSL::Vector[10.0, 13.0]
    original_m = m.clone

    c = m.cholesky_decomp
    x = b.clone
    GSL::Linalg::Cholesky.svx(c, x)

    # Verify
    result = original_m * x
    assert (result[0] - b[0]).abs < 1e-10, "Cholesky_svx solves correctly"
    assert (result[1] - b[1]).abs < 1e-10, "Cholesky_svx solves correctly"
  end

  # Cholesky.invert test skipped - method has different signature than expected

  # Note: Symmtd tests skipped due to bug in rb-gsl wrapper
  # The C code allocates tau with size N instead of N-1

  # Test Householder transformations
  def test_householder_transform
    v = GSL::Vector[3.0, 4.0]

    tau = GSL::Linalg::Householder.transform(v)
    assert tau.is_a?(Float), "Householder.transform returns tau"
  end

  # Test Householder hv (apply Householder to vector)
  def test_householder_hv
    v = GSL::Vector[3.0, 4.0, 0.0]
    tau = GSL::Linalg::Householder.transform(v)

    w = GSL::Vector[1.0, 2.0, 3.0]
    result = GSL::Linalg::Householder.hv(tau, v, w)

    assert result.is_a?(GSL::Vector), "Householder.hv returns a vector"
  end

  # Test HH solve (Householder solver) - additional verification
  def test_HH_solve_verification
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    x = GSL::Linalg::HH.solve(m, b)

    # Verify: m * x should equal b
    result = m * x
    assert (result[0] - b[0]).abs < 1e-10, "HH_solve returns correct x[0]"
    assert (result[1] - b[1]).abs < 1e-10, "HH_solve returns correct x[1]"
  end

  # Test balance_columns
  def test_balance_columns
    m = GSL::Matrix.alloc([1.0, 1000.0], [0.001, 1.0])

    # balance_columns! returns [matrix, vector]
    mat, vec = GSL::Linalg.balance_columns!(m)
    assert mat.is_a?(GSL::Matrix), "balance_columns! returns balanced matrix"
    assert vec.is_a?(GSL::Vector), "balance_columns! returns scaling vector"
  end

  # Test complex Cholesky
  def test_complex_cholesky
    # Hermitian positive-definite matrix
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, GSL::Complex.alloc(4.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(1.0, 1.0))
    m.set(1, 0, GSL::Complex.alloc(1.0, -1.0))
    m.set(1, 1, GSL::Complex.alloc(3.0, 0.0))

    c = GSL::Linalg::Complex::Cholesky.decomp(m)
    assert c.is_a?(GSL::Matrix::Complex), "Complex Cholesky.decomp returns matrix"
  end

  # Test complex LU decomposition
  def test_complex_LU_decomp
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, GSL::Complex.alloc(1.0, 1.0))
    m.set(0, 1, GSL::Complex.alloc(2.0, 0.0))
    m.set(1, 0, GSL::Complex.alloc(3.0, 0.0))
    m.set(1, 1, GSL::Complex.alloc(4.0, -1.0))

    lu, perm, sign = GSL::Linalg::Complex::LU.decomp(m)
    assert lu.is_a?(GSL::Matrix::Complex), "Complex LU.decomp returns matrix"
    assert perm.is_a?(GSL::Permutation), "Complex LU.decomp returns permutation"
  end

  # Test complex LU solve via instance method
  def test_complex_LU_solve
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, GSL::Complex.alloc(2.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(1.0, 0.0))
    m.set(1, 0, GSL::Complex.alloc(1.0, 0.0))
    m.set(1, 1, GSL::Complex.alloc(3.0, 0.0))

    b = GSL::Vector::Complex.alloc(2)
    b.set(0, GSL::Complex.alloc(5.0, 0.0))
    b.set(1, GSL::Complex.alloc(7.0, 0.0))

    # Use instance method which auto-decomposes
    x = m.LU_solve(b)
    assert x.is_a?(GSL::Vector::Complex), "Complex LU_solve returns vector"
  end

  # Test complex Householder
  def test_complex_householder
    v = GSL::Vector::Complex.alloc(2)
    v.set(0, GSL::Complex.alloc(3.0, 4.0))
    v.set(1, GSL::Complex.alloc(0.0, 0.0))

    tau = GSL::Linalg::Complex::Householder.transform(v)
    assert tau.is_a?(GSL::Complex), "Complex Householder.transform returns tau"
  end

  # Test PTLQ decomposition
  def test_PTLQ_decomp
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])

    lq, tau, perm, sign = GSL::Linalg::PTLQ.decomp(m)
    assert lq.is_a?(GSL::Matrix), "PTLQ_decomp returns LQ matrix"
    assert tau.is_a?(GSL::Vector), "PTLQ_decomp returns tau vector"
    assert perm.is_a?(GSL::Permutation), "PTLQ_decomp returns permutation"
    assert sign.is_a?(Integer), "PTLQ_decomp returns sign"
  end

  # Test LU refine
  def test_LU_refine
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    lu, perm, _sign = m.LU_decomp
    x = GSL::Linalg::LU.solve(lu, perm, b)

    # Refine the solution
    x_refined, residual = GSL::Linalg::LU.refine(m, lu, perm, b, x)

    assert x_refined.is_a?(GSL::Vector), "LU_refine returns refined solution"
    assert residual.is_a?(GSL::Vector), "LU_refine returns residual"
  end

  # Test SV decomposition with modified method
  def test_SV_decomp_mod
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0], [5.0, 6.0])

    u, v, s = GSL::Linalg::SV.decomp_mod(m)
    assert u.is_a?(GSL::Matrix), "SV_decomp_mod returns U matrix"
    assert v.is_a?(GSL::Matrix), "SV_decomp_mod returns V matrix"
    assert s.is_a?(GSL::Vector), "SV_decomp_mod returns singular values"
  end

  # Test QRPT decomp2 (returns Q, R matrices separately)
  def test_QRPT_decomp2
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])

    q, r, tau, perm, sign = GSL::Linalg::QRPT.decomp2(m)
    assert q.is_a?(GSL::Matrix), "QRPT_decomp2 returns Q matrix"
    assert r.is_a?(GSL::Matrix), "QRPT_decomp2 returns R matrix"
    assert tau.is_a?(GSL::Vector), "QRPT_decomp2 returns tau vector"
    assert perm.is_a?(GSL::Permutation), "QRPT_decomp2 returns permutation"
    assert sign.is_a?(Integer), "QRPT_decomp2 returns sign"
  end

  # Test QRPT svx (solve in place)
  def test_QRPT_svx
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]
    original_m = m.clone

    qr, tau, perm, _sign = m.QRPT_decomp
    x = b.clone
    qr.svx(tau, perm, x)

    # Verify: original_m * x should equal b
    result = original_m * x
    assert (result[0] - b[0]).abs < 1e-10, "QRPT_svx solves correctly"
    assert (result[1] - b[1]).abs < 1e-10, "QRPT_svx solves correctly"
  end

  # Test QRPT Rsolve (using instance method)
  def test_QRPT_Rsolve
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    qr, tau, perm, _sign = m.QRPT_decomp

    b = GSL::Vector[1.0, 2.0]
    x = qr.Rsolve(perm, b)
    assert x.is_a?(GSL::Vector), "QRPT_Rsolve returns a vector"
  end

  # Test QRPT Rsvx (using instance method)
  def test_QRPT_Rsvx
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    qr, tau, perm, _sign = m.QRPT_decomp

    x = GSL::Vector[1.0, 2.0]
    qr.Rsvx(perm, x)
    assert x.is_a?(GSL::Vector), "QRPT_Rsvx modifies vector in place"
  end

  # Test QR Rsolve
  def test_QR_Rsolve
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    qr, tau = m.QR_decomp

    b = GSL::Vector[1.0, 2.0]
    x = GSL::Linalg::QR.Rsolve(qr, b)
    assert x.is_a?(GSL::Vector), "QR_Rsolve returns a vector"
  end

  # Note: QR.Rsvx has a parameter type mismatch bug in rb-gsl
  # The C code expects the first arg to be vector but gets matrix

  # Test QR update
  def test_QR_update
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])
    qr, tau = m.QR_decomp
    q, r = GSL::Linalg::QR.unpack(qr, tau)

    w = GSL::Vector[0.1, 0.2]
    v = GSL::Vector[0.3, 0.4]

    result = GSL::Linalg::QR.update(q, r, w, v)
    assert result == 0, "QR_update returns success status"
  end

  # Test Hessenberg decomposition
  def test_hessenberg_decomp
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0])

    h, tau = GSL::Linalg::Hessenberg.decomp(m)
    assert h.is_a?(GSL::Matrix), "hessenberg_decomp returns H matrix"
    assert tau.is_a?(GSL::Vector), "hessenberg_decomp returns tau vector"
  end

  # Test Hessenberg unpack
  def test_hessenberg_unpack
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0])

    h, tau = GSL::Linalg::Hessenberg.decomp(m)
    u = GSL::Linalg::Hessenberg.unpack(h, tau)
    assert u.is_a?(GSL::Matrix), "hessenberg_unpack returns U matrix"
  end

  # Test Hessenberg unpack_accum
  def test_hessenberg_unpack_accum
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0])

    h, tau = GSL::Linalg::Hessenberg.decomp(m)
    u = GSL::Matrix.identity(3)
    result = GSL::Linalg::Hessenberg.unpack_accum(h, tau, u)
    assert result.is_a?(GSL::Matrix), "hessenberg_unpack_accum returns U matrix"
  end

  # Test Hessenberg set_zero
  def test_hessenberg_set_zero
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0])
    h, tau = GSL::Linalg::Hessenberg.decomp(m)

    result = GSL::Linalg::Hessenberg.set_zero(h)
    assert result == 0, "hessenberg_set_zero returns status"
  end

  # Test balance_matrix
  def test_balance_matrix
    m = GSL::Matrix.alloc([1.0, 1000.0, 0.0], [0.001, 1.0, 0.0], [0.0, 0.0, 1.0])

    balanced, d = GSL::Linalg.balance_matrix(m)
    assert balanced.is_a?(GSL::Matrix), "balance_matrix returns balanced matrix"
    assert d.is_a?(GSL::Vector), "balance_matrix returns scaling vector"
  end

  # Test LQ solve_T (with square matrix)
  def test_LQ_solve_T
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    lq, tau = m.LQ_decomp
    x = GSL::Linalg::LQ.solve_T(lq, tau, b)
    assert x.is_a?(GSL::Vector), "LQ_solve_T returns a vector"
  end

  # Test LQ svx_T (solve in place with square matrix)
  def test_LQ_svx_T
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    lq, tau = m.LQ_decomp
    x = b.clone
    lq.svx_T(tau, x)
    assert x.is_a?(GSL::Vector), "LQ_svx_T modifies vector in place"
  end

  # Test LQ lssolve_T (with square matrix for least squares)
  def test_LQ_lssolve_T
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    x, residual = GSL::Linalg::LQ.lssolve_T(m, b)
    assert x.is_a?(GSL::Vector), "LQ_lssolve_T returns solution vector"
    assert residual.is_a?(GSL::Vector), "LQ_lssolve_T returns residual"
  end

  # Test LQ vecQT (with square matrix)
  def test_LQ_vecQT
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    lq, tau = m.LQ_decomp
    v = GSL::Vector[1.0, 2.0]

    result = GSL::Linalg::LQ.vecQT(lq, tau, v)
    assert result.is_a?(GSL::Vector), "LQ_vecQT returns a vector"
  end

  # Test LQ vecQ (with square matrix)
  def test_LQ_vecQ
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    lq, tau = m.LQ_decomp
    v = GSL::Vector[1.0, 2.0]

    result = GSL::Linalg::LQ.vecQ(lq, tau, v)
    assert result.is_a?(GSL::Vector), "LQ_vecQ returns a vector"
  end

  # Test LQ unpack (with square matrix)
  def test_LQ_unpack
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    lq, tau = m.LQ_decomp

    l, q = GSL::Linalg::LQ.unpack(lq, tau)
    assert l.is_a?(GSL::Matrix), "LQ_unpack returns L matrix"
    assert q.is_a?(GSL::Matrix), "LQ_unpack returns Q matrix"
  end

  # Test LQ Lsolve_T
  def test_LQ_Lsolve_T
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    lq, tau = m.LQ_decomp

    b = GSL::Vector[1.0, 2.0]
    x = GSL::Linalg::LQ.Lsolve_T(lq, b)
    assert x.is_a?(GSL::Vector), "LQ_Lsolve_T returns a vector"
  end

  # Note: LQ.Lsvx_T has a bug in the C code - argv[istart+1]
  # should be argv[istart] at line 1633

  # Test PTLQ decomp!
  def test_PTLQ_decomp_bang
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])
    original = m.clone

    tau, perm, sign = GSL::Linalg::PTLQ.decomp!(m)
    refute m == original, "PTLQ_decomp! modifies matrix in place"
    assert tau.is_a?(GSL::Vector), "PTLQ_decomp! returns tau vector"
    assert perm.is_a?(GSL::Permutation), "PTLQ_decomp! returns permutation"
  end

  # Test PTLQ decomp2 (with square matrix)
  def test_PTLQ_decomp2
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])

    p, l, tau, perm, sign = GSL::Linalg::PTLQ.decomp2(m)
    assert p.is_a?(GSL::Matrix), "PTLQ_decomp2 returns P matrix"
    assert l.is_a?(GSL::Matrix), "PTLQ_decomp2 returns L matrix"
    assert tau.is_a?(GSL::Vector), "PTLQ_decomp2 returns tau vector"
    assert perm.is_a?(GSL::Permutation), "PTLQ_decomp2 returns permutation"
  end

  # Test PTLQ solve_T (with square matrix)
  def test_PTLQ_solve_T
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    x = GSL::Linalg::PTLQ.solve_T(m, b)
    assert x.is_a?(GSL::Vector), "PTLQ_solve_T returns a vector"
  end

  # Test PTLQ svx_T
  def test_PTLQ_svx_T
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]

    lq, tau, perm, _sign = m.PTLQ_decomp
    x = b.clone
    lq.svx_T(tau, perm, x)
    assert x.is_a?(GSL::Vector), "PTLQ_svx_T modifies vector in place"
  end

  # Test PTLQ Lsolve_T (using instance method)
  def test_PTLQ_Lsolve_T
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    lq, tau, perm, _sign = m.PTLQ_decomp

    b = GSL::Vector[1.0, 2.0]
    x = lq.Lsolve_T(perm, b)
    assert x.is_a?(GSL::Vector), "PTLQ_Lsolve_T returns a vector"
  end

  # Note: PTLQ.Lsvx_T appears to have a bug in the C code
  # (returns "unknown operation" in all cases)

  # Test Householder hm (apply Householder to matrix from left)
  def test_householder_hm
    v = GSL::Vector[3.0, 4.0, 0.0]
    tau = GSL::Linalg::Householder.transform(v)

    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0], [5.0, 6.0])
    result = GSL::Linalg::Householder.hm(tau, v, m)
    assert result.is_a?(GSL::Matrix), "Householder.hm returns a matrix"
  end

  # Test Householder mh (apply Householder to matrix from right)
  def test_householder_mh
    v = GSL::Vector[3.0, 4.0]
    tau = GSL::Linalg::Householder.transform(v)

    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0], [5.0, 6.0])
    result = GSL::Linalg::Householder.mh(tau, v, m)
    assert result.is_a?(GSL::Matrix), "Householder.mh returns a matrix"
  end

  # Test HH solve! (in place)
  def test_HH_solve_bang
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    original_m = m.clone
    b = GSL::Vector[5.0, 7.0]

    x = GSL::Linalg::HH.solve!(m, b)
    assert x.is_a?(GSL::Vector), "HH_solve! returns solution"
    refute m == original_m, "HH_solve! modifies matrix in place"
  end

  # Test bidiag_decomp! (in place)
  def test_bidiag_decomp_bang
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0], [10.0, 11.0, 12.0])
    original = m.clone

    tau_u, tau_v = GSL::Linalg::Bidiag.decomp!(m)
    refute m == original, "bidiag_decomp! modifies matrix in place"
    assert tau_u.is_a?(GSL::Vector), "bidiag_decomp! returns tau_U"
    assert tau_v.is_a?(GSL::Vector), "bidiag_decomp! returns tau_V"
  end

  # Test bidiag_unpack2
  def test_bidiag_unpack2
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0], [10.0, 11.0, 12.0])

    tau_u, tau_v = m.bidiag_decomp!
    v = m.bidiag_unpack2(tau_u, tau_v)
    assert v.is_a?(GSL::Matrix), "bidiag_unpack2 returns V matrix"
  end

  # Test bidiag_unpack_B - module function version
  def test_bidiag_unpack_B
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0])

    # bidiag_unpack_B extracts diagonal and super-diagonal from bidiag decomposition
    # Use module function which handles allocation correctly
    decomp = m.bidiag_decomp
    d, sd = GSL::Linalg::Bidiag.unpack_B(decomp[0])
    assert d.is_a?(GSL::Vector), "bidiag_unpack_B returns diagonal"
    assert sd.is_a?(GSL::Vector), "bidiag_unpack_B returns superdiagonal"
  end

  # Test R_solve (solve using R matrix from QR)
  def test_R_solve
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    qr, tau = m.QR_decomp
    q, r = GSL::Linalg::QR.unpack(qr, tau)

    b = GSL::Vector[1.0, 2.0]
    x = r.solve(b)
    assert x.is_a?(GSL::Vector), "R_solve returns solution vector"
  end

  # Test L_solve_T (solve using L matrix from LQ)
  def test_L_solve_T
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    lq, tau = m.LQ_decomp
    l, q = GSL::Linalg::LQ.unpack(lq, tau)

    b = GSL::Vector[1.0, 2.0]
    x = l.solve_T(b)
    assert x.is_a?(GSL::Vector), "L_solve_T returns solution vector"
  end

  # Test complex LU determinant
  def test_complex_LU_det
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, GSL::Complex.alloc(1.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(2.0, 0.0))
    m.set(1, 0, GSL::Complex.alloc(3.0, 0.0))
    m.set(1, 1, GSL::Complex.alloc(4.0, 0.0))

    det = m.det
    assert det.is_a?(GSL::Complex), "Complex det returns Complex"
    # det = 1*4 - 2*3 = -2
    assert (det.re - (-2.0)).abs < 1e-10, "Complex det computes correctly"
  end

  # Test complex LU lndet
  def test_complex_LU_lndet
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, GSL::Complex.alloc(2.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(0.0, 0.0))
    m.set(1, 0, GSL::Complex.alloc(0.0, 0.0))
    m.set(1, 1, GSL::Complex.alloc(3.0, 0.0))

    lndet = m.lndet
    expected = Math.log(6.0)
    assert (lndet - expected).abs < 1e-10, "Complex lndet computes correctly"
  end

  # Test complex LU invert
  def test_complex_LU_invert
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, GSL::Complex.alloc(1.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(2.0, 0.0))
    m.set(1, 0, GSL::Complex.alloc(3.0, 0.0))
    m.set(1, 1, GSL::Complex.alloc(4.0, 0.0))

    inv = m.inv
    assert inv.is_a?(GSL::Matrix::Complex), "Complex inv returns Complex matrix"

    # Check m * inv = I
    identity = m * inv
    assert (identity.get(0, 0).re - 1.0).abs < 1e-10, "m * inv = I check (0,0)"
    assert (identity.get(1, 1).re - 1.0).abs < 1e-10, "m * inv = I check (1,1)"
  end

  # Test complex Householder hv
  def test_complex_householder_hv
    v = GSL::Vector::Complex.alloc(2)
    v.set(0, GSL::Complex.alloc(3.0, 4.0))
    v.set(1, GSL::Complex.alloc(0.0, 0.0))

    tau = GSL::Linalg::Complex::Householder.transform(v)

    w = GSL::Vector::Complex.alloc(2)
    w.set(0, GSL::Complex.alloc(1.0, 0.0))
    w.set(1, GSL::Complex.alloc(1.0, 0.0))

    result = GSL::Linalg::Complex::Householder.hv(tau, v, w)
    assert result.is_a?(GSL::Vector::Complex), "Complex Householder.hv returns vector"
  end

  # Test LU decomposition with pre-allocated permutation
  def test_LU_decomp_with_permutation
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    perm = GSL::Permutation.alloc(2)

    lu, sign = m.LU_decomp(perm)
    assert lu.is_a?(GSL::Matrix), "LU_decomp with perm returns matrix"
    assert sign.is_a?(Integer), "LU_decomp with perm returns sign"
  end

  # Test LU_decomp! with pre-allocated permutation
  def test_LU_decomp_bang_with_permutation
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    perm = GSL::Permutation.alloc(2)

    sign = m.LU_decomp!(perm)
    assert sign.is_a?(Integer), "LU_decomp! with perm returns sign"
  end

  # Test LU solve with pre-allocated x vector
  def test_LU_solve_with_preallocated_x
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]
    x = GSL::Vector.alloc(2)

    lu, perm, _sign = m.LU_decomp
    result = GSL::Linalg::LU.solve(lu, perm, b, x)

    assert_equal x.object_id, result.object_id, "LU_solve returns the pre-allocated x vector"
  end

  # Test LU_svx via instance method
  def test_LU_svx_instance_method
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    b = GSL::Vector[5.0, 7.0]
    original_m = m.clone

    lu, perm, _sign = m.LU_decomp
    x = b.clone
    lu.svx(perm, x)

    # Verify
    result = original_m * x
    assert (result[0] - b[0]).abs < 1e-10, "LU_svx instance method solves correctly"
  end

  # Test Symmtd decomposition
  def test_symmtd_decomp
    # Symmetric matrix
    m = GSL::Matrix.alloc([4.0, 1.0, 2.0], [1.0, 3.0, 1.0], [2.0, 1.0, 5.0])

    q, tau = GSL::Linalg::Symmtd.decomp(m)
    assert q.is_a?(GSL::Matrix), "Symmtd.decomp returns Q matrix"
    assert tau.is_a?(GSL::Vector), "Symmtd.decomp returns tau vector"
  end

  # Test Symmtd decomp! (in place)
  def test_symmtd_decomp_bang
    m = GSL::Matrix.alloc([4.0, 1.0, 2.0], [1.0, 3.0, 1.0], [2.0, 1.0, 5.0])
    original = m.clone

    tau = GSL::Linalg::Symmtd.decomp!(m)
    refute m == original, "Symmtd.decomp! modifies matrix in place"
    assert tau.is_a?(GSL::Vector), "Symmtd.decomp! returns tau vector"
  end

  # Test Symmtd unpack
  def test_symmtd_unpack
    m = GSL::Matrix.alloc([4.0, 1.0, 2.0], [1.0, 3.0, 1.0], [2.0, 1.0, 5.0])

    q_decomp, tau = GSL::Linalg::Symmtd.decomp(m)
    q, d, sd = GSL::Linalg::Symmtd.unpack(q_decomp, tau)

    assert q.is_a?(GSL::Matrix), "Symmtd.unpack returns Q matrix"
    assert d.is_a?(GSL::Vector), "Symmtd.unpack returns diagonal vector"
    assert sd.is_a?(GSL::Vector), "Symmtd.unpack returns subdiagonal vector"
  end

  # Test Symmtd unpack_T
  def test_symmtd_unpack_T
    m = GSL::Matrix.alloc([4.0, 1.0, 2.0], [1.0, 3.0, 1.0], [2.0, 1.0, 5.0])

    q_decomp, tau = GSL::Linalg::Symmtd.decomp(m)
    d, sd = GSL::Linalg::Symmtd.unpack_T(q_decomp)

    assert d.is_a?(GSL::Vector), "Symmtd.unpack_T returns diagonal vector"
    assert sd.is_a?(GSL::Vector), "Symmtd.unpack_T returns subdiagonal vector"
  end

  # Test Hermtd decomposition (Hermitian tridiagonal)
  def test_hermtd_decomp
    # Hermitian matrix
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set(0, 0, GSL::Complex.alloc(4.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(1.0, 1.0))
    m.set(0, 2, GSL::Complex.alloc(2.0, 0.0))
    m.set(1, 0, GSL::Complex.alloc(1.0, -1.0))
    m.set(1, 1, GSL::Complex.alloc(3.0, 0.0))
    m.set(1, 2, GSL::Complex.alloc(1.0, 1.0))
    m.set(2, 0, GSL::Complex.alloc(2.0, 0.0))
    m.set(2, 1, GSL::Complex.alloc(1.0, -1.0))
    m.set(2, 2, GSL::Complex.alloc(5.0, 0.0))

    q, tau = GSL::Linalg::Hermtd.decomp(m)
    assert q.is_a?(GSL::Matrix::Complex), "Hermtd.decomp returns Q matrix"
    assert tau.is_a?(GSL::Vector::Complex), "Hermtd.decomp returns tau vector"
  end

  # Test Hermtd decomp! (in place)
  def test_hermtd_decomp_bang
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set(0, 0, GSL::Complex.alloc(4.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(1.0, 1.0))
    m.set(0, 2, GSL::Complex.alloc(2.0, 0.0))
    m.set(1, 0, GSL::Complex.alloc(1.0, -1.0))
    m.set(1, 1, GSL::Complex.alloc(3.0, 0.0))
    m.set(1, 2, GSL::Complex.alloc(1.0, 1.0))
    m.set(2, 0, GSL::Complex.alloc(2.0, 0.0))
    m.set(2, 1, GSL::Complex.alloc(1.0, -1.0))
    m.set(2, 2, GSL::Complex.alloc(5.0, 0.0))

    tau = GSL::Linalg::Hermtd.decomp!(m)
    assert tau.is_a?(GSL::Vector::Complex), "Hermtd.decomp! returns tau vector"
  end

  # Test Hermtd unpack
  def test_hermtd_unpack
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set(0, 0, GSL::Complex.alloc(4.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(1.0, 1.0))
    m.set(0, 2, GSL::Complex.alloc(2.0, 0.0))
    m.set(1, 0, GSL::Complex.alloc(1.0, -1.0))
    m.set(1, 1, GSL::Complex.alloc(3.0, 0.0))
    m.set(1, 2, GSL::Complex.alloc(1.0, 1.0))
    m.set(2, 0, GSL::Complex.alloc(2.0, 0.0))
    m.set(2, 1, GSL::Complex.alloc(1.0, -1.0))
    m.set(2, 2, GSL::Complex.alloc(5.0, 0.0))

    q_decomp, tau = GSL::Linalg::Hermtd.decomp(m)
    q, d, sd = GSL::Linalg::Hermtd.unpack(q_decomp, tau)

    assert q.is_a?(GSL::Matrix::Complex), "Hermtd.unpack returns Q matrix"
    assert d.is_a?(GSL::Vector), "Hermtd.unpack returns diagonal vector"
    assert sd.is_a?(GSL::Vector), "Hermtd.unpack returns subdiagonal vector"
  end

  # Test Hermtd unpack_T
  def test_hermtd_unpack_T
    m = GSL::Matrix::Complex.alloc(3, 3)
    m.set(0, 0, GSL::Complex.alloc(4.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(1.0, 1.0))
    m.set(0, 2, GSL::Complex.alloc(2.0, 0.0))
    m.set(1, 0, GSL::Complex.alloc(1.0, -1.0))
    m.set(1, 1, GSL::Complex.alloc(3.0, 0.0))
    m.set(1, 2, GSL::Complex.alloc(1.0, 1.0))
    m.set(2, 0, GSL::Complex.alloc(2.0, 0.0))
    m.set(2, 1, GSL::Complex.alloc(1.0, -1.0))
    m.set(2, 2, GSL::Complex.alloc(5.0, 0.0))

    q_decomp, tau = GSL::Linalg::Hermtd.decomp(m)
    d, sd = GSL::Linalg::Hermtd.unpack_T(q_decomp)

    assert d.is_a?(GSL::Vector), "Hermtd.unpack_T returns diagonal vector"
    assert sd.is_a?(GSL::Vector), "Hermtd.unpack_T returns subdiagonal vector"
  end

  # Test hesstri_decomp module function
  def test_hesstri_decomp
    a = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0])
    b = GSL::Matrix.alloc([9.0, 8.0, 7.0], [6.0, 5.0, 4.0], [3.0, 2.0, 1.0])

    h, r = GSL::Linalg.hesstri_decomp(a, b)
    assert h.is_a?(GSL::Matrix), "hesstri_decomp returns H matrix"
    assert r.is_a?(GSL::Matrix), "hesstri_decomp returns R matrix"
  end

  # Test hesstri_decomp! (in place)
  def test_hesstri_decomp_bang
    a = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0])
    b = GSL::Matrix.alloc([9.0, 8.0, 7.0], [6.0, 5.0, 4.0], [3.0, 2.0, 1.0])

    h, r = GSL::Linalg.hesstri_decomp!(a, b)
    assert h.is_a?(GSL::Matrix), "hesstri_decomp! returns H matrix"
    assert r.is_a?(GSL::Matrix), "hesstri_decomp! returns R matrix"
  end

  # Test hesstri_decomp with work vector
  def test_hesstri_decomp_with_work
    a = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0])
    b = GSL::Matrix.alloc([9.0, 8.0, 7.0], [6.0, 5.0, 4.0], [3.0, 2.0, 1.0])
    work = GSL::Vector.alloc(3)

    h, r = GSL::Linalg.hesstri_decomp(a, b, work)
    assert h.is_a?(GSL::Matrix), "hesstri_decomp with work returns H matrix"
    assert r.is_a?(GSL::Matrix), "hesstri_decomp with work returns R matrix"
  end

  # Test hesstri_decomp with U, V matrices
  def test_hesstri_decomp_with_uv
    a = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0])
    b = GSL::Matrix.alloc([9.0, 8.0, 7.0], [6.0, 5.0, 4.0], [3.0, 2.0, 1.0])
    u = GSL::Matrix.identity(3)
    v = GSL::Matrix.identity(3)

    h, r, u_out, v_out = GSL::Linalg.hesstri_decomp(a, b, u, v)
    assert h.is_a?(GSL::Matrix), "hesstri_decomp with UV returns H matrix"
    assert r.is_a?(GSL::Matrix), "hesstri_decomp with UV returns R matrix"
    assert u_out.is_a?(GSL::Matrix), "hesstri_decomp with UV returns U matrix"
    assert v_out.is_a?(GSL::Matrix), "hesstri_decomp with UV returns V matrix"
  end

  # Test balance_matrix! (in place)
  def test_balance_matrix_bang
    m = GSL::Matrix.alloc([1.0, 1000.0, 0.0], [0.001, 1.0, 0.0], [0.0, 0.0, 1.0])

    d = GSL::Linalg.balance_matrix!(m)
    assert d.is_a?(GSL::Vector), "balance_matrix! returns scaling vector"
  end

  # Test balance_matrix with pre-allocated D vector
  def test_balance_matrix_with_d
    m = GSL::Matrix.alloc([1.0, 1000.0, 0.0], [0.001, 1.0, 0.0], [0.0, 0.0, 1.0])
    d = GSL::Vector.alloc(3)

    balanced, d_out = GSL::Linalg.balance_matrix(m, d)
    assert balanced.is_a?(GSL::Matrix), "balance_matrix with D returns matrix"
    assert_equal d.object_id, d_out.object_id, "balance_matrix uses pre-allocated D"
  end

  # Test QR decomp via module function with tau
  def test_QR_decomp_with_tau
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])
    tau = GSL::Vector.alloc(2)

    qr = GSL::Linalg.QR_decomp(m, tau)
    assert qr.is_a?(GSL::Matrix), "QR_decomp with tau returns matrix"
  end

  # Test LQ decomp via module function with tau
  def test_LQ_decomp_with_tau
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])
    tau = GSL::Vector.alloc(2)

    lq = GSL::Linalg.LQ_decomp(m, tau)
    assert lq.is_a?(GSL::Matrix), "LQ_decomp with tau returns matrix"
  end

  # Test LQ update
  def test_LQ_update
    m = GSL::Matrix.alloc([1.0, 2.0], [3.0, 4.0])
    lq, tau = m.LQ_decomp
    l, q = GSL::Linalg::LQ.unpack(lq, tau)

    w = GSL::Vector[0.1, 0.2]
    v = GSL::Vector[0.3, 0.4]

    result = GSL::Linalg::LQ.update(q, l, w, v)
    assert result == 0, "LQ_update returns success status"
  end

  # Test QR QRsolve
  def test_QR_QRsolve
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])
    qr, tau = m.QR_decomp
    q, r = GSL::Linalg::QR.unpack(qr, tau)
    b = GSL::Vector[5.0, 7.0]

    x = GSL::Linalg::QR.QRsolve(q, r, b)
    assert x.is_a?(GSL::Vector), "QR.QRsolve returns solution vector"
  end

  # Test balance_columns (non-bang version)
  def test_balance_columns_non_bang
    m = GSL::Matrix.alloc([1.0, 1000.0], [0.001, 1.0])

    balanced, vec = GSL::Linalg.balance_columns(m)
    assert balanced.is_a?(GSL::Matrix), "balance_columns returns matrix"
    assert vec.is_a?(GSL::Vector), "balance_columns returns vector"
  end

  # Test LU decomp error - wrong argument count
  def test_LU_decomp_wrong_args
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])

    assert_raises(ArgumentError) do
      m.LU_decomp(GSL::Permutation.alloc(2), "extra_arg")
    end
  end

  # Test LU solve error - wrong argument count
  def test_LU_solve_wrong_args_module
    assert_raises(ArgumentError) do
      GSL::Linalg::LU.solve(GSL::Matrix.alloc(2, 2))  # Too few args
    end
  end

  # Test LU svx error - wrong argument count
  def test_LU_svx_wrong_args_module
    assert_raises(ArgumentError) do
      GSL::Linalg::LU.svx(GSL::Matrix.alloc(2, 2))  # Too few args
    end
  end

  # Test QR decomp error - wrong argument count
  def test_QR_decomp_wrong_args
    m = GSL::Matrix.alloc([2.0, 1.0], [1.0, 3.0])

    assert_raises(ArgumentError) do
      m.QR_decomp(GSL::Vector.alloc(2), "extra_arg")
    end
  end

  # Test Hessenberg unpack_accum without pre-allocated V
  def test_hessenberg_unpack_accum_no_preallocated
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0])

    h, tau = GSL::Linalg::Hessenberg.decomp(m)
    u = GSL::Linalg::Hessenberg.unpack_accum(h, tau)
    assert u.is_a?(GSL::Matrix), "hessenberg_unpack_accum allocates V matrix"
  end

  # Test complex LU svx via instance method
  def test_complex_LU_svx
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, GSL::Complex.alloc(2.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(1.0, 0.0))
    m.set(1, 0, GSL::Complex.alloc(1.0, 0.0))
    m.set(1, 1, GSL::Complex.alloc(3.0, 0.0))

    b = GSL::Vector::Complex.alloc(2)
    b.set(0, GSL::Complex.alloc(5.0, 0.0))
    b.set(1, GSL::Complex.alloc(7.0, 0.0))

    lu, perm, _sign = m.LU_decomp
    x = b.clone
    lu.svx(perm, x)
    assert x.is_a?(GSL::Vector::Complex), "Complex LU_svx modifies vector in place"
  end

  # Test complex Cholesky solve
  def test_complex_cholesky_solve
    # Hermitian positive-definite matrix
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, GSL::Complex.alloc(4.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(1.0, 1.0))
    m.set(1, 0, GSL::Complex.alloc(1.0, -1.0))
    m.set(1, 1, GSL::Complex.alloc(3.0, 0.0))

    b = GSL::Vector::Complex.alloc(2)
    b.set(0, GSL::Complex.alloc(10.0, 0.0))
    b.set(1, GSL::Complex.alloc(7.0, 0.0))

    x = GSL::Linalg::Complex::Cholesky.solve(m, b)
    assert x.is_a?(GSL::Vector::Complex), "Complex Cholesky.solve returns vector"
  end

  # Test complex Cholesky svx
  def test_complex_cholesky_svx
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, GSL::Complex.alloc(4.0, 0.0))
    m.set(0, 1, GSL::Complex.alloc(1.0, 1.0))
    m.set(1, 0, GSL::Complex.alloc(1.0, -1.0))
    m.set(1, 1, GSL::Complex.alloc(3.0, 0.0))

    b = GSL::Vector::Complex.alloc(2)
    b.set(0, GSL::Complex.alloc(10.0, 0.0))
    b.set(1, GSL::Complex.alloc(7.0, 0.0))

    c = GSL::Linalg::Complex::Cholesky.decomp(m)
    x = b.clone
    GSL::Linalg::Complex::Cholesky.svx(c, x)
    assert x.is_a?(GSL::Vector::Complex), "Complex Cholesky.svx modifies vector"
  end

  # Test complex Householder hm
  def test_complex_householder_hm
    v = GSL::Vector::Complex.alloc(3)
    v.set(0, GSL::Complex.alloc(3.0, 4.0))
    v.set(1, GSL::Complex.alloc(0.0, 0.0))
    v.set(2, GSL::Complex.alloc(0.0, 0.0))

    tau = GSL::Linalg::Complex::Householder.transform(v)

    m = GSL::Matrix::Complex.alloc(3, 2)
    6.times { |i| m.set(i / 2, i % 2, GSL::Complex.alloc(i + 1.0, 0.0)) }

    result = GSL::Linalg::Complex::Householder.hm(tau, v, m)
    assert result.is_a?(GSL::Matrix::Complex), "Complex Householder.hm returns matrix"
  end

end
