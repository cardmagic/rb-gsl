require 'test_helper'

class VectorTest < GSL::TestCase

  def test_get
    v = GSL::Vector::Int.indgen(5)
    assert_equal GSL::Vector::Int[3, 1, 2], v.get([3, 1, 2])
  end

  def test_addsub
    a = GSL::Vector::Int[2, 5, 4]
    b = GSL::Vector::Int[10, 30, 20]
    c = GSL::Vector::Int[12, 35, 24]
    d = GSL::Vector::Int[8, 25, 16]

    assert_equal c, a + b
    assert_equal d, b - a
  end

  def test_collect
    v = GSL::Vector::Int.indgen(5)
    u = GSL::Vector::Int[0, 1, 4, 9, 16]

    assert_equal u, v.collect { |val| val * val }
  end

  def test_ispos_neg
    v = GSL::Vector::Int.indgen(5)
    assert_equal 0,     v.ispos
    assert_equal false, v.ispos?
    assert_equal 0,     v.isneg
    assert_equal false, v.isneg?

    v += 1
    assert_equal 1,     v.ispos
    assert_equal true,  v.ispos?
    assert_equal 0,     v.isneg
    assert_equal false, v.isneg?

    v -= 100
    assert_equal 0,     v.ispos
    assert_equal false, v.ispos?
    assert_equal 1,     v.isneg
    assert_equal true,  v.isneg?
  end

  def test_isnonneg
    v = GSL::Vector::Int.indgen(5)
    assert_equal 1,     v.isnonneg
    assert_equal true,  v.isnonneg?
    assert_equal 0,     v.isneg
    assert_equal false, v.isneg?

    v -= 100
    assert_equal 0,     v.isnonneg
    assert_equal false, v.isnonneg?
    assert_equal 1,     v.isneg
    assert_equal true,  v.isneg?

    v += 200
    assert_equal 1,     v.isnonneg
    assert_equal true,  v.isnonneg?
    assert_equal 1,     v.ispos
    assert_equal true,  v.ispos?
  end

  def test_subvector
    v = GSL::Vector::Int.indgen(12)

    vv = v.subvector
    assert_not_equal v.object_id, vv.object_id
    assert_equal     v.subvector, v

    vv = v.subvector(3)
    assert_equal [0, 1, 2], vv.to_a
    assert_nothing_raised('subvector(-1)') { v.subvector(-1) }

    vv = v.subvector(-1)
    assert_equal [11], vv.to_a

    vv = v.subvector(-2)
    assert_equal [10, 11], vv.to_a
    assert_raises(RangeError) { v.subvector(-13) }

    vv = v.subvector(2, 3)
    assert_equal [2, 3, 4], vv.to_a

    vv = v.subvector(-4, 3)
    assert_equal [8, 9, 10], vv.to_a
    assert_nothing_raised('subvector(-4, -3)') { v.subvector(-4, -3) }

    vv = v.subvector(-4, -3)
    assert_equal [8, 7, 6], vv.to_a
    assert_raises(GSL::ERROR::EINVAL) { v.subvector(-11, -3) }

    vv = v.subvector(1, 3, 4)
    assert_equal [1, 4, 7, 10], vv.to_a

    {
    # ( range ) => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      ( 1..  3) => [   1, 2, 3                          ],
      ( 1... 3) => [   1, 2                             ],
      ( 3..  1) => [   3, 2, 1                          ],
      ( 3... 1) => [      3, 2                          ],
      (-7..  9) => [               5, 6, 7, 8, 9        ],
      (-7... 9) => [               5, 6, 7, 8           ],
      ( 4.. -3) => [            4, 5, 6, 7, 8, 9        ],
      ( 4...-3) => [            4, 5, 6, 7, 8           ],
      ( 2.. -2) => [      2, 3, 4, 5, 6, 7, 8, 9, 10    ],
      ( 2...-2) => [      2, 3, 4, 5, 6, 7, 8, 9        ],
      (-2..  2) => [     10, 9, 8, 7, 6, 5, 4, 3,  2    ],
      (-2... 2) => [     10, 9, 8, 7, 6, 5, 4, 3        ],
      (-3.. -1) => [                           9, 10, 11],
      (-3...-1) => [                           9, 10    ],
      (-1.. -3) => [                          11, 10,  9],
      (-1...-3) => [                          11, 10    ]
    }.each { |r, x|
      assert_nothing_raised("subvector(#{r})") { v.subvector(r) }
      assert_equal x, v.subvector(r).to_a, "subvector(#{r})"
    }

    {
    # [( range ), s] => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
      [( 1..  6), 2] => [   1,    3,    5                    ],
      [( 1... 6), 2] => [   1,    3,    5                    ],
      [( 0..  6), 3] => [0,       3,      6                  ],
      [( 0... 6), 3] => [0,    3                             ]
    }.each { |(r, s), x|
      assert_nothing_raised("subvector(#{r},#{s})") { v.subvector(r) }
      assert_equal x, v.subvector(r,s).to_a, "subvector(#{r},#{s})"
    }
  end

  def test_complex_get
    v = GSL::Vector::Complex.indgen(5)
    assert_equal GSL::Vector::Complex[[3, 0], [1, 0], [2, 0]], v.get([3, 1, 2])
  end

  def test_complex_addsub
    a = GSL::Vector::Complex[[-2,  5], [ 4, -1]]
    b = GSL::Vector::Complex[[10, 30], [20, 40]]
    c = GSL::Vector::Complex[[ 8, 35], [24, 39]]
    d = GSL::Vector::Complex[[12, 25], [16, 41]]

    assert_equal c, a + b
    assert_equal d, b - a
  end

  def test_complex_collect
    v = GSL::Vector::Complex.indgen(5)
    u = GSL::Vector::Complex[[0, 0], [1, 0], [4, 0], [9, 0], [16, 0]]

    assert_equal u, v.collect { |val| val * val }
  end

  def test_complex_subvector
    v = GSL::Vector::Complex.indgen(12)

    vv = v.subvector
    assert_not_equal v.object_id, vv.object_id
    assert_equal     v.subvector, v

    vv = v.subvector(3)
    assert_equal [0, 0, 1, 0, 2, 0], vv.to_a
    assert_nothing_raised('subvector(-1)') { v.subvector(-1) }

    vv = v.subvector(-1)
    assert_equal [11, 0], vv.to_a

    vv = v.subvector(-2)
    assert_equal [10, 0, 11, 0], vv.to_a
    assert_raises(RangeError) { v.subvector(-13) }

    vv = v.subvector(2, 3)
    assert_equal [2, 0, 3, 0, 4, 0], vv.to_a

    vv = v.subvector(-4, 3)
    assert_equal [8, 0, 9, 0, 10, 0], vv.to_a
    assert_nothing_raised('subvector(-4, -3)') { v.subvector(-4, -3) }

    vv = v.subvector(-4, -3)
    assert_equal [8, 0, 7, 0, 6, 0], vv.to_a
    assert_raises(GSL::ERROR::EINVAL) { v.subvector(-11, -3) }

    vv = v.subvector(1, 3, 4)
    assert_equal [1, 0, 4, 0, 7, 0, 10, 0], vv.to_a

    {
    # ( range ) => [0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, 0, 8, 0, 9, 0, 10, 0, 11, 0]
      ( 1..  3) => [      1, 0, 2, 0, 3, 0                                                  ],
      ( 1... 3) => [      1, 0, 2, 0,                                                       ],
      ( 3..  1) => [      3, 0, 2, 0, 1, 0                                                  ],
      ( 3... 1) => [            3, 0, 2, 0                                                  ],
      (-7..  9) => [                              5, 0, 6, 0, 7, 0, 8, 0, 9, 0              ],
      (-7... 9) => [                              5, 0, 6, 0, 7, 0, 8, 0                    ],
      ( 4.. -3) => [                        4, 0, 5, 0, 6, 0, 7, 0, 8, 0, 9, 0              ],
      ( 4...-3) => [                        4, 0, 5, 0, 6, 0, 7, 0, 8, 0                    ],
      ( 2.. -2) => [            2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, 0, 8, 0, 9, 0, 10, 0       ],
      ( 2...-2) => [            2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, 0, 8, 0, 9, 0              ],
      (-2..  2) => [           10, 0, 9, 0, 8, 0, 7, 0, 6, 0, 5, 0, 4, 0, 3, 0,  2, 0       ],
      (-2... 2) => [           10, 0, 9, 0, 8, 0, 7, 0, 6, 0, 5, 0, 4, 0, 3, 0              ],
      (-3.. -1) => [                                                      9, 0, 10, 0, 11, 0],
      (-3...-1) => [                                                      9, 0, 10, 0       ],
      (-1.. -3) => [                                                     11, 0, 10, 0,  9, 0],
      (-1...-3) => [                                                     11, 0, 10, 0       ]
    }.each { |r, x|
      assert_nothing_raised("subvector(#{r})") { v.subvector(r) }
      assert_equal x, v.subvector(r).to_a, "subvector(#{r})"
    }

    {
    # [( range ), s] => [0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, 0, 8, 0, 9, 0, 10, 0, 11, 0]
      [( 1..  6), 2] => [      1, 0,       3, 0,       5, 0                                      ],
      [( 1... 6), 2] => [      1, 0,       3, 0,       5, 0                                      ],
      [( 0..  6), 3] => [0, 0,             3, 0,             6, 0                                ],
      [( 0... 6), 3] => [0, 0,             3, 0                                                  ]
    }.each { |(r, s), x|
      assert_nothing_raised("subvector(#{r},#{s})") { v.subvector(r) }
      assert_equal x, v.subvector(r,s).to_a, "subvector(#{r},#{s})"
    }
  end

  # Additional tests for vector_source.h coverage

  # Test Vector.alloc with various inputs
  def test_alloc_with_size
    v = GSL::Vector.alloc(5)
    assert_equal 5, v.size
    assert_in_delta 0.0, v[0], 1e-10
  end

  def test_alloc_with_values
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert_equal 3, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 2.0, v[1], 1e-10
    assert_in_delta 3.0, v[2], 1e-10
  end

  def test_alloc_with_array
    v = GSL::Vector.alloc([1.0, 2.0, 3.0, 4.0])
    assert_equal 4, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 4.0, v[3], 1e-10
  end

  def test_alloc_with_range
    v = GSL::Vector.alloc(1..5)
    assert_equal 5, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 5.0, v[4], 1e-10
  end

  def test_alloc_with_vector
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(v1)
    assert_equal 3, v2.size
    assert_in_delta 1.0, v2[0], 1e-10
    refute_equal v1.object_id, v2.object_id
  end

  def test_calloc
    v = GSL::Vector.calloc(5)
    assert_equal 5, v.size
    5.times { |i| assert_in_delta 0.0, v[i], 1e-10 }
  end

  # Test set and set_all
  def test_set_all
    v = GSL::Vector.alloc(5)
    v.set_all(3.5)
    5.times { |i| assert_in_delta 3.5, v[i], 1e-10 }
  end

  def test_set_single_value
    v = GSL::Vector.alloc(5)
    v.set(2, 7.0)
    assert_in_delta 7.0, v[2], 1e-10
  end

  def test_set_negative_index
    v = GSL::Vector.alloc(5)
    v.set(-1, 9.0)
    assert_in_delta 9.0, v[4], 1e-10
  end

  # Test size and stride
  def test_size
    v = GSL::Vector.alloc(7)
    assert_equal 7, v.size
  end

  def test_stride
    v = GSL::Vector.alloc(5)
    assert_equal 1, v.stride
  end

  def test_set_stride
    v = GSL::Vector.alloc(10)
    v.stride = 2
    assert_equal 2, v.stride
  end

  # Test get with negative index
  def test_get_negative_index
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    assert_in_delta 5.0, v[-1], 1e-10
    assert_in_delta 4.0, v[-2], 1e-10
    assert_in_delta 1.0, v[-5], 1e-10
  end

  # Test set_zero and set_basis
  def test_set_zero
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v.set_zero
    3.times { |i| assert_in_delta 0.0, v[i], 1e-10 }
  end

  def test_set_basis
    v = GSL::Vector.alloc(5)
    v.set_basis(2)
    assert_in_delta 0.0, v[0], 1e-10
    assert_in_delta 0.0, v[1], 1e-10
    assert_in_delta 1.0, v[2], 1e-10
    assert_in_delta 0.0, v[3], 1e-10
    assert_in_delta 0.0, v[4], 1e-10
  end

  # Test min, max, minmax
  def test_min
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    assert_in_delta 1.0, v.min, 1e-10
  end

  def test_max
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    assert_in_delta 4.0, v.max, 1e-10
  end

  def test_minmax
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    min, max = v.minmax
    assert_in_delta 1.0, min, 1e-10
    assert_in_delta 4.0, max, 1e-10
  end

  def test_min_index
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    assert_equal 1, v.min_index
  end

  def test_max_index
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    assert_equal 2, v.max_index
  end

  def test_minmax_index
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    imin, imax = v.minmax_index
    assert_equal 1, imin
    assert_equal 2, imax
  end

  # Test swap_elements, reverse
  def test_swap_elements
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v.swap_elements(0, 2)
    assert_in_delta 3.0, v[0], 1e-10
    assert_in_delta 2.0, v[1], 1e-10
    assert_in_delta 1.0, v[2], 1e-10
  end

  def test_reverse
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0)
    v.reverse!
    assert_equal [4.0, 3.0, 2.0, 1.0], v.to_a
  end

  # Test to_a
  def test_to_a
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert_equal [1.0, 2.0, 3.0], v.to_a
  end

  # Test scale, add_constant
  def test_scale
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.scale(2.0)
    assert_equal [2.0, 4.0, 6.0], result.to_a
  end

  def test_scale_inplace
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v.scale!(2.0)
    assert_equal [2.0, 4.0, 6.0], v.to_a
  end

  def test_add_constant
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.add_constant(5.0)
    assert_equal [6.0, 7.0, 8.0], result.to_a
  end

  # Test mul, div, add, sub
  def test_vector_add
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(10.0, 20.0, 30.0)
    result = v1 + v2
    assert_equal [11.0, 22.0, 33.0], result.to_a
  end

  def test_vector_sub
    v1 = GSL::Vector.alloc(10.0, 20.0, 30.0)
    v2 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v1 - v2
    assert_equal [9.0, 18.0, 27.0], result.to_a
  end

  def test_vector_mul
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(2.0, 3.0, 4.0)
    result = v1 * v2
    assert_equal [2.0, 6.0, 12.0], result.to_a
  end

  def test_vector_div
    v1 = GSL::Vector.alloc(10.0, 20.0, 30.0)
    v2 = GSL::Vector.alloc(2.0, 4.0, 5.0)
    result = v1 / v2
    assert_equal [5.0, 5.0, 6.0], result.to_a
  end

  # Test sum
  def test_sum
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    assert_in_delta 15.0, v.sum, 1e-10
  end

  # Test indgen
  def test_indgen
    v = GSL::Vector.indgen(5)
    assert_equal [0.0, 1.0, 2.0, 3.0, 4.0], v.to_a
  end

  def test_indgen_with_start
    v = GSL::Vector.indgen(5, 2)
    assert_equal [2.0, 3.0, 4.0, 5.0, 6.0], v.to_a
  end

  def test_indgen_with_start_and_step
    v = GSL::Vector.indgen(5, 0, 2)
    assert_equal [0.0, 2.0, 4.0, 6.0, 8.0], v.to_a
  end

  # Test linspace
  def test_linspace
    v = GSL::Vector.linspace(0, 10, 5)
    assert_equal 5, v.size
    assert_in_delta 0.0, v[0], 1e-10
    assert_in_delta 2.5, v[1], 1e-10
    assert_in_delta 10.0, v[4], 1e-10
  end

  # Test abs
  def test_abs
    v = GSL::Vector.alloc(-1.0, 2.0, -3.0, 4.0)
    result = v.abs
    assert_equal [1.0, 2.0, 3.0, 4.0], result.to_a
  end

  # Test isnull
  def test_isnull
    v = GSL::Vector.alloc(0.0, 0.0, 0.0)
    assert v.isnull?
    v[0] = 1.0
    refute v.isnull?
  end

  # Test equal?
  def test_equal
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v3 = GSL::Vector.alloc(1.0, 2.0, 4.0)
    assert v1.equal?(v2)
    refute v1.equal?(v3)
  end

  # Test dup/clone
  def test_dup
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = v1.dup
    assert_equal v1.to_a, v2.to_a
    refute_equal v1.object_id, v2.object_id
  end

  def test_clone
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = v1.clone
    assert_equal v1.to_a, v2.to_a
    refute_equal v1.object_id, v2.object_id
  end

  # Test Vector::Int specific methods
  def test_int_indgen
    v = GSL::Vector::Int.indgen(5)
    assert_equal [0, 1, 2, 3, 4], v.to_a
  end

  def test_int_alloc_from_array
    v = GSL::Vector::Int[1, 2, 3, 4, 5]
    assert_equal 5, v.size
    assert_equal [1, 2, 3, 4, 5], v.to_a
  end

  def test_int_min_max
    v = GSL::Vector::Int.alloc(3, 1, 4, 1, 5, 9, 2)
    assert_equal 1, v.min
    assert_equal 9, v.max
  end

  # Test view
  def test_view_subvector
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    view = v.subvector(1, 3)
    assert_kind_of GSL::Vector::View, view
    assert_equal 3, view.size
    assert_equal [2.0, 3.0, 4.0], view.to_a
  end

  # Test logspace
  def test_logspace
    v = GSL::Vector.logspace(0, 2, 3)
    assert_equal 3, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 10.0, v[1], 1e-10
    assert_in_delta 100.0, v[2], 1e-10
  end

  def test_logspace2
    v = GSL::Vector.logspace2(1, 100, 3)
    assert_equal 3, v.size
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 10.0, v[1], 1e-10
    assert_in_delta 100.0, v[2], 1e-10
  end

  # Test arithmetic with scalars
  def test_add_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v + 5.0
    assert_equal [6.0, 7.0, 8.0], result.to_a
  end

  def test_sub_scalar
    v = GSL::Vector.alloc(10.0, 20.0, 30.0)
    result = v - 5.0
    assert_equal [5.0, 15.0, 25.0], result.to_a
  end

  def test_mul_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v * 3.0
    assert_equal [3.0, 6.0, 9.0], result.to_a
  end

  def test_div_scalar
    v = GSL::Vector.alloc(10.0, 20.0, 30.0)
    result = v / 2.0
    assert_equal [5.0, 10.0, 15.0], result.to_a
  end

  # Test each iterators
  def test_each
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    values = []
    v.each { |x| values << x }
    assert_equal [1.0, 2.0, 3.0], values
  end

  def test_reverse_each
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    values = []
    v.reverse_each { |x| values << x }
    assert_equal [3.0, 2.0, 1.0], values
  end

  def test_each_index
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    indices = []
    v.each_index { |i| indices << i }
    assert_equal [0, 1, 2], indices
  end

  def test_reverse_each_index
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    indices = []
    v.reverse_each_index { |i| indices << i }
    assert_equal [2, 1, 0], indices
  end

  # Test transpose
  def test_transpose
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    vt = v.trans
    assert_kind_of GSL::Vector, vt
  end

  # Test sumsq, prod
  def test_sumsq
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert_in_delta 14.0, v.sumsq, 1e-10  # 1 + 4 + 9
  end

  def test_prod
    v = GSL::Vector.alloc(2.0, 3.0, 4.0)
    assert_in_delta 24.0, v.prod, 1e-10  # 2 * 3 * 4
  end

  # Test connect
  def test_connect
    v1 = GSL::Vector.alloc(1.0, 2.0)
    v2 = GSL::Vector.alloc(3.0, 4.0)
    result = v1.connect(v2)
    assert_equal [1.0, 2.0, 3.0, 4.0], result.to_a
  end

  def test_connect_multiple
    v1 = GSL::Vector.alloc(1.0)
    v2 = GSL::Vector.alloc(2.0)
    v3 = GSL::Vector.alloc(3.0)
    result = v1.connect(v2, v3)
    assert_equal [1.0, 2.0, 3.0], result.to_a
  end

  # Test sgn
  def test_sgn
    v = GSL::Vector.alloc(-2.0, 0.0, 3.0)
    result = v.sgn
    assert_equal [-1.0, 0.0, 1.0], result.to_a
  end

  # Test square, sqrt
  def test_square
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.square
    assert_equal [1.0, 4.0, 9.0], result.to_a
  end

  def test_sqrt
    v = GSL::Vector.alloc(1.0, 4.0, 9.0)
    result = v.sqrt
    assert_equal [1.0, 2.0, 3.0], result.to_a
  end

  # Test memcpy
  def test_memcpy
    src = GSL::Vector.alloc(1.0, 2.0, 3.0)
    dest = GSL::Vector.alloc(3)
    GSL::Vector.memcpy(dest, src)
    assert_equal [1.0, 2.0, 3.0], dest.to_a
  end

  # Test swap
  def test_swap
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    w = GSL::Vector.alloc(4.0, 5.0, 6.0)
    GSL::Vector.swap(v, w)
    assert_equal [4.0, 5.0, 6.0], v.to_a
    assert_equal [1.0, 2.0, 3.0], w.to_a
  end

  # Test maxmin
  def test_maxmin
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    max, min = v.maxmin
    assert_in_delta 4.0, max, 1e-10
    assert_in_delta 1.0, min, 1e-10
  end

  def test_maxmin_index
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    imax, imin = v.maxmin_index
    assert_equal 2, imax
    assert_equal 1, imin
  end

  # Test unary plus
  def test_uplus
    v = GSL::Vector.alloc(1.0, -2.0, 3.0)
    result = +v
    assert_equal [1.0, -2.0, 3.0], result.to_a
    # Note: +v may return self in some implementations
  end

  # Test owner
  def test_owner
    v = GSL::Vector.alloc(5)
    assert_equal 1, v.owner
  end

  # Test get with range
  def test_get_with_range
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    result = v[1..3]
    assert_equal [2.0, 3.0, 4.0], result.to_a
  end

  # Test set with index and value
  def test_set_index_value
    v = GSL::Vector.alloc(5)
    v.set(0, 1.0)
    v.set(1, 2.0)
    v.set(2, 3.0)
    assert_in_delta 1.0, v[0], 1e-10
    assert_in_delta 2.0, v[1], 1e-10
    assert_in_delta 3.0, v[2], 1e-10
  end

  # Test file I/O
  def test_fwrite_fread
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    filename = "/tmp/test_vector_#{$$}.bin"
    begin
      File.open(filename, 'wb') { |f| v.fwrite(f) }
      v2 = GSL::Vector.alloc(3)
      File.open(filename, 'rb') { |f| v2.fread(f) }
      assert_equal v.to_a, v2.to_a
    ensure
      File.delete(filename) if File.exist?(filename)
    end
  end

  # Test fprintf/fscanf
  def test_fprintf_fscanf
    v = GSL::Vector.alloc(1.5, 2.5, 3.5)
    filename = "/tmp/test_vector_#{$$}.txt"
    begin
      File.open(filename, 'w') { |f| v.fprintf(f, "%.1f") }
      v2 = GSL::Vector.alloc(3)
      File.open(filename, 'r') { |f| v2.fscanf(f) }
      3.times { |i| assert_in_delta v[i], v2[i], 0.1 }
    ensure
      File.delete(filename) if File.exist?(filename)
    end
  end

  # Test negate
  def test_negate
    v = GSL::Vector.alloc(1.0, -2.0, 3.0)
    result = -v
    assert_equal [-1.0, 2.0, -3.0], result.to_a
  end

  # Test to_poly
  def test_to_poly
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    p = v.to_poly
    assert_kind_of GSL::Poly, p
  end

  # Test power
  def test_power
    v = GSL::Vector.alloc(2.0, 3.0, 4.0)
    result = v ** 2
    assert_equal [4.0, 9.0, 16.0], result.to_a
  end

  # Test Vector::Int additional methods
  def test_int_sum
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5)
    assert_equal 15, v.sum
  end

  def test_int_sumsq
    v = GSL::Vector::Int.alloc(1, 2, 3)
    assert_equal 14, v.sumsq  # 1 + 4 + 9
  end

  def test_int_prod
    v = GSL::Vector::Int.alloc(2, 3, 4)
    assert_equal 24, v.prod
  end

  def test_int_swap_elements
    v = GSL::Vector::Int.alloc(1, 2, 3)
    v.swap_elements(0, 2)
    assert_equal [3, 2, 1], v.to_a
  end

  def test_int_reverse
    v = GSL::Vector::Int.alloc(1, 2, 3, 4)
    v.reverse!
    assert_equal [4, 3, 2, 1], v.to_a
  end

  def test_int_connect
    v1 = GSL::Vector::Int.alloc(1, 2)
    v2 = GSL::Vector::Int.alloc(3, 4)
    result = v1.connect(v2)
    assert_equal [1, 2, 3, 4], result.to_a
  end

  def test_int_each
    v = GSL::Vector::Int.alloc(1, 2, 3)
    values = []
    v.each { |x| values << x }
    assert_equal [1, 2, 3], values
  end

  def test_int_set_all
    v = GSL::Vector::Int.alloc(5)
    v.set_all(7)
    assert_equal [7, 7, 7, 7, 7], v.to_a
  end

  def test_int_set_zero
    v = GSL::Vector::Int.alloc(1, 2, 3)
    v.set_zero
    assert_equal [0, 0, 0], v.to_a
  end

  def test_int_set_basis
    v = GSL::Vector::Int.alloc(5)
    v.set_basis(2)
    assert_equal [0, 0, 1, 0, 0], v.to_a
  end

  def test_int_isnull
    v = GSL::Vector::Int.alloc(0, 0, 0)
    assert v.isnull?
    v[0] = 1
    refute v.isnull?
  end

end
