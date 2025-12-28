require 'test_helper'

class MultiMinTest < GSL::TestCase

  def _test_fdf(desc, f, x, type)
    s = GSL::MultiMin::FdfMinimizer.alloc(type, f.n)
    s.set(f, x, 0.1 * GSL::Blas.dnrm2(x), 0.1)

    status = iter = 0

    begin
      iter += 1
      s.iterate

      status = GSL::MultiMin.test_gradient(s.gradient, 1e-3)
    end while iter < 5000 and status == GSL::CONTINUE

    status |= s.f.abs > 1e-5 ? 1 : 0
    assert status.zero?, "#{s.name}, on #{desc}: #{iter} iterations, f(x)=#{s.f}"
  end

  def _test_f(desc, f, x)
    step_size = GSL::Vector.alloc(f.n)
    f.n.times { |i| step_size[i] = 1 }

    s = GSL::MultiMin::FMinimizer.alloc('nmsimplex', f.n)
    s.set(f, x, step_size)

    status = iter = 0

    begin
      s.iterate
      status = GSL::MultiMin.test_size(s.size, 1e-3)
    end while iter < 5000 and status == GSL::CONTINUE

    status |= s.fval.abs > 1e-5 ? 1 : 0
    assert status.zero?, "#{s.name}, on #{desc}: #{iter} iterations, f(x)=#{s.fval}"

    s = GSL::MultiMin::FMinimizer.alloc('nmsimplex2rand', f.n)
    s.set(f, x, step_size)

    status = iter = 0

    begin
      s.iterate
      status = GSL::MultiMin.test_size(s.size, 1e-3)
    end while iter < 5000 and status == GSL::CONTINUE

    status |= s.fval.abs > 1e-5 ? 1 : 0
    assert status.zero?, "#{s.name}, on #{desc}: #{iter} iterations, f(x)=#{s.fval}"
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

  def _roth_f
    lambda { |x|
      u = x[0]
      v = x[1]
      a = -13.0 + u + ((5.0 - v) * v - 2.0) * v;
      b = -29.0 + u + ((v + 1.0) * v - 14.0) * v;
      a * a + b * b;
    }
  end

  def _wood_f
    lambda { |x|
      u1 = x[0]
      u2 = x[1]
      u3 = x[2]
      u4 = x[3]
      t1 = u1 * u1 - u2
      t2 = u3 * u3 - u4
      100 * t1 * t1 + (1 - u1) * (1 - u1) + 90 * t2 * t2 + (1 - u3) * (1 - u3) + 10.1 * ((1 - u2) * (1 - u2) + (1 - u4) * (1 - u4)) + 19.8 * (1 - u2) * (1 - u4)
    }
  end

  def _rosenbrock_f
    lambda { |x|
      u = x[0]
      v = x[1]
      a = u - 1
      b = u * u - v
      a * a + 10.0 * b * b
    }
  end

  def _rothdf
    GSL::MultiMin::Function_fdf.alloc(_roth_f, lambda { |x, df|
      u = x[0]
      v = x[1]
      a = -13.0 + u + ((5.0 - v) * v - 2.0) * v
      b = -29.0 + u + ((v + 1.0) * v - 14.0) * v
      c = -2 + v * (10 - 3 * v)
      d = -14 + v * (2 + 3 * v)
      df[0] = 2 * a + 2 * b
      df[1] = 2 * a * c + 2 * b * d
    }, 2)
  end

  def _wooddf
    GSL::MultiMin::Function_fdf.alloc(_wood_f, lambda { |x, df|
      u1 = x[0]
      u2 = x[1]
      u3 = x[2]
      u4 = x[3]
      t1 = u1 * u1 - u2
      t2 = u3 * u3 - u4
      df[0] = 400 * u1 * t1 - 2 * (1 - u1)
      df[1] = -200 * t1 - 20.2 * (1 - u2) - 19.8 * (1 - u4)
      df[2] = 360 * u3 * t2 - 2 * (1 - u3)
      df[3] = -180 * t2 - 20.2 * (1 - u4) - 19.8 * (1 - u2)
    }, 4)
  end

  def _rosenbrockdf
    GSL::MultiMin::Function_fdf.alloc(_rosenbrock_f, lambda { |x, df|
      u = x[0]
      v = x[1]
      a = u - 1
      b = u * u - v
      df[0] = 2 * a + 40 * u * b
      df[1] = -20 * b
    }, 2)
  end

  fdfminimizers = %w[steepest_descent conjugate_pr conjugate_fr vector_bfgs]
  fdfminimizers << 'vector_bfgs2' if GSL::GSL_VERSION >= '1.8.90'

  fdfminimizers.each { |type|
    define_method("test_fdf_roth_#{type}") { _test_fdf('Roth', _rothdf, _roth_initpt, type) }
    define_method("test_fdf_wood_#{type}") { _test_fdf('Wood', _wooddf, _wood_initpt, type) }
    define_method("test_fdf_rosenbrock_#{type}") { _test_fdf('Rosenbrock', _rosenbrockdf, _rosenbrock_initpt, type) }
  }

  def test_f_roth
    _test_f('Roth', GSL::MultiMin::Function.alloc(_roth_f, 2), _roth_initpt)
  end

  def test_f_wood
    _test_f('Wood', GSL::MultiMin::Function.alloc(_wood_f, 4), _wood_initpt)
  end

  def test_f_rosenbrock
    _test_f('Rosenbrock', GSL::MultiMin::Function.alloc(_rosenbrock_f, 2), _rosenbrock_initpt)
  end

  # Test Function methods
  def test_function_n
    f = GSL::MultiMin::Function.alloc(_rosenbrock_f, 2)
    assert_equal 2, f.n
  end

  def test_function_eval
    f = GSL::MultiMin::Function.alloc(_rosenbrock_f, 2)
    x = GSL::Vector.alloc(1.0, 1.0)
    result = f.eval(x)
    assert_in_delta 0.0, result, 1e-10
  end

  def test_function_call_alias
    f = GSL::MultiMin::Function.alloc(_rosenbrock_f, 2)
    x = GSL::Vector.alloc(-1.2, 1.0)
    result = f.call(x)
    assert result > 0
  end

  def test_function_set_proc
    f = GSL::MultiMin::Function.alloc(2)
    f.set_proc(_rosenbrock_f)
    x = GSL::Vector.alloc(1.0, 1.0)
    result = f.eval(x)
    assert_in_delta 0.0, result, 1e-10
  end

  def test_function_set_params
    func_with_params = lambda { |x, params|
      scale = params[0]
      x[0]**2 * scale + x[1]**2 * scale
    }
    f = GSL::MultiMin::Function.alloc(func_with_params, 2)
    f.set_params([2.0])
    x = GSL::Vector.alloc(1.0, 1.0)
    result = f.eval(x)
    assert_in_delta 4.0, result, 1e-10
  end

  def test_function_params
    func_with_params = lambda { |x, params|
      params[0] * x[0]**2
    }
    f = GSL::MultiMin::Function.alloc(func_with_params, 2)
    f.set_params([3.0])
    assert_equal [3.0], f.params
  end

  # Test Function_fdf methods
  def test_function_fdf_n
    fdf = _rosenbrockdf
    assert_equal 2, fdf.n
  end

  def test_function_fdf_set
    fdf = GSL::MultiMin::Function_fdf.alloc(1)
    fdf.set(_rosenbrock_f, lambda { |x, df|
      df[0] = 2 * (x[0] - 1) + 40 * x[0] * (x[0]**2 - x[1])
      df[1] = -20 * (x[0]**2 - x[1])
    }, 2)
    assert_equal 2, fdf.n
  end

  def test_function_fdf_set_procs
    fdf = GSL::MultiMin::Function_fdf.alloc(2)
    fdf.set_procs(_rosenbrock_f, lambda { |x, df|
      df[0] = 2 * (x[0] - 1) + 40 * x[0] * (x[0]**2 - x[1])
      df[1] = -20 * (x[0]**2 - x[1])
    })
    assert_equal 2, fdf.n
  end

  def test_function_fdf_set_params
    fdf = _rosenbrockdf
    fdf.set_params([1.0, 2.0])
    assert_equal [1.0, 2.0], fdf.params
  end

  def test_function_fdf_params
    fdf = _rosenbrockdf
    assert_nil fdf.params
  end

  # Test FdfMinimizer methods
  def test_fdfminimizer_name
    s = GSL::MultiMin::FdfMinimizer.alloc('steepest_descent', 2)
    assert_equal 'steepest_descent', s.name
  end

  def test_fdfminimizer_x
    fdf = _rosenbrockdf
    x = _rosenbrock_initpt
    s = GSL::MultiMin::FdfMinimizer.alloc('steepest_descent', 2)
    s.set(fdf, x, 0.01, 0.1)
    s.iterate
    result_x = s.x
    assert_kind_of GSL::Vector, result_x
    assert_equal 2, result_x.size
  end

  def test_fdfminimizer_f
    fdf = _rosenbrockdf
    x = _rosenbrock_initpt
    s = GSL::MultiMin::FdfMinimizer.alloc('steepest_descent', 2)
    s.set(fdf, x, 0.01, 0.1)
    s.iterate
    f_val = s.f
    assert_kind_of Float, f_val
  end

  def test_fdfminimizer_gradient
    fdf = _rosenbrockdf
    x = _rosenbrock_initpt
    s = GSL::MultiMin::FdfMinimizer.alloc('steepest_descent', 2)
    s.set(fdf, x, 0.01, 0.1)
    s.iterate
    grad = s.gradient
    assert_kind_of GSL::Vector, grad
    assert_equal 2, grad.size
  end

  def test_fdfminimizer_minimum
    fdf = _rosenbrockdf
    x = _rosenbrock_initpt
    s = GSL::MultiMin::FdfMinimizer.alloc('steepest_descent', 2)
    s.set(fdf, x, 0.01, 0.1)
    s.iterate
    min = s.minimum
    assert_kind_of Float, min
  end

  def test_fdfminimizer_restart
    fdf = _rosenbrockdf
    x = _rosenbrock_initpt
    s = GSL::MultiMin::FdfMinimizer.alloc('steepest_descent', 2)
    s.set(fdf, x, 0.01, 0.1)
    s.iterate
    status = s.restart
    assert_equal 0, status
  end

  def test_fdfminimizer_test_gradient
    fdf = _rosenbrockdf
    x = GSL::Vector.alloc(1.0, 1.0)  # At minimum
    s = GSL::MultiMin::FdfMinimizer.alloc('steepest_descent', 2)
    s.set(fdf, x, 0.01, 0.1)
    status = s.test_gradient(1e-3)
    assert_equal 0, status  # GSL_SUCCESS at minimum
  end

  # Test FMinimizer methods
  def test_fminimizer_name
    s = GSL::MultiMin::FMinimizer.alloc('nmsimplex', 2)
    assert_equal 'nmsimplex', s.name
  end

  def test_fminimizer_x
    f = GSL::MultiMin::Function.alloc(_rosenbrock_f, 2)
    x = _rosenbrock_initpt
    step_size = GSL::Vector.alloc(1, 1)
    s = GSL::MultiMin::FMinimizer.alloc('nmsimplex', 2)
    s.set(f, x, step_size)
    s.iterate
    result_x = s.x
    assert_kind_of GSL::Vector, result_x
    assert_equal 2, result_x.size
  end

  def test_fminimizer_minimum
    f = GSL::MultiMin::Function.alloc(_rosenbrock_f, 2)
    x = _rosenbrock_initpt
    step_size = GSL::Vector.alloc(1, 1)
    s = GSL::MultiMin::FMinimizer.alloc('nmsimplex', 2)
    s.set(f, x, step_size)
    s.iterate
    min = s.minimum
    assert_kind_of Float, min
  end

  def test_fminimizer_size
    f = GSL::MultiMin::Function.alloc(_rosenbrock_f, 2)
    x = _rosenbrock_initpt
    step_size = GSL::Vector.alloc(1, 1)
    s = GSL::MultiMin::FMinimizer.alloc('nmsimplex', 2)
    s.set(f, x, step_size)
    s.iterate
    size = s.size
    assert_kind_of Float, size
    assert size > 0
  end

  def test_fminimizer_fval
    f = GSL::MultiMin::Function.alloc(_rosenbrock_f, 2)
    x = _rosenbrock_initpt
    step_size = GSL::Vector.alloc(1, 1)
    s = GSL::MultiMin::FMinimizer.alloc('nmsimplex', 2)
    s.set(f, x, step_size)
    s.iterate
    fval = s.fval
    assert_kind_of Float, fval
  end

  def test_fminimizer_test_size
    f = GSL::MultiMin::Function.alloc(_rosenbrock_f, 2)
    x = _rosenbrock_initpt
    step_size = GSL::Vector.alloc(1, 1)
    s = GSL::MultiMin::FMinimizer.alloc('nmsimplex', 2)
    s.set(f, x, step_size)
    10.times { s.iterate }
    status = s.test_size(1e-1)
    assert [GSL::SUCCESS, GSL::CONTINUE].include?(status)
  end

  # Test minimizer type selection
  def test_fdfminimizer_types
    types = %w[steepest_descent conjugate_pr conjugate_fr vector_bfgs vector_bfgs2]
    types.each do |type|
      s = GSL::MultiMin::FdfMinimizer.alloc(type, 2)
      assert_equal type, s.name
    end
  end

  def test_fminimizer_types
    types = %w[nmsimplex nmsimplex2rand]
    types.each do |type|
      s = GSL::MultiMin::FMinimizer.alloc(type, 2)
      assert_match type, s.name
    end
  end

  # Test type constants
  def test_fdfminimizer_type_constants
    s = GSL::MultiMin::FdfMinimizer.alloc(GSL::MultiMin::FdfMinimizer::STEEPEST_DESCENT, 2)
    assert_equal 'steepest_descent', s.name
  end

  def test_fminimizer_type_constants
    s = GSL::MultiMin::FMinimizer.alloc(GSL::MultiMin::FMinimizer::NMSIMPLEX, 2)
    assert_equal 'nmsimplex', s.name
  end

end
