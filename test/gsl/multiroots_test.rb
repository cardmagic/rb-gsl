require 'test_helper'

class MultiRootsTest < GSL::TestCase

  def _rosenbrock_f
    lambda { |x, f|
      a = 1.0
      b = 10.0
      f[0] = a * (1 - x[0])
      f[1] = b * (x[1] - x[0] * x[0])
    }
  end

  def _rosenbrock_df
    lambda { |x, j|
      a = 1.0
      b = 10.0
      j[0, 0] = -a
      j[0, 1] = 0
      j[1, 0] = -2 * b * x[0]
      j[1, 1] = b
    }
  end

  def _rosenbrock_initpt
    GSL::Vector.alloc(-10.0, -5.0)
  end

  def _test_fsolver(desc, f, x, type)
    n = f.n
    s = GSL::MultiRoot::FSolver.alloc(type, n)
    s.set(f, x)

    status = iter = 0

    begin
      iter += 1
      s.iterate
      status = GSL::MultiRoot.test_residual(s.f, 1e-7)
    end while iter < 1000 && status == GSL::CONTINUE

    root = s.root
    assert((root[0] - 1.0).abs < 1e-6, "#{s.name}, on #{desc}: root[0] = #{root[0]}")
    assert((root[1] - 1.0).abs < 1e-6, "#{s.name}, on #{desc}: root[1] = #{root[1]}")
  end

  def _test_fdfsolver(desc, f, x, type)
    n = f.n
    s = GSL::MultiRoot::FdfSolver.alloc(type, n)
    s.set(f, x)

    status = iter = 0

    begin
      iter += 1
      s.iterate
      status = GSL::MultiRoot.test_residual(s.f, 1e-7)
    end while iter < 1000 && status == GSL::CONTINUE

    root = s.root
    assert((root[0] - 1.0).abs < 1e-6, "#{s.name}, on #{desc}: root[0] = #{root[0]}")
    assert((root[1] - 1.0).abs < 1e-6, "#{s.name}, on #{desc}: root[1] = #{root[1]}")
  end

  # Test FSolver types
  %w[hybrids hybrid dnewton broyden].each do |type|
    define_method("test_fsolver_rosenbrock_#{type}") do
      f = GSL::MultiRoot::Function.alloc(_rosenbrock_f, 2)
      _test_fsolver('Rosenbrock', f, _rosenbrock_initpt, type)
    end
  end

  # Test FdfSolver types
  %w[hybridsj hybridj newton gnewton].each do |type|
    define_method("test_fdfsolver_rosenbrock_#{type}") do
      f = GSL::MultiRoot::Function_fdf.alloc(_rosenbrock_f, _rosenbrock_df, 2)
      _test_fdfsolver('Rosenbrock', f, _rosenbrock_initpt, type)
    end
  end

  def test_function_properties
    f = GSL::MultiRoot::Function.alloc(_rosenbrock_f, 2)
    assert_equal 2, f.n

    x = GSL::Vector.alloc(1.0, 1.0)
    result = f.eval(x)
    assert result.is_a?(GSL::Vector), "eval should return a Vector"
    assert_in_delta 0.0, result[0], 1e-10
    assert_in_delta 0.0, result[1], 1e-10
  end

  def test_function_fdf_properties
    f = GSL::MultiRoot::Function_fdf.alloc(_rosenbrock_f, _rosenbrock_df, 2)
    assert_equal 2, f.n
  end

  def test_fsolver_accessors
    f = GSL::MultiRoot::Function.alloc(_rosenbrock_f, 2)
    s = GSL::MultiRoot::FSolver.alloc('hybrids', 2)
    s.set(f, _rosenbrock_initpt)

    assert s.name.is_a?(String)
    assert s.root.is_a?(GSL::Vector)
    assert s.x.is_a?(GSL::Vector)
    assert s.dx.is_a?(GSL::Vector)
    assert s.f.is_a?(GSL::Vector)

    s.iterate
    assert_equal 2, s.root.size
  end

  def test_fdfsolver_accessors
    f = GSL::MultiRoot::Function_fdf.alloc(_rosenbrock_f, _rosenbrock_df, 2)
    s = GSL::MultiRoot::FdfSolver.alloc('newton', 2)
    s.set(f, _rosenbrock_initpt)

    assert s.name.is_a?(String)
    assert s.root.is_a?(GSL::Vector)
    assert s.x.is_a?(GSL::Vector)
    assert s.dx.is_a?(GSL::Vector)
    assert s.f.is_a?(GSL::Vector)
    assert s.J.is_a?(GSL::Matrix)

    s.iterate
    assert_equal 2, s.root.size
  end

  def test_test_delta
    dx = GSL::Vector.alloc(1e-10, 1e-10)
    x = GSL::Vector.alloc(1.0, 1.0)
    status = GSL::MultiRoot.test_delta(dx, x, 1e-7, 1e-7)
    assert_equal GSL::SUCCESS, status
  end

  def test_test_residual
    f = GSL::Vector.alloc(1e-10, 1e-10)
    status = GSL::MultiRoot.test_residual(f, 1e-7)
    assert_equal GSL::SUCCESS, status

    f = GSL::Vector.alloc(1.0, 1.0)
    status = GSL::MultiRoot.test_residual(f, 1e-7)
    assert_equal GSL::CONTINUE, status
  end

end
