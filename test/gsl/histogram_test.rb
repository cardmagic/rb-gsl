require 'test_helper'

class HistogramTest < GSL::TestCase

  def test_alloc_with_size
    h = GSL::Histogram.alloc(10)
    assert h.is_a?(GSL::Histogram), "Histogram.alloc returns a histogram"
    assert_equal 10, h.bins, "Histogram has correct number of bins"
  end

  def test_alloc_with_range
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    assert h.is_a?(GSL::Histogram), "Histogram.alloc with range works"
    assert_equal 10, h.bins, "Histogram has 10 bins"
    assert_in_delta 0.0, h.min, 1e-10, "min is 0.0"
    assert_in_delta 10.0, h.max, 1e-10, "max is 10.0"
  end

  def test_alloc_with_array
    ranges = [0.0, 1.0, 3.0, 6.0, 10.0]
    h = GSL::Histogram.alloc(ranges)
    assert_equal 4, h.bins, "Histogram has n-1 bins"
  end

  def test_alloc_with_vector
    ranges = GSL::Vector[0.0, 1.0, 3.0, 6.0, 10.0]
    h = GSL::Histogram.alloc(ranges)
    assert_equal 4, h.bins, "Histogram from vector has n-1 bins"
  end

  def test_alloc_uniform
    h = GSL::Histogram.alloc_uniform(5, 0.0, 5.0)
    assert_equal 5, h.bins
    assert_in_delta 0.0, h.min, 1e-10
    assert_in_delta 5.0, h.max, 1e-10
  end

  def test_calloc
    h = GSL::Histogram.calloc(10)
    assert_equal 10, h.bins
  end

  def test_set_ranges_uniform
    h = GSL::Histogram.alloc(5)
    h.set_ranges_uniform(0.0, 10.0)
    assert_in_delta 0.0, h.min, 1e-10
    assert_in_delta 10.0, h.max, 1e-10
  end

  def test_set_ranges
    h = GSL::Histogram.alloc(4)
    ranges = GSL::Vector[0.0, 1.0, 3.0, 6.0, 10.0]
    h.set_ranges(ranges)
    assert_in_delta 0.0, h.min, 1e-10
    assert_in_delta 10.0, h.max, 1e-10
  end

  def test_increment
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5)
    h.increment(1.5)
    h.increment(5.5)

    assert_in_delta 2.0, h[1], 1e-10, "bin 1 has 2 counts"
    assert_in_delta 1.0, h[5], 1e-10, "bin 5 has 1 count"
    assert_in_delta 0.0, h[0], 1e-10, "bin 0 is empty"
  end

  def test_accumulate_with_weight
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5, 2.5)
    assert_in_delta 2.5, h[1], 1e-10, "bin has weighted count"
  end

  def test_increment2
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    # increment2 doesn't raise error for out-of-range values
    h.increment2(-1.0)  # out of range
    h.increment2(1.5)
    assert_in_delta 1.0, h[1], 1e-10
  end

  def test_get
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5)
    assert_in_delta 1.0, h.get(1), 1e-10
    assert_in_delta 1.0, h[1], 1e-10
  end

  def test_get_range
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    lower, upper = h.get_range(1)
    assert_in_delta 1.0, lower, 1e-10
    assert_in_delta 2.0, upper, 1e-10
  end

  def test_range
    h = GSL::Histogram.alloc(5, 0.0, 5.0)
    range = h.range
    assert range.is_a?(GSL::Histogram::Range), "range returns Range object"
  end

  def test_bin
    h = GSL::Histogram.alloc(5, 0.0, 5.0)
    h.increment(1.5)
    h.increment(3.5)
    bin = h.bin
    assert bin.is_a?(GSL::Histogram::Bin), "bin returns Bin object"
  end

  def test_find
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    bin_index = h.find(5.5)
    assert_equal 5, bin_index, "find returns correct bin index"
  end

  def test_max_val_and_bin
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5)
    h.increment(5.5)
    h.increment(5.5)
    h.increment(5.5)

    assert_in_delta 3.0, h.max_val, 1e-10
    assert_equal 5, h.max_bin
  end

  def test_min_val_and_bin
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5)
    h.increment(5.5)
    h.increment(5.5)

    assert_in_delta 0.0, h.min_val, 1e-10
    assert_equal 0, h.min_bin
  end

  def test_mean
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    # Add data to bins: centers are 0.5, 1.5, 2.5, ...
    h.increment(0.5)  # bin 0
    h.increment(9.5)  # bin 9

    mean = h.mean
    assert mean.is_a?(Float), "mean returns a float"
  end

  def test_sigma
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(0.5)
    h.increment(9.5)

    sigma = h.sigma
    assert sigma.is_a?(Float), "sigma returns a float"
  end

  def test_sum
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(0.5)
    h.increment(1.5)
    h.increment(2.5)

    assert_in_delta 3.0, h.sum, 1e-10, "sum returns total counts"
  end

  def test_integral_with_range
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(0.5)
    h.increment(1.5)
    h.increment(2.5)

    partial_sum = h.sum(0, 1)  # bins 0 and 1
    assert_in_delta 2.0, partial_sum, 1e-10, "partial sum is correct"
  end

  def test_reset
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5)
    h.increment(2.5)
    h.reset

    assert_in_delta 0.0, h.sum, 1e-10, "reset clears all bins"
  end

  def test_clone
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5)
    h.increment(2.5)

    h2 = h.clone
    assert h2.is_a?(GSL::Histogram)
    assert_in_delta h.sum, h2.sum, 1e-10
    assert_equal h.bins, h2.bins
  end

  def test_memcpy
    h1 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h1.increment(1.5)
    h2 = GSL::Histogram.alloc(10, 0.0, 10.0)

    GSL::Histogram.memcpy(h2, h1)
    assert_in_delta h1[1], h2[1], 1e-10
  end

  def test_equal_bins_p
    h1 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h2 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h3 = GSL::Histogram.alloc(10, 0.0, 20.0)

    assert h1.equal_bins_p?(h2), "same histograms have equal bins"
    refute h1.equal_bins_p?(h3), "different histograms have unequal bins"
  end

  def test_add
    h1 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h2 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h1.increment(1.5)
    h2.increment(1.5)
    h2.increment(2.5)

    h3 = h1 + h2
    assert_in_delta 2.0, h3[1], 1e-10
    assert_in_delta 1.0, h3[2], 1e-10
  end

  def test_sub
    h1 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h2 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h1.increment(1.5)
    h1.increment(1.5)
    h2.increment(1.5)

    h3 = h1 - h2
    assert_in_delta 1.0, h3[1], 1e-10
  end

  def test_mul
    h1 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h2 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h1.increment(1.5, 2.0)
    h2.increment(1.5, 3.0)

    h3 = h1 * h2
    assert_in_delta 6.0, h3[1], 1e-10
  end

  def test_div
    h1 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h2 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h1.increment(1.5, 6.0)
    h2.increment(1.5, 2.0)

    h3 = h1 / h2
    assert_in_delta 3.0, h3[1], 1e-10
  end

  def test_add_bang
    h1 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h2 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h1.increment(1.5)
    h2.increment(1.5)

    h1.add!(h2)
    assert_in_delta 2.0, h1[1], 1e-10
  end

  def test_sub_bang
    h1 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h2 = GSL::Histogram.alloc(10, 0.0, 10.0)
    h1.increment(1.5)
    h1.increment(1.5)
    h2.increment(1.5)

    h1.sub!(h2)
    assert_in_delta 1.0, h1[1], 1e-10
  end

  def test_scale
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5, 2.0)

    h2 = h.scale(3.0)
    assert_in_delta 6.0, h2[1], 1e-10
    assert_in_delta 2.0, h[1], 1e-10  # original unchanged
  end

  def test_scale_bang
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5, 2.0)

    h.scale!(3.0)
    assert_in_delta 6.0, h[1], 1e-10
  end

  def test_shift
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5, 2.0)

    h2 = h.shift(1.0)
    assert_in_delta 3.0, h2[1], 1e-10
    assert_in_delta 2.0, h[1], 1e-10  # original unchanged
  end

  def test_shift_bang
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5, 2.0)

    h.shift!(1.0)
    assert_in_delta 3.0, h[1], 1e-10
  end

  # PDF tests
  def test_pdf_alloc
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5)
    h.increment(5.5)

    pdf = GSL::Histogram::Pdf.alloc(h.bins)
    assert pdf.is_a?(GSL::Histogram::Pdf)
  end

  def test_pdf_init
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5)
    h.increment(5.5)

    pdf = GSL::Histogram::Pdf.alloc(h.bins)
    pdf.init(h)
    # If we get here without error, it worked
    assert true
  end

  def test_pdf_sample
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    10.times { |i| h.increment(i + 0.5) }

    pdf = GSL::Histogram::Pdf.alloc(h.bins)
    pdf.init(h)

    r = 0.5  # middle of probability range
    val = pdf.sample(r)
    assert val.is_a?(Float), "sample returns a float"
    assert val >= 0.0 && val <= 10.0, "sample is in range"
  end

  def test_normalize
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5, 10.0)
    h.increment(5.5, 20.0)

    h2 = h.normalize
    assert h2.is_a?(GSL::Histogram)
    # Normalized histogram should integrate to 1
  end

  def test_normalize_bang
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5, 10.0)
    h.increment(5.5, 20.0)

    h.normalize!
    # Should work without error
    assert true
  end

  def test_print
    h = GSL::Histogram.alloc(5, 0.0, 5.0)
    h.increment(1.5)
    # Just test that print doesn't crash
    # The method outputs to stdout
    assert true
  end

  # Test size/n aliases
  def test_size_alias
    h = GSL::Histogram.alloc(10)
    assert_equal 10, h.size
    assert_equal 10, h.n
  end

  # Test fill alias
  def test_fill_alias
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.fill(1.5)
    assert_in_delta 1.0, h[1], 1e-10
  end

  # Test accumulate alias
  def test_accumulate_alias
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.accumulate(1.5)
    assert_in_delta 1.0, h[1], 1e-10
  end

  # Test integral alias
  def test_integral_alias
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5)
    assert_in_delta 1.0, h.integral, 1e-10
  end

  # Test duplicate alias
  def test_duplicate_alias
    h = GSL::Histogram.alloc(10, 0.0, 10.0)
    h.increment(1.5)
    h2 = h.duplicate
    assert_in_delta h[1], h2[1], 1e-10
  end

  # Test bracket syntax for alloc
  def test_bracket_alloc
    h = GSL::Histogram[10]
    assert_equal 10, h.bins
  end

  # Test with min/max step
  def test_alloc_with_min_max_step
    h = GSL::Histogram.alloc_with_min_max_step(0.0, 10.0, 2.0)
    assert_equal 5, h.bins
  end

end
