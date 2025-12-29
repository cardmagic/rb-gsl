require 'test_helper'

# Coverage tests for function.c
# Tests GSL::Function with different input types
class FunctionCoverageTest < GSL::TestCase
  # =====================================================
  # GSL::Function creation tests
  # =====================================================

  def test_function_new_no_args
    f = GSL::Function.alloc
    assert_kind_of GSL::Function, f
  end

  def test_function_new_with_proc
    f = GSL::Function.alloc(proc { |x| x * 2 })
    assert_kind_of GSL::Function, f
    result = f.eval(5.0)
    assert_in_delta 10.0, result, 1e-10
  end

  def test_function_new_with_block
    f = GSL::Function.alloc { |x| x ** 2 }
    assert_kind_of GSL::Function, f
    result = f.eval(3.0)
    assert_in_delta 9.0, result, 1e-10
  end

  def test_function_new_with_params
    f = GSL::Function.alloc(proc { |x, a| x * a }, 3)
    assert_kind_of GSL::Function, f
    result = f.eval(5.0)
    assert_in_delta 15.0, result, 1e-10
  end

  def test_function_new_with_multiple_params
    f = GSL::Function.alloc(proc { |x, params| x * params[0] + params[1] }, 2, 3)
    assert_kind_of GSL::Function, f
    result = f.eval(5.0)
    assert_in_delta 13.0, result, 1e-10  # 5*2 + 3
  end

  # =====================================================
  # GSL::Function#set tests
  # =====================================================

  def test_function_set_with_block
    f = GSL::Function.alloc
    f.set { |x| x + 1 }
    result = f.eval(4.0)
    assert_in_delta 5.0, result, 1e-10
  end

  def test_function_set_with_proc
    f = GSL::Function.alloc
    f.set(proc { |x| x * 3 })
    result = f.eval(4.0)
    assert_in_delta 12.0, result, 1e-10
  end

  def test_function_set_with_proc_and_params
    f = GSL::Function.alloc
    f.set(proc { |x, a| x ** a }, 2)
    result = f.eval(3.0)
    assert_in_delta 9.0, result, 1e-10
  end

  # =====================================================
  # GSL::Function#eval with different input types
  # =====================================================

  def test_function_eval_with_fixnum
    f = GSL::Function.alloc { |x| x * 2 }
    result = f.eval(5)  # Fixnum
    assert_kind_of Numeric, result
    assert_in_delta 10.0, result, 1e-10
  end

  def test_function_eval_with_bignum
    f = GSL::Function.alloc { |x| x.to_f }
    result = f.eval(10**15)  # Large number
    assert_kind_of Numeric, result
  end

  def test_function_eval_with_float
    f = GSL::Function.alloc { |x| x * 2 }
    result = f.eval(5.0)
    assert_kind_of Float, result
    assert_in_delta 10.0, result, 1e-10
  end

  def test_function_eval_with_array
    f = GSL::Function.alloc { |x| x ** 2 }
    result = f.eval([1.0, 2.0, 3.0])
    assert_kind_of Array, result
    assert_equal 3, result.size
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 4.0, result[1], 1e-10
    assert_in_delta 9.0, result[2], 1e-10
  end

  def test_function_eval_with_range
    f = GSL::Function.alloc { |x| x ** 2 }
    result = f.eval(1..3)
    assert_kind_of Array, result
    assert_equal 3, result.size
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 9.0, result[2], 1e-10
  end

  def test_function_eval_with_vector
    f = GSL::Function.alloc { |x| x ** 2 }
    v = GSL::Vector[1.0, 2.0, 3.0]
    result = f.eval(v)
    assert_kind_of GSL::Vector, result
    assert_equal 3, result.size
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 4.0, result[1], 1e-10
    assert_in_delta 9.0, result[2], 1e-10
  end

  def test_function_eval_with_matrix
    f = GSL::Function.alloc { |x| x ** 2 }
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0, 4.0], 2, 2)
    result = f.eval(m)
    assert_kind_of GSL::Matrix, result
    assert_equal 2, result.size1
    assert_equal 2, result.size2
    assert_in_delta 1.0, result[0, 0], 1e-10
    assert_in_delta 4.0, result[0, 1], 1e-10
    assert_in_delta 9.0, result[1, 0], 1e-10
    assert_in_delta 16.0, result[1, 1], 1e-10
  end

  def test_function_eval_with_params_array
    f = GSL::Function.alloc(proc { |x, a| x ** a }, 3)
    result = f.eval([1.0, 2.0, 3.0])
    assert_kind_of Array, result
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 8.0, result[1], 1e-10
    assert_in_delta 27.0, result[2], 1e-10
  end

  def test_function_eval_with_params_vector
    f = GSL::Function.alloc(proc { |x, a| x ** a }, 2)
    v = GSL::Vector[1.0, 2.0, 3.0]
    result = f.eval(v)
    assert_kind_of GSL::Vector, result
    assert_in_delta 1.0, result[0], 1e-10
    assert_in_delta 4.0, result[1], 1e-10
    assert_in_delta 9.0, result[2], 1e-10
  end

  def test_function_eval_with_params_matrix
    f = GSL::Function.alloc(proc { |x, a| x + a }, 10)
    m = GSL::Matrix.alloc([1.0, 2.0, 3.0, 4.0], 2, 2)
    result = f.eval(m)
    assert_kind_of GSL::Matrix, result
    assert_in_delta 11.0, result[0, 0], 1e-10
    assert_in_delta 14.0, result[1, 1], 1e-10
  end

  def test_function_eval_wrong_type_raises
    f = GSL::Function.alloc { |x| x }
    assert_raises(TypeError) do
      f.eval("invalid")
    end
  end

  # =====================================================
  # GSL::Function#arity tests
  # =====================================================

  def test_function_arity
    f = GSL::Function.alloc { |x| x }
    # arity should return the arity of the proc
    assert_respond_to f, :arity
  end

  # =====================================================
  # GSL::Function#[] shorthand
  # =====================================================

  def test_function_bracket_eval
    f = GSL::Function.alloc { |x| x * 2 }
    result = f[5.0]
    assert_in_delta 10.0, result, 1e-10
  end

  def test_function_call
    f = GSL::Function.alloc { |x| x * 3 }
    result = f.call(4.0)
    assert_in_delta 12.0, result, 1e-10
  end

  # =====================================================
  # GSL::Function#proc tests
  # =====================================================

  def test_function_proc_accessor
    original_proc = proc { |x| x * 2 }
    f = GSL::Function.alloc(original_proc)
    retrieved = f.proc
    assert_kind_of Proc, retrieved
    assert_in_delta 10.0, retrieved.call(5.0), 1e-10
  end

  # =====================================================
  # GSL::Function#set_params tests
  # =====================================================

  def test_function_params_accessor
    f = GSL::Function.alloc(proc { |x, a| x * a }, 5)
    params = f.params
    assert_equal 5, params
  end

  def test_function_set_params
    f = GSL::Function.alloc(proc { |x, a| x * a }, 5)
    result1 = f.eval(10.0)
    assert_in_delta 50.0, result1, 1e-10

    f.set_params(3)
    result2 = f.eval(10.0)
    assert_in_delta 30.0, result2, 1e-10
  end

  # =====================================================
  # Integration with numerical methods
  # =====================================================

  def test_function_with_integration
    f = GSL::Function.alloc { |x| x ** 2 }
    # Integrate x^2 from 0 to 1 should be 1/3
    w = GSL::Integration::Workspace.alloc(1000)
    result, = f.integration_qags(0, 1, 1e-10, 1e-10, 1000, w)
    assert_in_delta 1.0/3.0, result, 1e-8
  end
end
