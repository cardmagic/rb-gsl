require 'test_helper'

class MultiRootTest < GSL::TestCase

  def _test_fdf(desc, fdf, x, factor, type)
    n = fdf.n
    x = x.scale(factor) if factor != 1.0

    s = GSL::MultiRoot::FdfSolver.alloc(type, n)
    s.set(fdf, x)

    status = iter = 0

    1000.times {
      s.iterate

      status = GSL::MultiRoot.test_residual(s.f, 0.0000001)
      break if status != GSL::CONTINUE
    }

    # Just check that we can access the jacobian
    jac = s.jac
    assert_kind_of GSL::Matrix, jac

    residual = 0.0
    n.times { |i| residual += s.f[i].abs }

    assert status.zero?, "#{type} on #{desc} (#{factor}), iter iterations, residual = #{residual}"
  end

  def _test_f(desc, fdf, x, factor, type)
    n = fdf.n
    x = x.scale(factor)

    function = GSL::MultiRoot::Function.alloc(fdf.f, n)

    s = GSL::MultiRoot::FSolver.alloc(type, n)
    s.set(function, x)

    status = iter = 0

    1000.times {
      s.iterate

      status = GSL::MultiRoot.test_residual(s.f,  0.0000001)
      break if status != GSL::CONTINUE
    }

    residual = 0.0
    n.times { |i| residual += s.f[i].abs }

    assert status.zero?, "#{type} on #{desc} (#{factor}), #{iter} iterations, residual = #{residual}"
  end

  def _roth_initpt
    GSL::Vector.alloc(4.5, 3.5)
  end

  def _wood_initpt
    GSL::Vector.alloc(-3.0, -1.0, -3.0, -1.0)
  end

  def _rosenbrock_initpt
    GSL::Vector.alloc(-1.2, 1.0)
  end

  def _roth
    GSL::MultiRoot::Function_fdf.alloc(lambda { |x, f|
      u = x[0]
      v = x[1]
      f[0] = -13.0 + u + ((5.0 - v) * v - 2.0) * v;
      f[1] = -29.0 + u + ((v + 1.0) * v - 14.0) * v;
    }, lambda { |x, df|
      x1 = x[1]
      df.set(0, 0, 1.0)
      df.set(0, 1, -3 * x1 * x1 + 10 * x1 - 2)
      df.set(1, 0, 1.0)
      df.set(1, 1, 3 * x1 * x1 + 2 * x1 - 14)
    }, 2)
  end

  def _rosenbrock
    GSL::MultiRoot::Function_fdf.alloc(lambda { |x, f|
      x0 = x[0]
      x1 = x[1]
      y0 = 1.0 - x0
      y1 = 10 * (x1 - x0 * x0)
      f[0] = y0
      f[1] = y1
      GSL::SUCCESS
    }, lambda { |x, df|
      x0 = x[0]
      df00 = -1.0
      df01 = 0.0
      df10 = -20 * x0
      df11 = 10
      df.set(0, 0, df00)
      df.set(0, 1, df01)
      df.set(1, 0, df10)
      df.set(1, 1, df11)
      GSL::SUCCESS
    }, 2)
  end

  %w[dnewton broyden hybrid hybrids].each { |type|
    define_method("test_f_roth_#{type}") {
      _test_f('Roth', _roth, _roth_initpt, 1.0, type)
    }

    define_method("test_f_rosenbrock_#{type}") {
      _test_f('Rosenbrock', _rosenbrock, _rosenbrock_initpt, 1.0, type)
    }
  }

  %w[newton gnewton hybridj hybridsj].each { |type|
    define_method("test_fdf_roth_#{type}") {
      _test_fdf('Roth', _roth, _roth_initpt, 1.0, type)
    }
  }

  # Test FSolver methods
  def test_fsolver_name
    s = GSL::MultiRoot::FSolver.alloc('dnewton', 2)
    assert_equal 'dnewton', s.name
  end

  def test_fsolver_x
    function = GSL::MultiRoot::Function.alloc(_rosenbrock.f, 2)
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FSolver.alloc('dnewton', 2)
    s.set(function, x)
    s.iterate
    result_x = s.x
    assert_kind_of GSL::Vector, result_x
    assert_equal 2, result_x.size
  end

  def test_fsolver_root
    function = GSL::MultiRoot::Function.alloc(_rosenbrock.f, 2)
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FSolver.alloc('dnewton', 2)
    s.set(function, x)
    s.iterate
    root = s.root
    assert_kind_of GSL::Vector, root
    assert_equal 2, root.size
  end

  def test_fsolver_dx
    function = GSL::MultiRoot::Function.alloc(_rosenbrock.f, 2)
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FSolver.alloc('dnewton', 2)
    s.set(function, x)
    s.iterate
    dx = s.dx
    assert_kind_of GSL::Vector, dx
    assert_equal 2, dx.size
  end

  def test_fsolver_f
    function = GSL::MultiRoot::Function.alloc(_rosenbrock.f, 2)
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FSolver.alloc('dnewton', 2)
    s.set(function, x)
    s.iterate
    f = s.f
    assert_kind_of GSL::Vector, f
    assert_equal 2, f.size
  end

  def test_fsolver_test_delta
    function = GSL::MultiRoot::Function.alloc(_rosenbrock.f, 2)
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FSolver.alloc('dnewton', 2)
    s.set(function, x)
    s.iterate
    status = s.test_delta(1e-7, 0.0)
    assert [GSL::SUCCESS, GSL::CONTINUE].include?(status)
  end

  def test_fsolver_test_residual
    function = GSL::MultiRoot::Function.alloc(_rosenbrock.f, 2)
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FSolver.alloc('dnewton', 2)
    s.set(function, x)
    s.iterate
    status = s.test_residual(1e-7)
    assert [GSL::SUCCESS, GSL::CONTINUE].include?(status)
  end

  # Test FdfSolver methods
  def test_fdfsolver_name
    s = GSL::MultiRoot::FdfSolver.alloc('newton', 2)
    assert_equal 'newton', s.name
  end

  def test_fdfsolver_x
    fdf = _rosenbrock
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FdfSolver.alloc('newton', 2)
    s.set(fdf, x)
    s.iterate
    result_x = s.x
    assert_kind_of GSL::Vector, result_x
    assert_equal 2, result_x.size
  end

  def test_fdfsolver_root
    fdf = _rosenbrock
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FdfSolver.alloc('newton', 2)
    s.set(fdf, x)
    s.iterate
    root = s.root
    assert_kind_of GSL::Vector, root
    assert_equal 2, root.size
  end

  def test_fdfsolver_dx
    fdf = _rosenbrock
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FdfSolver.alloc('newton', 2)
    s.set(fdf, x)
    s.iterate
    dx = s.dx
    assert_kind_of GSL::Vector, dx
    assert_equal 2, dx.size
  end

  def test_fdfsolver_f
    fdf = _rosenbrock
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FdfSolver.alloc('newton', 2)
    s.set(fdf, x)
    s.iterate
    f = s.f
    assert_kind_of GSL::Vector, f
    assert_equal 2, f.size
  end

  def test_fdfsolver_jac
    fdf = _rosenbrock
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FdfSolver.alloc('newton', 2)
    s.set(fdf, x)
    s.iterate
    jac = s.jac
    assert_kind_of GSL::Matrix, jac
    assert_equal [2, 2], [jac.size1, jac.size2]
  end

  def test_fdfsolver_test_delta
    fdf = _rosenbrock
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FdfSolver.alloc('newton', 2)
    s.set(fdf, x)
    s.iterate
    status = s.test_delta(1e-7, 0.0)
    assert [GSL::SUCCESS, GSL::CONTINUE].include?(status)
  end

  def test_fdfsolver_test_residual
    fdf = _rosenbrock
    x = _rosenbrock_initpt
    s = GSL::MultiRoot::FdfSolver.alloc('newton', 2)
    s.set(fdf, x)
    s.iterate
    status = s.test_residual(1e-7)
    assert [GSL::SUCCESS, GSL::CONTINUE].include?(status)
  end

  # Test Function methods
  def test_function_n
    f = GSL::MultiRoot::Function.alloc(_rosenbrock.f, 2)
    assert_equal 2, f.n
  end

  def test_function_eval
    f = GSL::MultiRoot::Function.alloc(_rosenbrock.f, 2)
    x = GSL::Vector.alloc(1.0, 1.0)
    result = f.eval(x)
    assert_kind_of GSL::Vector, result
    assert_in_delta 0.0, result[0], 1e-10
    assert_in_delta 0.0, result[1], 1e-10
  end

  # Test Function_fdf methods
  def test_function_fdf_n
    fdf = _rosenbrock
    assert_equal 2, fdf.n
  end

  # Test solver type selection
  def test_fsolver_types
    types = %w[dnewton broyden hybrid hybrids]
    types.each do |type|
      s = GSL::MultiRoot::FSolver.alloc(type, 2)
      assert_equal type, s.name
    end
  end

  def test_fdfsolver_types
    types = %w[newton gnewton hybridj hybridsj]
    types.each do |type|
      s = GSL::MultiRoot::FdfSolver.alloc(type, 2)
      assert_equal type, s.name
    end
  end

  # Test module-level functions
  def test_multiroot_test_delta
    dx = GSL::Vector.alloc(0.0001, 0.0001)
    x = GSL::Vector.alloc(1.0, 1.0)
    status = GSL::MultiRoot.test_delta(dx, x, 1e-3, 1e-3)
    assert_equal GSL::SUCCESS, status
  end

  def test_multiroot_test_residual
    f = GSL::Vector.alloc(0.0, 0.0)
    status = GSL::MultiRoot.test_residual(f, 1e-7)
    assert_equal GSL::SUCCESS, status
  end

end
