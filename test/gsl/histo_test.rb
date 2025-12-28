require 'test_helper'

class HistoTest < GSL::TestCase

  def test_histo
    h = GSL::Histogram.alloc(10, [0, 10])

    assert h
    assert h.get_range(2)
    assert h.range
    assert h.bin
  end

  # Tests for histogram_find.c via 1D histogram
  def test_histogram_find_basic
    h = GSL::Histogram.alloc(10)
    h.set_ranges_uniform(0, 10)

    # Find bin for value in middle
    assert_equal 5, h.find(5.5)

    # Find bin for value at start
    assert_equal 0, h.find(0.0)

    # Find bin for value near end (9.9 should be in bin 9)
    assert_equal 9, h.find(9.9)

    # Find bin for value at bin boundaries
    assert_equal 3, h.find(3.0)
    assert_equal 7, h.find(7.0)
  end

  def test_histogram_find_nonuniform_ranges
    h = GSL::Histogram.alloc(5)
    h.set_ranges([0, 1, 4, 9, 16, 25])

    # Value in first bin
    assert_equal 0, h.find(0.5)

    # Value in second bin
    assert_equal 1, h.find(2.0)

    # Value in last bin
    assert_equal 4, h.find(20.0)
  end

  # Tests for histogram_find.c via 2D histogram (uses mygsl_find2d -> mygsl_find)
  def test_histogram2d_find
    h = GSL::Histogram2d.alloc(10, 10)
    h.set_ranges_uniform(0, 10, 0, 10)

    # Find bin for point in center
    i, j = h.find(5.5, 5.5)
    assert_equal 5, i
    assert_equal 5, j

    # Find bin for point at origin
    i, j = h.find(0.0, 0.0)
    assert_equal 0, i
    assert_equal 0, j

    # Find bin for point near corner
    i, j = h.find(9.5, 9.5)
    assert_equal 9, i
    assert_equal 9, j

    # Find bin for point with different x and y
    i, j = h.find(2.5, 7.5)
    assert_equal 2, i
    assert_equal 7, j
  end

  def test_histogram2d_increment_uses_find
    h = GSL::Histogram2d.alloc(10, 10)
    h.set_ranges_uniform(0, 10, 0, 10)

    # Increment at specific point
    h.increment(5.5, 5.5)
    assert_rel h.get(5, 5), 1.0, 1e-10, '2D histogram increment'

    # Increment at boundary
    h.increment(0.0, 0.0)
    assert_rel h.get(0, 0), 1.0, 1e-10, '2D histogram increment at origin'

    # Increment multiple times
    h.increment(3.5, 7.5)
    h.increment(3.5, 7.5)
    assert_rel h.get(3, 7), 2.0, 1e-10, '2D histogram double increment'
  end

  # Tests for histogram_find.c via 3D histogram (uses mygsl_find3d -> mygsl_find)
  def test_histogram3d_find
    h = GSL::Histogram3d.alloc(5, 5, 5)
    h.set_ranges_uniform(0, 5, 0, 5, 0, 5)

    # Find bin for point in center
    i, j, k = h.find(2.5, 2.5, 2.5)
    assert_equal 2, i
    assert_equal 2, j
    assert_equal 2, k

    # Find bin for point at origin
    i, j, k = h.find(0.0, 0.0, 0.0)
    assert_equal 0, i
    assert_equal 0, j
    assert_equal 0, k

    # Find bin for point near corner
    i, j, k = h.find(4.5, 4.5, 4.5)
    assert_equal 4, i
    assert_equal 4, j
    assert_equal 4, k
  end

  def test_histogram3d_increment_uses_find
    h = GSL::Histogram3d.alloc(5, 5, 5)
    h.set_ranges_uniform(0, 5, 0, 5, 0, 5)

    h.increment(2.5, 2.5, 2.5)
    assert_rel h.get(2, 2, 2), 1.0, 1e-10, '3D histogram increment'

    h.increment(0.0, 0.0, 0.0)
    assert_rel h.get(0, 0, 0), 1.0, 1e-10, '3D histogram increment at origin'
  end

  # Tests for histogram_oper.c - equal_bins_p
  def test_histogram_equal_bins_p_same_binning
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    assert_equal 1, h1.equal_bins_p(h2)
    assert_equal true, h1.equal_bins_p?(h2)
  end

  def test_histogram_equal_bins_p_different_bin_count
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(5)
    h2.set_ranges_uniform(0, 10)

    assert_equal 0, h1.equal_bins_p(h2)
    assert_equal false, h1.equal_bins_p?(h2)
  end

  def test_histogram_equal_bins_p_different_ranges
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 20)

    assert_equal 0, h1.equal_bins_p(h2)
    assert_equal false, h1.equal_bins_p?(h2)
  end

  # Tests for histogram_oper.c - add operations
  def test_histogram_add
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    h1.increment(5.5)
    h2.increment(5.5)
    h2.increment(3.5)

    h3 = h1.add(h2)
    assert_rel h3.get(5), 2.0, 1e-10, 'histogram add bin 5'
    assert_rel h3.get(3), 1.0, 1e-10, 'histogram add bin 3'

    # Original histograms unchanged
    assert_rel h1.get(5), 1.0, 1e-10, 'original h1 unchanged'
    assert_rel h1.get(3), 0.0, 1e-10, 'original h1 bin 3 unchanged'
  end

  def test_histogram_add_operator
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    h1.increment(5.5)
    h2.increment(5.5)

    h3 = h1 + h2
    assert_rel h3.get(5), 2.0, 1e-10, 'histogram + operator'
  end

  def test_histogram_add_inplace
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    h1.increment(5.5)
    h2.increment(5.5)

    h1.add!(h2)
    assert_rel h1.get(5), 2.0, 1e-10, 'histogram add! in-place'
  end

  # Tests for histogram_oper.c - sub operations
  def test_histogram_sub
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    h1.increment(5.5)
    h1.increment(5.5)
    h1.increment(5.5)
    h2.increment(5.5)

    h3 = h1.sub(h2)
    assert_rel h3.get(5), 2.0, 1e-10, 'histogram sub'

    # Original unchanged
    assert_rel h1.get(5), 3.0, 1e-10, 'original h1 unchanged after sub'
  end

  def test_histogram_sub_operator
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    h1.increment(5.5)
    h1.increment(5.5)
    h2.increment(5.5)

    h3 = h1 - h2
    assert_rel h3.get(5), 1.0, 1e-10, 'histogram - operator'
  end

  def test_histogram_sub_inplace
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    h1.increment(5.5)
    h1.increment(5.5)
    h2.increment(5.5)

    h1.sub!(h2)
    assert_rel h1.get(5), 1.0, 1e-10, 'histogram sub! in-place'
  end

  # Tests for histogram_oper.c - mul operations
  def test_histogram_mul
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    h1.increment(5.5)
    h1.increment(5.5)
    h1.increment(5.5)
    h2.increment(5.5)
    h2.increment(5.5)

    h3 = h1.mul(h2)
    assert_rel h3.get(5), 6.0, 1e-10, 'histogram mul (3 * 2 = 6)'

    # Original unchanged
    assert_rel h1.get(5), 3.0, 1e-10, 'original h1 unchanged after mul'
  end

  def test_histogram_mul_operator
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    h1.increment(5.5)
    h1.increment(5.5)
    h2.increment(5.5)
    h2.increment(5.5)
    h2.increment(5.5)

    h3 = h1 * h2
    assert_rel h3.get(5), 6.0, 1e-10, 'histogram * operator (2 * 3 = 6)'
  end

  def test_histogram_mul_inplace
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    h1.increment(5.5)
    h1.increment(5.5)
    h2.increment(5.5)
    h2.increment(5.5)

    h1.mul!(h2)
    assert_rel h1.get(5), 4.0, 1e-10, 'histogram mul! in-place (2 * 2 = 4)'
  end

  # Tests for histogram_oper.c - div operations
  def test_histogram_div
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    # Set up h1 with 6 counts and h2 with 2 counts
    6.times { h1.increment(5.5) }
    2.times { h2.increment(5.5) }

    h3 = h1.div(h2)
    assert_rel h3.get(5), 3.0, 1e-10, 'histogram div (6 / 2 = 3)'

    # Original unchanged
    assert_rel h1.get(5), 6.0, 1e-10, 'original h1 unchanged after div'
  end

  def test_histogram_div_operator
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    4.times { h1.increment(5.5) }
    2.times { h2.increment(5.5) }

    h3 = h1 / h2
    assert_rel h3.get(5), 2.0, 1e-10, 'histogram / operator (4 / 2 = 2)'
  end

  def test_histogram_div_inplace
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    8.times { h1.increment(5.5) }
    4.times { h2.increment(5.5) }

    h1.div!(h2)
    assert_rel h1.get(5), 2.0, 1e-10, 'histogram div! in-place (8 / 4 = 2)'
  end

  # Tests for histogram2d_oper (also in histogram_oper.c pattern)
  def test_histogram2d_operations
    h1 = GSL::Histogram2d.alloc(5, 5)
    h1.set_ranges_uniform(0, 5, 0, 5)
    h2 = GSL::Histogram2d.alloc(5, 5)
    h2.set_ranges_uniform(0, 5, 0, 5)

    h1.increment(2.5, 2.5)
    h2.increment(2.5, 2.5)

    # Test add
    h3 = h1.add(h2)
    assert_rel h3.get(2, 2), 2.0, 1e-10, '2D histogram add'

    # Test sub
    h4 = h3.sub(h1)
    assert_rel h4.get(2, 2), 1.0, 1e-10, '2D histogram sub'
  end

  # Tests for histogram3d operations
  def test_histogram3d_add
    h1 = GSL::Histogram3d.alloc(5, 5, 5)
    h1.set_ranges_uniform(0, 5, 0, 5, 0, 5)
    h2 = GSL::Histogram3d.alloc(5, 5, 5)
    h2.set_ranges_uniform(0, 5, 0, 5, 0, 5)

    h1.increment(2.5, 2.5, 2.5)
    h2.increment(2.5, 2.5, 2.5)

    h3 = h1.add(h2)
    assert_rel h3.get(2, 2, 2), 2.0, 1e-10, '3D histogram add'

    # Original unchanged
    assert_rel h1.get(2, 2, 2), 1.0, 1e-10, '3D histogram add original unchanged'
  end

  def test_histogram3d_sub
    h1 = GSL::Histogram3d.alloc(5, 5, 5)
    h1.set_ranges_uniform(0, 5, 0, 5, 0, 5)
    h2 = GSL::Histogram3d.alloc(5, 5, 5)
    h2.set_ranges_uniform(0, 5, 0, 5, 0, 5)

    h1.increment(2.5, 2.5, 2.5)
    h1.increment(2.5, 2.5, 2.5)
    h2.increment(2.5, 2.5, 2.5)

    h3 = h1.sub(h2)
    assert_rel h3.get(2, 2, 2), 1.0, 1e-10, '3D histogram sub'
  end

  def test_histogram3d_mul
    h1 = GSL::Histogram3d.alloc(5, 5, 5)
    h1.set_ranges_uniform(0, 5, 0, 5, 0, 5)
    h2 = GSL::Histogram3d.alloc(5, 5, 5)
    h2.set_ranges_uniform(0, 5, 0, 5, 0, 5)

    h1.increment(2.5, 2.5, 2.5)
    h1.increment(2.5, 2.5, 2.5)
    h2.increment(2.5, 2.5, 2.5)
    h2.increment(2.5, 2.5, 2.5)
    h2.increment(2.5, 2.5, 2.5)

    h3 = h1.mul(h2)
    assert_rel h3.get(2, 2, 2), 6.0, 1e-10, '3D histogram mul (2 * 3 = 6)'
  end

  def test_histogram3d_div
    h1 = GSL::Histogram3d.alloc(5, 5, 5)
    h1.set_ranges_uniform(0, 5, 0, 5, 0, 5)
    h2 = GSL::Histogram3d.alloc(5, 5, 5)
    h2.set_ranges_uniform(0, 5, 0, 5, 0, 5)

    6.times { h1.increment(2.5, 2.5, 2.5) }
    2.times { h2.increment(2.5, 2.5, 2.5) }

    h3 = h1.div(h2)
    assert_rel h3.get(2, 2, 2), 3.0, 1e-10, '3D histogram div (6 / 2 = 3)'
  end

  def test_histogram3d_operators
    h1 = GSL::Histogram3d.alloc(5, 5, 5)
    h1.set_ranges_uniform(0, 5, 0, 5, 0, 5)
    h2 = GSL::Histogram3d.alloc(5, 5, 5)
    h2.set_ranges_uniform(0, 5, 0, 5, 0, 5)

    h1.increment(2.5, 2.5, 2.5)
    h2.increment(2.5, 2.5, 2.5)

    # Test + operator
    h3 = h1 + h2
    assert_rel h3.get(2, 2, 2), 2.0, 1e-10, '3D histogram + operator'

    # Test - operator
    h4 = h3 - h1
    assert_rel h4.get(2, 2, 2), 1.0, 1e-10, '3D histogram - operator'

    # Test * operator
    h5 = h1 * h2
    assert_rel h5.get(2, 2, 2), 1.0, 1e-10, '3D histogram * operator'

    # Test / operator
    h1.increment(2.5, 2.5, 2.5)
    h6 = h1 / h2
    assert_rel h6.get(2, 2, 2), 2.0, 1e-10, '3D histogram / operator'
  end

  def test_histogram3d_scale_and_shift
    h = GSL::Histogram3d.alloc(5, 5, 5)
    h.set_ranges_uniform(0, 5, 0, 5, 0, 5)
    h.increment(2.5, 2.5, 2.5)

    # Test scale
    h2 = h.scale(3.0)
    assert_rel h2.get(2, 2, 2), 3.0, 1e-10, '3D histogram scale'

    # Test shift
    h3 = h.shift(5.0)
    assert_rel h3.get(2, 2, 2), 6.0, 1e-10, '3D histogram shift'

    # Original unchanged
    assert_rel h.get(2, 2, 2), 1.0, 1e-10, '3D histogram original unchanged'
  end

  def test_histogram3d_statistics
    h = GSL::Histogram3d.alloc(5, 5, 5)
    h.set_ranges_uniform(0, 5, 0, 5, 0, 5)

    h.increment(2.5, 2.5, 2.5)
    h.increment(2.5, 2.5, 2.5)
    h.increment(4.5, 4.5, 4.5)

    # Test max/min values
    assert_rel h.max_val, 2.0, 1e-10, '3D histogram max_val'
    assert_rel h.min_val, 0.0, 1e-10, '3D histogram min_val'

    # Test sum
    assert_rel h.sum, 3.0, 1e-10, '3D histogram sum'
  end

  # Test edge cases
  def test_histogram_operations_empty_bins
    h1 = GSL::Histogram.alloc(10)
    h1.set_ranges_uniform(0, 10)
    h2 = GSL::Histogram.alloc(10)
    h2.set_ranges_uniform(0, 10)

    # Operations on empty bins
    h3 = h1.add(h2)
    assert_rel h3.get(5), 0.0, 1e-10, 'add empty bins'

    h4 = h1.mul(h2)
    assert_rel h4.get(5), 0.0, 1e-10, 'mul empty bins'
  end

  def test_histogram_scale_and_shift
    h = GSL::Histogram.alloc(10)
    h.set_ranges_uniform(0, 10)
    h.increment(5.5)
    h.increment(5.5)

    # Test scale
    h2 = h.scale(2.0)
    assert_rel h2.get(5), 4.0, 1e-10, 'histogram scale'

    # Test shift
    h3 = h.shift(10.0)
    assert_rel h3.get(5), 12.0, 1e-10, 'histogram shift'

    # Original unchanged
    assert_rel h.get(5), 2.0, 1e-10, 'original unchanged after scale/shift'
  end

  def test_histogram_scale_and_shift_inplace
    h = GSL::Histogram.alloc(10)
    h.set_ranges_uniform(0, 10)
    h.increment(5.5)
    h.increment(5.5)

    h.scale!(3.0)
    assert_rel h.get(5), 6.0, 1e-10, 'histogram scale! in-place'

    h.shift!(4.0)
    assert_rel h.get(5), 10.0, 1e-10, 'histogram shift! in-place'
  end
end
