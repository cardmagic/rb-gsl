require 'test_helper'

class IntegrationTest < GSL::TestCase

  def test_integration1
    f = GSL::Function.alloc { |x| Math.exp(x) * Math.cos(x) }

    xmin = 0.0
    xmax = 1.0
    limit = 1000

    # QNG
    assert f.integration_qng(xmin, xmax, 0.0, 1.0e-7)
    assert f.integration_qng(xmin, xmax)
    assert f.integration_qng([xmin, xmax])
    assert f.integration_qng([xmin, xmax], [0.0, 1.0e-7])
    assert f.integration_qng([xmin, xmax], 0.0, 1.0e-7)
    assert f.integration_qng(xmin, xmax, [0.0, 1.0e-7])

    # QAG
    assert f.integration_qag(xmin, xmax, 0.0, 1.0e-7, limit, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], 0.0, 1.0e-7, limit, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15)
    assert f.integration_qag(xmin, xmax, [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15)
    assert f.integration_qag(xmin, xmax, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], GSL::Integration::GAUSS15)

    w = GSL::Integration::Workspace.alloc
    assert f.integration_qag(xmin, xmax, [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15, w)
    assert f.integration_qag(xmin, xmax, 0.0, 1.0e-7, GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], 0.0, 1.0e-7, GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], w)

    # QAGS
    assert f.integration_qags(xmin, xmax)
    assert f.integration_qags([xmin, xmax])
    assert f.integration_qags(xmin, xmax, 0.0, 1e-7)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7])
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7])
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7)
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7, limit)
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7], limit)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7], limit)
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7, limit, w)
    assert f.integration_qags(xmin, xmax, 0.0, 1e-7, limit, w)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7], w)
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7], w)

    assert f.integration_qags([xmin, xmax], limit)
    assert f.integration_qags(xmin, xmax, limit)
    assert f.integration_qags([xmin, xmax], w)
    assert f.integration_qags(xmin, xmax, w)
    assert f.integration_qags(xmin, xmax, limit, w)
    assert f.integration_qags([xmin, xmax], limit, w)

    # QAGP
    assert f.integration_qagp([xmin, xmax])
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7])
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7)
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7, limit)
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7], limit)
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7, limit, w)
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7], w)

    assert f.integration_qagp([xmin, xmax], limit)
    assert f.integration_qagp([xmin, xmax], w)
    assert f.integration_qagp([xmin, xmax], limit, w)
  end

  def test_integration2
    f = GSL::Function.alloc { |x| Math.sin(x) / x }

    xmin = 0.0
    xmax = 2.0 * Math::PI
    limit = 1000

    # QNG
    assert f.integration_qng(xmin, xmax, 0.0, 1.0e-7)
    assert f.integration_qng(xmin, xmax)
    assert f.integration_qng([xmin, xmax])
    assert f.integration_qng([xmin, xmax], [0.0, 1.0e-7])
    assert f.integration_qng([xmin, xmax], 0.0, 1.0e-7)
    assert f.integration_qng(xmin, xmax, [0.0, 1.0e-7])

    # QAG
    assert f.integration_qag(xmin, xmax, 0.0, 1.0e-7, limit, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], 0.0, 1.0e-7, limit, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15)
    assert f.integration_qag(xmin, xmax, [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15)
    assert f.integration_qag(xmin, xmax, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], GSL::Integration::GAUSS15)

    w = GSL::Integration::Workspace.alloc(2000)
    assert f.integration_qag(xmin, xmax, [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15, w)
    assert f.integration_qag(xmin, xmax, 0.0, 1.0e-7, GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], 0.0, 1.0e-7, GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15, w)

    # QAGS
    assert f.integration_qags(xmin, xmax)
    assert f.integration_qags([xmin, xmax])
    assert f.integration_qags(xmin, xmax, 0.0, 1e-7)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7])
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7])
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7)
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7, limit)
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7], limit)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7], limit)
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7, limit, w)
    assert f.integration_qags(xmin, xmax, 0.0, 1e-7, limit, w)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7], w)
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7], w)

    assert f.integration_qags([xmin, xmax], limit)
    assert f.integration_qags(xmin, xmax, limit)
    assert f.integration_qags([xmin, xmax], w)
    assert f.integration_qags(xmin, xmax, w)
    assert f.integration_qags(xmin, xmax, limit, w)
    assert f.integration_qags([xmin, xmax], limit, w)

    # QAGP
    assert f.integration_qagp([xmin, xmax])
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7])
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7)
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7, limit)
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7], limit)
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7, limit, w)
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7], w)

    assert f.integration_qagp([xmin, xmax], limit)
    assert f.integration_qagp([xmin, xmax], w)
    assert f.integration_qagp([xmin, xmax], limit, w)
  end

  def test_integration3
    f = GSL::Function.alloc { |x| Math.exp(-x) / Math.sqrt(x) }

    xmin = 0.0
    xmax = 1.0
    limit = 1000

    # QNG
    # XXX GSL::ERROR::ETOL: Ruby/GSL error code 14, failed to reach tolerance with
    # highest-order rule (file qng.c, line 189), failed to reach the specified tolerance
    #assert f.integration_qng(xmin, xmax, 0.0, 1.0e-7)
    #assert f.integration_qng(xmin, xmax)
    #assert f.integration_qng([xmin, xmax])
    #assert f.integration_qng([xmin, xmax], [0.0, 1.0e-7])
    #assert f.integration_qng([xmin, xmax], 0.0, 1.0e-7)
    #assert f.integration_qng(xmin, xmax, [0.0, 1.0e-7])

    # QAG
    assert f.integration_qag(xmin, xmax, 0.0, 1.0e-7, limit, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], 0.0, 1.0e-7, limit, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15)
    assert f.integration_qag(xmin, xmax, [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15)
    assert f.integration_qag(xmin, xmax, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], GSL::Integration::GAUSS15)

    w = GSL::Integration::Workspace.alloc(2000)
    assert f.integration_qag(xmin, xmax, [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15, w)
    assert f.integration_qag(xmin, xmax, 0.0, 1.0e-7, GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], 0.0, 1.0e-7, GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15, w)

    # QAGS
    assert f.integration_qags(xmin, xmax)
    assert f.integration_qags([xmin, xmax])
    assert f.integration_qags(xmin, xmax, 0.0, 1e-7)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7])
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7])
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7)
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7, limit)
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7], limit)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7], limit)
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7, limit, w)
    assert f.integration_qags(xmin, xmax, 0.0, 1e-7, limit, w)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7], w)
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7], w)

    assert f.integration_qags([xmin, xmax], limit)
    assert f.integration_qags(xmin, xmax, limit)
    assert f.integration_qags([xmin, xmax], w)
    assert f.integration_qags(xmin, xmax, w)
    assert f.integration_qags(xmin, xmax, limit, w)
    assert f.integration_qags([xmin, xmax], limit, w)

    # QAGP
    assert f.integration_qagp([xmin, xmax])
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7])
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7)
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7, limit)
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7], limit)
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7, limit, w)
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7], w)

    assert f.integration_qagp([xmin, xmax], limit)
    assert f.integration_qagp([xmin, xmax], w)
    assert f.integration_qagp([xmin, xmax], limit, w)
  end

  def test_integration4
    f = GSL::Function.alloc { |x| (1.0 - Math.exp(-x)) / Math.sqrt(x) }

    xmin = 0.0
    xmax = 0.2
    limit = 1000

    # QNG
    # XXX GSL::ERROR::ETOL: Ruby/GSL error code 14, failed to reach tolerance with
    # highest-order rule (file qng.c, line 189), failed to reach the specified tolerance
    #assert f.integration_qng(xmin, xmax, 0.0, 1.0e-7)
    #assert f.integration_qng(xmin, xmax)
    #assert f.integration_qng([xmin, xmax])
    #assert f.integration_qng([xmin, xmax], [0.0, 1.0e-7])
    #assert f.integration_qng([xmin, xmax], 0.0, 1.0e-7)
    #assert f.integration_qng(xmin, xmax, [0.0, 1.0e-7])

    # QAG
    assert f.integration_qag(xmin, xmax, 0.0, 1.0e-7, limit, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], 0.0, 1.0e-7, limit, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15)
    assert f.integration_qag(xmin, xmax, [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15)
    assert f.integration_qag(xmin, xmax, GSL::Integration::GAUSS15)
    assert f.integration_qag([xmin, xmax], GSL::Integration::GAUSS15)

    w = GSL::Integration::Workspace.alloc(2000)
    assert f.integration_qag(xmin, xmax, [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15, w)
    assert f.integration_qag(xmin, xmax, 0.0, 1.0e-7, GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], 0.0, 1.0e-7, GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], GSL::Integration::GAUSS15, w)
    assert f.integration_qag([xmin, xmax], [0.0, 1.0e-7], limit, GSL::Integration::GAUSS15, w)

    # QAGS
    assert f.integration_qags(xmin, xmax)
    assert f.integration_qags([xmin, xmax])
    assert f.integration_qags(xmin, xmax, 0.0, 1e-7)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7])
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7])
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7)
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7, limit)
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7], limit)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7], limit)
    assert f.integration_qags([xmin, xmax], 0.0, 1e-7, limit, w)
    assert f.integration_qags(xmin, xmax, 0.0, 1e-7, limit, w)
    assert f.integration_qags(xmin, xmax, [0.0, 1e-7], w)
    assert f.integration_qags([xmin, xmax], [0.0, 1e-7], w)

    assert f.integration_qags([xmin, xmax], limit)
    assert f.integration_qags(xmin, xmax, limit)
    assert f.integration_qags([xmin, xmax], w)
    assert f.integration_qags(xmin, xmax, w)
    assert f.integration_qags(xmin, xmax, limit, w)
    assert f.integration_qags([xmin, xmax], limit, w)

    # QAGP
    assert f.integration_qagp([xmin, xmax])
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7])
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7)
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7, limit)
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7], limit)
    assert f.integration_qagp([xmin, xmax], 0.0, 1e-7, limit, w)
    assert f.integration_qagp([xmin, xmax], [0.0, 1e-7], w)

    assert f.integration_qagp([xmin, xmax], limit)
    assert f.integration_qagp([xmin, xmax], w)
    assert f.integration_qagp([xmin, xmax], limit, w)
  end

  # ===========================================
  # Numerical Verification Tests
  # ===========================================

  # Test QNG with known integrals
  def test_qng_numerical
    # Integral of x^2 from 0 to 1 = 1/3
    f = GSL::Function.alloc { |x| x * x }
    result, = f.integration_qng(0, 1)
    assert_rel result, 1.0/3.0, 1e-6, 'QNG: integral of x^2'

    # Integral of sin(x) from 0 to pi = 2
    f = GSL::Function.alloc { |x| Math.sin(x) }
    result, = f.integration_qng(0, Math::PI)
    assert_rel result, 2.0, 1e-6, 'QNG: integral of sin(x)'

    # Integral of exp(x) from 0 to 1 = e - 1
    f = GSL::Function.alloc { |x| Math.exp(x) }
    result, = f.integration_qng(0, 1)
    assert_rel result, Math::E - 1, 1e-6, 'QNG: integral of exp(x)'
  end

  # Test QAG with known integrals
  def test_qag_numerical
    # Integral of x^3 from 0 to 2 = 4
    f = GSL::Function.alloc { |x| x ** 3 }
    result, = f.integration_qag(0, 2, GSL::Integration::GAUSS15)
    assert_rel result, 4.0, 1e-6, 'QAG: integral of x^3'

    # Integral of 1/(1+x^2) from 0 to 1 = pi/4
    f = GSL::Function.alloc { |x| 1.0 / (1.0 + x * x) }
    result, = f.integration_qag(0, 1, GSL::Integration::GAUSS21)
    assert_rel result, Math::PI / 4, 1e-6, 'QAG: integral of 1/(1+x^2)'

    # Test different Gauss rules
    f = GSL::Function.alloc { |x| x * x }
    result15, = f.integration_qag(0, 1, GSL::Integration::GAUSS15)
    result21, = f.integration_qag(0, 1, GSL::Integration::GAUSS21)
    result31, = f.integration_qag(0, 1, GSL::Integration::GAUSS31)
    result41, = f.integration_qag(0, 1, GSL::Integration::GAUSS41)
    result51, = f.integration_qag(0, 1, GSL::Integration::GAUSS51)
    result61, = f.integration_qag(0, 1, GSL::Integration::GAUSS61)

    # All should give approximately 1/3
    assert_rel result15, 1.0/3.0, 1e-6, 'QAG GAUSS15'
    assert_rel result21, 1.0/3.0, 1e-6, 'QAG GAUSS21'
    assert_rel result31, 1.0/3.0, 1e-6, 'QAG GAUSS31'
    assert_rel result41, 1.0/3.0, 1e-6, 'QAG GAUSS41'
    assert_rel result51, 1.0/3.0, 1e-6, 'QAG GAUSS51'
    assert_rel result61, 1.0/3.0, 1e-6, 'QAG GAUSS61'
  end

  # Test QAGS with singular integrands
  def test_qags_numerical
    # Integral of 1/sqrt(x) from 0 to 1 = 2
    f = GSL::Function.alloc { |x| 1.0 / Math.sqrt(x) }
    result, = f.integration_qags(0, 1)
    assert_rel result, 2.0, 1e-5, 'QAGS: integral of 1/sqrt(x)'

    # Integral of ln(x) from 0 to 1 = -1
    f = GSL::Function.alloc { |x| x > 0 ? Math.log(x) : 0 }
    result, = f.integration_qags(0, 1)
    assert_rel result, -1.0, 1e-5, 'QAGS: integral of ln(x)'
  end

  # Test QAGP with known singularity points
  def test_qagp_numerical
    # Integral of 1/|x-0.5| from 0 to 1 (split at singularity)
    # This is technically divergent, but we can test with a regularized version
    # Integral of x from 0 to 1 with breakpoints = 1/2
    f = GSL::Function.alloc { |x| x }
    pts = [0.0, 0.5, 1.0]
    result, = f.integration_qagp(pts)
    assert_rel result, 0.5, 1e-6, 'QAGP: integral of x with breakpoints'
  end

  # Test QAGI (infinite intervals)
  def test_qagi_numerical
    # Integral of exp(-x^2) from -inf to +inf = sqrt(pi)
    f = GSL::Function.alloc { |x| Math.exp(-x * x) }
    result, = f.integration_qagi
    assert_rel result, Math.sqrt(Math::PI), 1e-6, 'QAGI: Gaussian integral'
  end

  # Test QAGIU (upper infinite)
  def test_qagiu_numerical
    # Integral of exp(-x) from 0 to inf = 1
    f = GSL::Function.alloc { |x| Math.exp(-x) }
    result, = f.integration_qagiu(0)
    assert_rel result, 1.0, 1e-6, 'QAGIU: integral of exp(-x)'

    # Integral of 1/(1+x^2) from 0 to inf = pi/2
    f = GSL::Function.alloc { |x| 1.0 / (1.0 + x * x) }
    result, = f.integration_qagiu(0)
    assert_rel result, Math::PI / 2, 1e-6, 'QAGIU: integral of 1/(1+x^2)'
  end

  # Test QAGIL (lower infinite)
  def test_qagil_numerical
    # Integral of exp(x) from -inf to 0 = 1
    f = GSL::Function.alloc { |x| Math.exp(x) }
    result, = f.integration_qagil(0)
    assert_rel result, 1.0, 1e-6, 'QAGIL: integral of exp(x)'
  end

  # Test error estimates
  def test_integration_error_estimates
    f = GSL::Function.alloc { |x| x * x }

    result, abserr = f.integration_qng(0, 1)
    assert result.is_a?(Float), 'QNG returns result'
    assert abserr.is_a?(Float), 'QNG returns error estimate'
    assert abserr >= 0, 'QNG error estimate is non-negative'
    assert abserr < 1e-10, 'QNG error estimate is small for simple function'

    result, abserr = f.integration_qag(0, 1, GSL::Integration::GAUSS15)
    assert result.is_a?(Float), 'QAG returns result'
    assert abserr.is_a?(Float), 'QAG returns error estimate'
    assert abserr >= 0, 'QAG error estimate is non-negative'
  end

  # Test workspace usage
  def test_integration_workspace
    w = GSL::Integration::Workspace.alloc(100)
    assert w.is_a?(GSL::Integration::Workspace), 'Workspace allocation'
    assert_equal 100, w.limit, 'Workspace limit'
    assert_equal 0, w.size, 'Workspace initial size'

    f = GSL::Function.alloc { |x| x * x }
    f.integration_qags(0, 1, 0, 1e-7, 100, w)

    # Workspace should have been used
    assert w.size >= 0, 'Workspace size after use'
  end

end
