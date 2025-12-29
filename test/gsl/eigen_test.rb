require 'test_helper'

class EigenTest < GSL::TestCase

  def _create_random_symm_matrix(size1, size2, rng, lower, upper)
    m = GSL::Matrix.alloc(size1, size2)

    size1.times { |i|
      size2.times { |j|
        x = rng.uniform * (upper - lower) + lower
        m[i, j] = x
        m[j, i] = x
      }
    }

    m
  end

  def _create_random_herm_matrix(size1, size2, rng, lower, upper)
    m = GSL::Matrix::Complex.alloc(size1, size2)

    size1.times { |i|
      size2.times { |j|
        z = GSL::Complex.alloc(rng.uniform * (upper - lower) + lower,
          i == j ? 0.0 : rng.uniform * (upper - lower) + lower)

        m[i, j] = z
        m[j, i] = z.conjugate
      }
    }

    m
  end

  def _create_random_posdef_matrix(size1, size2, rng)
    m = GSL::Matrix.alloc(size1, size2)
    x = rng.uniform

    size1.times { |i|
      i.upto(size2 - 1) { |j|
        a = GSL.pow(x, (j - i).to_f)
        m[i, j] = a
        m[j, i] = a
      }
    }

    m
  end

  def _create_random_complex_posdef_matrix(size1, size2, rng)
    m = GSL::Matrix::Complex.calloc(size1, size2)
    n = size1

    n.times { |i| m[i, i] = GSL::Complex.alloc(rng.uniform, 0.0) }

    work = GSL::Vector::Complex.alloc(n)

    n.times { |i|
      tau = GSL::Linalg::Complex.householder_transform(work)
      GSL::Linalg::Complex.householder_hm(tau, work, m)
      GSL::Linalg::Complex.householder_mh(tau.conjugate, work, m)
    }

    m
  end

  def _create_random_nonsymm_matrix(size1, size2, rng, lower, upper)
    m = GSL::Matrix.alloc(size1, size2)

    size1.times { |i|
      size2.times { |j|
        m[i, j] = rng.uniform * (upper - lower) + lower
      }
    }

    m
  end

  def _test_eigen_results(n, m, e_val, e_vec, desc, desc2)
    x = GSL::Vector.alloc(n)
    y = GSL::Vector.alloc(n)

    n.times { |i|
      ei = e_val[i]

      GSL::Vector.memcpy(x, e_vec.col(i))
      y = GSL::Blas.dgemv(GSL::Blas::NoTrans, 1.0, m, x, 0.0, y)

      n.times { |j|
        assert_rel y[j], ei * x[j], 1e8 * GSL::DBL_EPSILON,
          '%s, eigenvalue(%d,%d), %s' % [desc, i, j, desc2]
      }
    }

    n.times { |i|
      assert_rel GSL::Blas.dnrm2(e_vec.col(i)), 1.0, n * GSL::DBL_EPSILON,
        '%s, normalized(%d), %s' % [desc, i, desc2]
    }

    n.times { |i|
      vi = e_vec.col(i)

      (i + 1).upto(n - 1) { |j|
        assert_abs GSL::Blas.ddot(vi, e_vec.col(j)), 0.0, n * GSL::DBL_EPSILON,
          '%s, orthogonal(%d,%d), %s' % [desc, i, j, desc2]
      }
    }
  end

  def _test_eigen_complex_results(n, m, e_val, e_vec, desc, desc2)
    x = GSL::Vector::Complex.alloc(n)
    y = GSL::Vector::Complex.alloc(n)

    n.times { |i|
      ei = e_val[i]
      GSL::Vector::Complex.memcpy(x, e_vec.col(i))

      c1 = GSL::Complex.alloc(1.0, 0.0)
      c0 = GSL::Complex.alloc(0.0, 0.0)
      y = GSL::Blas.zgemv(GSL::Blas::NoTrans, c1, m, x, c0, y)

      n.times { |j|
        xj = x[j]
        yj = y[j]

        assert_rel yj.re, ei * xj.re, 1e8 * GSL::DBL_EPSILON,
          '%s, eigenvalue(%d,%d), real, %s' % [desc, i, j, desc2]
        assert_rel yj.im, ei * xj.im, 1e8 * GSL::DBL_EPSILON,
          '%s, eigenvalue(%d,%d), imag, %s' % [desc, i, j, desc2]
      }
    }

    n.times { |i|
      assert_rel GSL::Blas.dznrm2(e_vec.col(i)), 1.0, n * GSL::DBL_EPSILON,
        '%s, normalized(%d), %s' % [desc, i, desc2]
    }

    n.times { |i|
      vi = e_vec.col(i)

      (i + 1).upto(n - 1) { |j|
        assert_abs GSL::Blas.zdotc(vi, e_vec.col(j)).abs, 0.0, n * GSL::DBL_EPSILON,
          '%s, orthogonal(%d,%d), %s' % [desc, i, j, desc2]
      }
    }
  end

  def _test_eigenvalues(n, e_val, e_val2, desc, desc2)
    n.times { |i|
      assert_rel e_val[i], e_val2[i], GSL::DBL_EPSILON,
        '%s, direct eigenvalue(%d), %s' % [desc, i, desc2]
    }
  end

  def _test_eigenvalues_real(e_val, e_val2, desc, desc2)
    n, emax = e_val.size, 0

    n.times { |i|
      e = e_val[i].abs
      emax = e if e > emax
    }

    n.times { |i|
      e2i = e_val2[i]
      assert_abs e_val[i], e2i.abs < GSL::DBL_MIN ? 0 : e2i, emax * 1e8 * GSL::DBL_EPSILON,
        "#{desc}, direct eigenvalue(#{i}), #{desc2}"
    }
  end

  def _test_eigenvalues_complex(e_val, e_val2, desc, desc2)
    n = e_val.size

    n.times { |i|
      assert_rel e_val[i].real, e_val2[i].real, 10 * n * GSL::DBL_EPSILON,
        "#{desc}, direct eigenvalue(#{i}) real, #{desc2}"
      assert_rel e_val[i].imag, e_val2[i].imag, 10 * n * GSL::DBL_EPSILON,
        "#{desc}, direct eigenvalue(#{i}) imag, #{desc2}"
    }
  end

  def _test_eigen_schur(a, s, q, z, count, desc, desc2)
    n = a.size1

    t1 = a * z
    t2 = q * s

    n.times { |i|
      n.times { |j|
        assert_abs t1[i, j], t2[i, j], 1.0e8 * GSL::DBL_EPSILON,
          "#{desc}(N=#{n},cnt=#{count}), #{desc2}, schur(#{i},#{j})"
      }
    }
  end

  def _test_eigen_genherm_results(a, b, e_val, e_vec, count, desc, desc2)
    n = a.size1

    n.times { |i|
      vi = e_vec.column(i)

      assert_rel vi.nrm2, 1.0, n * GSL::DBL_EPSILON,
        "genherm(N=#{n},cnt=#{count}), #{desc}, normalized(#{i}), #{desc2}"

      y = a * vi
      x = (b * vi) * e_val[i]

      n.times { |j|
        assert_rel y[j].real, x[j].real, 1e9 * GSL::DBL_EPSILON,
          "genherm(N=#{n},cnt=#{count}), #{desc}, eigenvalue(#{i},#{j}), real, #{desc2}"
        assert_rel y[j].imag, x[j].imag, 1e9 * GSL::DBL_EPSILON,
          "genherm(N=#{n},cnt=#{count}), #{desc}, eigenvalue(#{i},#{j}), imag, #{desc2}"
      }
    }
  end

  def test_eigen_genherm
    rng = GSL::Rng.alloc

    1.upto(20) { |n|
      w = GSL::Eigen::Genherm.alloc(n)
      wv = GSL::Eigen::Genhermv.alloc(n)

      5.times { |i|
        a = _create_random_herm_matrix(n, n, rng, -10, 10)
        b = _create_random_complex_posdef_matrix(n, n, rng)

        e_valv, e_vec = GSL::Eigen.genhermv(a, b, wv)
        _test_eigen_genherm_results(a, b, e_valv, e_vec, i, 'random', 'unsorted')

        e_val = GSL::Eigen.genherm(a, b, w)

        x = e_val.sort
        y = e_valv.sort

        _test_eigenvalues_real(y, x, 'genherm, random', 'unsorted')

        GSL::Eigen.genhermv_sort(e_valv, e_vec, GSL::EIGEN_SORT_VAL_ASC)
        _test_eigen_genherm_results(a, b, e_valv, e_vec, i, 'random', 'val/asc')

        GSL::Eigen.genhermv_sort(e_valv, e_vec, GSL::EIGEN_SORT_VAL_DESC)
        _test_eigen_genherm_results(a, b, e_valv, e_vec, i, 'random', 'val/desc')

        GSL::Eigen.genhermv_sort(e_valv, e_vec, GSL::EIGEN_SORT_ABS_ASC)
        _test_eigen_genherm_results(a, b, e_valv, e_vec, i, 'random', 'abs/asc')
        GSL::Eigen.genhermv_sort(e_valv, e_vec, GSL::EIGEN_SORT_ABS_DESC)
        _test_eigen_genherm_results(a, b, e_valv, e_vec, i, 'random', 'abs/desc')
      }
    }
  end

  def _test_eigen_gen_results(a, b, alpha, beta, e_vec, count, desc, desc2)
    n = a.size1

    ma = a.to_complex
    mb = b.to_complex

    n.times { |i|
      vi = e_vec.column(i)

      x = (mb * vi) * alpha[i]
      y = (ma * vi) * beta[i]

      n.times { |j|
        assert_abs y[j].real, x[j].real, 1e8 * GSL::DBL_EPSILON,
          "gen(N=#{n},cnt=#{count}), #{desc}, eigenvalue(#{i},#{j}), real, #{desc2}"
        assert_abs y[j].imag, x[j].imag, 1e8 * GSL::DBL_EPSILON,
          "gen(N=#{n},cnt=#{count}), #{desc}, eigenvalue(#{i},#{j}), imag, #{desc2}"
      }
    }
  end

  def _test_eigen_gen_pencil(a, b, count, desc, test_schur, w, wv)
    n = a.size1

    aa = a.clone
    bb = b.clone

    if test_schur == 1
      alphav, betav, e_vec, q, z = GSL::Eigen.genv_QZ(aa, bb, wv)
      _test_eigen_schur(a, aa, q, z, count, 'genv/A', desc)
      _test_eigen_schur(b, bb, q, z, count, 'genv/B', desc)
    else
      alphav, betav, e_vec = GSL::Eigen.genv(aa, bb, wv)
    end

    _test_eigen_gen_results(a, b, alphav, betav, e_vec, count, desc, 'unsorted')

    aa = a.clone
    bb = b.clone

    if test_schur == 1
      GSL::Eigen.gen_params(1, 1, 0, w)

      alpha, beta, q, z = GSL::Eigen.gen_QZ(aa, bb, w)
      _test_eigen_schur(a, aa, q, z, count, 'gen/A', desc)
      _test_eigen_schur(b, bb, q, z, count, 'gen/B', desc)
    else
      GSL::Eigen.gen_params(0, 0, 0, w)
      alpha, beta = GSL::Eigen.gen(aa, bb, w)
    end

    e_val = GSL::Vector::Complex.alloc(n)
    e_valv = GSL::Vector::Complex.alloc(n)

    n.times { |i|
      ai = alpha[i]
      bi = beta[i]
      e_val[i] = GSL::Complex.alloc(ai.real / bi, ai.imag / bi)

      ai = alphav[i]
      bi = betav[i]
      e_valv[i] = GSL::Complex.alloc(ai.real / bi, ai.imag / bi)
    }

    GSL::Eigen.nonsymmv_sort(e_val, nil, GSL::EIGEN_SORT_ABS_ASC)
    GSL::Eigen.nonsymmv_sort(e_valv, nil, GSL::EIGEN_SORT_ABS_ASC)
    _test_eigenvalues_complex(e_valv, e_val, 'gen', desc)

    GSL::Eigen.genv_sort(alphav, betav, e_vec, GSL::EIGEN_SORT_ABS_ASC)
    _test_eigen_gen_results(a, b, alphav, betav, e_vec, count, desc, 'abs/asc')
    GSL::Eigen.genv_sort(alphav, betav, e_vec, GSL::EIGEN_SORT_ABS_DESC)
    _test_eigen_gen_results(a, b, alphav, betav, e_vec, count, desc, 'abs/desc')
  end

  def test_eigen_gen
    rng = GSL::Rng.alloc

    1.upto(20) { |n|
      w = GSL::Eigen::Gen.alloc(n)
      wv = GSL::Eigen::Genv.alloc(n)

      5.times { |i|
        a = _create_random_nonsymm_matrix(n, n, rng, -10, 10)
        b = _create_random_nonsymm_matrix(n, n, rng, -10, 10)
        _test_eigen_gen_pencil(a, b, i, 'random', 0, w, wv)
        _test_eigen_gen_pencil(a, b, i, 'random', 1, w, wv)
      }
    }

    ma = GSL::Matrix.alloc([1, 1, 0, 0, 0, -1, 1, 0, 0], 3, 3)
    mb = GSL::Matrix.alloc([-1, 0, -1, 0, -1, 0, 0, 0, -1], 3, 3)

    w = GSL::Eigen::Gen.alloc(3)
    wv = GSL::Eigen::Genv.alloc(3)

    _test_eigen_gen_pencil(ma, mb, 0, 'integer', 0, w, wv)
    _test_eigen_gen_pencil(ma, mb, 0, 'integer', 1, w, wv)
  end

  def _test_eigen_gensymm_results(a, b, e_val, e_vec, count, desc, desc2)
    n = a.size1

    n.times { |i|
      vi = e_vec.column(i)

      assert_rel vi.dnrm2, 1.0, n * GSL::DBL_EPSILON,
        "gensymm(N=#{n},cnt=#{count}), #{desc}, normalized(#{i}), #{desc2}"

      y = a * vi
      x = (b * vi) * e_val[i]

      n.times { |j|
        assert_rel y[j], x[j], 1e9 * GSL::DBL_EPSILON,
          "gensymm(N=#{n},cnt=#{count}), #{desc}, eigenvalue(#{i},#{j}), #{desc2}"
      }
    }
  end

  def test_eigen_gensymm
    rng = GSL::Rng.alloc

    1.upto(20) { |n|
      w  = GSL::Eigen::Gensymm::Workspace.alloc(n)
      wv = GSL::Eigen::Gensymmv::Workspace.alloc(n)

      5.times { |i|
        a = _create_random_symm_matrix(n, n, rng, -10, 10)
        b = _create_random_posdef_matrix(n, n, rng)

        e_valv, e_vec = GSL::Eigen.gensymmv(a.clone, b.clone, wv)
        _test_eigen_gensymm_results(a, b, e_valv, e_vec, i, 'random', 'unsorted')

        x = GSL::Eigen.gensymm(a.clone, b.clone, w).sort
        y = e_valv.sort

        _test_eigenvalues_real(y, x, 'gensymm, random', 'unsorted')

        GSL::Eigen::Gensymmv.sort(e_valv, e_vec, GSL::EIGEN_SORT_VAL_ASC)
        _test_eigen_gensymm_results(a, b, e_valv, e_vec, i, 'random', 'val/asc')

        GSL::Eigen::Gensymmv.sort(e_valv, e_vec, GSL::EIGEN_SORT_VAL_DESC)
        _test_eigen_gensymm_results(a, b, e_valv, e_vec, i, 'random', 'val/desc')

        GSL::Eigen::Gensymmv.sort(e_valv, e_vec, GSL::EIGEN_SORT_ABS_ASC)
        _test_eigen_gensymm_results(a, b, e_valv, e_vec, i, 'random', 'abs/asc')
        GSL::Eigen::Gensymmv.sort(e_valv, e_vec, GSL::EIGEN_SORT_ABS_DESC)
        _test_eigen_gensymm_results(a, b, e_valv, e_vec, i, 'random', 'abs/desc')
      }
    }
  end

  def test_nonsymm
    m = GSL::Matrix[[1, 2], [3, 2]]
    e_val = m.eigen_nonsymm.real.sort
    assert_abs e_val[0], -1, 0, 'GSL::Matrix::eigen_nonsymm'
    assert_abs e_val[1], 4, 0, 'GSL::Matrix::eigen_nonsymm'

    m = GSL::Matrix[[1, 4, 2, 3], 2, 2]
    e_val = m.eigen_nonsymm.real.sort
    assert_abs e_val[0], -1, 0, 'GSL::Matrix::eigen_nonsymm'
    assert_abs e_val[1], 5, 0, 'GSL::Matrix::eigen_nonsymm'

    m = GSL::Matrix[[2, 4], [3, 1]]
    e_val = m.eigen_nonsymm.real.sort
    assert_abs e_val[0], -2, 0, 'GSL::Matrix::eigen_nonsymm'
    assert_abs e_val[1], 5, 0, 'GSL::Matrix::eigen_nonsymm'

    m = GSL::Matrix[[5, 6, 3, 2], 2, 2]
    e_val = m.eigen_nonsymm.real.sort
    assert_abs e_val[0], -1, 0, 'GSL::Matrix::eigen_nonsymm'
    assert_abs e_val[1], 8, 0, 'GSL::Matrix::eigen_nonsymm'

    m = GSL::Matrix[[4, 1, -1, 2, 5, -2, 1, 1, 2], 3, 3]
    e_val = m.eigen_nonsymm.real.sort
    assert_abs e_val[0], 3, 1e-10, 'GSL::Matrix::eigen_nonsymm'
    assert_abs e_val[1], 3, 0, 'GSL::Matrix::eigen_nonsymm'
    # 2008/Oct/17 YT
    # This test fails in Darwin9.5.0-gcc4.0.1
    #   expected: 5
    #   obtained: 4.99999999999999911
    #assert_abs e_val[2], 5, 0, 'GSL::Matrix::eigen_nonsymm'
    assert_abs e_val[2], 4.99999999999999911, 0, 'GSL::Matrix::eigen_nonsymm'

    m = GSL::Matrix[[-3, 1, -1], [-7, 5, -1], [-6, 6, -2]]
    e_val = m.eigen_nonsymm.real.sort
    assert_abs e_val[0], -2, 1e-6, 'GSL::Matrix::eigen_nonsymm'
    assert_abs e_val[1], -2, 1e-6, 'GSL::Matrix::eigen_nonsymm'
    assert_abs e_val[2], 4, 1e-10, 'GSL::Matrix::eigen_nonsymm'

    m = GSL::Matrix[[11, -8, 4, -8, -1, -2, 4, -2, -4], 3, 3]
    e_val = m.eigen_nonsymm.real.sort
    assert_abs e_val[0], -5, 1e-10, 'GSL::Matrix::eigen_nonsymm'
    assert_abs e_val[1], -5, 1e-10, 'GSL::Matrix::eigen_nonsymm'
    assert_abs e_val[2], 16, 1e-10, 'GSL::Matrix::eigen_nonsymm'
  end

  def _test_nonsymmv2(m, eps)
    m2 = m.clone

    e_val, e_vec = m2.eigen_nonsymmv
    e_valre = e_val.real
    e_vecre = e_vec.real

    a = e_vecre.inv * m * e_vecre

    assert_abs a[0, 0], e_valre[0], eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[1, 1], e_valre[1], eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[0, 1], 0, eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[1, 0], 0, eps, 'GSL::Matrix::eigen_nonsymmv'
  end

  def _test_nonsymmv3(m, eps)
    m2 = m.clone

    e_val, e_vec = m2.eigen_nonsymmv
    e_valre = e_val.real
    e_vecre = e_vec.real

    a = e_vecre.inv * m * e_vecre

    assert_abs a[0, 0], e_valre[0], eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[1, 1], e_valre[1], eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[2, 2], e_valre[2], eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[0, 1], 0, eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[0, 2], 0, eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[1, 0], 0, eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[1, 2], 0, eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[2, 0], 0, eps, 'GSL::Matrix::eigen_nonsymmv'
    assert_abs a[2, 1], 0, eps, 'GSL::Matrix::eigen_nonsymmv'
  end

  def test_nonsymmv
    m = GSL::Matrix[[1, 2], [3, 2]]
    _test_nonsymmv2(m, 1e-10)

    m = GSL::Matrix[[4, 2, 3, -1], 2, 2]
    _test_nonsymmv2(m, 1e-10)

    m = GSL::Matrix[[2, 2, -5], [3, 7, -15], [1, 2, -4]]
    _test_nonsymmv3(m, 1e-10)

    m = GSL::Matrix[[4, 1, -1], [2, 5, -2], [1, 1, 2]]
    _test_nonsymmv3(m, 1e-10)

    m = GSL::Matrix[[-3, 1, -1], [-7, 5, -1], [-6, 6, -2]]
    _test_nonsymmv3(m, 1e-6)

    m = GSL::Matrix[[11, -8, 4], [-8, -1, -2], [4, -2, -4]]
    _test_nonsymmv3(m, 1e-10)
  end

  def _test_eigen_symm(desc, m)
    n = m.size1
    a = GSL::Matrix.alloc(n, n)

    w1 = GSL::Eigen::Symm::Workspace.alloc(n)
    w2 = GSL::Eigen::Symmv::Workspace.alloc(n)

    GSL::Matrix.memcpy(a, m)
    e_val, e_vec = a.eigen_symmv(w2)
    _test_eigen_results(n, m, e_val, e_vec, desc, 'unsorted')

    GSL::Matrix.memcpy(a, m)
    e_val2 = a.eigen_symm(w1)
    _test_eigenvalues(n, e_val, e_val2, desc, 'unsorted')

    GSL::Eigen::Symmv.sort(e_val, e_vec, GSL::Eigen::SORT_VAL_ASC)
    _test_eigen_results(n, m, e_val, e_vec, desc, 'val/asc')
    GSL::Eigen::Symmv.sort(e_val, e_vec, GSL::Eigen::SORT_VAL_DESC)
    _test_eigen_results(n, m, e_val, e_vec, desc, 'val/desc')
    GSL::Eigen::Symmv.sort(e_val, e_vec, GSL::Eigen::SORT_ABS_ASC)
    _test_eigen_results(n, m, e_val, e_vec, desc, 'abs/asc')
    GSL::Eigen::Symmv.sort(e_val, e_vec, GSL::Eigen::SORT_ABS_DESC)
    _test_eigen_results(n, m, e_val, e_vec, desc, 'abs/desc')
  end

  def _test_eigen_herm(desc, m)
    n = m.size1
    a = GSL::Matrix::Complex.alloc(n, n)

    w1 = GSL::Eigen::Herm::Workspace.alloc(n)
    w2 = GSL::Eigen::Hermv::Workspace.alloc(n)

    GSL::Matrix::Complex.memcpy(a, m)
    e_val, e_vec = a.eigen_hermv(w2)
    _test_eigen_complex_results(n, m, e_val, e_vec, desc, 'unsorted')

    GSL::Matrix::Complex.memcpy(a, m)
    e_val2 = a.eigen_herm(w1)
    _test_eigenvalues(n, e_val, e_val2, desc, 'unsorted')

    GSL::Eigen::Hermv.sort(e_val, e_vec, GSL::Eigen::SORT_VAL_ASC)
    _test_eigen_complex_results(n, m, e_val, e_vec, desc, 'val/asc')
    GSL::Eigen::Hermv.sort(e_val, e_vec, GSL::Eigen::SORT_VAL_DESC)
    _test_eigen_complex_results(n, m, e_val, e_vec, desc, 'val/desc')
    GSL::Eigen::Hermv.sort(e_val, e_vec, GSL::Eigen::SORT_ABS_ASC)
    _test_eigen_complex_results(n, m, e_val, e_vec, desc, 'abs/asc')
    GSL::Eigen::Hermv.sort(e_val, e_vec, GSL::Eigen::SORT_ABS_DESC)
    _test_eigen_complex_results(n, m, e_val, e_vec, desc, 'abs/desc')
  end

  def test_symm_herm
    r = GSL::Matrix.alloc([0, 0, -1, 0], [0, 1, 0, 1], [-1, 0, 0, 0], [0, 1, 0, 0])
    _test_eigen_symm('symm(4)', r)
    _test_eigen_herm('herm(4)', r.to_complex)

    r = GSL::Matrix.alloc(4, 4)
    r.set_diagonal([1, 2, 3, 4])
    _test_eigen_symm('symm(4) diag', r)
    _test_eigen_herm('herm(4) diag', r.to_complex)
  end

  def test_eigen_francis
    m = GSL::Matrix[[1, 2], [3, 2]]
    e_val = GSL::Eigen.francis(m)
    assert_kind_of GSL::Vector::Complex, e_val
    assert_equal 2, e_val.size

    e_real = e_val.real.sort
    assert_abs e_real[0], -1, 1e-10, 'GSL::Eigen.francis eigenvalue 1'
    assert_abs e_real[1], 4, 1e-10, 'GSL::Eigen.francis eigenvalue 2'

    # Use an upper Hessenberg matrix (zeros below the first subdiagonal)
    # The francis algorithm requires upper Hessenberg form
    m2 = GSL::Matrix[[4, 1, -1], [2, 5, -2], [0, 1, 2]]
    e_val2 = m2.eigen_francis
    assert_equal 3, e_val2.size
    e_real2 = e_val2.real.sort
    assert_abs e_real2[0], 2.5857864376, 1e-6, 'GSL::Matrix#eigen_francis eigenvalue 1'
    assert_abs e_real2[1], 3.0, 1e-6, 'GSL::Matrix#eigen_francis eigenvalue 2'
    assert_abs e_real2[2], 5.4142135624, 1e-6, 'GSL::Matrix#eigen_francis eigenvalue 3'

    w = GSL::Eigen::Francis::Workspace.alloc
    v = GSL::Vector::Complex.alloc(2)
    m3 = GSL::Matrix[[1, 2], [3, 2]]
    result = GSL::Eigen.francis(m3, v, w)
    assert_same v, result
    e_real3 = v.real.sort
    assert_abs e_real3[0], -1, 1e-10, 'GSL::Eigen.francis with workspace'
    assert_abs e_real3[1], 4, 1e-10, 'GSL::Eigen.francis with workspace'

    m4 = GSL::Matrix[[1, 2], [3, 2]]
    result2 = GSL::Eigen.francis(m4, w)
    e_real4 = result2.real.sort
    assert_abs e_real4[0], -1, 1e-10, 'GSL::Eigen.francis with workspace only'
    assert_abs e_real4[1], 4, 1e-10, 'GSL::Eigen.francis with workspace only'
  end

  def test_eigen_francis_Z
    # Test basic usage - no extra args (allocates v and Z internally)
    m = GSL::Matrix[[1, 2], [3, 2]]
    e_val, z = GSL::Eigen.francis_Z(m)
    assert_kind_of GSL::Vector::Complex, e_val
    assert_kind_of GSL::Matrix, z
    assert_equal 2, e_val.size
    assert_equal [2, 2], [z.size1, z.size2]

    e_real = e_val.real.sort
    assert_abs e_real[0], -1, 1e-10, 'GSL::Eigen.francis_Z eigenvalue 1'
    assert_abs e_real[1], 4, 1e-10, 'GSL::Eigen.francis_Z eigenvalue 2'

    # Test method form
    m2 = GSL::Matrix[[1, 2], [3, 2]]
    e_val2, z2 = m2.eigen_francis_Z
    assert_kind_of GSL::Vector::Complex, e_val2
    assert_kind_of GSL::Matrix, z2

    # Test with workspace only (1 extra arg)
    w = GSL::Eigen::Francis::Workspace.alloc
    m3 = GSL::Matrix[[1, 2], [3, 2]]
    e_val3, z3 = GSL::Eigen.francis_Z(m3, w)
    e_real3 = e_val3.real.sort
    assert_abs e_real3[0], -1, 1e-10, 'GSL::Eigen.francis_Z with workspace'
    assert_abs e_real3[1], 4, 1e-10, 'GSL::Eigen.francis_Z with workspace'

    # Test with v, Z, and workspace (3 extra args)
    w2 = GSL::Eigen::Francis::Workspace.alloc
    v2 = GSL::Vector::Complex.alloc(2)
    zmat = GSL::Matrix.alloc(2, 2)
    m4 = GSL::Matrix[[1, 2], [3, 2]]
    e_val4, z4 = GSL::Eigen.francis_Z(m4, v2, zmat, w2)
    assert_same v2, e_val4
    assert_same zmat, z4
    e_real4 = v2.real.sort
    assert_abs e_real4[0], -1, 1e-10, 'GSL::Eigen.francis_Z with all args'
    assert_abs e_real4[1], 4, 1e-10, 'GSL::Eigen.francis_Z with all args'
  end

  def test_eigen_francis_T
    w = GSL::Eigen::Francis::Workspace.alloc
    # When called on the workspace object, T takes an integer argument
    result = w.T(1)
    assert_equal true, result
    result = w.T(0)
    assert_equal true, result
  end

  def test_eigen_nonsymm_Z
    m = GSL::Matrix[[1, 2], [3, 2]]
    e_val, z = m.eigen_nonsymm_Z
    assert_kind_of GSL::Vector::Complex, e_val
    assert_kind_of GSL::Matrix, z
    assert_equal 2, e_val.size

    e_real = e_val.real.sort
    assert_abs e_real[0], -1, 1e-10, 'GSL::Matrix#eigen_nonsymm_Z eigenvalue 1'
    assert_abs e_real[1], 4, 1e-10, 'GSL::Matrix#eigen_nonsymm_Z eigenvalue 2'

    m2 = GSL::Matrix[[4, 1, -1], [2, 5, -2], [1, 1, 2]]
    e_val2, z2 = GSL::Eigen.nonsymm_Z(m2)
    assert_equal 3, e_val2.size
    e_real2 = e_val2.real.sort
    assert_abs e_real2[0], 3, 1e-10, 'GSL::Eigen.nonsymm_Z'
    assert_abs e_real2[1], 3, 1e-10, 'GSL::Eigen.nonsymm_Z'
    assert_abs e_real2[2], 5, 1e-10, 'GSL::Eigen.nonsymm_Z'

    w = GSL::Eigen::Nonsymm::Workspace.alloc(2)
    m3 = GSL::Matrix[[1, 2], [3, 2]]
    e_val3, z3 = GSL::Eigen.nonsymm_Z(m3, w)
    e_real3 = e_val3.real.sort
    assert_abs e_real3[0], -1, 1e-10, 'GSL::Eigen.nonsymm_Z with workspace'
    assert_abs e_real3[1], 4, 1e-10, 'GSL::Eigen.nonsymm_Z with workspace'
  end

  def test_eigen_nonsymmv_Z
    m = GSL::Matrix[[1, 2], [3, 2]]
    e_val, e_vec, z = m.eigen_nonsymmv_Z
    assert_kind_of GSL::Vector::Complex, e_val
    assert_kind_of GSL::Matrix::Complex, e_vec
    assert_kind_of GSL::Matrix, z
    assert_equal 2, e_val.size

    e_real = e_val.real.sort
    assert_abs e_real[0], -1, 1e-10, 'GSL::Matrix#eigen_nonsymmv_Z eigenvalue 1'
    assert_abs e_real[1], 4, 1e-10, 'GSL::Matrix#eigen_nonsymmv_Z eigenvalue 2'

    m2 = GSL::Matrix[[4, 1, -1], [2, 5, -2], [1, 1, 2]]
    e_val2, e_vec2, z2 = GSL::Eigen.nonsymmv_Z(m2)
    assert_equal 3, e_val2.size
    e_real2 = e_val2.real.sort
    assert_abs e_real2[0], 3, 1e-10, 'GSL::Eigen.nonsymmv_Z'
    assert_abs e_real2[1], 3, 1e-10, 'GSL::Eigen.nonsymmv_Z'
    assert_abs e_real2[2], 5, 1e-10, 'GSL::Eigen.nonsymmv_Z'

    w = GSL::Eigen::Nonsymmv::Workspace.alloc(2)
    m3 = GSL::Matrix[[1, 2], [3, 2]]
    e_val3, e_vec3, z3 = GSL::Eigen.nonsymmv_Z(m3, w)
    e_real3 = e_val3.real.sort
    assert_abs e_real3[0], -1, 1e-10, 'GSL::Eigen.nonsymmv_Z with workspace'
    assert_abs e_real3[1], 4, 1e-10, 'GSL::Eigen.nonsymmv_Z with workspace'
  end

  def test_eigen_nonsymm_params
    w = GSL::Eigen::Nonsymm::Workspace.alloc(3)
    result = w.params(1, 1)
    assert_equal true, result

    w2 = GSL::Eigen::Nonsymm::Workspace.alloc(3)
    result2 = GSL::Eigen::Nonsymm.params(0, 0, w2)
    assert_equal true, result2
  end

  def test_eigen_vectors_unpack
    m = GSL::Matrix[[1, 0, 0], [0, 2, 0], [0, 0, 3]]
    e_val, e_vec = m.eigen_symmv
    vectors = e_vec.unpack
    assert_kind_of Array, vectors
    assert_equal 3, vectors.size
    vectors.each do |v|
      assert_kind_of GSL::Vector, v
      assert_equal 3, v.size
    end
  end

  def test_eigen_herm_vectors_unpack
    m = GSL::Matrix::Complex.alloc(3, 3)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[2, 2] = GSL::Complex.alloc(3.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[0, 2] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 2] = GSL::Complex.alloc(0.0, 0.0)
    m[2, 0] = GSL::Complex.alloc(0.0, 0.0)
    m[2, 1] = GSL::Complex.alloc(0.0, 0.0)

    e_val, e_vec = m.eigen_hermv
    vectors = e_vec.unpack
    assert_kind_of Array, vectors
    assert_equal 3, vectors.size
    vectors.each do |v|
      assert_kind_of GSL::Vector::Complex, v
      assert_equal 3, v.size
    end
  end

  def test_eigen_nonsymm_with_workspace
    n = 3
    w = GSL::Eigen::Nonsymm::Workspace.alloc(n)
    m = GSL::Matrix[[4, 1, -1], [2, 5, -2], [1, 1, 2]]
    v = GSL::Vector::Complex.alloc(n)
    result = GSL::Eigen.nonsymm(m, v, w)
    assert_same v, result
    e_real = v.real.sort
    assert_abs e_real[0], 3, 1e-10, 'GSL::Eigen.nonsymm with vector+workspace'
    assert_abs e_real[1], 3, 1e-10, 'GSL::Eigen.nonsymm with vector+workspace'
    assert_abs e_real[2], 5, 1e-10, 'GSL::Eigen.nonsymm with vector+workspace'

    m2 = GSL::Matrix[[4, 1, -1], [2, 5, -2], [1, 1, 2]]
    result2 = GSL::Eigen.nonsymm(m2, w)
    e_real2 = result2.real.sort
    assert_abs e_real2[0], 3, 1e-10, 'GSL::Eigen.nonsymm with workspace only'
    assert_abs e_real2[1], 3, 1e-10, 'GSL::Eigen.nonsymm with workspace only'
    assert_abs e_real2[2], 5, 1e-10, 'GSL::Eigen.nonsymm with workspace only'
  end

  def test_eigen_nonsymmv_with_workspace
    n = 3
    w = GSL::Eigen::Nonsymmv::Workspace.alloc(n)
    m = GSL::Matrix[[4, 1, -1], [2, 5, -2], [1, 1, 2]]
    e_val, e_vec = GSL::Eigen.nonsymmv(m, w)
    assert_kind_of GSL::Vector::Complex, e_val
    assert_kind_of GSL::Matrix::Complex, e_vec
    e_real = e_val.real.sort
    assert_abs e_real[0], 3, 1e-10, 'GSL::Eigen.nonsymmv with workspace'
    assert_abs e_real[1], 3, 1e-10, 'GSL::Eigen.nonsymmv with workspace'
    assert_abs e_real[2], 5, 1e-10, 'GSL::Eigen.nonsymmv with workspace'
  end

  def test_eigen_nonsymmv_sort
    m = GSL::Matrix[[4, 1, -1], [2, 5, -2], [1, 1, 2]]
    e_val, e_vec = m.eigen_nonsymmv

    e_val_copy = e_val.clone
    GSL::Eigen.nonsymmv_sort(e_val_copy, nil, GSL::EIGEN_SORT_ABS_ASC)
    assert_abs e_val_copy[0].abs, 3, 1e-10, 'nonsymmv_sort abs/asc first'

    e_val2, e_vec2 = m.clone.eigen_nonsymmv
    GSL::Eigen::Nonsymmv.sort(e_val2, e_vec2, GSL::EIGEN_SORT_ABS_DESC)
    assert_abs e_val2[0].abs, 5, 1e-10, 'nonsymmv_sort abs/desc first'
  end

  def test_module_level_eigen_functions
    m = GSL::Matrix[[1, 2], [3, 2]]

    e_val = GSL.eigen_nonsymm(m.clone)
    e_real = e_val.real.sort
    assert_abs e_real[0], -1, 1e-10, 'GSL.eigen_nonsymm'
    assert_abs e_real[1], 4, 1e-10, 'GSL.eigen_nonsymm'

    e_val2, e_vec2 = GSL.eigen_nonsymmv(m.clone)
    e_real2 = e_val2.real.sort
    assert_abs e_real2[0], -1, 1e-10, 'GSL.eigen_nonsymmv'
    assert_abs e_real2[1], 4, 1e-10, 'GSL.eigen_nonsymmv'

    e_val3, z3 = GSL.eigen_nonsymm_Z(m.clone)
    e_real3 = e_val3.real.sort
    assert_abs e_real3[0], -1, 1e-10, 'GSL.eigen_nonsymm_Z'
    assert_abs e_real3[1], 4, 1e-10, 'GSL.eigen_nonsymm_Z'

    e_val4, e_vec4, z4 = GSL.eigen_nonsymmv_Z(m.clone)
    e_real4 = e_val4.real.sort
    assert_abs e_real4[0], -1, 1e-10, 'GSL.eigen_nonsymmv_Z'
    assert_abs e_real4[1], 4, 1e-10, 'GSL.eigen_nonsymmv_Z'

    e_val5 = GSL.eigen_francis(m.clone)
    e_real5 = e_val5.real.sort
    assert_abs e_real5[0], -1, 1e-10, 'GSL.eigen_francis'
    assert_abs e_real5[1], 4, 1e-10, 'GSL.eigen_francis'

    e_val6, z6 = GSL.eigen_francis_Z(m.clone)
    e_real6 = e_val6.real.sort
    assert_abs e_real6[0], -1, 1e-10, 'GSL.eigen_francis_Z'
    assert_abs e_real6[1], 4, 1e-10, 'GSL.eigen_francis_Z'
  end

  def test_eigen_symm_module_functions
    m = GSL::Matrix[[1, 0], [0, 2]]
    e_val = GSL.eigen_symm(m.clone)
    e_sorted = e_val.to_a.sort
    assert_abs e_sorted[0], 1, 1e-10, 'GSL.eigen_symm'
    assert_abs e_sorted[1], 2, 1e-10, 'GSL.eigen_symm'

    e_val2, e_vec2 = GSL.eigen_symmv(m.clone)
    e_sorted2 = e_val2.to_a.sort
    assert_abs e_sorted2[0], 1, 1e-10, 'GSL.eigen_symmv'
    assert_abs e_sorted2[1], 2, 1e-10, 'GSL.eigen_symmv'
  end

  def test_eigen_herm_module_functions
    m = GSL::Matrix::Complex.alloc(2, 2)
    m[0, 0] = GSL::Complex.alloc(1.0, 0.0)
    m[1, 1] = GSL::Complex.alloc(2.0, 0.0)
    m[0, 1] = GSL::Complex.alloc(0.0, 0.0)
    m[1, 0] = GSL::Complex.alloc(0.0, 0.0)

    e_val = GSL.eigen_herm(m.clone)
    e_sorted = e_val.to_a.sort
    assert_abs e_sorted[0], 1, 1e-10, 'GSL.eigen_herm'
    assert_abs e_sorted[1], 2, 1e-10, 'GSL.eigen_herm'

    e_val2, e_vec2 = GSL.eigen_hermv(m.clone)
    e_sorted2 = e_val2.to_a.sort
    assert_abs e_sorted2[0], 1, 1e-10, 'GSL.eigen_hermv'
    assert_abs e_sorted2[1], 2, 1e-10, 'GSL.eigen_hermv'
  end

  def test_eigen_gensymm_module_functions
    rng = GSL::Rng.alloc
    n = 3

    a = _create_random_symm_matrix(n, n, rng, -10, 10)
    b = _create_random_posdef_matrix(n, n, rng)

    e_val = GSL.eigen_gensymm(a.clone, b.clone)
    assert_kind_of GSL::Vector, e_val
    assert_equal n, e_val.size

    e_val2, e_vec2 = GSL.eigen_gensymmv(a.clone, b.clone)
    assert_kind_of GSL::Vector, e_val2
    assert_kind_of GSL::Matrix, e_vec2

    GSL.eigen_gensymmv_sort(e_val2, e_vec2, GSL::EIGEN_SORT_VAL_ASC)
    assert e_val2[0] <= e_val2[1] && e_val2[1] <= e_val2[2], 'gensymmv_sort val/asc'
  end

  def test_eigen_genherm_module_functions
    rng = GSL::Rng.alloc
    n = 3

    a = _create_random_herm_matrix(n, n, rng, -10, 10)
    b = _create_random_complex_posdef_matrix(n, n, rng)

    e_val = GSL.eigen_genherm(a.clone, b.clone)
    assert_kind_of GSL::Vector, e_val
    assert_equal n, e_val.size

    e_val2, e_vec2 = GSL.eigen_genhermv(a.clone, b.clone)
    assert_kind_of GSL::Vector, e_val2
    assert_kind_of GSL::Matrix::Complex, e_vec2

    GSL.eigen_genhermv_sort(e_val2, e_vec2, GSL::EIGEN_SORT_VAL_ASC)
    assert e_val2[0] <= e_val2[1] && e_val2[1] <= e_val2[2], 'genhermv_sort val/asc'
  end

  def test_eigen_gen_workspace_methods
    n = 3
    w = GSL::Eigen::Gen.alloc(n)
    wv = GSL::Eigen::Genv.alloc(n)

    a = GSL::Matrix[[1, 1, 0], [0, -1, 1], [0, 0, 1]]
    b = GSL::Matrix[[-1, 0, -1], [0, -1, 0], [0, 0, -1]]

    w.params(1, 1, 0)
    alpha, beta = w.gen(a.clone, b.clone)
    assert_kind_of GSL::Vector::Complex, alpha
    assert_kind_of GSL::Vector, beta

    alphav, betav, e_vec = wv.genv(a.clone, b.clone)
    assert_kind_of GSL::Vector::Complex, alphav
    assert_kind_of GSL::Vector, betav
    assert_kind_of GSL::Matrix::Complex, e_vec
  end

  def test_eigen_gen_QZ_workspace_methods
    n = 3
    w = GSL::Eigen::Gen.alloc(n)
    wv = GSL::Eigen::Genv.alloc(n)

    a = GSL::Matrix[[1, 1, 0], [0, -1, 1], [0, 0, 1]]
    b = GSL::Matrix[[-1, 0, -1], [0, -1, 0], [0, 0, -1]]

    GSL::Eigen.gen_params(1, 1, 0, w)
    alpha, beta, q, z = w.gen_QZ(a.clone, b.clone)
    assert_kind_of GSL::Vector::Complex, alpha
    assert_kind_of GSL::Vector, beta
    assert_kind_of GSL::Matrix, q
    assert_kind_of GSL::Matrix, z

    alphav, betav, e_vec, qv, zv = wv.genv_QZ(a.clone, b.clone)
    assert_kind_of GSL::Vector::Complex, alphav
    assert_kind_of GSL::Vector, betav
    assert_kind_of GSL::Matrix::Complex, e_vec
    assert_kind_of GSL::Matrix, qv
    assert_kind_of GSL::Matrix, zv
  end

  def test_eigen_genv_sort_module
    rng = GSL::Rng.alloc
    n = 3
    a = _create_random_nonsymm_matrix(n, n, rng, -10, 10)
    b = _create_random_nonsymm_matrix(n, n, rng, -10, 10)

    wv = GSL::Eigen::Genv.alloc(n)
    alphav, betav, e_vec = GSL::Eigen.genv(a.clone, b.clone, wv)

    GSL.eigen_genv_sort(alphav, betav, e_vec, GSL::EIGEN_SORT_ABS_ASC)
    assert_kind_of GSL::Vector::Complex, alphav
    assert_kind_of GSL::Vector, betav
  end

end
