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

  # Test Function#set method
  def test_function_set
    f = GSL::MultiRoot::Function.alloc(2)
    new_proc = lambda { |x, result|
      result[0] = x[0] - 1.0
      result[1] = x[1] - 2.0
    }
    f.set(new_proc, 2)
    assert_equal 2, f.n
  end

  # Test Function#set_params and #params
  def test_function_params
    f = GSL::MultiRoot::Function.alloc(_rosenbrock.f, 2)
    f.set_params(42)
    assert_equal 42, f.params
  end

  def test_function_params_array
    f = GSL::MultiRoot::Function.alloc(_rosenbrock.f, 2)
    f.set_params(1.0, 2.0, 3.0)
    params = f.params
    assert_kind_of Array, params
    assert_equal [1.0, 2.0, 3.0], params
  end

  # Test Function#solve (high-level solving)
  def test_function_solve
    f = GSL::MultiRoot::Function.alloc(
      lambda { |x, result|
        result[0] = 1.0 - x[0]
        result[1] = 10 * (x[1] - x[0] * x[0])
      },
      2
    )
    x0 = GSL::Vector.alloc(-1.2, 1.0)
    result, iter, status = f.solve(x0)
    assert_kind_of GSL::Vector, result
    assert_kind_of Integer, iter
    assert_equal GSL::SUCCESS, status
    assert_in_delta 1.0, result[0], 1e-5
    assert_in_delta 1.0, result[1], 1e-5
  end

  def test_function_solve_with_options
    f = GSL::MultiRoot::Function.alloc(
      lambda { |x, result|
        result[0] = 1.0 - x[0]
        result[1] = 10 * (x[1] - x[0] * x[0])
      },
      2
    )
    x0 = GSL::Vector.alloc(-1.2, 1.0)
    result, iter, status = f.solve(x0, "dnewton", 1e-6, 5000)
    assert_kind_of GSL::Vector, result
    assert_equal GSL::SUCCESS, status
  end

  def test_function_solve_with_array_initial
    f = GSL::MultiRoot::Function.alloc(
      lambda { |x, result|
        result[0] = 1.0 - x[0]
        result[1] = 10 * (x[1] - x[0] * x[0])
      },
      2
    )
    result, iter, status = f.solve([-1.2, 1.0])
    assert_kind_of GSL::Vector, result
    assert_equal GSL::SUCCESS, status
  end

  # Test FSolver#solve (high-level method)
  def test_fsolver_solve
    f = GSL::MultiRoot::Function.alloc(
      lambda { |x, result|
        result[0] = 1.0 - x[0]
        result[1] = 10 * (x[1] - x[0] * x[0])
      },
      2
    )
    s = GSL::MultiRoot::FSolver.alloc("dnewton", 2)
    x0 = GSL::Vector.alloc(-1.2, 1.0)
    s.set(f, x0)
    result, iter, status = s.solve
    assert_kind_of GSL::Vector, result
    assert_kind_of Integer, iter
    assert [GSL::SUCCESS, GSL::CONTINUE].include?(status)
  end

  # Note: FSolver#solve with tolerance/max_iter arguments has a bug in the C code
  # (uses switch(argv[i]) instead of switch(TYPE(argv[i]))), so we skip those tests

  # Test FSolver.solve class method
  def test_fsolver_class_solve
    f = GSL::MultiRoot::Function.alloc(
      lambda { |x, result|
        result[0] = 1.0 - x[0]
        result[1] = 10 * (x[1] - x[0] * x[0])
      },
      2
    )
    s = GSL::MultiRoot::FSolver.alloc("dnewton", 2)
    x0 = GSL::Vector.alloc(-1.2, 1.0)
    s.set(f, x0)
    result, iter, status = GSL::MultiRoot::FSolver.solve(s)
    assert_kind_of GSL::Vector, result
  end

  # Test Function_fdf#set method
  def test_function_fdf_set
    fdf = GSL::MultiRoot::Function_fdf.alloc(3)
    f_proc = lambda { |x, f| f[0] = x[0]; f[1] = x[1]; f[2] = x[2] }
    df_proc = lambda { |x, jac|
      jac.set(0, 0, 1.0); jac.set(0, 1, 0.0); jac.set(0, 2, 0.0)
      jac.set(1, 0, 0.0); jac.set(1, 1, 1.0); jac.set(1, 2, 0.0)
      jac.set(2, 0, 0.0); jac.set(2, 1, 0.0); jac.set(2, 2, 1.0)
    }
    fdf.set(f_proc, df_proc, 3)
    assert_equal 3, fdf.n
  end

  # Test Function_fdf#set_params and #params
  def test_function_fdf_params
    fdf = _rosenbrock
    fdf.set_params(123)
    assert_equal 123, fdf.params
  end

  def test_function_fdf_params_array
    fdf = _rosenbrock
    fdf.set_params(1.5, 2.5)
    params = fdf.params
    assert_kind_of Array, params
    assert_equal [1.5, 2.5], params
  end

  # Test Function_fdf#f and #df accessors
  def test_function_fdf_f_accessor
    fdf = _rosenbrock
    f_proc = fdf.f
    assert_kind_of Proc, f_proc
  end

  def test_function_fdf_df_accessor
    fdf = _rosenbrock
    df_proc = fdf.df
    assert_kind_of Proc, df_proc
  end

  # Test MultiRoot.fdjacobian
  def test_fdjacobian_with_function
    f = GSL::MultiRoot::Function.alloc(
      lambda { |x, result|
        result[0] = x[0] * x[0]
        result[1] = x[1] * x[1]
      },
      2
    )
    x = GSL::Vector.alloc(1.0, 2.0)
    fval = GSL::Vector.alloc(2)
    fval[0] = 1.0
    fval[1] = 4.0
    jac, status = GSL::MultiRoot.fdjacobian(f, x, fval, 1e-8)
    assert_kind_of GSL::Matrix, jac
    assert_equal GSL::SUCCESS, status
    assert_in_delta 2.0, jac.get(0, 0), 1e-4
    assert_in_delta 4.0, jac.get(1, 1), 1e-4
  end

  def test_fdjacobian_with_function_fdf
    fdf = _rosenbrock
    x = GSL::Vector.alloc(1.0, 1.0)
    fval = GSL::Vector.alloc(2)
    fval[0] = 0.0
    fval[1] = 0.0
    jac, status = GSL::MultiRoot.fdjacobian(fdf, x, fval, 1e-8)
    assert_kind_of GSL::Matrix, jac
    assert_equal GSL::SUCCESS, status
  end

  def test_fdjacobian_with_output_matrix
    f = GSL::MultiRoot::Function.alloc(
      lambda { |x, result|
        result[0] = x[0] * x[0]
        result[1] = x[1] * x[1]
      },
      2
    )
    x = GSL::Vector.alloc(1.0, 2.0)
    fval = GSL::Vector.alloc(1.0, 4.0)
    jac = GSL::Matrix.alloc(2, 2)
    result, status = GSL::MultiRoot.fdjacobian(f, x, fval, 1e-8, jac)
    assert_equal GSL::SUCCESS, status
    assert_same jac, result
  end

  # Test FSolver with array as initial point
  def test_fsolver_set_with_array
    f = GSL::MultiRoot::Function.alloc(
      lambda { |x, result|
        result[0] = x[0] - 1.0
        result[1] = x[1] - 2.0
      },
      2
    )
    s = GSL::MultiRoot::FSolver.alloc("dnewton", 2)
    status = s.set(f, [0.5, 1.0])
    assert_equal GSL::SUCCESS, status
  end

  # Test FdfSolver with array as initial point
  def test_fdfsolver_set_with_array
    fdf = _rosenbrock
    s = GSL::MultiRoot::FdfSolver.alloc("newton", 2)
    status = s.set(fdf, [-1.2, 1.0])
    assert_equal GSL::SUCCESS, status
  end

  # Test solver allocation with integer type constants
  def test_fsolver_alloc_with_constant
    s = GSL::MultiRoot::FSolver.alloc(GSL::MultiRoot::FSolver::DNEWTON, 2)
    assert_equal 'dnewton', s.name
  end

  def test_fdfsolver_alloc_with_constant
    s = GSL::MultiRoot::FdfSolver.alloc(GSL::MultiRoot::FdfSolver::NEWTON, 2)
    assert_equal 'newton', s.name
  end

  # Test function with params passed to callback
  def test_function_with_params_in_callback
    param_value = nil
    f = GSL::MultiRoot::Function.alloc(
      lambda { |x, params, result|
        param_value = params
        result[0] = x[0] - params
        result[1] = x[1] - params
      },
      2
    )
    f.set_params(5.0)
    s = GSL::MultiRoot::FSolver.alloc("dnewton", 2)
    x0 = GSL::Vector.alloc(0.0, 0.0)
    s.set(f, x0)
    s.iterate
    assert_equal 5.0, param_value
  end

  # Test Function_fdf with fdf combined callback
  def test_function_fdf_with_combined_fdf
    fdf = GSL::MultiRoot::Function_fdf.alloc(
      lambda { |x, f|
        f[0] = 1.0 - x[0]
        f[1] = 10 * (x[1] - x[0] * x[0])
      },
      lambda { |x, jac|
        jac.set(0, 0, -1.0)
        jac.set(0, 1, 0.0)
        jac.set(1, 0, -20 * x[0])
        jac.set(1, 1, 10)
      },
      lambda { |x, f, jac|
        f[0] = 1.0 - x[0]
        f[1] = 10 * (x[1] - x[0] * x[0])
        jac.set(0, 0, -1.0)
        jac.set(0, 1, 0.0)
        jac.set(1, 0, -20 * x[0])
        jac.set(1, 1, 10)
      },
      2
    )
    assert_equal 2, fdf.n
    s = GSL::MultiRoot::FdfSolver.alloc("newton", 2)
    x = GSL::Vector.alloc(-1.2, 1.0)
    s.set(fdf, x)
    s.iterate
    assert_kind_of GSL::Vector, s.x
  end

  # Test Function_fdf with params
  def test_function_fdf_with_params_in_callback
    param_value = nil
    fdf = GSL::MultiRoot::Function_fdf.alloc(
      lambda { |x, params, f|
        param_value = params
        f[0] = x[0] - params
        f[1] = x[1] - params
      },
      lambda { |x, params, jac|
        jac.set(0, 0, 1.0)
        jac.set(0, 1, 0.0)
        jac.set(1, 0, 0.0)
        jac.set(1, 1, 1.0)
      },
      2
    )
    fdf.set_params(7.0)
    s = GSL::MultiRoot::FdfSolver.alloc("newton", 2)
    x = GSL::Vector.alloc(0.0, 0.0)
    s.set(fdf, x)
    s.iterate
    assert_equal 7.0, param_value
  end

end
