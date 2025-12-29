require 'test_helper'

class RootCoverageTest < GSL::TestCase
  # =====================================================
  # FSolver constructor tests
  # =====================================================

  def test_fsolver_alloc_with_string_bisection
    s = GSL::Root::FSolver.alloc("bisection")
    assert_equal "bisection", s.name
  end

  def test_fsolver_alloc_with_string_falsepos
    s = GSL::Root::FSolver.alloc("falsepos")
    assert_equal "falsepos", s.name
  end

  def test_fsolver_alloc_with_string_brent
    s = GSL::Root::FSolver.alloc("brent")
    assert_equal "brent", s.name
  end

  def test_fsolver_alloc_with_fixnum_bisection
    s = GSL::Root::FSolver.alloc(GSL::Root::FSolver::BISECTION)
    assert_equal "bisection", s.name
  end

  def test_fsolver_alloc_with_fixnum_falsepos
    s = GSL::Root::FSolver.alloc(GSL::Root::FSolver::FALSEPOS)
    assert_equal "falsepos", s.name
  end

  def test_fsolver_alloc_with_fixnum_brent
    s = GSL::Root::FSolver.alloc(GSL::Root::FSolver::BRENT)
    assert_equal "brent", s.name
  end

  def test_fsolver_alloc_with_invalid_string
    assert_raises(TypeError) do
      GSL::Root::FSolver.alloc("invalid")
    end
  end

  def test_fsolver_alloc_with_invalid_fixnum
    assert_raises(TypeError) do
      GSL::Root::FSolver.alloc(999)
    end
  end

  def test_fsolver_alloc_with_wrong_type
    assert_raises(TypeError) do
      GSL::Root::FSolver.alloc([1, 2, 3])
    end
  end

  # =====================================================
  # FdfSolver constructor tests
  # =====================================================

  def test_fdfsolver_alloc_with_string_newton
    s = GSL::Root::FdfSolver.alloc("newton")
    assert_equal "newton", s.name
  end

  def test_fdfsolver_alloc_with_string_secant
    s = GSL::Root::FdfSolver.alloc("secant")
    assert_equal "secant", s.name
  end

  def test_fdfsolver_alloc_with_string_steffenson
    s = GSL::Root::FdfSolver.alloc("steffenson")
    assert_equal "steffenson", s.name
  end

  def test_fdfsolver_alloc_with_fixnum_newton
    s = GSL::Root::FdfSolver.alloc(GSL::Root::FdfSolver::NEWTON)
    assert_equal "newton", s.name
  end

  def test_fdfsolver_alloc_with_fixnum_secant
    s = GSL::Root::FdfSolver.alloc(GSL::Root::FdfSolver::SECANT)
    assert_equal "secant", s.name
  end

  def test_fdfsolver_alloc_with_fixnum_steffenson
    s = GSL::Root::FdfSolver.alloc(GSL::Root::FdfSolver::STEFFENSON)
    assert_equal "steffenson", s.name
  end

  def test_fdfsolver_alloc_with_invalid_string
    assert_raises(TypeError) do
      GSL::Root::FdfSolver.alloc("invalid")
    end
  end

  def test_fdfsolver_alloc_with_invalid_fixnum
    assert_raises(TypeError) do
      GSL::Root::FdfSolver.alloc(999)
    end
  end

  def test_fdfsolver_alloc_with_wrong_type
    assert_raises(TypeError) do
      GSL::Root::FdfSolver.alloc({})
    end
  end

  # =====================================================
  # FSolver method tests
  # =====================================================

  def test_fsolver_set_and_iterate
    f = GSL::Function.alloc { |x| x * x - 2 }
    s = GSL::Root::FSolver.alloc("brent")
    s.set(f, 0.0, 2.0)

    status = s.iterate
    assert_kind_of Integer, status

    root = s.root
    assert_in_delta 1.414, root, 0.5  # Close to sqrt(2)
  end

  def test_fsolver_x_lower_and_x_upper
    f = GSL::Function.alloc { |x| x * x - 2 }
    s = GSL::Root::FSolver.alloc("brent")
    s.set(f, 0.0, 2.0)
    s.iterate

    xl = s.x_lower
    xu = s.x_upper
    assert xl <= xu
    assert xl >= 0.0
    assert xu <= 2.0
  end

  def test_fsolver_test_interval
    f = GSL::Function.alloc { |x| x * x - 2 }
    s = GSL::Root::FSolver.alloc("brent")
    s.set(f, 1.0, 2.0)

    # Iterate until close enough
    10.times { s.iterate }

    status = s.test_interval(1e-10, 0.0)
    assert_kind_of Integer, status
  end

  def test_fsolver_solve_with_two_args
    f = GSL::Function.alloc { |x| x * x - 2 }
    s = GSL::Root::FSolver.alloc("brent")

    result = s.solve(f, [1.0, 2.0])
    assert_kind_of Array, result
    assert_equal 3, result.size

    root, iterations, status = result
    assert_in_delta 1.41421356, root, 1e-5
    assert iterations > 0
    assert status == GSL::SUCCESS
  end

  def test_fsolver_solve_with_three_args
    f = GSL::Function.alloc { |x| x * x - 2 }
    s = GSL::Root::FSolver.alloc("brent")

    result = s.solve(f, [1.0, 2.0], [1e-10, 1e-10])
    assert_kind_of Array, result
    assert_equal 3, result.size

    root, iterations, status = result
    assert_in_delta 1.41421356, root, 1e-6
  end

  def test_fsolver_solve_wrong_args
    f = GSL::Function.alloc { |x| x * x - 2 }
    s = GSL::Root::FSolver.alloc("brent")

    assert_raises(ArgumentError) do
      s.solve(f)  # Too few arguments
    end
  end

  # =====================================================
  # FdfSolver method tests
  # =====================================================

  def test_fdfsolver_set_and_iterate
    f = lambda { |x| x * x - 2 }
    df = lambda { |x| 2 * x }
    fdf = GSL::Function_fdf.alloc(f, df)

    s = GSL::Root::FdfSolver.alloc("newton")
    s.set(fdf, 5.0)

    status = s.iterate
    assert_kind_of Integer, status

    root = s.root
    # After one Newton iteration from 5: x - (x^2-2)/(2x) = 5 - 23/10 = 2.7
    assert_in_delta 2.7, root, 0.1
  end

  def test_fdfsolver_converges
    f = lambda { |x| x * x - 2 }
    df = lambda { |x| 2 * x }
    fdf = GSL::Function_fdf.alloc(f, df)

    s = GSL::Root::FdfSolver.alloc("newton")
    s.set(fdf, 1.5)

    20.times { s.iterate }

    root = s.root
    assert_in_delta 1.41421356, root, 1e-8
  end

  def test_fdfsolver_solve_with_two_args
    f = lambda { |x| x * x - 2 }
    df = lambda { |x| 2 * x }
    fdf = GSL::Function_fdf.alloc(f, df)

    s = GSL::Root::FdfSolver.alloc("newton")
    result = s.solve(fdf, 1.5)

    assert_kind_of Array, result
    assert_equal 3, result.size

    root, iterations, status = result
    assert_in_delta 1.41421356, root, 1e-5
  end

  def test_fdfsolver_solve_with_three_args
    f = lambda { |x| x * x - 2 }
    df = lambda { |x| 2 * x }
    fdf = GSL::Function_fdf.alloc(f, df)

    s = GSL::Root::FdfSolver.alloc("steffenson")
    result = s.solve(fdf, 1.5, [1e-10, 1e-10])

    assert_kind_of Array, result
    root, iterations, status = result
    assert_in_delta 1.41421356, root, 1e-6
  end

  def test_fdfsolver_solve_wrong_args
    f = lambda { |x| x * x - 2 }
    df = lambda { |x| 2 * x }
    fdf = GSL::Function_fdf.alloc(f, df)

    s = GSL::Root::FdfSolver.alloc("newton")

    assert_raises(ArgumentError) do
      s.solve(fdf)  # Too few arguments
    end
  end

  # =====================================================
  # Root module method tests
  # =====================================================

  def test_root_test_interval
    # Should return GSL::SUCCESS (0) when interval is small enough
    status = GSL::Root.test_interval(1.0, 1.0001, 0.001, 0.0)
    assert_equal GSL::SUCCESS, status
  end

  def test_root_test_interval_not_converged
    # Should return GSL::CONTINUE when interval is too large
    status = GSL::Root.test_interval(0.0, 10.0, 0.001, 0.0)
    assert_equal GSL::CONTINUE, status
  end

  def test_root_test_delta
    # Should return GSL::SUCCESS when delta is small enough
    status = GSL::Root.test_delta(1.41421356, 1.41421357, 1e-6, 0.0)
    assert_equal GSL::SUCCESS, status
  end

  def test_root_test_delta_not_converged
    # Should return GSL::CONTINUE when delta is too large
    status = GSL::Root.test_delta(1.0, 2.0, 0.001, 0.0)
    assert_equal GSL::CONTINUE, status
  end

  def test_root_test_residual
    # Should return GSL::SUCCESS when residual is small enough
    status = GSL::Root.test_residual(0.0001, 0.001)
    assert_equal GSL::SUCCESS, status
  end

  def test_root_test_residual_not_converged
    # Should return GSL::CONTINUE when residual is too large
    status = GSL::Root.test_residual(1.0, 0.001)
    assert_equal GSL::CONTINUE, status
  end

  # =====================================================
  # Function#fsolve tests
  # =====================================================

  def test_function_fsolve_with_two_args
    f = GSL::Function.alloc { |x| x * x - 2 }
    result = f.fsolve(1.0, 2.0)

    assert_kind_of Array, result
    assert_equal 3, result.size

    root, iterations, status = result
    assert_in_delta 1.41421356, root, 1e-5
    assert status == GSL::SUCCESS
  end

  def test_function_fsolve_with_array
    f = GSL::Function.alloc { |x| x * x - 2 }
    result = f.fsolve([1.0, 2.0])

    assert_kind_of Array, result
    root, iterations, status = result
    assert_in_delta 1.41421356, root, 1e-5
  end

  def test_function_fsolve_wrong_args
    f = GSL::Function.alloc { |x| x * x - 2 }

    assert_raises(ArgumentError) do
      f.fsolve  # No interval given
    end
  end

  def test_function_fsolve_wrong_array_type
    f = GSL::Function.alloc { |x| x * x - 2 }

    assert_raises(TypeError) do
      f.fsolve("not an array")  # Wrong type
    end
  end

  def test_function_solve_alias
    f = GSL::Function.alloc { |x| x * x - 2 }
    result = f.solve(1.0, 2.0)

    assert_kind_of Array, result
    root = result[0]
    assert_in_delta 1.41421356, root, 1e-5
  end

  # =====================================================
  # Constants tests
  # =====================================================

  def test_fsolver_constants
    assert_equal 0, GSL::Root::FSolver::BISECTION
    assert_equal 1, GSL::Root::FSolver::FALSEPOS
    assert_equal 2, GSL::Root::FSolver::BRENT

    # Aliases with different case
    assert_equal 0, GSL::Root::FSolver::Bisection
    assert_equal 1, GSL::Root::FSolver::Falsepos
    assert_equal 2, GSL::Root::FSolver::Brent
  end

  def test_fdfsolver_constants
    assert_equal 3, GSL::Root::FdfSolver::NEWTON
    assert_equal 4, GSL::Root::FdfSolver::SECANT
    assert_equal 5, GSL::Root::FdfSolver::STEFFENSON

    # Aliases with different case
    assert_equal 3, GSL::Root::FdfSolver::Newton
    assert_equal 4, GSL::Root::FdfSolver::Secant
    assert_equal 5, GSL::Root::FdfSolver::Steffenson
  end

  # =====================================================
  # Different solver types full workflow
  # =====================================================

  def test_bisection_full_workflow
    f = GSL::Function.alloc { |x| x * x - 2 }
    s = GSL::Root::FSolver.alloc(GSL::Root::FSolver::Bisection)
    s.set(f, 1.0, 2.0)

    20.times { s.iterate }

    root = s.root
    assert_in_delta 1.41421356, root, 1e-5
  end

  def test_falsepos_full_workflow
    f = GSL::Function.alloc { |x| x * x - 2 }
    s = GSL::Root::FSolver.alloc(GSL::Root::FSolver::Falsepos)
    s.set(f, 1.0, 2.0)

    20.times { s.iterate }

    root = s.root
    assert_in_delta 1.41421356, root, 1e-5
  end

  def test_secant_full_workflow
    f = lambda { |x| x * x - 2 }
    df = lambda { |x| 2 * x }
    fdf = GSL::Function_fdf.alloc(f, df)

    s = GSL::Root::FdfSolver.alloc(GSL::Root::FdfSolver::Secant)
    s.set(fdf, 1.5)

    # Secant method can hit zero derivative, so we catch that error
    begin
      10.times { s.iterate }
    rescue GSL::ERROR::EZERODIV
      # This is expected when we've converged
    end

    root = s.root
    assert_in_delta 1.41421356, root, 1e-3
  end

  def test_steffenson_full_workflow
    f = lambda { |x| x * x - 2 }
    df = lambda { |x| 2 * x }
    fdf = GSL::Function_fdf.alloc(f, df)

    s = GSL::Root::FdfSolver.alloc(GSL::Root::FdfSolver::Steffenson)
    s.set(fdf, 1.5)

    20.times { s.iterate }

    root = s.root
    assert_in_delta 1.41421356, root, 1e-5
  end
end
