require 'test_helper'

class WaveletTest < GSL::TestCase

  def make_4x4_matrix
    m = GSL::Matrix.alloc(4, 4)
    4.times do |i|
      4.times do |j|
        m.set(i, j, i * 4.0 + j + 1.0)
      end
    end
    m
  end

  # Test Wavelet allocation with different types
  def test_wavelet_alloc_daubechies
    w = GSL::Wavelet.alloc("daubechies", 4)
    assert_equal "daubechies", w.name
  end

  def test_wavelet_alloc_daubechies_centered
    w = GSL::Wavelet.alloc("daubechies_centered", 4)
    assert_equal "daubechies-centered", w.name
  end

  def test_wavelet_alloc_haar
    w = GSL::Wavelet.alloc("haar", 2)
    assert_equal "haar", w.name
  end

  def test_wavelet_alloc_haar_centered
    w = GSL::Wavelet.alloc("haar_centered", 2)
    assert_equal "haar-centered", w.name
  end

  def test_wavelet_alloc_bspline
    w = GSL::Wavelet.alloc("bspline", 103)
    assert_equal "bspline", w.name
  end

  def test_wavelet_alloc_bspline_centered
    w = GSL::Wavelet.alloc("bspline_centered", 103)
    assert_equal "bspline-centered", w.name
  end

  # Test allocation with integer constants
  def test_wavelet_alloc_with_constant
    w = GSL::Wavelet.alloc(GSL::Wavelet::DAUBECHIES, 4)
    assert_equal "daubechies", w.name
  end

  def test_wavelet_alloc_haar_constant
    w = GSL::Wavelet.alloc(GSL::Wavelet::HAAR, 2)
    assert_equal "haar", w.name
  end

  def test_wavelet_alloc_bspline_constant
    w = GSL::Wavelet.alloc(GSL::Wavelet::BSPLINE, 103)
    assert_equal "bspline", w.name
  end

  def test_wavelet_alloc_daubechies_centered_constant
    w = GSL::Wavelet.alloc(GSL::Wavelet::DAUBECHIES_CENTERED, 4)
    assert_equal "daubechies-centered", w.name
  end

  def test_wavelet_alloc_haar_centered_constant
    w = GSL::Wavelet.alloc(GSL::Wavelet::HAAR_CENTERED, 2)
    assert_equal "haar-centered", w.name
  end

  def test_wavelet_alloc_bspline_centered_constant
    w = GSL::Wavelet.alloc(GSL::Wavelet::BSPLINE_CENTERED, 103)
    assert_equal "bspline-centered", w.name
  end

  # Test Workspace allocation
  def test_workspace_alloc
    work = GSL::Wavelet::Workspace.alloc(128)
    assert_kind_of GSL::Wavelet::Workspace, work
  end

  # Test 1D wavelet transform on vectors
  def test_wavelet_transform_vector
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    result = w.transform(v)
    assert_kind_of GSL::Vector, result
    assert_equal 8, result.size
    # Original should be unchanged
    assert_in_delta 1.0, v[0], 1e-10
  end

  def test_wavelet_transform_with_direction
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    result = w.transform(v, GSL::Wavelet::FORWARD)
    assert_kind_of GSL::Vector, result
  end

  def test_wavelet_transform_with_workspace
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    work = GSL::Wavelet::Workspace.alloc(8)
    result = w.transform(v, GSL::Wavelet::FORWARD, work)
    assert_kind_of GSL::Vector, result
  end

  def test_wavelet_transform_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    original_first = v[0]
    result = w.transform!(v)
    assert_same v, result
    # Value should have changed
    refute_equal original_first, v[0]
  end

  def test_wavelet_transform_forward
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    result = w.forward(v)
    assert_kind_of GSL::Vector, result
    assert_equal 8, result.size
  end

  def test_wavelet_transform_inverse
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    transformed = w.forward(v)
    reconstructed = w.inverse(transformed)
    assert_kind_of GSL::Vector, reconstructed
    8.times do |i|
      assert_in_delta v[i], reconstructed[i], 1e-10
    end
  end

  def test_wavelet_transform_forward_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    result = w.forward!(v)
    assert_same v, result
  end

  def test_wavelet_transform_inverse_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    w.forward!(v)
    result = w.inverse!(v)
    assert_same v, result
  end

  # Test using class methods
  def test_wavelet_class_transform
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    result = GSL::Wavelet.transform(w, v)
    assert_kind_of GSL::Vector, result
  end

  def test_wavelet_class_transform_forward
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    result = GSL::Wavelet.transform_forward(w, v)
    assert_kind_of GSL::Vector, result
  end

  def test_wavelet_class_transform_inverse
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    transformed = GSL::Wavelet.transform_forward(w, v)
    result = GSL::Wavelet.transform_inverse(w, transformed)
    assert_kind_of GSL::Vector, result
  end

  # Test vector methods
  def test_vector_wavelet_transform
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    result = v.wavelet_transform(w)
    assert_kind_of GSL::Vector, result
  end

  def test_vector_wavelet_transform_forward
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    result = v.wavelet_transform_forward(w)
    assert_kind_of GSL::Vector, result
  end

  def test_vector_wavelet_transform_inverse
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    transformed = v.wavelet_transform_forward(w)
    result = transformed.wavelet_transform_inverse(w)
    assert_kind_of GSL::Vector, result
  end

  def test_vector_wavelet_transform_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    result = v.wavelet_transform!(w)
    assert_same v, result
  end

  # Test 2D wavelet transforms on matrices
  def test_wavelet_transform_matrix
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = w.transform_matrix(m)
    assert_kind_of GSL::Matrix, result
    assert_equal 4, result.size1
    assert_equal 4, result.size2
  end

  def test_wavelet_transform_matrix_with_direction
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = w.transform_matrix(m, GSL::Wavelet::FORWARD)
    assert_kind_of GSL::Matrix, result
  end

  def test_wavelet_transform_matrix_with_workspace
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    work = GSL::Wavelet::Workspace.alloc(4)
    result = w.transform_matrix(m, GSL::Wavelet::FORWARD, work)
    assert_kind_of GSL::Matrix, result
  end

  def test_wavelet_transform_matrix_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = w.transform_matrix!(m)
    assert_same m, result
  end

  def test_wavelet_transform_matrix_forward
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = w.transform_matrix_forward(m)
    assert_kind_of GSL::Matrix, result
  end

  def test_wavelet_transform_matrix_inverse
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    original = make_4x4_matrix
    transformed = w.transform_matrix_forward(m)
    result = w.transform_matrix_inverse(transformed)
    assert_kind_of GSL::Matrix, result
    # Verify reconstruction
    4.times do |i|
      4.times do |j|
        assert_in_delta original.get(i, j), result.get(i, j), 1e-10
      end
    end
  end

  def test_wavelet_transform_matrix_forward_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = w.transform_matrix_forward!(m)
    assert_same m, result
  end

  def test_wavelet_transform_matrix_inverse_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    w.transform_matrix_forward!(m)
    result = w.transform_matrix_inverse!(m)
    assert_same m, result
  end

  # Test matrix methods
  def test_matrix_wavelet_transform
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = m.wavelet_transform(w)
    assert_kind_of GSL::Matrix, result
  end

  def test_matrix_wavelet_transform_forward
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = m.wavelet_transform_forward(w)
    assert_kind_of GSL::Matrix, result
  end

  def test_matrix_wavelet_transform_inverse
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    transformed = m.wavelet_transform_forward(w)
    result = transformed.wavelet_transform_inverse(w)
    assert_kind_of GSL::Matrix, result
  end

  def test_matrix_wavelet_transform_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = m.wavelet_transform!(w)
    assert_same m, result
  end

  # Test non-standard transform (nstransform)
  def test_wavelet_nstransform_matrix
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = w.nstransform_matrix(m)
    assert_kind_of GSL::Matrix, result
  end

  def test_wavelet_nstransform_matrix_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = w.nstransform_matrix!(m)
    assert_same m, result
  end

  def test_wavelet_nstransform_matrix_forward
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = w.nstransform_matrix_forward(m)
    assert_kind_of GSL::Matrix, result
  end

  def test_wavelet_nstransform_matrix_inverse
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    transformed = w.nstransform_matrix_forward(m)
    result = w.nstransform_matrix_inverse(transformed)
    assert_kind_of GSL::Matrix, result
  end

  def test_wavelet_nstransform_matrix_forward_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    result = w.nstransform_matrix_forward!(m)
    assert_same m, result
  end

  def test_wavelet_nstransform_matrix_inverse_inplace
    w = GSL::Wavelet.alloc("haar", 2)
    m = make_4x4_matrix
    w.nstransform_matrix_forward!(m)
    result = w.nstransform_matrix_inverse!(m)
    assert_same m, result
  end

  # Test different wavelet types with transforms
  def test_daubechies_transform
    w = GSL::Wavelet.alloc("daubechies", 4)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    transformed = w.forward(v)
    reconstructed = w.inverse(transformed)
    8.times do |i|
      assert_in_delta v[i], reconstructed[i], 1e-10
    end
  end

  def test_bspline_transform
    w = GSL::Wavelet.alloc("bspline", 103)
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0])
    transformed = w.forward(v)
    reconstructed = w.inverse(transformed)
    8.times do |i|
      assert_in_delta v[i], reconstructed[i], 1e-10
    end
  end

  # Test round-trip with larger data
  def test_roundtrip_larger_vector
    w = GSL::Wavelet.alloc("haar", 2)
    v = GSL::Vector.alloc(128)
    128.times { |i| v[i] = Math.sin(2 * Math::PI * i / 128.0) }
    transformed = w.forward(v)
    reconstructed = w.inverse(transformed)
    128.times do |i|
      assert_in_delta v[i], reconstructed[i], 1e-10
    end
  end

  def test_roundtrip_larger_matrix
    w = GSL::Wavelet.alloc("haar", 2)
    m = GSL::Matrix.alloc(8, 8)
    8.times do |i|
      8.times do |j|
        m.set(i, j, i * 8.0 + j)
      end
    end
    transformed = w.transform_matrix_forward(m)
    reconstructed = w.transform_matrix_inverse(transformed)
    8.times do |i|
      8.times do |j|
        assert_in_delta m.get(i, j), reconstructed.get(i, j), 1e-10
      end
    end
  end

end
