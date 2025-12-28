require 'test_helper'

class ChebTest < GSL::TestCase

  def setup
    @order = 40
    @pi = GSL::M_PI
    @tol = 100.0 * GSL::DBL_EPSILON
    @cs = GSL::Cheb.alloc(@order)
    @cs.init(GSL::Function.alloc { |x| Math.sin(x) }, -@pi, @pi)
  end

  def test_cheb_new
    cs = GSL::Cheb.new(10)
    assert_kind_of GSL::Cheb, cs
  end

  def test_cheb_order
    assert_equal @order, @cs.order
    cs2 = GSL::Cheb.alloc(20)
    assert_equal 20, cs2.order
  end

  def test_cheb_a_b
    assert_in_delta(-@pi, @cs.a, @tol)
    assert_in_delta(@pi, @cs.b, @tol)

    cs2 = GSL::Cheb.alloc(10)
    cs2.init(GSL::Function.alloc { |x| x * x }, 0.0, 2.0)
    assert_in_delta(0.0, cs2.a, @tol)
    assert_in_delta(2.0, cs2.b, @tol)
  end

  def test_cheb_coef_alias
    c_method = @cs.coef
    c_alias = @cs.c
    assert_kind_of GSL::Vector::View, c_method
    assert_kind_of GSL::Vector::View, c_alias
    assert_equal c_method.size, c_alias.size
    c_method.size.times { |i| assert_in_delta(c_method[i], c_alias[i], @tol) }
  end

  def test_cheb_f
    f = @cs.f
    assert_kind_of GSL::Vector::View, f
    assert_equal @order + 1, f.size
  end

  # Note: Array input has a bug in cheb.c - Need_Float(xx) should be Need_Float(x)

  def test_cheb_eval_with_vector
    x_vec = GSL::Vector.alloc([-@pi, 0.0, @pi / 2, @pi])
    result = @cs.eval(x_vec)
    assert_kind_of GSL::Vector, result
    assert_equal 4, result.size
    4.times do |i|
      assert_in_delta(Math.sin(x_vec[i]), result[i], @tol)
    end
  end

  def test_cheb_eval_with_matrix
    x_mat = GSL::Matrix.alloc([-@pi, 0.0], [@pi / 2, @pi])
    result = @cs.eval(x_mat)
    assert_kind_of GSL::Matrix, result
    assert_equal 2, result.size1
    assert_equal 2, result.size2
    2.times do |i|
      2.times do |j|
        assert_in_delta(Math.sin(x_mat[i, j]), result[i, j], @tol)
      end
    end
  end

  # Note: Array input has a bug in cheb.c for eval_err

  def test_cheb_eval_err_with_vector
    x_vec = GSL::Vector.alloc([-@pi, 0.0, @pi / 2])
    results, errors = @cs.eval_err(x_vec)
    assert_kind_of GSL::Vector, results
    assert_kind_of GSL::Vector, errors
    assert_equal 3, results.size
    3.times do |i|
      assert_in_delta(Math.sin(x_vec[i]), results[i], @tol)
    end
  end

  def test_cheb_eval_err_with_matrix
    x_mat = GSL::Matrix.alloc([-@pi, 0.0], [@pi / 2, @pi])
    results, errors = @cs.eval_err(x_mat)
    assert_kind_of GSL::Matrix, results
    assert_kind_of GSL::Matrix, errors
    2.times do |i|
      2.times do |j|
        assert_in_delta(Math.sin(x_mat[i, j]), results[i, j], @tol)
        assert errors[i, j] >= 0
      end
    end
  end

  # Note: Array input has a bug in cheb.c for eval_n

  def test_cheb_eval_n_with_vector
    x_vec = GSL::Vector.alloc([-@pi, 0.0, @pi / 2])
    result = @cs.eval_n(25, x_vec)
    assert_kind_of GSL::Vector, result
    assert_equal 3, result.size
    3.times do |i|
      assert_in_delta(Math.sin(x_vec[i]), result[i], @tol)
    end
  end

  def test_cheb_eval_n_with_matrix
    x_mat = GSL::Matrix.alloc([-@pi, 0.0], [@pi / 2, @pi])
    result = @cs.eval_n(25, x_mat)
    assert_kind_of GSL::Matrix, result
    2.times do |i|
      2.times do |j|
        assert_in_delta(Math.sin(x_mat[i, j]), result[i, j], @tol)
      end
    end
  end

  # Note: Array input has a bug in cheb.c for eval_n_err

  def test_cheb_eval_n_err_with_vector
    x_vec = GSL::Vector.alloc([-@pi, 0.0, @pi / 2])
    results, errors = @cs.eval_n_err(25, x_vec)
    assert_kind_of GSL::Vector, results
    assert_kind_of GSL::Vector, errors
    assert_equal 3, results.size
  end

  def test_cheb_eval_n_err_with_matrix
    x_mat = GSL::Matrix.alloc([-@pi, 0.0], [@pi / 2, @pi])
    results, errors = @cs.eval_n_err(25, x_mat)
    assert_kind_of GSL::Matrix, results
    assert_kind_of GSL::Matrix, errors
    assert_equal 2, results.size1
    assert_equal 2, results.size2
  end

  def test_cheb_calc_deriv_instance_method_no_arg
    csd = @cs.calc_deriv
    assert_kind_of GSL::Cheb, csd
    x = 0.0
    assert_in_delta(Math.cos(x), csd.eval(x), 1600 * @tol)
  end

  def test_cheb_calc_deriv_instance_method_with_arg
    csd = GSL::Cheb.alloc(@order)
    result = @cs.calc_deriv(csd)
    assert_same csd, result
    x = 0.0
    assert_in_delta(Math.cos(x), csd.eval(x), 1600 * @tol)
  end

  def test_cheb_calc_deriv_class_method_one_arg
    csd = GSL::Cheb.calc_deriv(@cs)
    assert_kind_of GSL::Cheb, csd
    x = 0.0
    assert_in_delta(Math.cos(x), csd.eval(x), 1600 * @tol)
  end

  def test_cheb_calc_deriv_class_method_two_args
    csd = GSL::Cheb.alloc(@order)
    result = GSL::Cheb.calc_deriv(csd, @cs)
    assert_same csd, result
    x = 0.0
    assert_in_delta(Math.cos(x), csd.eval(x), 1600 * @tol)
  end

  def test_cheb_deriv_alias
    csd = @cs.deriv
    assert_kind_of GSL::Cheb, csd
  end

  def test_cheb_calc_integ_instance_method_no_arg
    csi = @cs.calc_integ
    assert_kind_of GSL::Cheb, csi
    x = 0.0
    assert_in_delta(-(1 + Math.cos(x)), csi.eval(x), @tol)
  end

  def test_cheb_calc_integ_instance_method_with_arg
    csi = GSL::Cheb.alloc(@order)
    result = @cs.calc_integ(csi)
    assert_same csi, result
    x = 0.0
    assert_in_delta(-(1 + Math.cos(x)), csi.eval(x), @tol)
  end

  def test_cheb_calc_integ_class_method_one_arg
    csi = GSL::Cheb.calc_integ(@cs)
    assert_kind_of GSL::Cheb, csi
    x = 0.0
    assert_in_delta(-(1 + Math.cos(x)), csi.eval(x), @tol)
  end

  def test_cheb_calc_integ_class_method_two_args
    csi = GSL::Cheb.alloc(@order)
    result = GSL::Cheb.calc_integ(csi, @cs)
    assert_same csi, result
    x = 0.0
    assert_in_delta(-(1 + Math.cos(x)), csi.eval(x), @tol)
  end

  def test_cheb_integ_alias
    csi = @cs.integ
    assert_kind_of GSL::Cheb, csi
  end

  def test_cheb
    tol, pi, order = 100.0 * GSL::DBL_EPSILON, GSL::M_PI, 40

    cs = GSL::Cheb.alloc(order)

    cs.init(GSL::Function.alloc { |x| 1.0 }, -1.0, 1.0)
    order.times { |i|
      assert_abs cs.c[i], i == 0 ? 2.0 : 0.0, tol, 'c[%d] for T_0(x)' % i
    }

    cs.init(GSL::Function.alloc { |x| x }, -1.0, 1.0)
    order.times { |i|
      assert_abs cs.c[i], i == 1 ? 1.0 : 0.0, tol, 'c[%d] for T_1(x)' % i
    }

    cs.init(GSL::Function.alloc { |x| 2.0 * x * x - 1.0 }, -1.0, 1.0)
    order.times { |i|
      assert_abs cs.c[i], i == 2 ? 1.0 : 0.0, tol, 'c[%d] for T_2(x)' % i
    }

    cs.init(GSL::Function.alloc { |x| Math.sin(x) }, -pi, pi)
    assert_abs cs.c[0], 0.0, tol, 'c[0] for F_sin(x)'
    assert_abs cs.c[1], 5.69230686359506e-01, tol, 'c[1] for F_sin(x)'
    assert_abs cs.c[2], 0.0, tol, 'c[2] for F_sin(x)'
    assert_abs cs.c[3], -6.66916672405979e-01, tol, 'c[3] for F_sin(x)'
    assert_abs cs.c[4], 0.0, tol, 'c[4] for F_sin(x)'
    assert_abs cs.c[5], 1.04282368734237e-01, tol, 'c[5] for F_sin(x)'

    x = -pi
    while x < pi
      assert_abs cs.eval(x), Math.sin(x), tol, 'GSL::Cheb#eval, sin(%.3g)' % x
      x += pi / 100.0
    end

    x = -pi
    while x < pi
      r, e = cs.eval_err(x)

      assert_abs r, Math.sin(x), tol, 'GSL::Cheb#eval_err, sin(%.3g)' % x
      assert_factor((r - Math.sin(x)).abs + GSL::DBL_EPSILON, e, 10.0,
        'GSL::Cheb#eval_err, error sin(%.3g)' % x)

      x += pi / 100.0
    end

    x = -pi
    while x < pi
      assert_abs cs.eval_n(25, x), Math.sin(x), tol, 'GSL::Cheb#eval_n, sin(%.3g)' % x
      x += pi / 100.0
    end

    x = -pi
    while x < pi
      r, e = cs.eval_n_err(25, x)

      assert_abs r, Math.sin(x), tol, 'GSL::Cheb#eval_n_err, sin(%.3g)' % x
      assert_factor((r - Math.sin(x)).abs + GSL::DBL_EPSILON, e, 10.0,
        'GSL::Cheb#eval_n_err, error sin(%.3g)' % x)

      x += pi / 100.0
    end

    csd, x = cs.calc_deriv, -pi
    while x < pi
      assert_abs csd.eval(x), Math.cos(x), 1600 * tol, 'GSL::Cheb#eval, deriv sin(%.3g)' % x
      x += pi / 100.0
    end

    csi, x = cs.calc_integ, -pi
    while x < pi
      assert_abs csi.eval(x), -(1 + Math.cos(x)), tol, 'GSL::Cheb#eval, integ sin(%.3g)' % x
      x += pi / 100.0
    end
  end

end
