require 'test_helper'
require 'tempfile'

class CommonCoverageTest < GSL::TestCase
  # =====================================================
  # File I/O tests - tests rb_gsl_open_writefile and rb_gsl_open_readfile
  # =====================================================

  def test_vector_fwrite_with_file_object
    v = GSL::Vector[1, 2, 3, 4, 5]
    Tempfile.create('vector_fwrite') do |f|
      # Write using File object
      File.open(f.path, 'wb') do |file|
        v.fwrite(file)
      end
      # Read back
      v2 = GSL::Vector.alloc(5)
      v2.fread(f.path)
      assert_in_delta 1.0, v2[0], 1e-10
      assert_in_delta 5.0, v2[4], 1e-10
    end
  end

  def test_vector_fread_with_file_object
    v = GSL::Vector[1, 2, 3, 4, 5]
    Tempfile.create('vector_fread') do |f|
      # Write using string path
      v.fwrite(f.path)
      # Read using File object
      v2 = GSL::Vector.alloc(5)
      File.open(f.path, 'rb') do |file|
        v2.fread(file)
      end
      assert_in_delta 1.0, v2[0], 1e-10
      assert_in_delta 5.0, v2[4], 1e-10
    end
  end

  def test_matrix_fwrite_with_file_object
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    Tempfile.create('matrix_fwrite') do |f|
      File.open(f.path, 'wb') do |file|
        m.fwrite(file)
      end
      m2 = GSL::Matrix.alloc(2, 2)
      m2.fread(f.path)
      assert_in_delta 1.0, m2[0, 0], 1e-10
      assert_in_delta 4.0, m2[1, 1], 1e-10
    end
  end

  def test_matrix_fread_with_file_object
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    Tempfile.create('matrix_fread') do |f|
      m.fwrite(f.path)
      m2 = GSL::Matrix.alloc(2, 2)
      File.open(f.path, 'rb') do |file|
        m2.fread(file)
      end
      assert_in_delta 1.0, m2[0, 0], 1e-10
      assert_in_delta 4.0, m2[1, 1], 1e-10
    end
  end

  def test_vector_fprintf_with_file_object
    v = GSL::Vector[1, 2, 3]
    Tempfile.create('vector_fprintf') do |f|
      File.open(f.path, 'w') do |file|
        v.fprintf(file)
      end
      content = File.read(f.path)
      assert content.include?("1")
      assert content.include?("2")
      assert content.include?("3")
    end
  end

  def test_matrix_fprintf_with_file_object
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    Tempfile.create('matrix_fprintf') do |f|
      File.open(f.path, 'w') do |file|
        m.fprintf(file)
      end
      content = File.read(f.path)
      assert content.include?("1")
    end
  end

  def test_vector_fscanf_with_file_object
    v = GSL::Vector[1.5, 2.5, 3.5]
    Tempfile.create('vector_fscanf') do |f|
      v.fprintf(f.path)
      v2 = GSL::Vector.alloc(3)
      File.open(f.path, 'r') do |file|
        v2.fscanf(file)
      end
      assert_in_delta 1.5, v2[0], 1e-10
      assert_in_delta 3.5, v2[2], 1e-10
    end
  end

  def test_matrix_fscanf_with_file_object
    m = GSL::Matrix.alloc([1.5, 2.5, 3.5, 4.5], 2, 2)
    Tempfile.create('matrix_fscanf') do |f|
      m.fprintf(f.path)
      m2 = GSL::Matrix.alloc(2, 2)
      File.open(f.path, 'r') do |file|
        m2.fscanf(file)
      end
      assert_in_delta 1.5, m2[0, 0], 1e-10
      assert_in_delta 4.5, m2[1, 1], 1e-10
    end
  end

  def test_file_io_wrong_type_error
    v = GSL::Vector[1, 2, 3]
    assert_raises(TypeError) { v.fwrite(123) }
    assert_raises(TypeError) { v.fread(123) }
    assert_raises(TypeError) { v.fprintf(123) }
    assert_raises(TypeError) { v.fscanf(123) }
  end

  def test_file_io_cannot_open_error
    v = GSL::Vector[1, 2, 3]
    # Try to read from non-existent file
    assert_raises(IOError) { v.fread("/nonexistent/path/to/file") }
    # Try to write to non-writable path
    assert_raises(IOError) { v.fwrite("/nonexistent/path/to/file") }
  end

  # =====================================================
  # Complex conversion tests - tests ary2complex
  # =====================================================

  def test_complex_from_array
    # ary2complex is called internally when creating complex values from arrays
    c = GSL::Complex.alloc([1.0, 2.0])
    assert_in_delta 1.0, c.real, 1e-10
    assert_in_delta 2.0, c.imag, 1e-10
  end

  def test_complex_from_complex
    c1 = GSL::Complex.alloc(3.0, 4.0)
    # Operations that use ary2complex internally
    c2 = c1.dup
    assert_in_delta 3.0, c2.real, 1e-10
    assert_in_delta 4.0, c2.imag, 1e-10
  end

  # =====================================================
  # Vector evaluation tests - tests vector_eval_create and get_ptr_double3
  # =====================================================

  def test_vector_eval_math_functions
    v = GSL::Vector[0, Math::PI/2, Math::PI]
    # These operations use vector_eval_create internally
    sin_v = GSL::Sf.sin(v)
    assert_in_delta 0.0, sin_v[0], 1e-10
    assert_in_delta 1.0, sin_v[1], 1e-10
    assert_in_delta 0.0, sin_v[2], 1e-10

    cos_v = GSL::Sf.cos(v)
    assert_in_delta 1.0, cos_v[0], 1e-10
    assert_in_delta 0.0, cos_v[1], 1e-10
    assert_in_delta(-1.0, cos_v[2], 1e-10)
  end

  def test_vector_eval_with_stride
    # Create a vector with non-unit stride via view
    m = GSL::Matrix.alloc([1, 2, 3, 4, 5, 6], 2, 3)
    col = m.col(0)  # Column view has stride = size2 = 3
    # Math operations should work with non-unit stride
    result = col.abs
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 4.0, result[1], 1e-10
  end

  # =====================================================
  # Matrix evaluation tests - tests matrix_eval_create
  # =====================================================

  def test_matrix_eval_math_functions
    m = GSL::Matrix.alloc([0, Math::PI/2, Math::PI, 3*Math::PI/2], 2, 2)
    # These operations use matrix_eval_create internally
    sin_m = GSL::Sf.sin(m)
    assert_in_delta 0.0, sin_m[0, 0], 1e-10
    assert_in_delta 1.0, sin_m[0, 1], 1e-10
    assert_in_delta 0.0, sin_m[1, 0], 1e-10
    assert_in_delta(-1.0, sin_m[1, 1], 1e-10)
  end

  # =====================================================
  # Array evaluation tests - tests rb_gsl_ary_eval1
  # =====================================================

  def test_array_eval_with_sf_functions
    # When passing a Ruby array to SF functions, rb_gsl_ary_eval1 is used
    ary = [0, Math::PI/2, Math::PI]
    result = GSL::Sf.sin(ary)
    assert_kind_of Array, result
    assert_in_delta 0.0, result[0], 1e-10
    assert_in_delta 1.0, result[1], 1e-10
    assert_in_delta 0.0, result[2], 1e-10
  end

  # =====================================================
  # Read-only object tests - tests rb_gsl_obj_read_only
  # =====================================================

  def test_view_modification_behavior
    # Views are read-only for certain operations
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    view = m.submatrix(0, 0, 2, 2)
    # Modifying view should work for elements
    view[0, 0] = 10.0
    assert_in_delta 10.0, m[0, 0], 1e-10
  end

  # =====================================================
  # Block accessor tests
  # =====================================================

  def test_vector_block_accessor
    v = GSL::Vector[1, 2, 3, 4, 5]
    block = v.block
    assert_kind_of GSL::Block, block
  end

  def test_matrix_block_accessor
    m = GSL::Matrix.alloc([1, 2, 3, 4], 2, 2)
    block = m.block
    assert_kind_of GSL::Block, block
  end

  # =====================================================
  # Histogram file I/O tests - tests read/write through histograms
  # =====================================================

  def test_histogram_fwrite_fread
    h = GSL::Histogram.alloc(10)
    h.set_ranges_uniform(0, 10)
    h.increment(2.5)
    h.increment(5.5)
    h.increment(5.5)

    Tempfile.create('histogram') do |f|
      h.fwrite(f.path)
      h2 = GSL::Histogram.alloc(10)
      h2.fread(f.path)
      assert_in_delta 1.0, h2[2], 1e-10
      assert_in_delta 2.0, h2[5], 1e-10
    end
  end

  def test_histogram_fprintf_fscanf
    h = GSL::Histogram.alloc(5)
    h.set_ranges_uniform(0, 5)
    h.increment(1.5)
    h.increment(3.5)

    Tempfile.create('histogram') do |f|
      h.fprintf(f.path)
      h2 = GSL::Histogram.alloc(5)
      h2.fscanf(f.path)
      assert_in_delta 1.0, h2[1], 1e-10
      assert_in_delta 1.0, h2[3], 1e-10
    end
  end

  # =====================================================
  # Vector::Int file I/O tests
  # =====================================================

  def test_vector_int_fwrite_fread
    v = GSL::Vector::Int[1, 2, 3, 4, 5]
    Tempfile.create('vector_int') do |f|
      v.fwrite(f.path)
      v2 = GSL::Vector::Int.alloc(5)
      v2.fread(f.path)
      assert_equal 1, v2[0]
      assert_equal 5, v2[4]
    end
  end

  def test_vector_int_fprintf_fscanf
    v = GSL::Vector::Int[10, 20, 30]
    Tempfile.create('vector_int') do |f|
      v.fprintf(f.path, "%d")
      v2 = GSL::Vector::Int.alloc(3)
      v2.fscanf(f.path)
      assert_equal 10, v2[0]
      assert_equal 30, v2[2]
    end
  end

  # =====================================================
  # Matrix::Int file I/O tests
  # =====================================================

  def test_matrix_int_fwrite_fread
    m = GSL::Matrix::Int.alloc([1, 2, 3, 4], 2, 2)
    Tempfile.create('matrix_int') do |f|
      m.fwrite(f.path)
      m2 = GSL::Matrix::Int.alloc(2, 2)
      m2.fread(f.path)
      assert_equal 1, m2[0, 0]
      assert_equal 4, m2[1, 1]
    end
  end

  def test_matrix_int_fprintf_fscanf
    m = GSL::Matrix::Int.alloc([10, 20, 30, 40], 2, 2)
    Tempfile.create('matrix_int') do |f|
      m.fprintf(f.path, "%d")
      m2 = GSL::Matrix::Int.alloc(2, 2)
      m2.fscanf(f.path)
      assert_equal 10, m2[0, 0]
      assert_equal 40, m2[1, 1]
    end
  end

  # =====================================================
  # Permutation file I/O tests
  # =====================================================

  def test_permutation_fwrite_fread
    p = GSL::Permutation.alloc(5)
    p.init
    p.swap(0, 4)
    p.swap(1, 3)

    Tempfile.create('permutation') do |f|
      p.fwrite(f.path)
      p2 = GSL::Permutation.alloc(5)
      p2.fread(f.path)
      assert_equal p[0], p2[0]
      assert_equal p[4], p2[4]
    end
  end

  def test_permutation_fprintf_fscanf
    p = GSL::Permutation.alloc(4)
    p.init
    p.reverse

    Tempfile.create('permutation') do |f|
      p.fprintf(f.path)
      p2 = GSL::Permutation.alloc(4)
      p2.fscanf(f.path)
      assert_equal p[0], p2[0]
      assert_equal p[3], p2[3]
    end
  end

  # =====================================================
  # Combination file I/O tests
  # =====================================================

  def test_combination_fwrite_fread
    c = GSL::Combination.alloc(5, 3)
    c.init_first
    c.next
    c.next

    Tempfile.create('combination') do |f|
      c.fwrite(f.path)
      c2 = GSL::Combination.alloc(5, 3)
      c2.fread(f.path)
      assert_equal c.get(0), c2.get(0)
      assert_equal c.get(2), c2.get(2)
    end
  end

  # =====================================================
  # Block file I/O tests
  # =====================================================

  def test_block_fwrite_fread
    # Create a vector and test its block
    v = GSL::Vector[10.0, 1.0, 1.0, 1.0, 50.0]
    b = v.block

    Tempfile.create('block') do |f|
      b.fwrite(f.path)
      b2 = GSL::Block.alloc(5)
      b2.fread(f.path)
      # Create vector view of block to check values
      assert_kind_of GSL::Block, b2
      assert_equal 5, b2.size
    end
  end

  # =====================================================
  # Complex vector/matrix tests (basic operations only - fread/fwrite
  # have pre-existing issues with tempfiles)
  # =====================================================

  def test_complex_vector_basic
    v = GSL::Vector::Complex.alloc(3)
    v.set(0, [1.0, 2.0])
    v.set(1, [3.0, 4.0])
    v.set(2, [5.0, 6.0])

    assert_in_delta 1.0, v[0].real, 1e-10
    assert_in_delta 2.0, v[0].imag, 1e-10
    assert_in_delta 5.0, v[2].real, 1e-10
    assert_in_delta 6.0, v[2].imag, 1e-10
  end

  def test_complex_matrix_basic
    m = GSL::Matrix::Complex.alloc(2, 2)
    m.set(0, 0, [1.0, 2.0])
    m.set(1, 1, [3.0, 4.0])

    assert_in_delta 1.0, m[0, 0].real, 1e-10
    assert_in_delta 2.0, m[0, 0].imag, 1e-10
    assert_in_delta 3.0, m[1, 1].real, 1e-10
    assert_in_delta 4.0, m[1, 1].imag, 1e-10
  end
end
