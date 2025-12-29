require 'test_helper'

class MonteTest < GSL::TestCase

  DIM = 1
  DIM_2D = 2
  CALLS = 1000

  # Test function: f(x) = x[0]^2 for 1D
  # Integral over [0,1] = 1/3
  PROC_1D = proc { |x, _dim| x[0] ** 2 }

  # Test function: f(x,y) = x*y for 2D
  # Integral over [0,1]x[0,1] = 1/4
  PROC_2D = proc { |x, _dim| x[0] * x[1] }

  # Test function with single param: f(x) = a * x[0]^2 where a is the param
  PROC_WITH_PARAM = proc { |x, _dim, param| param * x[0] ** 2 }

  # Test function with multiple params (as array): f(x) = a + b*x[0]
  PROC_WITH_PARAMS = proc { |x, _dim, params| params[0] + params[1] * x[0] }

  # ==========================
  # Monte::Function tests
  # ==========================

  def test_monte_function_new_basic
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    assert_instance_of GSL::Monte::Function, func
    assert_equal PROC_1D, func.proc
  end

  def test_monte_function_new_with_block
    func = GSL::Monte::Function.alloc(DIM) { |x, _dim| x[0] ** 2 }
    assert_instance_of GSL::Monte::Function, func
    assert_not_nil func.proc
  end

  def test_monte_function_eval
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    x = GSL::Vector.alloc([0.5])
    result = func.eval(x)
    assert_in_delta 0.25, result, 1e-10
  end

  def test_monte_function_call_alias
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    x = GSL::Vector.alloc([0.5])
    result = func.call(x)
    assert_in_delta 0.25, result, 1e-10
  end

  def test_monte_function_params_single
    func = GSL::Monte::Function.alloc(PROC_WITH_PARAM, DIM)
    func.set_params(2.0)  # a = 2.0
    x = GSL::Vector.alloc([0.5])
    result = func.eval(x)
    assert_in_delta 0.5, result, 1e-10  # 2.0 * 0.25 = 0.5
  end

  def test_monte_function_params_multiple
    func = GSL::Monte::Function.alloc(PROC_WITH_PARAMS, DIM)
    func.set_params(1.0, 2.0)
    x = GSL::Vector.alloc([0.5])
    result = func.eval(x)
    assert_in_delta 2.0, result, 1e-10  # 1.0 + 2.0*0.5 = 2.0
  end

  def test_monte_function_params_accessor
    func = GSL::Monte::Function.alloc(PROC_WITH_PARAM, DIM)
    func.set_params(5.0)
    assert_equal 5.0, func.params
  end

  def test_monte_function_set
    func = GSL::Monte::Function.alloc
    func.set(PROC_1D, DIM)
    x = GSL::Vector.alloc([0.5])
    result = func.eval(x)
    assert_in_delta 0.25, result, 1e-10
  end

  def test_monte_function_set_proc_alias
    func = GSL::Monte::Function.alloc
    func.set_proc(PROC_1D, DIM)
    x = GSL::Vector.alloc([0.5])
    result = func.eval(x)
    assert_in_delta 0.25, result, 1e-10
  end

  # ==========================
  # Monte::Plain tests
  # ==========================

  def test_plain_new
    plain = GSL::Monte::Plain.alloc(DIM)
    assert_instance_of GSL::Monte::Plain, plain
  end

  def test_plain_init
    plain = GSL::Monte::Plain.alloc(DIM)
    result = plain.init
    assert_equal 0, result
  end

  def test_plain_integrate
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    plain = GSL::Monte::Plain.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = plain.integrate(func, xl, xu, CALLS, rng)
    # Integral of x^2 from 0 to 1 = 1/3 ≈ 0.333...
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_plain_integrate_without_rng
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    plain = GSL::Monte::Plain.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])

    result, err = plain.integrate(func, xl, xu, CALLS)
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_plain_integrate_with_dim_param
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    plain = GSL::Monte::Plain.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = plain.integrate(func, xl, xu, DIM, CALLS, rng)
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_plain_class_integrate
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    plain = GSL::Monte::Plain.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = GSL::Monte::Plain.integrate(func, xl, xu, CALLS, rng, plain)
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  # ==========================
  # Monte::Miser tests
  # ==========================

  def test_miser_new
    miser = GSL::Monte::Miser.alloc(DIM)
    assert_instance_of GSL::Monte::Miser, miser
  end

  def test_miser_init
    miser = GSL::Monte::Miser.alloc(DIM)
    result = miser.init
    assert_equal 0, result
  end

  def test_miser_integrate
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    miser = GSL::Monte::Miser.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = miser.integrate(func, xl, xu, CALLS, rng)
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_miser_integrate_without_rng
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    miser = GSL::Monte::Miser.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])

    result, err = miser.integrate(func, xl, xu, CALLS)
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_miser_class_integrate
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    miser = GSL::Monte::Miser.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = GSL::Monte::Miser.integrate(func, xl, xu, CALLS, rng, miser)
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_miser_direct_accessors
    miser = GSL::Monte::Miser.alloc(DIM)

    # Test estimate_frac getter/setter
    miser.estimate_frac = 0.2
    assert_in_delta 0.2, miser.estimate_frac, 1e-10

    # Test min_calls getter/setter
    miser.min_calls = 100
    assert_equal 100, miser.min_calls

    # Test min_calls_per_bisection getter/setter
    miser.min_calls_per_bisection = 50
    assert_equal 50, miser.min_calls_per_bisection

    # Test alpha getter/setter
    miser.alpha = 1.5
    assert_in_delta 1.5, miser.alpha, 1e-10

    # Test dither getter/setter
    miser.dither = 0.1
    assert_in_delta 0.1, miser.dither, 1e-10
  end

  def test_miser_state
    miser = GSL::Monte::Miser.alloc(DIM)
    miser.estimate_frac = 0.15
    miser.min_calls = 20
    miser.min_calls_per_bisection = 40
    miser.alpha = 1.2
    miser.dither = 0.05

    state = miser.state
    assert_instance_of Array, state
    assert_equal 5, state.size
    assert_in_delta 0.15, state[0], 1e-10  # estimate_frac
    assert_equal 20, state[1]              # min_calls
    assert_equal 40, state[2]              # min_calls_per_bisection
    assert_in_delta 1.2, state[3], 1e-10   # alpha
    assert_in_delta 0.05, state[4], 1e-10  # dither
  end

  def test_miser
    return unless GSL::Monte::Miser.method_defined?(:params_get)

    miser = GSL::Monte::Miser.alloc(DIM)
    params = miser.params_get

    params.estimate_frac = 99
    miser.params_set(params)
    assert_abs miser.estimate_frac, 99, 1e-5, 'miser_estimate_frac'

    params.min_calls = 9
    miser.params_set(params)
    assert_int miser.min_calls, 9, 'miser_min_calls'

    params.min_calls_per_bisection = 7
    miser.params_set(params)
    assert_int miser.min_calls_per_bisection, 7, 'miser_min_calls_per_bisection'

    params.alpha = 3
    miser.params_set(params)
    assert_abs miser.alpha, 3, 1e-5, 'miser_alpha'

    params.dither = 4
    miser.params_set(params)
    assert_abs miser.dither, 4, 1e-5, 'miser_dither'
  end

  # ==========================
  # Monte::Vegas tests
  # ==========================

  def test_vegas_new
    vegas = GSL::Monte::Vegas.alloc(DIM)
    assert_instance_of GSL::Monte::Vegas, vegas
  end

  def test_vegas_init
    vegas = GSL::Monte::Vegas.alloc(DIM)
    result = vegas.init
    assert_equal 0, result
  end

  def test_vegas_integrate
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    vegas = GSL::Monte::Vegas.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = vegas.integrate(func, xl, xu, CALLS, rng)
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_vegas_integrate_without_rng
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    vegas = GSL::Monte::Vegas.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])

    result, err = vegas.integrate(func, xl, xu, CALLS)
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_vegas_class_integrate
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    vegas = GSL::Monte::Vegas.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = GSL::Monte::Vegas.integrate(func, xl, xu, CALLS, rng, vegas)
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_vegas_direct_accessors
    vegas = GSL::Monte::Vegas.alloc(DIM)

    # Test alpha getter/setter
    vegas.alpha = 1.5
    assert_in_delta 1.5, vegas.alpha, 1e-10

    # Test iterations getter/setter
    vegas.iterations = 5
    assert_equal 5, vegas.iterations

    # Test stage getter/setter
    vegas.stage = 1
    assert_equal 1, vegas.stage

    # Test mode getter/setter
    vegas.mode = GSL::Monte::Vegas::MODE_IMPORTANCE
    assert_equal GSL::Monte::Vegas::MODE_IMPORTANCE, vegas.mode

    # Test verbose getter/setter
    vegas.verbose = 2
    assert_equal 2, vegas.verbose
  end

  def test_vegas_result_sigma_chisq
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    vegas = GSL::Monte::Vegas.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    vegas.integrate(func, xl, xu, CALLS, rng)

    # After integration, result/sigma/chisq should be set
    result = vegas.result
    sigma = vegas.sigma
    chisq = vegas.chisq

    assert_instance_of Float, result
    assert_instance_of Float, sigma
    assert_instance_of Float, chisq
  end

  def test_vegas_state
    vegas = GSL::Monte::Vegas.alloc(DIM)
    vegas.alpha = 1.5
    vegas.iterations = 5
    vegas.stage = 1
    vegas.mode = GSL::Monte::Vegas::MODE_IMPORTANCE
    vegas.verbose = 0

    state = vegas.state
    assert_instance_of Array, state
    assert_equal 8, state.size
    # state = [result, sigma, chisq, alpha, iterations, stage, mode, verbose]
    assert_in_delta 1.5, state[3], 1e-10   # alpha
    assert_equal 5, state[4]                # iterations
    assert_equal 1, state[5]                # stage
    assert_equal GSL::Monte::Vegas::MODE_IMPORTANCE, state[6]  # mode
    assert_equal 0, state[7]                # verbose
  end

  def test_vegas_runval
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    vegas = GSL::Monte::Vegas.alloc(DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    vegas.integrate(func, xl, xu, CALLS, rng)

    result, sigma = vegas.runval
    assert_instance_of Float, result
    assert_instance_of Float, sigma
  end

  def test_vegas_params
    return unless GSL::Monte::Vegas.method_defined?(:params_get)

    vegas = GSL::Monte::Vegas.alloc(DIM)
    params = vegas.params_get

    params.alpha = 1
    vegas.params_set(params)
    assert_abs vegas.alpha, 1, 1e-5, 'vegas_alpha'

    params.iterations = 4
    vegas.params_set(params)
    assert_int vegas.iterations, 4, 'vegas_iterations'

    params.stage = 3
    vegas.params_set(params)
    assert_int vegas.stage, 3, 'vegas_stage'

    params.mode = GSL::Monte::Vegas::MODE_IMPORTANCE
    vegas.params_set(params)
    assert_int vegas.mode, GSL::Monte::Vegas::MODE_IMPORTANCE, 'vegas_mode MODE_IMPORTANCE'

    params.mode = GSL::Monte::Vegas::MODE_IMPORTANCE_ONLY
    vegas.params_set(params)
    assert_int vegas.mode, GSL::Monte::Vegas::MODE_IMPORTANCE_ONLY, 'vegas_mode MODE_IMPORTANCE_ONLY'

    params.mode = GSL::Monte::Vegas::MODE_STRATIFIED
    vegas.params_set(params)
    assert_int vegas.mode, GSL::Monte::Vegas::MODE_STRATIFIED, 'vegas_mode MODE_STRATIFIED'

    params.verbose = 0
    vegas.params_set(params)
    assert_int vegas.verbose, 0, 'vegas_verbose 0'

    params.verbose = 1
    vegas.params_set(params)
    assert_int vegas.verbose, 1, 'vegas_verbose 1'

    params.verbose = -1
    vegas.params_set(params)
    assert_int vegas.verbose, -1, 'vegas_verbose -1'
  end

  # ==========================
  # Generic integrate tests (with type string)
  # ==========================

  def test_function_integrate_with_plain_string
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = func.integrate(xl, xu, CALLS, rng, "plain")
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_function_integrate_with_miser_string
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = func.integrate(xl, xu, CALLS, rng, "miser")
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_function_integrate_with_vegas_string
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = func.integrate(xl, xu, CALLS, rng, "vegas")
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  def test_function_integrate_with_type_constant
    func = GSL::Monte::Function.alloc(PROC_1D, DIM)
    xl = GSL::Vector.alloc([0.0])
    xu = GSL::Vector.alloc([1.0])
    rng = GSL::Rng.alloc

    result, err = func.integrate(xl, xu, CALLS, rng, GSL::Monte::PLAIN)
    assert_in_delta 1.0/3.0, result, 0.05
    assert err >= 0
  end

  # ==========================
  # 2D integration tests
  # ==========================

  def test_plain_integrate_2d
    func = GSL::Monte::Function.alloc(PROC_2D, DIM_2D)
    plain = GSL::Monte::Plain.alloc(DIM_2D)
    xl = GSL::Vector.alloc([0.0, 0.0])
    xu = GSL::Vector.alloc([1.0, 1.0])
    rng = GSL::Rng.alloc

    result, err = plain.integrate(func, xl, xu, CALLS, rng)
    # Integral of x*y over [0,1]x[0,1] = 1/4
    assert_in_delta 0.25, result, 0.05
    assert err >= 0
  end

  def test_miser_integrate_2d
    func = GSL::Monte::Function.alloc(PROC_2D, DIM_2D)
    miser = GSL::Monte::Miser.alloc(DIM_2D)
    xl = GSL::Vector.alloc([0.0, 0.0])
    xu = GSL::Vector.alloc([1.0, 1.0])
    rng = GSL::Rng.alloc

    result, err = miser.integrate(func, xl, xu, CALLS, rng)
    assert_in_delta 0.25, result, 0.05
    assert err >= 0
  end

  def test_vegas_integrate_2d
    func = GSL::Monte::Function.alloc(PROC_2D, DIM_2D)
    vegas = GSL::Monte::Vegas.alloc(DIM_2D)
    xl = GSL::Vector.alloc([0.0, 0.0])
    xu = GSL::Vector.alloc([1.0, 1.0])
    rng = GSL::Rng.alloc

    result, err = vegas.integrate(func, xl, xu, CALLS, rng)
    assert_in_delta 0.25, result, 0.05
    assert err >= 0
  end

  # ==========================
  # Constants tests
  # ==========================

  def test_monte_constants
    assert_equal 1, GSL::Monte::PLAIN
    assert_equal 2, GSL::Monte::MISER
    assert_equal 3, GSL::Monte::VEGAS
  end

  def test_vegas_mode_constants
    assert_kind_of Integer, GSL::Monte::Vegas::MODE_IMPORTANCE
    assert_kind_of Integer, GSL::Monte::Vegas::MODE_IMPORTANCE_ONLY
    assert_kind_of Integer, GSL::Monte::Vegas::MODE_STRATIFIED
  end

end
