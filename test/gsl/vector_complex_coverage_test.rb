require 'test_helper'

class VectorComplexCoverageTest < GSL::TestCase
  # ======= Constructors =======

  def test_new_with_fixnum
    v = GSL::Vector::Complex.alloc(5)
    assert_equal 5, v.size
    # All zeros
    assert_in_delta 0.0, v[0].real, 1e-10
    assert_in_delta 0.0, v[0].imag, 1e-10
  end

  def test_new_with_array_of_arrays
    v = GSL::Vector::Complex.alloc([[1.0, 2.0], [3.0, 4.0]])
    assert_equal 2, v.size
    assert_in_delta 1.0, v[0].real, 1e-10
    assert_in_delta 2.0, v[0].imag, 1e-10
    assert_in_delta 3.0, v[1].real, 1e-10
    assert_in_delta 4.0, v[1].imag, 1e-10
  end

  def test_new_with_array_of_complex
    z1 = GSL::Complex.alloc(1.0, 2.0)
    z2 = GSL::Complex.alloc(3.0, 4.0)
    v = GSL::Vector::Complex.alloc([z1, z2])
    assert_equal 2, v.size
    assert_in_delta 1.0, v[0].real, 1e-10
    assert_in_delta 2.0, v[0].imag, 1e-10
  end

  def test_new_with_two_vectors
    vr = GSL::Vector[1.0, 2.0, 3.0]
    vi = GSL::Vector[4.0, 5.0, 6.0]
    vc = GSL::Vector::Complex.alloc(vr, vi)
    assert_equal 3, vc.size
    assert_in_delta 1.0, vc[0].real, 1e-10
    assert_in_delta 4.0, vc[0].imag, 1e-10
    assert_in_delta 2.0, vc[1].real, 1e-10
    assert_in_delta 5.0, vc[1].imag, 1e-10
  end

  def test_new_with_multiple_arrays
    v = GSL::Vector::Complex[[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]
    assert_equal 3, v.size
    assert_in_delta 1.0, v[0].real, 1e-10
    assert_in_delta 5.0, v[2].real, 1e-10
  end

  def test_new_with_multiple_complex
    z1 = GSL::Complex.alloc(1.0, 2.0)
    z2 = GSL::Complex.alloc(3.0, 4.0)
    v = GSL::Vector::Complex[z1, z2]
    assert_equal 2, v.size
  end

  def test_new_with_wrong_type_in_array
    assert_raises(TypeError) do
      GSL::Vector::Complex.alloc(["invalid"])
    end
  end

  def test_new_with_wrong_arg_type
    assert_raises(TypeError) do
      GSL::Vector::Complex.alloc("invalid")
    end
  end

  def test_new_with_wrong_arg_type_varargs
    assert_raises(TypeError) do
      GSL::Vector::Complex["invalid"]
    end
  end

  def test_calloc
    v = GSL::Vector::Complex.calloc(5)
    assert_equal 5, v.size
    assert_in_delta 0.0, v[0].real, 1e-10
  end

  # ======= Get operations =======

  def test_get_with_fixnum
    v = GSL::Vector::Complex.alloc(3)
    v[1] = GSL::Complex.alloc(5.0, 6.0)
    z = v[1]
    assert z.is_a?(GSL::Complex)
    assert_in_delta 5.0, z.real, 1e-10
    assert_in_delta 6.0, z.imag, 1e-10
  end

  def test_get_with_negative_index
    v = GSL::Vector::Complex.alloc(3)
    v[2] = GSL::Complex.alloc(5.0, 6.0)
    z = v[-1]
    assert_in_delta 5.0, z.real, 1e-10
  end

  def test_get_with_array
    v = GSL::Vector::Complex.alloc(5)
    v[1] = GSL::Complex.alloc(1.0, 0.0)
    v[3] = GSL::Complex.alloc(3.0, 0.0)

    result = v[[1, 3]]
    assert result.is_a?(GSL::Vector::Complex)
    assert_equal 2, result.size
    assert_in_delta 1.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[1].real, 1e-10
  end

  def test_get_with_array_negative_index
    v = GSL::Vector::Complex.alloc(5)
    v[4] = GSL::Complex.alloc(4.0, 0.0)

    result = v[[-1]]
    assert_in_delta 4.0, result[0].real, 1e-10
  end

  def test_get_with_range
    v = GSL::Vector::Complex.alloc(5)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(1.0, 0.0)
    v[2] = GSL::Complex.alloc(2.0, 0.0)

    result = v[0..2]
    assert result.is_a?(GSL::Vector::Complex) || result.is_a?(GSL::Vector::Complex::View)
    assert_equal 3, result.size
  end

  def test_get_with_permutation
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(10.0, 0.0)
    v[1] = GSL::Complex.alloc(20.0, 0.0)
    v[2] = GSL::Complex.alloc(30.0, 0.0)

    p = GSL::Permutation.alloc(3)
    p.init
    p.swap(0, 2)  # [2, 1, 0]

    result = v[p]
    assert result.is_a?(GSL::Vector::Complex)
    assert_in_delta 30.0, result[0].real, 1e-10  # v[2]
    assert_in_delta 10.0, result[2].real, 1e-10  # v[0]
  end

  def test_get_wrong_type
    v = GSL::Vector::Complex.alloc(3)
    assert_raises(TypeError) do
      v["invalid"]
    end
  end

  # ======= Set operations =======

  def test_set_all_with_complex
    v = GSL::Vector::Complex.alloc(3)
    z = GSL::Complex.alloc(5.0, 6.0)
    v.set_all(z)
    assert_in_delta 5.0, v[0].real, 1e-10
    assert_in_delta 5.0, v[1].real, 1e-10
    assert_in_delta 5.0, v[2].real, 1e-10
  end

  def test_set_all_with_two_floats
    v = GSL::Vector::Complex.alloc(3)
    v.set_all(5.0, 6.0)
    assert_in_delta 5.0, v[0].real, 1e-10
    assert_in_delta 6.0, v[0].imag, 1e-10
  end

  def test_set_all_wrong_args
    v = GSL::Vector::Complex.alloc(3)
    assert_raises(ArgumentError) do
      v.set_all
    end
  end

  def test_set_all_too_many_args
    v = GSL::Vector::Complex.alloc(3)
    assert_raises(ArgumentError) do
      v.set_all(1.0, 2.0, 3.0)
    end
  end

  def test_set_with_index
    v = GSL::Vector::Complex.alloc(3)
    z = GSL::Complex.alloc(5.0, 6.0)
    v[1] = z
    assert_in_delta 5.0, v[1].real, 1e-10
    assert_in_delta 6.0, v[1].imag, 1e-10
  end

  def test_set_with_negative_index
    v = GSL::Vector::Complex.alloc(3)
    z = GSL::Complex.alloc(5.0, 6.0)
    v[-1] = z
    assert_in_delta 5.0, v[2].real, 1e-10
    assert_in_delta 6.0, v[2].imag, 1e-10
  end

  def test_set_subvector_with_vector
    v = GSL::Vector::Complex.alloc(5)
    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(1.0, 0.0)
    v2[1] = GSL::Complex.alloc(2.0, 0.0)
    v2[2] = GSL::Complex.alloc(3.0, 0.0)

    v[1, 3] = v2
    assert_in_delta 1.0, v[1].real, 1e-10
    assert_in_delta 2.0, v[2].real, 1e-10
    assert_in_delta 3.0, v[3].real, 1e-10
  end

  def test_set_subvector_with_array
    v = GSL::Vector::Complex.alloc(5)
    z1 = GSL::Complex.alloc(1.0, 0.0)
    z2 = GSL::Complex.alloc(2.0, 0.0)

    v[1, 2] = [z1, z2]
    assert_in_delta 1.0, v[1].real, 1e-10
    assert_in_delta 2.0, v[2].real, 1e-10
  end

  def test_set_subvector_with_range
    v = GSL::Vector::Complex.alloc(5)
    v[1, 3] = 10..12
    assert_in_delta 10.0, v[1].real, 1e-10
    assert_in_delta 11.0, v[2].real, 1e-10
    assert_in_delta 12.0, v[3].real, 1e-10
  end

  def test_set_subvector_with_scalar
    v = GSL::Vector::Complex.alloc(5)
    z = GSL::Complex.alloc(5.0, 0.0)
    # Using 2-argument form: offset, length, value
    v.set(1, z)  # Just set one element
    assert_in_delta 5.0, v[1].real, 1e-10
  end

  def test_set_subvector_length_mismatch_vector
    v = GSL::Vector::Complex.alloc(5)
    v2 = GSL::Vector::Complex.alloc(2)

    assert_raises(RangeError) do
      v[1, 3] = v2  # Lengths don't match
    end
  end

  def test_set_subvector_length_mismatch_array
    v = GSL::Vector::Complex.alloc(5)
    z1 = GSL::Complex.alloc(1.0, 0.0)

    assert_raises(RangeError) do
      v[1, 3] = [z1]  # Lengths don't match
    end
  end

  def test_set_subvector_length_mismatch_range
    v = GSL::Vector::Complex.alloc(5)

    assert_raises(RangeError) do
      v[1, 3] = 10..20  # Lengths don't match
    end
  end

  def test_set_wrong_args
    v = GSL::Vector::Complex.alloc(3)
    assert_raises(ArgumentError) do
      v[1, 2, 3, 4, 5] = GSL::Complex.alloc(1.0, 0.0)
    end
  end

  # ======= Iteration =======

  def test_each
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    sum = 0.0
    v.each { |z| sum += z.real }
    assert_in_delta 6.0, sum, 1e-10
  end

  def test_reverse_each
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    values = []
    v.reverse_each { |z| values << z.real }
    assert_equal [3.0, 2.0, 1.0], values
  end

  def test_each_index
    v = GSL::Vector::Complex.alloc(3)
    indices = []
    v.each_index { |i| indices << i }
    assert_equal [0, 1, 2], indices
  end

  def test_reverse_each_index
    v = GSL::Vector::Complex.alloc(3)
    indices = []
    v.reverse_each_index { |i| indices << i }
    assert_equal [2, 1, 0], indices
  end

  def test_collect
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    result = v.collect { |z| GSL::Complex.alloc(z.real * 2, z.imag) }
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 4.0, result[1].real, 1e-10
    # Original unchanged
    assert_in_delta 1.0, v[0].real, 1e-10
  end

  def test_collect_bang
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    v.collect! { |z| GSL::Complex.alloc(z.real * 2, z.imag) }
    assert_in_delta 2.0, v[0].real, 1e-10
    assert_in_delta 4.0, v[1].real, 1e-10
  end

  # ======= Properties =======

  def test_size
    v = GSL::Vector::Complex.alloc(7)
    assert_equal 7, v.size
  end

  def test_stride
    v = GSL::Vector::Complex.alloc(5)
    assert_equal 1, v.stride
  end

  def test_owner
    v = GSL::Vector::Complex.alloc(5)
    # Owner should be 1 for allocated vectors
    assert_equal 1, v.owner
  end

  def test_ptr
    v = GSL::Vector::Complex.alloc(3)
    v[1] = GSL::Complex.alloc(5.0, 6.0)
    p = v.ptr(1)
    assert p.is_a?(GSL::Complex)
    assert_in_delta 5.0, p.real, 1e-10
  end

  # ======= Set operations =======

  def test_set_zero
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(5.0, 6.0)
    v.set_zero
    assert_in_delta 0.0, v[0].real, 1e-10
    assert_in_delta 0.0, v[0].imag, 1e-10
  end

  def test_set_basis
    v = GSL::Vector::Complex.alloc(3)
    v.set_basis(1)
    assert_in_delta 0.0, v[0].real, 1e-10
    assert_in_delta 1.0, v[1].real, 1e-10
    assert_in_delta 0.0, v[2].real, 1e-10
  end

  # ======= String conversions =======

  def test_to_s_empty
    v = GSL::Vector::Complex.alloc(0)
    s = v.to_s
    assert_equal "[ ]", s
  end

  def test_to_s_row
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    s = v.to_s
    assert s.include?("[")
    assert s.include?("]")
  end

  def test_to_s_column
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    vc = v.col
    s = vc.to_s
    assert s.include?("[")
  end

  def test_to_s_large_row
    v = GSL::Vector::Complex.alloc(20)
    s = v.to_s
    assert s.include?("...")
  end

  def test_to_s_large_column
    v = GSL::Vector::Complex.alloc(20)
    vc = v.col
    s = vc.to_s
    assert s.include?("...")
  end

  def test_inspect
    v = GSL::Vector::Complex.alloc(2)
    s = v.inspect
    assert s.include?("Vector::Complex")
    assert s.include?("[2]")
  end

  # ======= Row/Column conversion =======

  def test_col
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    vc = v.col
    assert vc.is_a?(GSL::Vector::Complex)
    assert_in_delta 1.0, vc[0].real, 1e-10
  end

  def test_row
    v = GSL::Vector::Complex.alloc(3)
    vc = v.col
    vr = vc.row
    assert vr.is_a?(GSL::Vector::Complex)
  end

  # ======= I/O operations =======

  def test_fprintf_wrong_args
    v = GSL::Vector::Complex.alloc(3)
    assert_raises(ArgumentError) do
      v.fprintf
    end
  end

  # ======= Real/Imag views and setters =======

  def test_real_view
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    v[2] = GSL::Complex.alloc(5.0, 6.0)

    real_part = v.real
    assert real_part.is_a?(GSL::Vector) || real_part.is_a?(GSL::Vector::View)
    assert_equal 3, real_part.size
    assert_in_delta 1.0, real_part[0], 1e-10
    assert_in_delta 3.0, real_part[1], 1e-10
    assert_in_delta 5.0, real_part[2], 1e-10
  end

  def test_imag_view
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    v[2] = GSL::Complex.alloc(5.0, 6.0)

    imag_part = v.imag
    assert imag_part.is_a?(GSL::Vector) || imag_part.is_a?(GSL::Vector::View)
    assert_equal 3, imag_part.size
    assert_in_delta 2.0, imag_part[0], 1e-10
    assert_in_delta 4.0, imag_part[1], 1e-10
    assert_in_delta 6.0, imag_part[2], 1e-10
  end

  def test_real_view_col
    v = GSL::Vector::Complex.alloc(3).col
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    real_part = v.real
    assert_in_delta 1.0, real_part[0], 1e-10
  end

  def test_imag_view_col
    v = GSL::Vector::Complex.alloc(3).col
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    imag_part = v.imag
    assert_in_delta 2.0, imag_part[0], 1e-10
  end

  def test_set_real
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v.set_real(10.0)
    assert_in_delta 10.0, v[0].real, 1e-10
    assert_in_delta 10.0, v[1].real, 1e-10
    assert_in_delta 10.0, v[2].real, 1e-10
    # Imaginary parts unchanged
    assert_in_delta 2.0, v[0].imag, 1e-10
  end

  def test_set_imag
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v.set_imag(20.0)
    # Real parts unchanged
    assert_in_delta 1.0, v[0].real, 1e-10
    assert_in_delta 20.0, v[0].imag, 1e-10
    assert_in_delta 20.0, v[1].imag, 1e-10
    assert_in_delta 20.0, v[2].imag, 1e-10
  end

  # ======= Conjugate =======

  def test_conj
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, -4.0)

    result = v.conj
    assert_in_delta 1.0, result[0].real, 1e-10
    assert_in_delta(-2.0, result[0].imag, 1e-10)
    assert_in_delta 3.0, result[1].real, 1e-10
    assert_in_delta 4.0, result[1].imag, 1e-10
    # Original unchanged
    assert_in_delta 2.0, v[0].imag, 1e-10
  end

  def test_conj_bang
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, -4.0)

    v.conj!
    assert_in_delta 1.0, v[0].real, 1e-10
    assert_in_delta(-2.0, v[0].imag, 1e-10)
    assert_in_delta 3.0, v[1].real, 1e-10
    assert_in_delta 4.0, v[1].imag, 1e-10
  end

  # ======= Array conversions =======

  def test_to_a
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)

    arr = v.to_a
    assert arr.is_a?(Array)
    assert_equal 4, arr.size  # Flattened: [re0, im0, re1, im1]
    assert_in_delta 1.0, arr[0], 1e-10
    assert_in_delta 2.0, arr[1], 1e-10
    assert_in_delta 3.0, arr[2], 1e-10
    assert_in_delta 4.0, arr[3], 1e-10
  end

  def test_to_a2
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)

    arr = v.to_a2
    assert arr.is_a?(Array)
    assert_equal 2, arr.size  # Array of Complex objects
    assert arr[0].is_a?(GSL::Complex)
    assert_in_delta 1.0, arr[0].real, 1e-10
    assert_in_delta 2.0, arr[0].imag, 1e-10
  end

  # ======= Subvector =======

  def test_subvector
    v = GSL::Vector::Complex.alloc(5)
    v[2] = GSL::Complex.alloc(2.0, 0.0)
    v[3] = GSL::Complex.alloc(3.0, 0.0)

    sub = v.subvector(2, 2)  # Start at 2, length 2
    assert_equal 2, sub.size
    assert_in_delta 2.0, sub[0].real, 1e-10
    assert_in_delta 3.0, sub[1].real, 1e-10
  end

  def test_subvector_with_stride
    v = GSL::Vector::Complex.alloc(6)
    (0..5).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    sub = v.subvector_with_stride(0, 2, 3)  # offset=0, stride=2, length=3
    assert_equal 3, sub.size
    assert_in_delta 0.0, sub[0].real, 1e-10
    assert_in_delta 2.0, sub[1].real, 1e-10
    assert_in_delta 4.0, sub[2].real, 1e-10
  end

  def test_subvector_with_stride_negative_offset
    v = GSL::Vector::Complex.alloc(6)
    (0..5).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    sub = v.subvector_with_stride(-3, 1, 2)  # offset=-3 (=3), stride=1, length=2
    assert_equal 2, sub.size
    assert_in_delta 3.0, sub[0].real, 1e-10
    assert_in_delta 4.0, sub[1].real, 1e-10
  end

  def test_subvector_col
    v = GSL::Vector::Complex.alloc(5).col
    v[2] = GSL::Complex.alloc(2.0, 0.0)

    sub = v.subvector(2, 2)
    assert_in_delta 2.0, sub[0].real, 1e-10
  end

  # ======= Clone and Memcpy =======

  def test_clone
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)

    vc = v.clone
    assert_equal v.size, vc.size
    assert_in_delta 1.0, vc[0].real, 1e-10
    # Modifying clone doesn't affect original
    vc[0] = GSL::Complex.alloc(99.0, 0.0)
    assert_in_delta 1.0, v[0].real, 1e-10
  end

  def test_clone_col
    v = GSL::Vector::Complex.alloc(3).col
    v[0] = GSL::Complex.alloc(1.0, 2.0)

    vc = v.clone
    assert_in_delta 1.0, vc[0].real, 1e-10
  end

  def test_memcpy
    src = GSL::Vector::Complex.alloc(3)
    src[0] = GSL::Complex.alloc(1.0, 2.0)
    src[1] = GSL::Complex.alloc(3.0, 4.0)

    dst = GSL::Vector::Complex.alloc(3)
    GSL::Vector::Complex.memcpy(dst, src)

    assert_in_delta 1.0, dst[0].real, 1e-10
    assert_in_delta 2.0, dst[0].imag, 1e-10
    assert_in_delta 3.0, dst[1].real, 1e-10
  end

  # ======= Reverse =======

  def test_reverse_bang
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    v.reverse!
    assert_in_delta 3.0, v[0].real, 1e-10
    assert_in_delta 2.0, v[1].real, 1e-10
    assert_in_delta 1.0, v[2].real, 1e-10
  end

  def test_reverse
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    vr = v.reverse
    assert_in_delta 3.0, vr[0].real, 1e-10
    assert_in_delta 2.0, vr[1].real, 1e-10
    assert_in_delta 1.0, vr[2].real, 1e-10
    # Original unchanged
    assert_in_delta 1.0, v[0].real, 1e-10
  end

  def test_reverse_col
    v = GSL::Vector::Complex.alloc(3).col
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    vr = v.reverse
    assert_in_delta 3.0, vr[0].real, 1e-10
  end

  def test_swap_elements
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    v.swap_elements(0, 2)
    assert_in_delta 3.0, v[0].real, 1e-10
    assert_in_delta 1.0, v[2].real, 1e-10
  end

  # ======= FFT shift =======

  def test_fftshift_even
    v = GSL::Vector::Complex.alloc(4)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(1.0, 0.0)
    v[2] = GSL::Complex.alloc(2.0, 0.0)
    v[3] = GSL::Complex.alloc(3.0, 0.0)

    result = v.fftshift
    # For even: [0,1,2,3] -> [2,3,0,1]
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[1].real, 1e-10
    assert_in_delta 0.0, result[2].real, 1e-10
    assert_in_delta 1.0, result[3].real, 1e-10
  end

  def test_fftshift_odd
    v = GSL::Vector::Complex.alloc(5)
    (0..4).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    result = v.fftshift
    # For odd: [0,1,2,3,4] -> [3,4,0,1,2]
    assert_in_delta 3.0, result[0].real, 1e-10
    assert_in_delta 4.0, result[1].real, 1e-10
    assert_in_delta 0.0, result[2].real, 1e-10
  end

  def test_fftshift_bang_even
    v = GSL::Vector::Complex.alloc(4)
    (0..3).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    v.fftshift!
    assert_in_delta 2.0, v[0].real, 1e-10
    assert_in_delta 3.0, v[1].real, 1e-10
  end

  def test_fftshift_bang_odd
    v = GSL::Vector::Complex.alloc(5)
    (0..4).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    v.fftshift!
    assert_in_delta 3.0, v[0].real, 1e-10
    assert_in_delta 4.0, v[1].real, 1e-10
  end

  def test_ifftshift_even
    v = GSL::Vector::Complex.alloc(4)
    (0..3).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    result = v.ifftshift
    # ifftshift is inverse of fftshift
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[1].real, 1e-10
  end

  def test_ifftshift_odd
    v = GSL::Vector::Complex.alloc(5)
    (0..4).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    result = v.ifftshift
    assert_in_delta 2.0, result[0].real, 1e-10
  end

  def test_ifftshift_bang_even
    v = GSL::Vector::Complex.alloc(4)
    (0..3).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    v.ifftshift!
    assert_in_delta 2.0, v[0].real, 1e-10
  end

  def test_ifftshift_bang_odd
    v = GSL::Vector::Complex.alloc(5)
    (0..4).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    v.ifftshift!
    assert_in_delta 2.0, v[0].real, 1e-10
  end

  # ======= isnull =======

  def test_isnull_true
    v = GSL::Vector::Complex.alloc(3)
    assert v.isnull
  end

  def test_isnull_false
    v = GSL::Vector::Complex.alloc(3)
    v[1] = GSL::Complex.alloc(1.0, 0.0)
    refute v.isnull
  end

  # ======= Matrix view =======

  def test_matrix_view
    v = GSL::Vector::Complex.alloc(6)
    (0..5).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    m = v.matrix_view(2, 3)  # 2 rows, 3 cols
    assert m.is_a?(GSL::Matrix::Complex) || m.is_a?(GSL::Matrix::Complex::View)
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 0.0, m[0, 0].real, 1e-10
    assert_in_delta 1.0, m[0, 1].real, 1e-10
  end

  def test_matrix_view_with_tda
    v = GSL::Vector::Complex.alloc(8)
    (0..7).each { |i| v[i] = GSL::Complex.alloc(i.to_f, 0.0) }

    m = v.matrix_view_with_tda(2, 3, 4)  # 2 rows, 3 cols, tda=4
    assert_equal 2, m.size1
    assert_equal 3, m.size2
  end

  def test_matrix_view_wrong_args
    v = GSL::Vector::Complex.alloc(6)
    assert_raises(ArgumentError) do
      v.matrix_view(1)  # Wrong number of args
    end
  end

  # ======= Transpose =======

  def test_trans
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    vt = v.trans
    assert_in_delta 1.0, vt[0].real, 1e-10
  end

  def test_trans_bang
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    v.trans!
    # Should flip row/col type
    v.trans!
    assert_in_delta 1.0, v[0].real, 1e-10
  end

  def test_trans_col
    v = GSL::Vector::Complex.alloc(3).col
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    vt = v.trans
    assert_in_delta 1.0, vt[0].real, 1e-10
  end

  # ======= to_real =======

  def test_to_real
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    v[2] = GSL::Complex.alloc(5.0, 6.0)

    real = v.to_real
    assert real.is_a?(GSL::Vector)
    assert_equal 3, real.size
    assert_in_delta 1.0, real[0], 1e-10
    assert_in_delta 3.0, real[1], 1e-10
    assert_in_delta 5.0, real[2], 1e-10
  end

  def test_to_real_col
    v = GSL::Vector::Complex.alloc(3).col
    v[0] = GSL::Complex.alloc(1.0, 2.0)

    real = v.to_real
    assert_in_delta 1.0, real[0], 1e-10
  end

  # ======= Arithmetic operations =======

  def test_add_with_float
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)

    result = v.add(5.0)
    assert_in_delta 6.0, result[0].real, 1e-10
    assert_in_delta 2.0, result[0].imag, 1e-10
  end

  def test_add_with_complex
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    z = GSL::Complex.alloc(3.0, 4.0)

    result = v.add(z)
    assert_in_delta 4.0, result[0].real, 1e-10
    assert_in_delta 6.0, result[0].imag, 1e-10
  end

  def test_add_with_vector
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)
    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(3.0, 4.0)

    result = v1.add(v2)
    assert_in_delta 4.0, result[0].real, 1e-10
    assert_in_delta 6.0, result[0].imag, 1e-10
  end

  def test_add_with_real_vector
    vc = GSL::Vector::Complex.alloc(3)
    vc[0] = GSL::Complex.alloc(1.0, 2.0)
    vr = GSL::Vector[3.0, 0.0, 0.0]

    result = vc.add(vr)
    assert_in_delta 4.0, result[0].real, 1e-10
    assert_in_delta 2.0, result[0].imag, 1e-10
  end

  def test_sub_with_float
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(5.0, 2.0)

    result = v.sub(3.0)
    assert_in_delta 2.0, result[0].real, 1e-10
  end

  def test_sub_with_complex
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(5.0, 6.0)
    z = GSL::Complex.alloc(2.0, 3.0)

    result = v.sub(z)
    assert_in_delta 3.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[0].imag, 1e-10
  end

  def test_sub_with_vector
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(5.0, 6.0)
    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(2.0, 3.0)

    result = v1.sub(v2)
    assert_in_delta 3.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[0].imag, 1e-10
  end

  def test_sub_with_real_vector
    vc = GSL::Vector::Complex.alloc(3)
    vc[0] = GSL::Complex.alloc(5.0, 2.0)
    vr = GSL::Vector[3.0, 0.0, 0.0]

    result = vc.sub(vr)
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 2.0, result[0].imag, 1e-10
  end

  def test_mul_with_float
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(2.0, 3.0)

    result = v.mul(2.0)
    assert_in_delta 4.0, result[0].real, 1e-10
    assert_in_delta 6.0, result[0].imag, 1e-10
  end

  def test_mul_with_complex
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    z = GSL::Complex.alloc(3.0, 4.0)

    result = v.mul(z)
    # (1+2i)(3+4i) = 3 + 4i + 6i + 8i^2 = 3 + 10i - 8 = -5 + 10i
    assert_in_delta(-5.0, result[0].real, 1e-10)
    assert_in_delta 10.0, result[0].imag, 1e-10
  end

  def test_mul_with_vector
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)
    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(3.0, 4.0)

    result = v1.mul(v2)
    assert_in_delta(-5.0, result[0].real, 1e-10)
    assert_in_delta 10.0, result[0].imag, 1e-10
  end

  def test_mul_with_real_vector
    vc = GSL::Vector::Complex.alloc(3)
    vc[0] = GSL::Complex.alloc(2.0, 3.0)
    vr = GSL::Vector[2.0, 1.0, 1.0]

    result = vc.mul(vr)
    assert_in_delta 4.0, result[0].real, 1e-10
    assert_in_delta 6.0, result[0].imag, 1e-10
  end

  def test_div_with_float
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(4.0, 6.0)

    result = v.div(2.0)
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[0].imag, 1e-10
  end

  def test_div_with_complex
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(5.0, 10.0)
    z = GSL::Complex.alloc(1.0, 2.0)

    result = v.div(z)
    # (5+10i)/(1+2i) = (5+10i)(1-2i)/5 = (5 - 10i + 10i + 20)/5 = 25/5 = 5
    assert_in_delta 5.0, result[0].real, 1e-10
    assert_in_delta 0.0, result[0].imag, 1e-10
  end

  def test_div_with_vector
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(5.0, 10.0)
    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(1.0, 2.0)

    result = v1.div(v2)
    assert_in_delta 5.0, result[0].real, 1e-10
    assert_in_delta 0.0, result[0].imag, 1e-10
  end

  def test_div_with_real_vector
    vc = GSL::Vector::Complex.alloc(3)
    vc[0] = GSL::Complex.alloc(4.0, 6.0)
    vr = GSL::Vector[2.0, 1.0, 1.0]

    result = vc.div(vr)
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 3.0, result[0].imag, 1e-10
  end

  # ======= In-place arithmetic =======

  def test_add_bang
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v.add!(5.0)
    assert_in_delta 6.0, v[0].real, 1e-10
  end

  def test_sub_bang
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(5.0, 2.0)
    v.sub!(3.0)
    assert_in_delta 2.0, v[0].real, 1e-10
  end

  def test_mul_bang
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(2.0, 3.0)
    v.mul!(2.0)
    assert_in_delta 4.0, v[0].real, 1e-10
    assert_in_delta 6.0, v[0].imag, 1e-10
  end

  def test_div_bang
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(4.0, 6.0)
    v.div!(2.0)
    assert_in_delta 2.0, v[0].real, 1e-10
    assert_in_delta 3.0, v[0].imag, 1e-10
  end

  # ======= Arithmetic operators =======

  def test_operator_plus
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)
    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(3.0, 4.0)

    result = v1 + v2
    assert_in_delta 4.0, result[0].real, 1e-10
  end

  def test_operator_minus
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(5.0, 6.0)
    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(2.0, 3.0)

    result = v1 - v2
    assert_in_delta 3.0, result[0].real, 1e-10
  end

  def test_operator_multiply
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(2.0, 3.0)

    result = v1 * 2.0
    assert_in_delta 4.0, result[0].real, 1e-10
  end

  def test_operator_divide
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(4.0, 6.0)

    result = v / 2.0
    assert_in_delta 2.0, result[0].real, 1e-10
  end

  def test_wrong_type_arithmetic
    v = GSL::Vector::Complex.alloc(3)
    assert_raises(TypeError) do
      v.add("invalid")
    end
  end

  # ======= Coerce =======

  def test_coerce_with_float
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)

    result = 2.0 + v
    assert_in_delta 3.0, result[0].real, 1e-10
    assert_in_delta 2.0, result[0].imag, 1e-10
  end

  def test_coerce_wrong_type
    v = GSL::Vector::Complex.alloc(3)
    assert_raises(TypeError) do
      v.coerce("invalid")
    end
  end

  # ======= Inner product =======

  def test_inner_product_instance
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 0.0)
    v1[1] = GSL::Complex.alloc(2.0, 0.0)
    v1[2] = GSL::Complex.alloc(3.0, 0.0)

    v2 = v1.col
    result = v1.inner_product(v2)
    # 1*1 + 2*2 + 3*3 = 14
    assert result.is_a?(GSL::Complex)
    assert_in_delta 14.0, result.real, 1e-10
  end

  def test_inner_product_class_method
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 0.0)
    v1[1] = GSL::Complex.alloc(2.0, 0.0)

    v2 = GSL::Vector::Complex.alloc(3).col
    v2[0] = GSL::Complex.alloc(3.0, 0.0)
    v2[1] = GSL::Complex.alloc(4.0, 0.0)

    result = GSL::Vector::Complex.inner_product(v1, v2)
    # 1*3 + 2*4 + 0*0 = 11
    assert_in_delta 11.0, result.real, 1e-10
  end

  def test_inner_product_wrong_args
    v1 = GSL::Vector::Complex.alloc(3)
    v2 = GSL::Vector::Complex.alloc(3)  # Not col

    assert_raises(TypeError) do
      v1.inner_product(v2)
    end
  end

  def test_inner_product_length_mismatch
    v1 = GSL::Vector::Complex.alloc(3)
    v2 = GSL::Vector::Complex.alloc(4).col

    assert_raises(RangeError) do
      v1.inner_product(v2)
    end
  end

  def test_row_times_col
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 0.0)
    v1[1] = GSL::Complex.alloc(2.0, 0.0)

    v2 = v1.col
    # Row * Col = inner product (scalar)
    result = v1 * v2
    assert result.is_a?(GSL::Complex)
  end

  def test_col_times_row
    v1 = GSL::Vector::Complex.alloc(2).col
    v1[0] = GSL::Complex.alloc(1.0, 0.0)
    v1[1] = GSL::Complex.alloc(2.0, 0.0)

    v2 = GSL::Vector::Complex.alloc(2)
    v2[0] = GSL::Complex.alloc(3.0, 0.0)
    v2[1] = GSL::Complex.alloc(4.0, 0.0)

    # Col * Row = outer product (matrix)
    result = v1 * v2
    assert result.is_a?(GSL::Matrix::Complex)
    assert_equal 2, result.size1
    assert_equal 2, result.size2
  end

  # ======= Unary operators =======

  def test_uplus
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)

    result = +v
    assert_in_delta 1.0, result[0].real, 1e-10
  end

  def test_uminus
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)

    result = -v
    assert_in_delta(-1.0, result[0].real, 1e-10)
    assert_in_delta(-2.0, result[0].imag, 1e-10)
  end

  # ======= Math functions (abs, sqrt, exp, log, etc.) =======

  def test_abs2
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(3.0, 4.0)
    v[1] = GSL::Complex.alloc(0.0, 1.0)

    result = v.abs2
    assert result.is_a?(GSL::Vector)
    assert_in_delta 25.0, result[0], 1e-10  # 3^2 + 4^2 = 25
    assert_in_delta 1.0, result[1], 1e-10   # 0^2 + 1^2 = 1
  end

  def test_abs
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(3.0, 4.0)
    v[1] = GSL::Complex.alloc(0.0, 1.0)

    result = v.abs
    assert result.is_a?(GSL::Vector)
    assert_in_delta 5.0, result[0], 1e-10
    assert_in_delta 1.0, result[1], 1e-10
  end

  def test_arg
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(0.0, 1.0)

    result = v.arg
    assert result.is_a?(GSL::Vector)
    assert_in_delta 0.0, result[0], 1e-10
    assert_in_delta Math::PI / 2, result[1], 1e-10
  end

  def test_logabs
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(Math::E, 0.0)

    result = v.logabs
    assert result.is_a?(GSL::Vector)
    assert_in_delta 0.0, result[0], 1e-10
    assert_in_delta 1.0, result[1], 1e-10
  end

  def test_sqrt
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(4.0, 0.0)
    v[1] = GSL::Complex.alloc(0.0, 4.0)

    result = v.sqrt
    assert result.is_a?(GSL::Vector::Complex)
    assert_in_delta 2.0, result[0].real, 1e-10
    assert_in_delta 0.0, result[0].imag, 1e-10
  end

  def test_sqrt_bang
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(4.0, 0.0)

    v.sqrt!
    assert_in_delta 2.0, v[0].real, 1e-10
  end

  def test_exp
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(1.0, 0.0)

    result = v.exp
    assert_in_delta 1.0, result[0].real, 1e-10
    assert_in_delta Math::E, result[1].real, 1e-10
  end

  def test_exp_bang
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    v.exp!
    assert_in_delta 1.0, v[0].real, 1e-10
  end

  def test_pow
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(2.0, 0.0)
    z = GSL::Complex.alloc(3.0, 0.0)

    result = v.pow(z)
    assert_in_delta 8.0, result[0].real, 1e-10
  end

  def test_pow_bang
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(2.0, 0.0)
    z = GSL::Complex.alloc(3.0, 0.0)

    v.pow!(z)
    assert_in_delta 8.0, v[0].real, 1e-10
  end

  def test_log
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(Math::E, 0.0)

    result = v.log
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta 1.0, result[1].real, 1e-10
  end

  def test_log_bang
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(Math::E, 0.0)

    v.log!
    assert_in_delta 1.0, v[0].real, 1e-10
  end

  def test_log10
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(10.0, 0.0)

    result = v.log10
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta 1.0, result[1].real, 1e-10
  end

  def test_log10_bang
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(10.0, 0.0)

    v.log10!
    assert_in_delta 1.0, v[0].real, 1e-10
  end

  def test_log_b
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(8.0, 0.0)
    z = GSL::Complex.alloc(2.0, 0.0)

    result = v.log_b(z)
    assert_in_delta 3.0, result[0].real, 1e-10
  end

  def test_log_b_bang
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(8.0, 0.0)
    z = GSL::Complex.alloc(2.0, 0.0)

    v.log_b!(z)
    assert_in_delta 3.0, v[0].real, 1e-10
  end

  # ======= Statistics =======

  def test_sum
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    v[2] = GSL::Complex.alloc(5.0, 6.0)

    result = v.sum
    assert result.is_a?(GSL::Complex)
    assert_in_delta 9.0, result.real, 1e-10
    assert_in_delta 12.0, result.imag, 1e-10
  end

  def test_mean
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(4.0, 5.0)
    v[2] = GSL::Complex.alloc(7.0, 8.0)

    result = v.mean
    assert result.is_a?(GSL::Complex)
    assert_in_delta 4.0, result.real, 1e-10
    assert_in_delta 5.0, result.imag, 1e-10
  end

  def test_tss
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    result = v.tss
    assert result.is_a?(Float)
    assert_in_delta 2.0, result, 1e-10
  end

  def test_tss_m
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)
    mean = GSL::Complex.alloc(2.0, 0.0)

    result = v.tss_m(mean)
    assert_in_delta 2.0, result, 1e-10
  end

  def test_tss_m_with_float
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    result = v.tss_m(2.0)
    assert_in_delta 2.0, result, 1e-10
  end

  def test_variance
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    result = v.variance
    assert result.is_a?(Float)
    assert_in_delta 1.0, result, 1e-10
  end

  def test_variance_m
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)
    mean = GSL::Complex.alloc(2.0, 0.0)

    result = v.variance_m(mean)
    assert_in_delta 1.0, result, 1e-10
  end

  def test_variance_fm
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)
    mean = GSL::Complex.alloc(2.0, 0.0)

    result = v.variance_fm(mean)
    # With fixed mean, divide by n instead of n-1
    assert_in_delta 2.0 / 3.0, result, 1e-10
  end

  def test_sd
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)

    result = v.sd
    assert result.is_a?(Float)
    assert_in_delta 1.0, result, 1e-10
  end

  def test_sd_m
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)
    mean = GSL::Complex.alloc(2.0, 0.0)

    result = v.sd_m(mean)
    assert_in_delta 1.0, result, 1e-10
  end

  def test_sd_fm
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)
    v[2] = GSL::Complex.alloc(3.0, 0.0)
    mean = GSL::Complex.alloc(2.0, 0.0)

    result = v.sd_fm(mean)
    assert_in_delta Math.sqrt(2.0 / 3.0), result, 1e-10
  end

  # ======= Trigonometric functions =======

  def test_sin
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(Math::PI / 2, 0.0)

    result = v.sin
    assert result.is_a?(GSL::Vector::Complex)
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta 1.0, result[1].real, 1e-10
  end

  def test_cos
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(Math::PI, 0.0)

    result = v.cos
    assert_in_delta 1.0, result[0].real, 1e-10
    assert_in_delta(-1.0, result[1].real, 1e-10)
  end

  def test_tan
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(Math::PI / 4, 0.0)

    result = v.tan
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta 1.0, result[1].real, 1e-10
  end

  def test_sec
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.sec
    assert_in_delta 1.0, result[0].real, 1e-10
  end

  def test_csc
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(Math::PI / 2, 0.0)

    result = v.csc
    assert_in_delta 1.0, result[0].real, 1e-10
  end

  def test_cot
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(Math::PI / 4, 0.0)

    result = v.cot
    assert_in_delta 1.0, result[0].real, 1e-10
  end

  def test_arcsin
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(1.0, 0.0)

    result = v.arcsin
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta Math::PI / 2, result[1].real, 1e-10
  end

  def test_arccos
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(0.0, 0.0)

    result = v.arccos
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta Math::PI / 2, result[1].real, 1e-10
  end

  def test_arctan
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(0.0, 0.0)
    v[1] = GSL::Complex.alloc(1.0, 0.0)

    result = v.arctan
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta Math::PI / 4, result[1].real, 1e-10
  end

  def test_arcsec
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    result = v.arcsec
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_arccsc
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    result = v.arccsc
    assert_in_delta Math::PI / 2, result[0].real, 1e-10
  end

  def test_arccot
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    result = v.arccot
    assert_in_delta Math::PI / 4, result[0].real, 1e-10
  end

  # ======= Hyperbolic functions =======

  def test_sinh
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.sinh
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_cosh
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.cosh
    assert_in_delta 1.0, result[0].real, 1e-10
  end

  def test_tanh
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.tanh
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_sech
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.sech
    assert_in_delta 1.0, result[0].real, 1e-10
  end

  def test_csch
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    result = v.csch
    assert_in_delta 1.0 / Math.sinh(1.0), result[0].real, 1e-10
  end

  def test_coth
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    result = v.coth
    assert_in_delta 1.0 / Math.tanh(1.0), result[0].real, 1e-10
  end

  def test_arcsinh
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.arcsinh
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_arccosh
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    result = v.arccosh
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_arctanh
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(0.0, 0.0)

    result = v.arctanh
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_arcsech
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    result = v.arcsech
    assert_in_delta 0.0, result[0].real, 1e-10
  end

  def test_arccsch
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    result = v.arccsch
    # arccsch(1) = arcsinh(1)
    assert_in_delta Math.log(1.0 + Math.sqrt(2.0)), result[0].real, 1e-10
  end

  def test_arccoth
    v = GSL::Vector::Complex.alloc(1)
    v[0] = GSL::Complex.alloc(2.0, 0.0)

    result = v.arccoth
    # arccoth(2) = arctanh(0.5)
    assert_in_delta Math.atanh(0.5), result[0].real, 1e-10
  end

  # ======= Concat =======

  def test_concat_with_float
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    v[1] = GSL::Complex.alloc(2.0, 0.0)

    result = v.concat(3.0)
    assert_equal 3, result.size
    assert_in_delta 1.0, result[0].real, 1e-10
    assert_in_delta 2.0, result[1].real, 1e-10
    assert_in_delta 3.0, result[2].real, 1e-10
  end

  def test_concat_with_complex
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)
    z = GSL::Complex.alloc(3.0, 4.0)

    result = v.concat(z)
    assert_equal 3, result.size
    assert_in_delta 3.0, result[2].real, 1e-10
    assert_in_delta 4.0, result[2].imag, 1e-10
  end

  def test_concat_with_array
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    z1 = GSL::Complex.alloc(3.0, 0.0)
    z2 = GSL::Complex.alloc(4.0, 0.0)
    result = v.concat([z1, z2])
    assert_equal 4, result.size
    assert_in_delta 3.0, result[2].real, 1e-10
    assert_in_delta 4.0, result[3].real, 1e-10
  end

  def test_concat_with_range
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 0.0)

    result = v.concat(3..5)
    assert_equal 5, result.size
    assert_in_delta 3.0, result[2].real, 1e-10
    assert_in_delta 4.0, result[3].real, 1e-10
    assert_in_delta 5.0, result[4].real, 1e-10
  end

  def test_concat_with_vector
    v1 = GSL::Vector::Complex.alloc(2)
    v1[0] = GSL::Complex.alloc(1.0, 0.0)
    v1[1] = GSL::Complex.alloc(2.0, 0.0)

    v2 = GSL::Vector::Complex.alloc(2)
    v2[0] = GSL::Complex.alloc(3.0, 0.0)
    v2[1] = GSL::Complex.alloc(4.0, 0.0)

    result = v1.concat(v2)
    assert_equal 4, result.size
    assert_in_delta 3.0, result[2].real, 1e-10
    assert_in_delta 4.0, result[3].real, 1e-10
  end

  def test_concat_wrong_type
    v = GSL::Vector::Complex.alloc(2)
    assert_raises(TypeError) do
      v.concat("invalid")
    end
  end

  # ======= indgen =======

  def test_indgen
    v = GSL::Vector::Complex.alloc(5)
    result = v.indgen
    assert_equal 5, result.size
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta 1.0, result[1].real, 1e-10
    assert_in_delta 4.0, result[4].real, 1e-10
  end

  def test_indgen_with_start
    v = GSL::Vector::Complex.alloc(5)
    result = v.indgen(10.0)
    assert_in_delta 10.0, result[0].real, 1e-10
    assert_in_delta 11.0, result[1].real, 1e-10
  end

  def test_indgen_with_start_and_step
    v = GSL::Vector::Complex.alloc(5)
    result = v.indgen(10.0, 2.0)
    assert_in_delta 10.0, result[0].real, 1e-10
    assert_in_delta 12.0, result[1].real, 1e-10
    assert_in_delta 14.0, result[2].real, 1e-10
  end

  def test_indgen_bang
    v = GSL::Vector::Complex.alloc(5)
    v.indgen!
    assert_in_delta 0.0, v[0].real, 1e-10
    assert_in_delta 4.0, v[4].real, 1e-10
  end

  def test_indgen_bang_with_start
    v = GSL::Vector::Complex.alloc(5)
    v.indgen!(10.0)
    assert_in_delta 10.0, v[0].real, 1e-10
  end

  def test_indgen_bang_with_start_and_step
    v = GSL::Vector::Complex.alloc(5)
    v.indgen!(10.0, 2.0)
    assert_in_delta 10.0, v[0].real, 1e-10
    assert_in_delta 12.0, v[1].real, 1e-10
  end

  def test_indgen_wrong_args
    v = GSL::Vector::Complex.alloc(5)
    assert_raises(ArgumentError) do
      v.indgen(1, 2, 3)
    end
  end

  def test_indgen_bang_wrong_args
    v = GSL::Vector::Complex.alloc(5)
    assert_raises(ArgumentError) do
      v.indgen!(1, 2, 3)
    end
  end

  def test_indgen_singleton
    result = GSL::Vector::Complex.indgen(5)
    assert_equal 5, result.size
    assert_in_delta 0.0, result[0].real, 1e-10
    assert_in_delta 4.0, result[4].real, 1e-10
  end

  def test_indgen_singleton_with_start
    result = GSL::Vector::Complex.indgen(5, 10.0)
    assert_in_delta 10.0, result[0].real, 1e-10
  end

  def test_indgen_singleton_with_start_and_step
    result = GSL::Vector::Complex.indgen(5, 10.0, 2.0)
    assert_in_delta 10.0, result[0].real, 1e-10
    assert_in_delta 12.0, result[1].real, 1e-10
  end

  def test_indgen_singleton_wrong_args
    assert_raises(ArgumentError) do
      GSL::Vector::Complex.indgen(5, 1, 2, 3)
    end
  end

  # ======= zip =======

  def test_zip
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 0.0)
    v1[1] = GSL::Complex.alloc(2.0, 0.0)
    v1[2] = GSL::Complex.alloc(3.0, 0.0)

    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(4.0, 0.0)
    v2[1] = GSL::Complex.alloc(5.0, 0.0)
    v2[2] = GSL::Complex.alloc(6.0, 0.0)

    result = v1.zip(v2)
    assert result.is_a?(Array)
    assert_equal 3, result.size
    # Each element is a GSL::Vector::Complex with 2 elements
    # containing the corresponding elements from v1 and v2
    assert result[0].is_a?(GSL::Vector::Complex)
    assert_equal 2, result[0].size
    assert_in_delta 1.0, result[0][0].real, 1e-10
    assert_in_delta 4.0, result[0][1].real, 1e-10
  end

  # ======= equal? and not_equal? =======

  def test_equal_with_vector
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)
    v1[1] = GSL::Complex.alloc(3.0, 4.0)
    v1[2] = GSL::Complex.alloc(5.0, 6.0)

    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(1.0, 2.0)
    v2[1] = GSL::Complex.alloc(3.0, 4.0)
    v2[2] = GSL::Complex.alloc(5.0, 6.0)

    assert v1.equal?(v2)
  end

  def test_equal_with_tolerance
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)

    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(1.0001, 2.0001)

    refute v1.equal?(v2)
    assert v1.equal?(v2, 0.001)
  end

  def test_not_equal_with_vector
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)

    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(9.0, 9.0)

    assert v1.not_equal?(v2)
  end

  def test_not_equal_with_tolerance
    v1 = GSL::Vector::Complex.alloc(3)
    v1[0] = GSL::Complex.alloc(1.0, 2.0)

    v2 = GSL::Vector::Complex.alloc(3)
    v2[0] = GSL::Complex.alloc(1.0001, 2.0001)

    assert v1.not_equal?(v2)  # Strict comparison
    refute v1.not_equal?(v2, 0.001)  # With tolerance
  end

  # ======= I/O (file operations) =======

  def test_fwrite_fread
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    v[2] = GSL::Complex.alloc(5.0, 6.0)

    require 'tempfile'
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'test_complex_vector.bin')
      v.fwrite(path)

      v2 = GSL::Vector::Complex.alloc(3)
      v2.fread(path)

      assert_in_delta 1.0, v2[0].real, 1e-10
      assert_in_delta 2.0, v2[0].imag, 1e-10
      assert_in_delta 3.0, v2[1].real, 1e-10
    end
  end

  def test_fprintf_fscanf
    v = GSL::Vector::Complex.alloc(3)
    v[0] = GSL::Complex.alloc(1.5, 2.5)
    v[1] = GSL::Complex.alloc(3.5, 4.5)
    v[2] = GSL::Complex.alloc(5.5, 6.5)

    require 'tempfile'
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'test_complex_vector.txt')
      v.fprintf(path, "%g")

      v2 = GSL::Vector::Complex.alloc(3)
      v2.fscanf(path)

      assert_in_delta 1.5, v2[0].real, 1e-10
      assert_in_delta 2.5, v2[0].imag, 1e-10
    end
  end

  def test_fprintf_with_format
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.123456, 2.123456)

    require 'tempfile'
    file = Tempfile.new('gsl_vc_test')
    begin
      v.fprintf(file.path, "%.2f")
      # Just verify it doesn't crash
    ensure
      file.close
      file.unlink
    end
  end

  def test_printf
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    # Just verify it doesn't crash
    # Captures stdout implicitly
    result = v.printf
    assert_equal 0, result
  end

  def test_printf_with_format
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    # Just verify it doesn't crash
    result = v.printf("%.2f")
    assert_equal 0, result
  end

  def test_print
    v = GSL::Vector::Complex.alloc(2)
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    # Just verify it doesn't crash
    result = v.print
    assert_equal v, result
  end

  def test_print_col
    v = GSL::Vector::Complex.alloc(2).col
    v[0] = GSL::Complex.alloc(1.0, 2.0)
    v[1] = GSL::Complex.alloc(3.0, 4.0)
    # Just verify it doesn't crash
    result = v.print
    assert_equal v, result
  end
end
