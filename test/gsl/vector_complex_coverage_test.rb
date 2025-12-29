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
end
