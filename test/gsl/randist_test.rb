require 'test_helper'

class RandistTest < GSL::TestCase

  N = 100000
  MULTI_DIM = 10

  BINS = 100
  STEPS = 100

  R_GLOBAL = GSL::Rng.alloc

  @@use_nmatrix = false

  def test_shuffle
    n = 10

    input = [GSL::Matrix.calloc(n, n)]
    input << NMatrix.new([n,n], 0, dtype: :float64) if @@use_nmatrix

    input.each do |count|
      x = GSL::Permutation.alloc(n)

      N.times { |i|
        n.times { |j| x[j] = j }
        GSL::Ran.shuffle(R_GLOBAL, x)
        n.times { |j| count[x[j], j] += 1 }
      }

      expected = N / 10.0

      n.times { |i|
        n.times { |j|
          d = (count[i, j] - expected).abs

          refute d > 1 && d / Math.sqrt(expected) > 5,
            "gsl_ran_shuffle #{i},#{j} (#{count[i, j] / N} observed vs 0.1 expected)"
        }
      }
    end
  end

  def _test_moments(name, arg, a, b, pp)
    count, expected = 0, pp * N

    N.times {
      r = R_GLOBAL.send(*[name, arg].compact)
      count += 1 if r < b && r > a
    }

    refute((count - expected).abs / Math.sqrt(expected) > 3,
      "#{name}(#{arg}) [#{a},#{b}] (#{count.to_f / N} observed vs #{pp} expected)")
  end

  def _test_pdf(name, *args)
    pdf = "#{name}_pdf"

    a, b = -5.0, 5.0
    dx = (b - a) / BINS

    status = status_i = 0

    count = @@use_nmatrix ? NMatrix.new([BINS], 0 ,dtype: :float64) : 
      GSL::Vector.calloc(BINS)
    pp = @@use_nmatrix ? NMatrix.new([BINS], 0 ,dtype: :float64) : GSL::Vector.calloc(BINS)

    N.times { |i|
      r = R_GLOBAL.send(name, *args)

      if r < b && r > a
        j = ((r - a) / dx).to_i
        count[j] = count[j] + 1
      end
    }

    BINS.times { |i|
      x = a + i * dx
      x = 0.0 if x.abs < 1e-10

      sum = 0.0

      STEPS.times { |j| sum += GSL::Ran.send(pdf, x + j * dx / STEPS, *args) }

      pp[i] = 0.5 * (GSL::Ran.send(pdf, x, *args) + 2 * sum + GSL::Ran.send(pdf, x + dx - 1e-7, *args)) * dx / STEPS
    }

    BINS.times { |i|
      x = a + i * dx
      d = count[i] - N * pp[i]

      status_i = (pp[i] == 0 ? count[i] != 0 : d < 1 && d / Math.sqrt(N * pp[i]) > 5) ? 1 : 0
      status |= status_i

      refute status_i == 1,
        "#{name} [#{x},#{x + dx}) (#{count[i]}/#{N}=#{count[i].to_f / N} observed vs #{pp[i]} expected)"
    }

    assert status.zero?, "#{name}, sampling against pdf over range [#{a},#{b})"
  end

  def _test_randist
    _test_moments(:ugaussian,      nil,  0.0,   100.0, 0.5)
    _test_moments(:ugaussian,      nil, -1.0,     1.0, 0.6826895)
    _test_moments(:ugaussian,      nil,  3.0,     3.5, 0.0011172689)
    _test_moments(:ugaussian_tail, 3.0,  3.0,     3.5, 0.0011172689 / 0.0013498981)
    _test_moments(:exponential,    2.0,  0.0,     1.0, 1 - Math.exp(-0.5))
    _test_moments(:cauchy,         2.0,  0.0, 10000.0, 0.5)

    v = GSL::Vector.alloc(0.59, 0.4, 0.01)

    _test_moments(:discrete, GSL::Ran::Discrete.alloc(v), -0.5, 0.5, 0.59)
    _test_moments(:discrete, GSL::Ran::Discrete.alloc(v),  0.5, 1.5, 0.40)
    _test_moments(:discrete, GSL::Ran::Discrete.alloc(v),  1.5, 3.5, 0.01)

    v = GSL::Vector.alloc(1, 9, 3, 4, 5, 8, 6, 7, 2, 0)

    _test_moments(:discrete, GSL::Ran::Discrete.alloc(v), -0.5,  0.5, 1.0 / 45.0)
    _test_moments(:discrete, GSL::Ran::Discrete.alloc(v),  8.5,  9.5, 0)

    _test_pdf(:beta,   2.0, 3.0)
    _test_pdf(:cauchy, 2.0)
    _test_pdf(:chisq,  2.0)

    _test_pdf(:exponential,    2.0)
    _test_pdf(:exppow,         3.7, 0.3)
    _test_pdf(:fdist,          3.0, 4.0)
    _test_pdf(:flat,           3.0, 4.0)
    _test_pdf(:gamma,          2.5, 2.17)
    _test_pdf(:gaussian,       3.0)
    _test_pdf(:ugaussian_tail, 0.1, 2.0)
  end

  def test_randist
    @@use_nmatrix = false
    _test_randist

    if ENV['NMATRIX']
      @@use_nmatrix = true
      _test_randist;
    end
  end

  # Additional tests for various distributions

  def test_laplace
    r = GSL::Rng.alloc
    val = r.laplace(1.0)
    assert val.is_a?(Float), "laplace returns a float"
  end

  def test_laplace_pdf
    pdf = GSL::Ran.laplace_pdf(0.0, 1.0)
    assert_in_delta 0.5, pdf, 0.01, "laplace_pdf at 0"
  end

  def test_rayleigh
    r = GSL::Rng.alloc
    val = r.rayleigh(1.0)
    assert val >= 0, "rayleigh is non-negative"
  end

  def test_rayleigh_pdf
    pdf = GSL::Ran.rayleigh_pdf(1.0, 1.0)
    assert pdf > 0, "rayleigh_pdf is positive"
  end

  def test_rayleigh_tail
    r = GSL::Rng.alloc
    a = 1.0
    val = r.rayleigh_tail(a, 2.0)
    assert val >= a, "rayleigh_tail is >= a"
  end

  def test_rayleigh_tail_pdf
    pdf = GSL::Ran.rayleigh_tail_pdf(2.0, 1.0, 2.0)
    assert pdf >= 0, "rayleigh_tail_pdf is non-negative"
  end

  def test_landau
    r = GSL::Rng.alloc
    val = r.landau
    assert val.is_a?(Float), "landau returns a float"
  end

  def test_landau_pdf
    pdf = GSL::Ran.landau_pdf(0.0)
    assert pdf > 0, "landau_pdf is positive"
  end

  def test_levy
    r = GSL::Rng.alloc
    val = r.levy(1.0, 1.5)
    assert val.is_a?(Float), "levy returns a float"
  end

  def test_levy_skew
    r = GSL::Rng.alloc
    val = r.levy_skew(1.0, 1.5, 0.5)
    assert val.is_a?(Float), "levy_skew returns a float"
  end

  def test_gamma
    r = GSL::Rng.alloc
    val = r.gamma(2.0, 1.0)
    assert val >= 0, "gamma is non-negative"
  end

  def test_gamma_pdf
    pdf = GSL::Ran.gamma_pdf(1.0, 2.0, 1.0)
    assert pdf >= 0, "gamma_pdf is non-negative"
  end

  def test_lognormal
    r = GSL::Rng.alloc
    val = r.lognormal(0.0, 1.0)
    assert val > 0, "lognormal is positive"
  end

  def test_lognormal_pdf
    pdf = GSL::Ran.lognormal_pdf(1.0, 0.0, 1.0)
    assert pdf >= 0, "lognormal_pdf is non-negative"
  end

  def test_chisq
    r = GSL::Rng.alloc
    val = r.chisq(5.0)
    assert val >= 0, "chisq is non-negative"
  end

  def test_chisq_pdf
    pdf = GSL::Ran.chisq_pdf(2.0, 5.0)
    assert pdf >= 0, "chisq_pdf is non-negative"
  end

  def test_fdist
    r = GSL::Rng.alloc
    val = r.fdist(5.0, 10.0)
    assert val >= 0, "fdist is non-negative"
  end

  def test_fdist_pdf
    pdf = GSL::Ran.fdist_pdf(1.0, 5.0, 10.0)
    assert pdf >= 0, "fdist_pdf is non-negative"
  end

  def test_tdist
    r = GSL::Rng.alloc
    val = r.tdist(5.0)
    assert val.is_a?(Float), "tdist returns a float"
  end

  def test_tdist_pdf
    pdf = GSL::Ran.tdist_pdf(0.0, 5.0)
    assert pdf > 0, "tdist_pdf is positive at 0"
  end

  def test_beta
    r = GSL::Rng.alloc
    val = r.beta(2.0, 3.0)
    assert val >= 0 && val <= 1, "beta is in [0,1]"
  end

  def test_beta_pdf
    pdf = GSL::Ran.beta_pdf(0.5, 2.0, 3.0)
    assert pdf >= 0, "beta_pdf is non-negative"
  end

  def test_logistic
    r = GSL::Rng.alloc
    val = r.logistic(1.0)
    assert val.is_a?(Float), "logistic returns a float"
  end

  def test_logistic_pdf
    pdf = GSL::Ran.logistic_pdf(0.0, 1.0)
    assert pdf > 0, "logistic_pdf is positive"
  end

  def test_pareto
    r = GSL::Rng.alloc
    a, b = 2.0, 1.0
    val = r.pareto(a, b)
    assert val >= b, "pareto is >= b"
  end

  def test_pareto_pdf
    pdf = GSL::Ran.pareto_pdf(2.0, 2.0, 1.0)
    assert pdf >= 0, "pareto_pdf is non-negative"
  end

  def test_weibull
    r = GSL::Rng.alloc
    val = r.weibull(1.0, 2.0)
    assert val >= 0, "weibull is non-negative"
  end

  def test_weibull_pdf
    pdf = GSL::Ran.weibull_pdf(1.0, 1.0, 2.0)
    assert pdf >= 0, "weibull_pdf is non-negative"
  end

  def test_gumbel1
    r = GSL::Rng.alloc
    val = r.gumbel1(1.0, 1.0)
    assert val.is_a?(Float), "gumbel1 returns a float"
  end

  def test_gumbel1_pdf
    pdf = GSL::Ran.gumbel1_pdf(0.0, 1.0, 1.0)
    assert pdf >= 0, "gumbel1_pdf is non-negative"
  end

  def test_gumbel2
    r = GSL::Rng.alloc
    val = r.gumbel2(1.0, 1.0)
    assert val > 0, "gumbel2 is positive"
  end

  def test_gumbel2_pdf
    pdf = GSL::Ran.gumbel2_pdf(1.0, 1.0, 1.0)
    assert pdf >= 0, "gumbel2_pdf is non-negative"
  end

  def test_bivariate_gaussian
    r = GSL::Rng.alloc
    x, y = r.bivariate_gaussian(1.0, 1.0, 0.5)
    assert x.is_a?(Float), "bivariate_gaussian returns x"
    assert y.is_a?(Float), "bivariate_gaussian returns y"
  end

  def test_bivariate_gaussian_pdf
    pdf = GSL::Ran.bivariate_gaussian_pdf(0.0, 0.0, 1.0, 1.0, 0.5)
    assert pdf > 0, "bivariate_gaussian_pdf is positive"
  end

  # Discrete distributions
  def test_poisson
    r = GSL::Rng.alloc
    val = r.poisson(3.0)
    assert val.is_a?(Integer), "poisson returns an integer"
    assert val >= 0, "poisson is non-negative"
  end

  def test_poisson_pdf
    pdf = GSL::Ran.poisson_pdf(3, 3.0)
    assert pdf >= 0, "poisson_pdf is non-negative"
  end

  def test_binomial
    r = GSL::Rng.alloc
    val = r.binomial(0.5, 10)
    assert val.is_a?(Integer), "binomial returns an integer"
    assert val >= 0 && val <= 10, "binomial is in [0, n]"
  end

  def test_binomial_pdf
    pdf = GSL::Ran.binomial_pdf(5, 0.5, 10)
    assert pdf >= 0, "binomial_pdf is non-negative"
  end

  def test_negative_binomial
    r = GSL::Rng.alloc
    val = r.negative_binomial(0.5, 5.0)
    assert val.is_a?(Integer), "negative_binomial returns an integer"
    assert val >= 0, "negative_binomial is non-negative"
  end

  def test_negative_binomial_pdf
    pdf = GSL::Ran.negative_binomial_pdf(3, 0.5, 5.0)
    assert pdf >= 0, "negative_binomial_pdf is non-negative"
  end

  def test_geometric
    r = GSL::Rng.alloc
    val = r.geometric(0.5)
    assert val.is_a?(Integer), "geometric returns an integer"
    assert val >= 1, "geometric is >= 1"
  end

  def test_geometric_pdf
    pdf = GSL::Ran.geometric_pdf(3, 0.5)
    assert pdf >= 0, "geometric_pdf is non-negative"
  end

  def test_hypergeometric
    r = GSL::Rng.alloc
    val = r.hypergeometric(10, 20, 5)
    assert val.is_a?(Integer), "hypergeometric returns an integer"
    assert val >= 0 && val <= 5, "hypergeometric is in valid range"
  end

  def test_hypergeometric_pdf
    pdf = GSL::Ran.hypergeometric_pdf(2, 10, 20, 5)
    assert pdf >= 0, "hypergeometric_pdf is non-negative"
  end

  def test_logarithmic
    r = GSL::Rng.alloc
    val = r.logarithmic(0.5)
    assert val.is_a?(Integer), "logarithmic returns an integer"
    assert val >= 1, "logarithmic is >= 1"
  end

  def test_logarithmic_pdf
    pdf = GSL::Ran.logarithmic_pdf(2, 0.5)
    assert pdf >= 0, "logarithmic_pdf is non-negative"
  end

  def test_pascal
    r = GSL::Rng.alloc
    val = r.pascal(0.5, 5)
    assert val.is_a?(Integer), "pascal returns an integer"
    assert val >= 0, "pascal is non-negative"
  end

  def test_pascal_pdf
    pdf = GSL::Ran.pascal_pdf(3, 0.5, 5)
    assert pdf >= 0, "pascal_pdf is non-negative"
  end

  # Spherical distributions
  def test_dir_2d
    r = GSL::Rng.alloc
    x, y = r.dir_2d
    assert_in_delta 1.0, x*x + y*y, 1e-10, "dir_2d gives unit vector"
  end

  def test_dir_3d
    r = GSL::Rng.alloc
    x, y, z = r.dir_3d
    assert_in_delta 1.0, x*x + y*y + z*z, 1e-10, "dir_3d gives unit vector"
  end

  # dir_nd test skipped - API unclear

  # Dirichlet distribution
  def test_dirichlet
    r = GSL::Rng.alloc
    alpha = GSL::Vector[1.0, 1.0, 1.0]
    theta = GSL::Vector.alloc(3)
    r.dirichlet(alpha, theta)
    assert_in_delta 1.0, theta.sum, 1e-10, "dirichlet sums to 1"
  end

  def test_dirichlet_pdf
    alpha = GSL::Vector[2.0, 2.0, 2.0]
    theta = GSL::Vector[0.33, 0.33, 0.34]
    pdf = GSL::Ran.dirichlet_pdf(alpha, theta)
    assert pdf >= 0, "dirichlet_pdf is non-negative"
  end

  def test_dirichlet_lnpdf
    alpha = GSL::Vector[2.0, 2.0, 2.0]
    theta = GSL::Vector[0.33, 0.33, 0.34]
    lnpdf = GSL::Ran.dirichlet_lnpdf(alpha, theta)
    assert lnpdf.is_a?(Float), "dirichlet_lnpdf returns a float"
  end

  # Multinomial, gamma_int, gamma_knuth tests skipped - methods don't exist on Rng

  # Gaussian ziggurat
  def test_gaussian_ziggurat
    r = GSL::Rng.alloc
    val = r.gaussian_ziggurat(1.0)
    assert val.is_a?(Float), "gaussian_ziggurat returns a float"
  end

  # === Branch coverage tests for helper functions ===

  # Test vector generation paths (returns vector when count specified)
  def test_gaussian_vector_generation
    r = GSL::Rng.alloc
    vec = r.gaussian(1.0, 5)
    assert vec.is_a?(GSL::Vector), "gaussian with count returns vector"
    assert_equal 5, vec.size
  end

  def test_gaussian_vector_generation_module
    r = GSL::Rng.alloc
    vec = GSL::Ran.gaussian(r, 1.0, 5)
    assert vec.is_a?(GSL::Vector), "module gaussian with count returns vector"
    assert_equal 5, vec.size
  end

  def test_exponential_vector_generation
    r = GSL::Rng.alloc
    vec = r.exponential(1.0, 5)
    assert vec.is_a?(GSL::Vector), "exponential with count returns vector"
    assert_equal 5, vec.size
    vec.each { |v| assert v >= 0, "exponential values are non-negative" }
  end

  def test_exponential_vector_generation_module
    r = GSL::Rng.alloc
    vec = GSL::Ran.exponential(r, 1.0, 5)
    assert vec.is_a?(GSL::Vector), "module exponential with count returns vector"
    assert_equal 5, vec.size
  end

  def test_cauchy_vector_generation
    r = GSL::Rng.alloc
    vec = r.cauchy(1.0, 5)
    assert vec.is_a?(GSL::Vector), "cauchy with count returns vector"
    assert_equal 5, vec.size
  end

  def test_gamma_vector_generation
    r = GSL::Rng.alloc
    vec = r.gamma(2.0, 1.0, 5)
    assert vec.is_a?(GSL::Vector), "gamma with count returns vector"
    assert_equal 5, vec.size
    vec.each { |v| assert v >= 0, "gamma values are non-negative" }
  end

  def test_gamma_vector_generation_module
    r = GSL::Rng.alloc
    vec = GSL::Ran.gamma(r, 2.0, 1.0, 5)
    assert vec.is_a?(GSL::Vector), "module gamma with count returns vector"
    assert_equal 5, vec.size
  end

  def test_flat_vector_generation
    r = GSL::Rng.alloc
    vec = r.flat(0.0, 1.0, 5)
    assert vec.is_a?(GSL::Vector), "flat with count returns vector"
    assert_equal 5, vec.size
    vec.each { |v| assert v >= 0 && v <= 1, "flat values in [0,1]" }
  end

  def test_beta_vector_generation
    r = GSL::Rng.alloc
    vec = r.beta(2.0, 3.0, 5)
    assert vec.is_a?(GSL::Vector), "beta with count returns vector"
    assert_equal 5, vec.size
    vec.each { |v| assert v >= 0 && v <= 1, "beta values in [0,1]" }
  end

  def test_levy_vector_generation
    r = GSL::Rng.alloc
    vec = r.levy(1.0, 1.5, 5)
    assert vec.is_a?(GSL::Vector), "levy with count returns vector"
    assert_equal 5, vec.size
  end

  def test_levy_skew_vector_generation
    r = GSL::Rng.alloc
    vec = r.levy_skew(1.0, 1.5, 0.5, 5)
    assert vec.is_a?(GSL::Vector), "levy_skew with count returns vector"
    assert_equal 5, vec.size
  end

  def test_levy_skew_vector_generation_module
    r = GSL::Rng.alloc
    vec = GSL::Ran.levy_skew(r, 1.0, 1.5, 0.5, 5)
    assert vec.is_a?(GSL::Vector), "module levy_skew with count returns vector"
    assert_equal 5, vec.size
  end

  # Test integer-returning distributions with vector generation
  def test_poisson_vector_generation
    r = GSL::Rng.alloc
    vec = r.poisson(3.0, 5)
    assert vec.is_a?(GSL::Vector::Int), "poisson with count returns int vector"
    assert_equal 5, vec.size
  end

  def test_poisson_vector_generation_module
    r = GSL::Rng.alloc
    vec = GSL::Ran.poisson(r, 3.0, 5)
    assert vec.is_a?(GSL::Vector::Int), "module poisson with count returns int vector"
    assert_equal 5, vec.size
  end

  def test_geometric_vector_generation
    r = GSL::Rng.alloc
    vec = r.geometric(0.5, 5)
    assert vec.is_a?(GSL::Vector::Int), "geometric with count returns int vector"
    assert_equal 5, vec.size
  end

  def test_bernoulli
    r = GSL::Rng.alloc
    val = r.bernoulli(0.5)
    assert val == 0 || val == 1, "bernoulli returns 0 or 1"
  end

  def test_bernoulli_module
    r = GSL::Rng.alloc
    val = GSL::Ran.bernoulli(r, 0.5)
    assert val == 0 || val == 1, "module bernoulli returns 0 or 1"
  end

  def test_bernoulli_vector_generation
    r = GSL::Rng.alloc
    vec = r.bernoulli(0.5, 10)
    assert vec.is_a?(GSL::Vector::Int), "bernoulli with count returns int vector"
    assert_equal 10, vec.size
    vec.each { |v| assert v == 0 || v == 1, "bernoulli values are 0 or 1" }
  end

  def test_bernoulli_pdf
    pdf0 = GSL::Ran.bernoulli_pdf(0, 0.3)
    pdf1 = GSL::Ran.bernoulli_pdf(1, 0.3)
    assert_in_delta 0.7, pdf0, 1e-10
    assert_in_delta 0.3, pdf1, 1e-10
  end

  def test_binomial_tpe
    r = GSL::Rng.alloc
    val = r.binomial_tpe(0.5, 10)
    assert val.is_a?(Integer), "binomial_tpe returns an integer"
    assert val >= 0 && val <= 10, "binomial_tpe is in [0, n]"
  end

  def test_binomial_tpe_module
    r = GSL::Rng.alloc
    val = GSL::Ran.binomial_tpe(r, 0.5, 10)
    assert val.is_a?(Integer), "module binomial_tpe returns an integer"
    assert val >= 0 && val <= 10, "binomial_tpe is in [0, n]"
  end

  # Test gaussian with different argument counts
  def test_gaussian_default_sigma
    r = GSL::Rng.alloc
    val = r.gaussian
    assert val.is_a?(Float), "gaussian with no args uses default sigma=1"
  end

  def test_gaussian_with_sigma
    r = GSL::Rng.alloc
    val = r.gaussian(2.0)
    assert val.is_a?(Float), "gaussian with sigma returns float"
  end

  def test_gaussian_module_call
    r = GSL::Rng.alloc
    val = GSL::Ran.gaussian(r)
    assert val.is_a?(Float), "module gaussian with just rng works"
  end

  def test_gaussian_module_with_sigma
    r = GSL::Rng.alloc
    val = GSL::Ran.gaussian(r, 2.0)
    assert val.is_a?(Float), "module gaussian with sigma works"
  end

  # Test gaussian_tail with different argument counts
  def test_gaussian_tail_with_sigma
    r = GSL::Rng.alloc
    val = r.gaussian_tail(1.0, 2.0)
    assert val.is_a?(Float), "gaussian_tail with a and sigma returns float"
    assert val >= 1.0, "gaussian_tail is >= a"
  end

  def test_gaussian_tail_module
    r = GSL::Rng.alloc
    val = GSL::Ran.gaussian_tail(r, 1.0)
    assert val.is_a?(Float), "module gaussian_tail works"
    assert val >= 1.0, "gaussian_tail is >= a"
  end

  def test_gaussian_tail_module_with_sigma
    r = GSL::Rng.alloc
    val = GSL::Ran.gaussian_tail(r, 1.0, 2.0)
    assert val.is_a?(Float), "module gaussian_tail with sigma works"
    assert val >= 1.0, "gaussian_tail is >= a"
  end

  def test_gaussian_tail_vector_generation
    r = GSL::Rng.alloc
    vec = r.gaussian_tail(1.0, 2.0, 5)
    assert vec.is_a?(GSL::Vector), "gaussian_tail with count returns vector"
    assert_equal 5, vec.size
    vec.each { |v| assert v >= 1.0, "gaussian_tail values >= a" }
  end

  def test_gaussian_tail_vector_generation_module
    r = GSL::Rng.alloc
    vec = GSL::Ran.gaussian_tail(r, 1.0, 2.0, 5)
    assert vec.is_a?(GSL::Vector), "module gaussian_tail with count returns vector"
    assert_equal 5, vec.size
  end

  # Test gaussian_ratio_method
  def test_gaussian_ratio_method
    r = GSL::Rng.alloc
    val = r.gaussian_ratio_method
    assert val.is_a?(Float), "gaussian_ratio_method returns float"
  end

  def test_gaussian_ratio_method_with_sigma
    r = GSL::Rng.alloc
    val = r.gaussian_ratio_method(2.0)
    assert val.is_a?(Float), "gaussian_ratio_method with sigma returns float"
  end

  def test_gaussian_ratio_method_module
    r = GSL::Rng.alloc
    val = GSL::Ran.gaussian_ratio_method(r)
    assert val.is_a?(Float), "module gaussian_ratio_method returns float"
  end

  def test_gaussian_ratio_method_module_with_sigma
    r = GSL::Rng.alloc
    val = GSL::Ran.gaussian_ratio_method(r, 2.0)
    assert val.is_a?(Float), "module gaussian_ratio_method with sigma returns float"
  end

  # Test PDF functions with vectors
  def test_gaussian_pdf_with_vector
    x = GSL::Vector[0.0, 1.0, 2.0]
    pdf = GSL::Ran.gaussian_pdf(x, 1.0)
    assert pdf.is_a?(GSL::Vector), "gaussian_pdf with vector returns vector"
    assert_equal 3, pdf.size
    pdf.each { |p| assert p >= 0, "pdf values are non-negative" }
  end

  def test_ugaussian_pdf_with_vector
    x = GSL::Vector[0.0, 1.0, 2.0]
    pdf = GSL::Ran.gaussian_pdf(x)
    assert pdf.is_a?(GSL::Vector), "ugaussian_pdf with vector returns vector"
    assert_equal 3, pdf.size
  end

  def test_exponential_pdf_with_vector
    x = GSL::Vector[0.0, 1.0, 2.0]
    pdf = GSL::Ran.exponential_pdf(x, 1.0)
    assert pdf.is_a?(GSL::Vector), "exponential_pdf with vector returns vector"
    assert_equal 3, pdf.size
  end

  def test_gamma_pdf_with_vector
    x = GSL::Vector[0.5, 1.0, 2.0]
    pdf = GSL::Ran.gamma_pdf(x, 2.0, 1.0)
    assert pdf.is_a?(GSL::Vector), "gamma_pdf with vector returns vector"
    assert_equal 3, pdf.size
  end

  # Test gaussian_tail_pdf
  def test_ugaussian_tail_pdf
    pdf = GSL::Ran.gaussian_tail_pdf(1.5, 1.0)
    assert pdf.is_a?(Float), "ugaussian_tail_pdf returns float"
    assert pdf >= 0, "pdf is non-negative"
  end

  def test_gaussian_tail_pdf_full
    pdf = GSL::Ran.gaussian_tail_pdf(3.0, 1.0, 2.0)
    assert pdf.is_a?(Float), "gaussian_tail_pdf returns float"
    assert pdf >= 0, "pdf is non-negative"
  end

  # Test exppow distribution
  def test_exppow
    r = GSL::Rng.alloc
    val = r.exppow(1.0, 2.0)
    assert val.is_a?(Float), "exppow returns float"
  end

  def test_exppow_module
    r = GSL::Rng.alloc
    val = GSL::Ran.exppow(r, 1.0, 2.0)
    assert val.is_a?(Float), "module exppow returns float"
  end

  def test_exppow_pdf
    pdf = GSL::Ran.exppow_pdf(0.0, 1.0, 2.0)
    assert pdf.is_a?(Float), "exppow_pdf returns float"
    assert pdf > 0, "exppow_pdf is positive at 0"
  end

  # Test flat distribution
  def test_flat
    r = GSL::Rng.alloc
    val = r.flat(1.0, 3.0)
    assert val >= 1.0 && val <= 3.0, "flat is in [a, b]"
  end

  def test_flat_pdf
    pdf = GSL::Ran.flat_pdf(1.5, 1.0, 2.0)
    assert_in_delta 1.0, pdf, 1e-10, "flat_pdf is 1/(b-a) inside range"

    pdf_outside = GSL::Ran.flat_pdf(0.5, 1.0, 2.0)
    assert_in_delta 0.0, pdf_outside, 1e-10, "flat_pdf is 0 outside range"
  end

  # Test negative_binomial module call
  def test_negative_binomial_module
    r = GSL::Rng.alloc
    val = GSL::Ran.negative_binomial(r, 0.5, 5.0)
    assert val.is_a?(Integer), "module negative_binomial returns integer"
    assert val >= 0, "negative_binomial is non-negative"
  end

  # Test hypergeometric module call
  def test_hypergeometric_module
    r = GSL::Rng.alloc
    val = GSL::Ran.hypergeometric(r, 10, 20, 5)
    assert val.is_a?(Integer), "module hypergeometric returns integer"
    assert val >= 0 && val <= 5, "hypergeometric is in valid range"
  end

  # Test logarithmic module call
  def test_logarithmic_module
    r = GSL::Rng.alloc
    val = GSL::Ran.logarithmic(r, 0.5)
    assert val.is_a?(Integer), "module logarithmic returns integer"
    assert val >= 1, "logarithmic is >= 1"
  end

  # Test pascal module call
  def test_pascal_module
    r = GSL::Rng.alloc
    val = GSL::Ran.pascal(r, 0.5, 5)
    assert val.is_a?(Integer), "module pascal returns integer"
    assert val >= 0, "pascal is non-negative"
  end

  # Test direction distributions
  def test_dir_2d_trig_method
    r = GSL::Rng.alloc
    x, y = r.dir_2d_trig_method
    assert_in_delta 1.0, x*x + y*y, 1e-10, "dir_2d_trig_method gives unit vector"
  end

  # Error path tests
  def test_gaussian_wrong_args
    r = GSL::Rng.alloc
    assert_raises(ArgumentError) { r.gaussian(1.0, 2.0, 3.0) }
  end

  def test_gaussian_module_wrong_args
    r = GSL::Rng.alloc
    assert_raises(ArgumentError) { GSL::Ran.gaussian(r, 1.0, 2.0, 3.0) }
  end

  def test_exponential_wrong_args
    r = GSL::Rng.alloc
    assert_raises(ArgumentError) { r.exponential(1.0, 2.0, 3.0) }
  end

  def test_gamma_wrong_args
    r = GSL::Rng.alloc
    assert_raises(ArgumentError) { r.gamma(1.0, 2.0, 3.0, 4.0, 5.0) }
  end

  def test_binomial_wrong_args
    r = GSL::Rng.alloc
    assert_raises(ArgumentError) { r.binomial(0.5, 10, 20) }
  end

end
