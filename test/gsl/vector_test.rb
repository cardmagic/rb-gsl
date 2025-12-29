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

  # Additional tests for improved coverage

  # Test inner_product / dot
  def test_inner_product
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(4.0, 5.0, 6.0)
    # 1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32
    assert_in_delta 32.0, v1.inner_product(v2), 1e-10
  end

  def test_inner_product_int
    v1 = GSL::Vector::Int.alloc(1, 2, 3)
    v2 = GSL::Vector::Int.alloc(4, 5, 6)
    assert_equal 32, v1.inner_product(v2)
  end

  # Test matrix_view - reshape vector to matrix
  def test_matrix_view
    v = GSL::Vector.indgen(6)  # [0, 1, 2, 3, 4, 5]
    m = v.matrix_view(2, 3)
    assert_kind_of GSL::Matrix::View, m
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 0.0, m[0, 0], 1e-10
    assert_in_delta 1.0, m[0, 1], 1e-10
    assert_in_delta 2.0, m[0, 2], 1e-10
    assert_in_delta 3.0, m[1, 0], 1e-10
  end

  # Test to_m_diagonal
  def test_to_m_diagonal
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    m = v.to_m_diagonal
    assert_kind_of GSL::Matrix, m
    assert_equal 3, m.size1
    assert_equal 3, m.size2
    assert_in_delta 1.0, m[0, 0], 1e-10
    assert_in_delta 0.0, m[0, 1], 1e-10
    assert_in_delta 2.0, m[1, 1], 1e-10
    assert_in_delta 3.0, m[2, 2], 1e-10
  end

  # Test to_m_circulant
  def test_to_m_circulant
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    m = v.to_m_circulant
    assert_kind_of GSL::Matrix, m
    assert_equal 3, m.size1
    assert_equal 3, m.size2
    # First row is [3, 1, 2] (circulant matrix)
    assert_in_delta 3.0, m[0, 0], 1e-10
    assert_in_delta 1.0, m[0, 1], 1e-10
    assert_in_delta 2.0, m[0, 2], 1e-10
  end

  # Test sort methods
  def test_sort
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    sorted = v.sort
    assert_equal [1.0, 1.5, 2.0, 3.0, 4.0], sorted.to_a
  end

  def test_sort_bang
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    v.sort!
    assert_equal [1.0, 1.5, 2.0, 3.0, 4.0], v.to_a
  end

  def test_sort_index
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    indices = v.sort_index
    assert_kind_of GSL::Permutation, indices
    # Index 1 has min (1.0), index 3 has 1.5, index 4 has 2.0, etc.
    assert_equal 1, indices[0]  # 1.0 is at index 1
  end

  def test_sort_smallest
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    smallest = v.sort_smallest(3)
    assert_equal 3, smallest.size
    assert_equal [1.0, 1.5, 2.0], smallest.to_a
  end

  def test_sort_largest
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    largest = v.sort_largest(3)
    assert_equal 3, largest.size
    assert_equal [4.0, 3.0, 2.0], largest.to_a
  end

  def test_sort_smallest_index
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    indices = v.sort_smallest_index(2)
    assert_equal 2, indices.size
    # Smallest values are at indices 1 and 3
    assert_includes indices.to_a, 1
  end

  def test_sort_largest_index
    v = GSL::Vector.alloc(3.0, 1.0, 4.0, 1.5, 2.0)
    indices = v.sort_largest_index(2)
    assert_equal 2, indices.size
    # Largest values are at indices 2 and 0
    assert_includes indices.to_a, 2
  end

  # Test diff
  def test_diff
    v = GSL::Vector.alloc(1.0, 3.0, 6.0, 10.0)
    d = v.diff
    assert_equal [2.0, 3.0, 4.0], d.to_a
  end

  def test_diff_with_n
    v = GSL::Vector.alloc(1.0, 3.0, 6.0, 10.0, 15.0)
    d = v.diff(2)  # second difference
    assert_equal 3, d.size
  end

  # Test isnan, isinf, finite
  def test_isnan
    v = GSL::Vector.alloc(1.0, Float::NAN, 3.0)
    result = v.isnan
    assert_kind_of GSL::Vector::Int, result
    assert_equal 0, result[0]
    assert_equal 1, result[1]
    assert_equal 0, result[2]
  end

  def test_isnan_predicate
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    # isnan? returns an array-like result, not a boolean
    result1 = v1.isnan?
    assert_kind_of Array, result1
    assert_equal [false, false, false], result1

    v2 = GSL::Vector.alloc(1.0, Float::NAN, 3.0)
    result2 = v2.isnan?
    assert_kind_of Array, result2
    assert_equal [false, true, false], result2
  end

  def test_isinf
    v = GSL::Vector.alloc(1.0, Float::INFINITY, 3.0)
    result = v.isinf
    assert_kind_of GSL::Vector::Int, result
    assert_equal 0, result[0]
    assert_equal 1, result[1]
    assert_equal 0, result[2]
  end

  def test_isinf_predicate
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    # isinf? returns an array-like result, not a boolean
    result1 = v1.isinf?
    assert_kind_of Array, result1
    assert_equal [false, false, false], result1

    v2 = GSL::Vector.alloc(1.0, Float::INFINITY, 3.0)
    result2 = v2.isinf?
    assert_kind_of Array, result2
    assert_equal [false, true, false], result2
  end

  def test_finite
    v = GSL::Vector.alloc(1.0, Float::NAN, Float::INFINITY)
    result = v.finite
    assert_kind_of GSL::Vector::Int, result
    assert_equal 1, result[0]
    assert_equal 0, result[1]
    assert_equal 0, result[2]
  end

  def test_finite_predicate
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    # finite? returns an array-like result
    result1 = v1.finite?
    assert_kind_of Array, result1
    assert_equal [true, true, true], result1

    v2 = GSL::Vector.alloc(1.0, Float::NAN, 3.0)
    result2 = v2.finite?
    assert_kind_of Array, result2
    assert_equal [true, false, true], result2
  end

  # Test delete_at - modifies original, returns deleted element
  def test_delete_at
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    result = v.delete_at(2)
    assert_in_delta 3.0, result, 1e-10  # Returns deleted element
    assert_equal [1.0, 2.0, 4.0, 5.0], v.to_a  # Original is modified
  end

  # Test delete_if
  def test_delete_if
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    result = v.delete_if { |x| x > 3.0 }
    assert_equal [1.0, 2.0, 3.0], result.to_a
  end

  # Test delete - returns deleted value
  def test_delete_value
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 2.0, 5.0)
    result = v.delete(2.0)
    assert_in_delta 2.0, result, 1e-10  # Returns deleted value
    # Check original is modified
    assert_equal [1.0, 3.0, 5.0], v.to_a
  end

  # Test concat
  def test_concat
    v1 = GSL::Vector.alloc(1.0, 2.0)
    v2 = GSL::Vector.alloc(3.0, 4.0)
    result = v1.concat(v2)
    assert_equal [1.0, 2.0, 3.0, 4.0], result.to_a
  end

  # Test first and last
  def test_first
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    assert_in_delta 1.0, v.first, 1e-10
  end

  def test_last
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    assert_in_delta 5.0, v.last, 1e-10
  end

  # Test cumsum and cumprod
  def test_cumsum
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0)
    result = v.cumsum
    assert_equal [1.0, 3.0, 6.0, 10.0], result.to_a
  end

  def test_cumprod
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0)
    result = v.cumprod
    assert_equal [1.0, 2.0, 6.0, 24.0], result.to_a
  end

  # Helper to convert Block::Byte to array
  def block_to_array(block)
    arr = []
    block.each { |x| arr << x }
    arr
  end

  # Test comparison operators
  def test_eq
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(1.0, 5.0, 3.0)
    result = v1.eq(v2)
    assert_equal [1, 0, 1], block_to_array(result)
  end

  def test_ne
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(1.0, 5.0, 3.0)
    result = v1.ne(v2)
    assert_equal [0, 1, 0], block_to_array(result)
  end

  def test_gt
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(0.0, 2.0, 5.0)
    result = v1.gt(v2)
    assert_equal [1, 0, 0], block_to_array(result)
  end

  def test_ge
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(0.0, 2.0, 5.0)
    result = v1.ge(v2)
    assert_equal [1, 1, 0], block_to_array(result)
  end

  def test_lt
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(0.0, 2.0, 5.0)
    result = v1.lt(v2)
    assert_equal [0, 0, 1], block_to_array(result)
  end

  def test_le
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(0.0, 2.0, 5.0)
    result = v1.le(v2)
    assert_equal [0, 1, 1], block_to_array(result)
  end

  def test_vector_and
    v1 = GSL::Vector.alloc(0.0, 1.0, 2.0)
    v2 = GSL::Vector.alloc(1.0, 0.0, 3.0)
    result = v1.and(v2)
    assert_equal [0, 0, 1], block_to_array(result)
  end

  def test_vector_or
    v1 = GSL::Vector.alloc(0.0, 1.0, 0.0)
    v2 = GSL::Vector.alloc(1.0, 0.0, 0.0)
    result = v1.or(v2)
    assert_equal [1, 1, 0], block_to_array(result)
  end

  def test_vector_xor
    v1 = GSL::Vector.alloc(0.0, 1.0, 1.0)
    v2 = GSL::Vector.alloc(1.0, 0.0, 1.0)
    result = v1.xor(v2)
    assert_equal [1, 1, 0], block_to_array(result)
  end

  def test_vector_not
    v = GSL::Vector.alloc(0.0, 1.0, 2.0)
    result = v.not
    assert_equal [1, 0, 0], block_to_array(result)
  end

  # Test any, none, all
  def test_any
    v1 = GSL::Vector.alloc(0.0, 0.0, 0.0)
    assert_equal 0, v1.any
    refute v1.any?

    v2 = GSL::Vector.alloc(0.0, 1.0, 0.0)
    assert_equal 1, v2.any
    assert v2.any?
  end

  # The 'none' method may not exist, only 'none?'
  def test_none
    v1 = GSL::Vector.alloc(0.0, 0.0, 0.0)
    assert v1.none?

    v2 = GSL::Vector.alloc(0.0, 1.0, 0.0)
    refute v2.none?
  end

  # The 'all' method may not exist, only 'all?'
  def test_all
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert v1.all?

    v2 = GSL::Vector.alloc(0.0, 1.0, 2.0)
    refute v2.all?
  end

  # Test where
  def test_where
    v = GSL::Vector.alloc(0.0, 1.0, 0.0, 2.0, 0.0)
    indices = v.where
    # Returns indices where values are non-zero
    assert_includes indices.to_a, 1
    assert_includes indices.to_a, 3
  end

  def test_where2
    v = GSL::Vector.alloc(0.0, 1.0, 0.0, 2.0, 0.0)
    nonzero, zero = v.where2
    # nonzero contains indices of non-zero values
    # zero contains indices of zero values
    assert_equal 2, nonzero.size
    assert_equal 3, zero.size
  end

  # Test zip
  def test_zip
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(4.0, 5.0, 6.0)
    result = v1.zip(v2)
    assert_kind_of Array, result
    assert_equal 3, result.size
  end

  # Test join
  def test_join
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.join(", ")
    assert_kind_of String, result
    assert_match(/1/, result)
    assert_match(/2/, result)
    assert_match(/3/, result)
  end

  def test_join_default
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.join
    assert_kind_of String, result
  end

  # Test inplace operations
  def test_add_inplace
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(10.0, 20.0, 30.0)
    v1.add!(v2)
    assert_equal [11.0, 22.0, 33.0], v1.to_a
  end

  def test_sub_inplace
    v1 = GSL::Vector.alloc(10.0, 20.0, 30.0)
    v2 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v1.sub!(v2)
    assert_equal [9.0, 18.0, 27.0], v1.to_a
  end

  def test_mul_inplace
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(2.0, 3.0, 4.0)
    v1.mul!(v2)
    assert_equal [2.0, 6.0, 12.0], v1.to_a
  end

  def test_div_inplace
    v1 = GSL::Vector.alloc(10.0, 20.0, 30.0)
    v2 = GSL::Vector.alloc(2.0, 4.0, 5.0)
    v1.div!(v2)
    assert_equal [5.0, 5.0, 6.0], v1.to_a
  end

  # Test subvector_with_stride
  def test_subvector_with_stride
    v = GSL::Vector.indgen(10)  # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    # Every other element starting from 0
    sv = v.subvector_with_stride(2)
    assert_equal [0.0, 2.0, 4.0, 6.0, 8.0], sv.to_a
  end

  def test_subvector_with_stride_offset
    v = GSL::Vector.indgen(10)
    # Every other element starting from index 1
    sv = v.subvector_with_stride(1, 2)
    assert_equal [1.0, 3.0, 5.0, 7.0, 9.0], sv.to_a
  end

  def test_subvector_with_stride_offset_length
    v = GSL::Vector.indgen(10)
    # 3 elements, starting at index 2, stride 2
    sv = v.subvector_with_stride(2, 2, 3)
    assert_equal [2.0, 4.0, 6.0], sv.to_a
  end

  # Test to_s and inspect
  def test_to_s
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    s = v.to_s
    assert_kind_of String, s
    assert_match(/\[/, s)
    assert_match(/\]/, s)
  end

  def test_to_s_empty
    v = GSL::Vector.alloc(0)
    s = v.to_s
    assert_equal "[ ]", s
  end

  def test_inspect
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    s = v.inspect
    assert_kind_of String, s
    assert_match(/GSL::Vector/, s)
  end

  # Test print
  def test_print
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    # print returns nil
    assert_nil v.print
  end

  # Test block
  def test_block
    v = GSL::Vector.alloc(5)
    b = v.block
    assert_kind_of GSL::Block, b
  end

  # Test to_m
  def test_to_m
    v = GSL::Vector.indgen(6)
    m = v.to_m(2, 3)
    assert_kind_of GSL::Matrix, m
    assert_equal 2, m.size1
    assert_equal 3, m.size2
  end

  # Test histogram
  def test_histogram
    v = GSL::Vector.alloc(0.5, 1.5, 2.5, 3.5, 4.5)
    h = v.histogram(5)
    assert_kind_of GSL::Histogram, h
    assert_equal 5, h.bins
  end

  # Test indgen_bang
  def test_indgen_bang
    v = GSL::Vector.alloc(5)
    v.indgen!
    assert_equal [0.0, 1.0, 2.0, 3.0, 4.0], v.to_a
  end

  def test_indgen_bang_with_start
    v = GSL::Vector.alloc(5)
    v.indgen!(10)
    assert_equal [10.0, 11.0, 12.0, 13.0, 14.0], v.to_a
  end

  def test_indgen_bang_with_start_and_step
    v = GSL::Vector.alloc(5)
    v.indgen!(0, 2)
    assert_equal [0.0, 2.0, 4.0, 6.0, 8.0], v.to_a
  end

  # Test trans! (in-place transpose)
  def test_trans_bang
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v.trans!
    assert_kind_of GSL::Vector::Col, v
  end

  # Test Vector::Col
  def test_vector_col
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    col = v.col
    assert_kind_of GSL::Vector::Col, col
  end

  def test_vector_col_to_s
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    col = v.col
    s = col.to_s
    assert_kind_of String, s
    # Column vectors have newlines in their representation
    assert_match(/\n/, s)
  end

  # Test reverse (non-destructive)
  def test_reverse_nondestructive
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    r = v.reverse
    assert_equal [3.0, 2.0, 1.0], r.to_a
    # Original unchanged
    assert_equal [1.0, 2.0, 3.0], v.to_a
  end

  # Test with permutation for get
  def test_get_with_permutation
    v = GSL::Vector.alloc(10.0, 20.0, 30.0, 40.0, 50.0)
    p = GSL::Permutation.alloc(3)
    p[0] = 4
    p[1] = 2
    p[2] = 0
    result = v[p]
    assert_equal [50.0, 30.0, 10.0], result.to_a
  end

  # Test set with subvector from array
  def test_set_subvector_from_array
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    v.set(1, 3, [10.0, 20.0, 30.0])
    assert_equal [1.0, 10.0, 20.0, 30.0, 5.0], v.to_a
  end

  # Test set with subvector from range
  def test_set_subvector_from_range
    v = GSL::Vector.alloc(5)
    v.set(0, 5, 1..5)
    assert_equal [1.0, 2.0, 3.0, 4.0, 5.0], v.to_a
  end

  # Test alloc with single float value
  def test_alloc_with_float
    v = GSL::Vector.alloc(3.14)
    assert_equal 1, v.size
    assert_in_delta 3.14, v[0], 1e-10
  end

  # Test Int sort
  def test_int_sort
    v = GSL::Vector::Int.alloc(3, 1, 4, 1, 5)
    sorted = v.sort
    assert_equal [1, 1, 3, 4, 5], sorted.to_a
  end

  def test_int_sort_bang
    v = GSL::Vector::Int.alloc(3, 1, 4, 1, 5)
    v.sort!
    assert_equal [1, 1, 3, 4, 5], v.to_a
  end

  # Test Int abs
  def test_int_abs
    v = GSL::Vector::Int.alloc(-1, 2, -3)
    result = v.abs
    assert_equal [1, 2, 3], result.to_a
  end

  # Test Int sgn
  def test_int_sgn
    v = GSL::Vector::Int.alloc(-2, 0, 3)
    result = v.sgn
    assert_equal [-1, 0, 1], result.to_a
  end

  # Test add_constant!
  def test_add_constant_bang
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v.add_constant!(5.0)
    assert_equal [6.0, 7.0, 8.0], v.to_a
  end

  # Test equal? with epsilon
  def test_equal_with_epsilon
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(1.0001, 2.0001, 3.0001)
    refute v1.equal?(v2, 1e-5)
    assert v1.equal?(v2, 1e-3)
  end

  # Test equal? with scalar
  def test_equal_with_scalar
    v = GSL::Vector.alloc(5.0, 5.0, 5.0)
    assert v.equal?(5.0)
    refute v.equal?(6.0)
  end

  # Test collect!
  def test_collect_bang
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v.collect! { |x| x * x }
    assert_equal [1.0, 4.0, 9.0], v.to_a
  end

  # Test Int collect!
  def test_int_collect_bang
    v = GSL::Vector::Int.alloc(1, 2, 3)
    v.collect! { |x| x * 2 }
    assert_equal [2, 4, 6], v.to_a
  end

  # Test Int collect
  def test_int_collect
    v = GSL::Vector::Int.alloc(1, 2, 3)
    result = v.collect { |x| x * 2 }
    assert_equal [2, 4, 6], result.to_a
    # Original unchanged
    assert_equal [1, 2, 3], v.to_a
  end

  # Test view from subvector
  def test_view_size
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    view = v.subvector(1, 3)
    assert_equal 3, view.size
  end

  def test_view_stride
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    view = v.subvector(0, 2, 2)  # offset=0, stride=2, length=2
    assert_equal 2, view.stride
  end

  # Test clone from view
  def test_clone_from_view
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    view = v.subvector(1, 3)
    cloned = view.clone
    assert_equal [2.0, 3.0, 4.0], cloned.to_a
    # Cloned is a regular vector, not a view
    assert_kind_of GSL::Vector, cloned
  end

  # Test Int view
  def test_int_view
    v = GSL::Vector::Int.indgen(5)
    view = v.subvector(1, 3)
    assert_kind_of GSL::Vector::Int::View, view
    assert_equal [1, 2, 3], view.to_a
  end

  # Test Int memcpy
  def test_int_memcpy
    src = GSL::Vector::Int.alloc(1, 2, 3)
    dest = GSL::Vector::Int.alloc(3)
    GSL::Vector::Int.memcpy(dest, src)
    assert_equal [1, 2, 3], dest.to_a
  end

  # Test Int swap
  def test_int_swap
    v = GSL::Vector::Int.alloc(1, 2, 3)
    w = GSL::Vector::Int.alloc(4, 5, 6)
    GSL::Vector::Int.swap(v, w)
    assert_equal [4, 5, 6], v.to_a
    assert_equal [1, 2, 3], w.to_a
  end

  # Test Vector::Int::Col
  def test_int_col
    v = GSL::Vector::Int.alloc(1, 2, 3)
    col = v.col
    assert_kind_of GSL::Vector::Int::Col, col
  end

  def test_int_trans
    v = GSL::Vector::Int.alloc(1, 2, 3)
    col = v.trans
    assert_kind_of GSL::Vector::Int::Col, col
  end

  def test_int_trans_bang
    v = GSL::Vector::Int.alloc(1, 2, 3)
    v.trans!
    assert_kind_of GSL::Vector::Int::Col, v
  end

  # Test Int comparison operations
  def test_int_eq
    v1 = GSL::Vector::Int.alloc(1, 2, 3)
    v2 = GSL::Vector::Int.alloc(1, 5, 3)
    result = v1.eq(v2)
    # Int comparison returns GSL::Block::Byte, convert to array manually
    arr = []
    result.each { |x| arr << x }
    assert_equal [1, 0, 1], arr
  end

  def test_int_gt
    v1 = GSL::Vector::Int.alloc(1, 2, 3)
    v2 = GSL::Vector::Int.alloc(0, 2, 5)
    result = v1.gt(v2)
    # Int comparison returns GSL::Block::Byte, convert to array manually
    arr = []
    result.each { |x| arr << x }
    assert_equal [1, 0, 0], arr
  end

  # Test Int any/all/none
  def test_int_any
    v1 = GSL::Vector::Int.alloc(0, 0, 0)
    refute v1.any?

    v2 = GSL::Vector::Int.alloc(0, 1, 0)
    assert v2.any?
  end

  def test_int_all
    v1 = GSL::Vector::Int.alloc(1, 2, 3)
    assert v1.all?

    v2 = GSL::Vector::Int.alloc(0, 1, 2)
    refute v2.all?
  end

  def test_int_none
    v1 = GSL::Vector::Int.alloc(0, 0, 0)
    assert v1.none?

    v2 = GSL::Vector::Int.alloc(0, 1, 0)
    refute v2.none?
  end

  # Test Int where
  def test_int_where
    v = GSL::Vector::Int.alloc(0, 1, 0, 2, 0)
    indices = v.where
    assert_includes indices.to_a, 1
    assert_includes indices.to_a, 3
  end

  # Test Int cumsum/cumprod
  def test_int_cumsum
    v = GSL::Vector::Int.alloc(1, 2, 3, 4)
    result = v.cumsum
    assert_equal [1, 3, 6, 10], result.to_a
  end

  def test_int_cumprod
    v = GSL::Vector::Int.alloc(1, 2, 3, 4)
    result = v.cumprod
    assert_equal [1, 2, 6, 24], result.to_a
  end

  # Test Int inner_product via singleton
  def test_inner_product_singleton
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(4.0, 5.0, 6.0)
    result = GSL::Vector.inner_product(v1, v2)
    assert_in_delta 32.0, result, 1e-10
  end

  # ========== Block tests ==========

  def test_block_alloc
    b = GSL::Block.alloc(5)
    assert_kind_of GSL::Block, b
    assert_equal 5, b.size
  end

  def test_block_calloc
    b = GSL::Block.calloc(5)
    assert_kind_of GSL::Block, b
    assert_equal 5, b.size
    # calloc initializes to zero
    5.times { |i| assert_in_delta 0.0, b[i], 1e-10 }
  end

  def test_block_get_set
    b = GSL::Block.alloc(5)
    b[0] = 1.0
    b[1] = 2.0
    b[2] = 3.0
    assert_in_delta 1.0, b[0], 1e-10
    assert_in_delta 2.0, b[1], 1e-10
    assert_in_delta 3.0, b[2], 1e-10
  end

  def test_block_to_s
    b = GSL::Block.alloc(3)
    b[0] = 1.0
    b[1] = 2.0
    b[2] = 3.0
    s = b.to_s
    assert_kind_of String, s
  end

  def test_block_inspect
    b = GSL::Block.alloc(3)
    s = b.inspect
    assert_kind_of String, s
    assert_match(/Block/, s)
  end

  def test_block_size
    b = GSL::Block.alloc(7)
    assert_equal 7, b.size
  end

  def test_block_each
    b = GSL::Block.alloc(3)
    b[0] = 1.0
    b[1] = 2.0
    b[2] = 3.0
    values = []
    b.each { |x| values << x }
    assert_equal 3, values.size
    assert_in_delta 1.0, values[0], 1e-10
    assert_in_delta 2.0, values[1], 1e-10
    assert_in_delta 3.0, values[2], 1e-10
  end

  def test_block_collect
    b = GSL::Block.alloc(3)
    b[0] = 1.0
    b[1] = 2.0
    b[2] = 3.0
    result = b.collect { |x| x * 2 }
    assert_kind_of GSL::Block, result
    assert_in_delta 2.0, result[0], 1e-10
    assert_in_delta 4.0, result[1], 1e-10
    assert_in_delta 6.0, result[2], 1e-10
  end

  def test_block_get_with_range
    b = GSL::Block.alloc(5)
    5.times { |i| b[i] = i.to_f }
    result = b[1..3]
    assert_kind_of GSL::Block, result
    assert_equal 3, result.size
  end

  def test_block_get_with_array
    b = GSL::Block.alloc(5)
    5.times { |i| b[i] = i.to_f * 10 }
    result = b[[0, 2, 4]]
    assert_kind_of GSL::Block, result
    assert_equal 3, result.size
    assert_in_delta 0.0, result[0], 1e-10
    assert_in_delta 20.0, result[1], 1e-10
    assert_in_delta 40.0, result[2], 1e-10
  end

  def test_block_fwrite_fread
    b = GSL::Block.alloc(3)
    b[0] = 1.5
    b[1] = 2.5
    b[2] = 3.5
    filename = "/tmp/test_block_#{$$}.bin"
    begin
      File.open(filename, 'wb') { |f| b.fwrite(f) }
      b2 = GSL::Block.alloc(3)
      File.open(filename, 'rb') { |f| b2.fread(f) }
      3.times { |i| assert_in_delta b[i], b2[i], 1e-10 }
    ensure
      File.delete(filename) if File.exist?(filename)
    end
  end

  def test_block_fprintf_fscanf
    b = GSL::Block.alloc(3)
    b[0] = 1.5
    b[1] = 2.5
    b[2] = 3.5
    filename = "/tmp/test_block_#{$$}.txt"
    begin
      File.open(filename, 'w') { |f| b.fprintf(f, "%.1f") }
      b2 = GSL::Block.alloc(3)
      File.open(filename, 'r') { |f| b2.fscanf(f) }
      3.times { |i| assert_in_delta b[i], b2[i], 0.1 }
    ensure
      File.delete(filename) if File.exist?(filename)
    end
  end

  def test_block_comparison_eq
    b1 = GSL::Block.alloc(3)
    b2 = GSL::Block.alloc(3)
    3.times { |i|
      b1[i] = i.to_f
      b2[i] = i.to_f
    }
    b2[1] = 10.0  # Make one different
    result = b1.eq(b2)
    arr = block_to_array(result)
    assert_equal [1, 0, 1], arr
  end

  def test_block_comparison_ne
    b1 = GSL::Block.alloc(3)
    b2 = GSL::Block.alloc(3)
    3.times { |i|
      b1[i] = i.to_f
      b2[i] = i.to_f
    }
    b2[1] = 10.0
    result = b1.ne(b2)
    arr = block_to_array(result)
    assert_equal [0, 1, 0], arr
  end

  def test_block_comparison_gt
    b1 = GSL::Block.alloc(3)
    b2 = GSL::Block.alloc(3)
    b1[0] = 5.0; b2[0] = 3.0  # gt
    b1[1] = 3.0; b2[1] = 3.0  # eq
    b1[2] = 1.0; b2[2] = 3.0  # lt
    result = b1.gt(b2)
    arr = block_to_array(result)
    assert_equal [1, 0, 0], arr
  end

  def test_block_comparison_ge
    b1 = GSL::Block.alloc(3)
    b2 = GSL::Block.alloc(3)
    b1[0] = 5.0; b2[0] = 3.0
    b1[1] = 3.0; b2[1] = 3.0
    b1[2] = 1.0; b2[2] = 3.0
    result = b1.ge(b2)
    arr = block_to_array(result)
    assert_equal [1, 1, 0], arr
  end

  def test_block_comparison_lt
    b1 = GSL::Block.alloc(3)
    b2 = GSL::Block.alloc(3)
    b1[0] = 5.0; b2[0] = 3.0
    b1[1] = 3.0; b2[1] = 3.0
    b1[2] = 1.0; b2[2] = 3.0
    result = b1.lt(b2)
    arr = block_to_array(result)
    assert_equal [0, 0, 1], arr
  end

  def test_block_comparison_le
    b1 = GSL::Block.alloc(3)
    b2 = GSL::Block.alloc(3)
    b1[0] = 5.0; b2[0] = 3.0
    b1[1] = 3.0; b2[1] = 3.0
    b1[2] = 1.0; b2[2] = 3.0
    result = b1.le(b2)
    arr = block_to_array(result)
    assert_equal [0, 1, 1], arr
  end

  def test_block_and
    b1 = GSL::Block.alloc(3)
    b2 = GSL::Block.alloc(3)
    b1[0] = 0.0; b2[0] = 1.0
    b1[1] = 1.0; b2[1] = 0.0
    b1[2] = 1.0; b2[2] = 1.0
    result = b1.and(b2)
    arr = block_to_array(result)
    assert_equal [0, 0, 1], arr
  end

  def test_block_or
    b1 = GSL::Block.alloc(3)
    b2 = GSL::Block.alloc(3)
    b1[0] = 0.0; b2[0] = 0.0
    b1[1] = 1.0; b2[1] = 0.0
    b1[2] = 0.0; b2[2] = 1.0
    result = b1.or(b2)
    arr = block_to_array(result)
    assert_equal [0, 1, 1], arr
  end

  def test_block_xor
    b1 = GSL::Block.alloc(3)
    b2 = GSL::Block.alloc(3)
    b1[0] = 0.0; b2[0] = 1.0
    b1[1] = 1.0; b2[1] = 0.0
    b1[2] = 1.0; b2[2] = 1.0
    result = b1.xor(b2)
    arr = block_to_array(result)
    assert_equal [1, 1, 0], arr
  end

  def test_block_not
    b = GSL::Block.alloc(3)
    b[0] = 0.0
    b[1] = 1.0
    b[2] = 2.0
    result = b.not
    arr = block_to_array(result)
    assert_equal [1, 0, 0], arr
  end

  def test_block_any
    b1 = GSL::Block.alloc(3)
    b1[0] = 0.0; b1[1] = 0.0; b1[2] = 0.0
    refute b1.any?

    b2 = GSL::Block.alloc(3)
    b2[0] = 0.0; b2[1] = 1.0; b2[2] = 0.0
    assert b2.any?
  end

  def test_block_all
    b1 = GSL::Block.alloc(3)
    b1[0] = 1.0; b1[1] = 2.0; b1[2] = 3.0
    assert b1.all?

    b2 = GSL::Block.alloc(3)
    b2[0] = 0.0; b2[1] = 1.0; b2[2] = 2.0
    refute b2.all?
  end

  def test_block_none
    b1 = GSL::Block.alloc(3)
    b1[0] = 0.0; b1[1] = 0.0; b1[2] = 0.0
    assert b1.none?

    b2 = GSL::Block.alloc(3)
    b2[0] = 0.0; b2[1] = 1.0; b2[2] = 0.0
    refute b2.none?
  end

  def test_block_where
    b = GSL::Block.alloc(5)
    b[0] = 0.0
    b[1] = 1.0
    b[2] = 0.0
    b[3] = 2.0
    b[4] = 0.0
    indices = b.where
    # Indices where non-zero
    assert_includes indices.to_a, 1
    assert_includes indices.to_a, 3
  end

  def test_block_where2
    b = GSL::Block.alloc(5)
    b[0] = 0.0
    b[1] = 1.0
    b[2] = 0.0
    b[3] = 2.0
    b[4] = 0.0
    nonzero, zero = b.where2
    assert_equal 2, nonzero.size
    assert_equal 3, zero.size
  end

  # ========== Additional tests for vector_source.h coverage ==========

  # Test concat with different argument types
  def test_concat_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.concat(4.0)
    assert_equal [1.0, 2.0, 3.0, 4.0], result.to_a
  end

  def test_concat_with_array
    v = GSL::Vector.alloc(1.0, 2.0)
    result = v.concat([3.0, 4.0, 5.0])
    assert_equal [1.0, 2.0, 3.0, 4.0, 5.0], result.to_a
  end

  def test_concat_with_range
    v = GSL::Vector.alloc(1.0, 2.0)
    result = v.concat(3..5)
    assert_equal [1.0, 2.0, 3.0, 4.0, 5.0], result.to_a
  end

  # Test comparison operators with scalars
  def test_eq_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 1.0)
    result = v.eq(1.0)
    assert_equal [1, 0, 1], block_to_array(result)
  end

  def test_ne_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 1.0)
    result = v.ne(1.0)
    assert_equal [0, 1, 0], block_to_array(result)
  end

  def test_gt_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.gt(2.0)
    assert_equal [0, 0, 1], block_to_array(result)
  end

  def test_ge_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.ge(2.0)
    assert_equal [0, 1, 1], block_to_array(result)
  end

  def test_lt_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.lt(2.0)
    assert_equal [1, 0, 0], block_to_array(result)
  end

  def test_le_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.le(2.0)
    assert_equal [1, 1, 0], block_to_array(result)
  end

  def test_and_with_scalar
    v = GSL::Vector.alloc(0.0, 1.0, 2.0)
    result = v.and(1.0)
    assert_equal [0, 1, 1], block_to_array(result)
  end

  def test_or_with_scalar
    v = GSL::Vector.alloc(0.0, 1.0, 0.0)
    result = v.or(1.0)
    assert_equal [1, 1, 1], block_to_array(result)
  end

  def test_xor_with_scalar
    v = GSL::Vector.alloc(0.0, 1.0, 2.0)
    result = v.xor(0.0)
    assert_equal [0, 1, 1], block_to_array(result)
  end

  # Test any/all/none with block
  def test_any_with_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert v.any? { |x| x > 2.0 }
    refute v.any? { |x| x > 10.0 }
  end

  def test_all_with_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert v.all? { |x| x > 0.0 }
    refute v.all? { |x| x > 2.0 }
  end

  def test_none_with_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert v.none? { |x| x > 10.0 }
    refute v.none? { |x| x > 2.0 }
  end

  def test_any_with_block_returning_int
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert_equal 1, v.any { |x| x > 2.0 }
    assert_equal 0, v.any { |x| x > 10.0 }
  end

  # Test where with block
  def test_where_with_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    indices = v.where { |x| x > 3.0 }
    assert_includes indices.to_a, 3
    assert_includes indices.to_a, 4
  end

  def test_where2_with_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    over, under = v.where2 { |x| x > 3.0 }
    assert_equal 2, over.size
    assert_equal 3, under.size
  end

  # Test where returning nil when no matches
  def test_where_returns_nil_when_no_matches
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.where { |x| x > 10.0 }
    assert_nil result
  end

  # Test where2 edge cases
  def test_where2_all_true
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    over, under = v.where2 { |x| x > 0.0 }
    assert_equal 3, over.size
    assert_nil under
  end

  def test_where2_all_false
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    over, under = v.where2 { |x| x > 10.0 }
    assert_nil over
    assert_equal 3, under.size
  end

  # Test inplace operations with scalars
  def test_add_inplace_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v.add!(5.0)
    assert_equal [6.0, 7.0, 8.0], v.to_a
  end

  def test_sub_inplace_with_scalar
    v = GSL::Vector.alloc(10.0, 20.0, 30.0)
    v.sub!(5.0)
    assert_equal [5.0, 15.0, 25.0], v.to_a
  end

  def test_mul_inplace_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v.mul!(3.0)
    assert_equal [3.0, 6.0, 9.0], v.to_a
  end

  def test_div_inplace_with_scalar
    v = GSL::Vector.alloc(10.0, 20.0, 30.0)
    v.div!(2.0)
    assert_equal [5.0, 10.0, 15.0], v.to_a
  end

  # Test histogram with different argument types
  def test_histogram_with_range
    v = GSL::Vector.alloc(0.5, 1.5, 2.5, 3.5, 4.5)
    h = v.histogram(5, [0, 5])
    assert_kind_of GSL::Histogram, h
    assert_equal 5, h.bins
  end

  def test_histogram_with_min_max
    v = GSL::Vector.alloc(0.5, 1.5, 2.5, 3.5, 4.5)
    h = v.histogram(5, 0.0, 5.0)
    assert_kind_of GSL::Histogram, h
    assert_equal 5, h.bins
  end

  def test_histogram_with_range_vector
    v = GSL::Vector.alloc(0.5, 1.5, 2.5, 3.5, 4.5)
    ranges = GSL::Vector.alloc(0.0, 1.0, 2.0, 3.0, 4.0, 5.0)
    h = v.histogram(ranges)
    assert_kind_of GSL::Histogram, h
    assert_equal 5, h.bins
  end

  def test_histogram_with_array
    v = GSL::Vector.alloc(0.5, 1.5, 2.5, 3.5, 4.5)
    h = v.histogram([0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    assert_kind_of GSL::Histogram, h
    assert_equal 5, h.bins
  end

  # Test matrix_view_with_tda
  def test_matrix_view_with_tda
    v = GSL::Vector.indgen(12)
    m = v.matrix_view(3, 3, 4)  # 3x3 matrix with tda=4
    assert_kind_of GSL::Matrix::View, m
    assert_equal 3, m.size1
    assert_equal 3, m.size2
  end

  # Test subvector_with_stride error cases
  def test_subvector_with_stride_zero_stride_error
    v = GSL::Vector.indgen(10)
    assert_raises(ArgumentError) { v.subvector_with_stride(0) }
  end

  def test_subvector_with_stride_negative_offset
    v = GSL::Vector.indgen(10)
    sv = v.subvector_with_stride(-5, 2)
    assert_equal [5.0, 7.0, 9.0], sv.to_a
  end

  def test_subvector_with_stride_offset_out_of_range
    v = GSL::Vector.indgen(10)
    assert_raises(RangeError) { v.subvector_with_stride(10, 1) }
    assert_raises(RangeError) { v.subvector_with_stride(-11, 1) }
  end

  def test_subvector_with_stride_negative_length
    v = GSL::Vector.indgen(10)
    assert_raises(ArgumentError) { v.subvector_with_stride(0, 2, -1) }
  end

  # Test delete_at edge cases
  def test_delete_at_negative_index
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    result = v.delete_at(-1)
    assert_in_delta 5.0, result, 1e-10
    assert_equal [1.0, 2.0, 3.0, 4.0], v.to_a
  end

  def test_delete_at_out_of_range
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.delete_at(10)
    assert_nil result
    result = v.delete_at(-10)
    assert_nil result
  end

  def test_delete_at_empty
    v = GSL::Vector.alloc(0)
    result = v.delete_at(0)
    assert_nil result
  end

  # Test delete edge cases
  def test_delete_not_found
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.delete(10.0)
    assert_nil result
    assert_equal [1.0, 2.0, 3.0], v.to_a  # unchanged
  end

  # Test set with range assignment
  def test_set_subvector_from_vector
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    other = GSL::Vector.alloc(10.0, 20.0, 30.0)
    v.set(1, 3, other)
    assert_equal [1.0, 10.0, 20.0, 30.0, 5.0], v.to_a
  end

  # Test set with scalar for subvector
  def test_set_subvector_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    v.set(1, 3, 0.0)
    assert_equal [1.0, 0.0, 0.0, 0.0, 5.0], v.to_a
  end

  # Test Int comparison with scalar
  def test_int_eq_with_scalar
    v = GSL::Vector::Int.alloc(1, 2, 1, 3, 1)
    result = v.eq(1)
    arr = block_to_array(result)
    assert_equal [1, 0, 1, 0, 1], arr
  end

  def test_int_gt_with_scalar
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5)
    result = v.gt(3)
    arr = block_to_array(result)
    assert_equal [0, 0, 0, 1, 1], arr
  end

  # Test Int and/or/xor/not
  def test_int_and
    v1 = GSL::Vector::Int.alloc(0, 1, 2)
    v2 = GSL::Vector::Int.alloc(1, 0, 3)
    result = v1.and(v2)
    arr = block_to_array(result)
    assert_equal [0, 0, 1], arr
  end

  def test_int_or
    v1 = GSL::Vector::Int.alloc(0, 1, 0)
    v2 = GSL::Vector::Int.alloc(1, 0, 0)
    result = v1.or(v2)
    arr = block_to_array(result)
    assert_equal [1, 1, 0], arr
  end

  def test_int_xor
    v1 = GSL::Vector::Int.alloc(0, 1, 1)
    v2 = GSL::Vector::Int.alloc(1, 0, 1)
    result = v1.xor(v2)
    arr = block_to_array(result)
    assert_equal [1, 1, 0], arr
  end

  def test_int_not
    v = GSL::Vector::Int.alloc(0, 1, 2)
    result = v.not
    arr = block_to_array(result)
    assert_equal [1, 0, 0], arr
  end

  # Test Int concat
  def test_int_concat
    v1 = GSL::Vector::Int.alloc(1, 2)
    v2 = GSL::Vector::Int.alloc(3, 4)
    result = v1.concat(v2)
    assert_equal [1, 2, 3, 4], result.to_a
  end

  def test_int_concat_with_scalar
    v = GSL::Vector::Int.alloc(1, 2, 3)
    result = v.concat(4)
    assert_equal [1, 2, 3, 4], result.to_a
  end

  def test_int_concat_with_array
    v = GSL::Vector::Int.alloc(1, 2)
    result = v.concat([3, 4, 5])
    assert_equal [1, 2, 3, 4, 5], result.to_a
  end

  def test_int_concat_with_range
    v = GSL::Vector::Int.alloc(1, 2)
    result = v.concat(3..5)
    assert_equal [1, 2, 3, 4, 5], result.to_a
  end

  # Test Int diff
  def test_int_diff
    v = GSL::Vector::Int.alloc(1, 3, 6, 10)
    d = v.diff
    assert_equal [2, 3, 4], d.to_a
  end

  # Test Int to_m
  def test_int_to_m
    v = GSL::Vector::Int.indgen(6)
    m = v.to_m(2, 3)
    assert_kind_of GSL::Matrix::Int, m
    assert_equal 2, m.size1
    assert_equal 3, m.size2
  end

  # Test Int to_m_diagonal
  def test_int_to_m_diagonal
    v = GSL::Vector::Int.alloc(1, 2, 3)
    m = v.to_m_diagonal
    assert_kind_of GSL::Matrix::Int, m
    assert_equal 1, m[0, 0]
    assert_equal 0, m[0, 1]
    assert_equal 2, m[1, 1]
    assert_equal 3, m[2, 2]
  end

  # Test Int to_m_circulant
  def test_int_to_m_circulant
    v = GSL::Vector::Int.alloc(1, 2, 3)
    m = v.to_m_circulant
    assert_kind_of GSL::Matrix::Int, m
    assert_equal 3, m.size1
  end

  # Test Int matrix_view
  def test_int_matrix_view
    v = GSL::Vector::Int.indgen(6)
    m = v.matrix_view(2, 3)
    assert_kind_of GSL::Matrix::Int::View, m
    assert_equal 2, m.size1
    assert_equal 3, m.size2
  end

  # Test Int histogram
  def test_int_histogram
    v = GSL::Vector::Int.alloc(0, 1, 2, 3, 4)
    h = v.histogram(5)
    assert_kind_of GSL::Histogram, h
    assert_equal 5, h.bins
  end

  # Test Int first/last
  def test_int_first
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5)
    assert_equal 1, v.first
  end

  def test_int_last
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5)
    assert_equal 5, v.last
  end

  # Test Int delete operations
  def test_int_delete_at
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5)
    result = v.delete_at(2)
    assert_equal 3, result
    assert_equal [1, 2, 4, 5], v.to_a
  end

  def test_int_delete_if
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5)
    result = v.delete_if { |x| x > 3 }
    assert_equal [1, 2, 3], result.to_a
  end

  def test_int_delete
    v = GSL::Vector::Int.alloc(1, 2, 3, 2, 5)
    result = v.delete(2)
    assert_equal 2, result
    assert_equal [1, 3, 5], v.to_a
  end

  # Test Int scale and add_constant
  def test_int_scale
    v = GSL::Vector::Int.alloc(1, 2, 3)
    result = v.scale(2)
    assert_equal [2, 4, 6], result.to_a
  end

  def test_int_scale_bang
    v = GSL::Vector::Int.alloc(1, 2, 3)
    v.scale!(2)
    assert_equal [2, 4, 6], v.to_a
  end

  def test_int_add_constant
    v = GSL::Vector::Int.alloc(1, 2, 3)
    result = v.add_constant(5)
    assert_equal [6, 7, 8], result.to_a
  end

  def test_int_add_constant_bang
    v = GSL::Vector::Int.alloc(1, 2, 3)
    v.add_constant!(5)
    assert_equal [6, 7, 8], v.to_a
  end

  # Test Int ispos/isneg/isnonneg
  def test_int_ispos
    v = GSL::Vector::Int.alloc(1, 2, 3)
    assert_equal 1, v.ispos
    assert v.ispos?
  end

  def test_int_isneg
    v = GSL::Vector::Int.alloc(-1, -2, -3)
    assert_equal 1, v.isneg
    assert v.isneg?
  end

  def test_int_isnonneg
    v = GSL::Vector::Int.alloc(0, 1, 2)
    assert_equal 1, v.isnonneg
    assert v.isnonneg?
  end

  # Test Int zip
  def test_int_zip
    v1 = GSL::Vector::Int.alloc(1, 2, 3)
    v2 = GSL::Vector::Int.alloc(4, 5, 6)
    result = v1.zip(v2)
    assert_kind_of Array, result
    assert_equal 3, result.size
  end

  # Test Int join
  def test_int_join
    v = GSL::Vector::Int.alloc(1, 2, 3)
    result = v.join(", ")
    assert_kind_of String, result
    assert_match(/1/, result)
    assert_match(/2/, result)
    assert_match(/3/, result)
  end

  # Test Int indgen variations
  def test_int_indgen_instance
    v = GSL::Vector::Int.alloc(5)
    result = v.indgen(10, 2)
    assert_equal [10, 12, 14, 16, 18], result.to_a
  end

  def test_int_indgen_bang
    v = GSL::Vector::Int.alloc(5)
    v.indgen!(10, 2)
    assert_equal [10, 12, 14, 16, 18], v.to_a
  end

  # Test Int sort methods
  def test_int_sort_index
    v = GSL::Vector::Int.alloc(3, 1, 4, 1, 5)
    indices = v.sort_index
    assert_kind_of GSL::Permutation, indices
  end

  def test_int_sort_smallest
    v = GSL::Vector::Int.alloc(3, 1, 4, 1, 5)
    smallest = v.sort_smallest(3)
    assert_equal [1, 1, 3], smallest.to_a
  end

  def test_int_sort_largest
    v = GSL::Vector::Int.alloc(3, 1, 4, 1, 5)
    largest = v.sort_largest(3)
    assert_equal [5, 4, 3], largest.to_a
  end

  def test_int_sort_smallest_index
    v = GSL::Vector::Int.alloc(3, 1, 4, 1, 5)
    indices = v.sort_smallest_index(2)
    assert_equal 2, indices.size
  end

  def test_int_sort_largest_index
    v = GSL::Vector::Int.alloc(3, 1, 4, 1, 5)
    indices = v.sort_largest_index(2)
    assert_equal 2, indices.size
  end

  # Test Int equal?
  def test_int_equal
    v1 = GSL::Vector::Int.alloc(1, 2, 3)
    v2 = GSL::Vector::Int.alloc(1, 2, 3)
    v3 = GSL::Vector::Int.alloc(1, 2, 4)
    assert v1.equal?(v2)
    refute v1.equal?(v3)
  end

  def test_int_equal_with_scalar
    v = GSL::Vector::Int.alloc(5, 5, 5)
    assert v.equal?(5)
    refute v.equal?(6)
  end

  # Test to_gplot
  def test_to_gplot
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.to_gplot
    assert_kind_of String, result
    assert_match(/1/, result)
  end

  def test_to_gplot_with_multiple_vectors
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(4.0, 5.0, 6.0)
    result = v1.to_gplot(v2)
    assert_kind_of String, result
  end

  def test_to_gplot_singleton
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(4.0, 5.0, 6.0)
    result = GSL::Vector.to_gplot(v1, v2)
    assert_kind_of String, result
  end

  def test_to_gplot_singleton_with_array
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(4.0, 5.0, 6.0)
    result = GSL::Vector.to_gplot([v1, v2])
    assert_kind_of String, result
  end

  # Test Int to_gplot
  def test_int_to_gplot
    v = GSL::Vector::Int.alloc(1, 2, 3)
    result = v.to_gplot
    assert_kind_of String, result
  end

  # Test connect singleton method
  def test_connect_singleton
    v1 = GSL::Vector.alloc(1.0, 2.0)
    v2 = GSL::Vector.alloc(3.0, 4.0)
    result = GSL::Vector.connect(v1, v2)
    assert_equal [1.0, 2.0, 3.0, 4.0], result.to_a
  end

  def test_int_connect_singleton
    v1 = GSL::Vector::Int.alloc(1, 2)
    v2 = GSL::Vector::Int.alloc(3, 4)
    result = GSL::Vector::Int.connect(v1, v2)
    assert_equal [1, 2, 3, 4], result.to_a
  end

  # Test zip singleton method
  def test_zip_singleton
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(4.0, 5.0, 6.0)
    result = GSL::Vector.zip(v1, v2)
    assert_kind_of Array, result
  end

  # Test Int view clone
  def test_int_view_clone
    v = GSL::Vector::Int.indgen(5)
    view = v.subvector(1, 3)
    cloned = view.clone
    assert_equal [1, 2, 3], cloned.to_a
    assert_kind_of GSL::Vector::Int, cloned
  end

  # Test Col to_s
  def test_int_col_to_s
    v = GSL::Vector::Int.alloc(1, 2, 3)
    col = v.col
    s = col.to_s
    assert_kind_of String, s
    assert_match(/\n/, s)
  end

  # Test Int owner
  def test_int_owner
    v = GSL::Vector::Int.alloc(5)
    assert_equal 1, v.owner
  end

  # Test Int block
  def test_int_block
    v = GSL::Vector::Int.alloc(5)
    b = v.block
    assert_kind_of GSL::Block::Int, b
  end

  # Test Int fwrite/fread
  def test_int_fwrite_fread
    v = GSL::Vector::Int.alloc(1, 2, 3)
    filename = "/tmp/test_vector_int_#{$$}.bin"
    begin
      File.open(filename, 'wb') { |f| v.fwrite(f) }
      v2 = GSL::Vector::Int.alloc(3)
      File.open(filename, 'rb') { |f| v2.fread(f) }
      assert_equal v.to_a, v2.to_a
    ensure
      File.delete(filename) if File.exist?(filename)
    end
  end

  # Test Int fprintf/fscanf
  def test_int_fprintf_fscanf
    v = GSL::Vector::Int.alloc(1, 2, 3)
    filename = "/tmp/test_vector_int_#{$$}.txt"
    begin
      File.open(filename, 'w') { |f| v.fprintf(f, "%d") }
      v2 = GSL::Vector::Int.alloc(3)
      File.open(filename, 'r') { |f| v2.fscanf(f) }
      assert_equal v.to_a, v2.to_a
    ensure
      File.delete(filename) if File.exist?(filename)
    end
  end

  # Test Col view operations
  def test_col_view
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    col = v.col
    view = col.subvector(1, 3)
    assert_kind_of GSL::Vector::Col::View, view
    assert_equal [2.0, 3.0, 4.0], view.to_a
  end

  # Test Int Col view operations
  def test_int_col_view
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5)
    col = v.col
    view = col.subvector(1, 3)
    assert_kind_of GSL::Vector::Int::Col::View, view
    assert_equal [2, 3, 4], view.to_a
  end

  # Test row alias on Col
  def test_col_row
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    col = v.col
    row = col.row
    assert_kind_of GSL::Vector, row
  end

  def test_int_col_row
    v = GSL::Vector::Int.alloc(1, 2, 3)
    col = v.col
    row = col.row
    assert_kind_of GSL::Vector::Int, row
  end

  # Test alloc with Bignum error
  def test_alloc_bignum_error
    assert_raises(RangeError) { GSL::Vector.alloc(2**64) }
  end

  # Test View modifications are reflected in original
  def test_view_modifies_original
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    view = v.subvector(1, 3)
    view[0] = 10.0
    assert_in_delta 10.0, v[1], 1e-10
  end

  def test_int_view_modifies_original
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5)
    view = v.subvector(1, 3)
    view[0] = 10
    assert_equal 10, v[1]
  end

  # Test parse_subvector_args error cases
  def test_subvector_begin_out_of_range
    v = GSL::Vector::Int.indgen(5)
    assert_raises(RangeError) { v.subvector(10..12) }
  end

  def test_subvector_end_out_of_range
    v = GSL::Vector::Int.indgen(5)
    assert_raises(RangeError) { v.subvector(0..10) }
  end

  def test_subvector_length_out_of_range
    v = GSL::Vector::Int.indgen(5)
    assert_raises(RangeError) { v.subvector(10) }
  end

  def test_subvector_negative_length_out_of_range
    v = GSL::Vector::Int.indgen(5)
    assert_raises(RangeError) { v.subvector(-10) }
  end

  def test_subvector_stride_zero_error
    v = GSL::Vector::Int.indgen(5)
    # Range with stride 0 should raise error when begin != end
    assert_raises(ArgumentError) { v.subvector(0..3, 0) }
  end

  # Additional tests for vector_source.h coverage

  # Test histogram with additional variations (extends existing test_histogram)
  def test_histogram_with_range_bounds
    v = GSL::Vector.alloc(0.5, 1.5, 2.5, 3.5, 4.5)
    h = v.histogram(5, [0, 5])
    assert_kind_of GSL::Histogram, h
    assert_equal 5, h.bins
  end

  def test_histogram_with_explicit_min_max
    v = GSL::Vector.alloc(0.5, 1.5, 2.5, 3.5, 4.5)
    h = v.histogram(5, 0.0, 5.0)
    assert_kind_of GSL::Histogram, h
    assert_equal 5, h.bins
  end

  def test_histogram_with_array_ranges
    v = GSL::Vector.alloc(0.5, 1.5, 2.5, 3.5, 4.5)
    h = v.histogram([0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
    assert_kind_of GSL::Histogram, h
    assert_equal 5, h.bins
  end

  def test_histogram_with_vector_ranges
    v = GSL::Vector.alloc(0.5, 1.5, 2.5, 3.5, 4.5)
    ranges = GSL::Vector.alloc(0.0, 1.0, 2.0, 3.0, 4.0, 5.0)
    h = v.histogram(ranges)
    assert_kind_of GSL::Histogram, h
    assert_equal 5, h.bins
  end

  # Test where with block
  def test_where_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    indices = v.where { |x| x > 3 }
    assert_kind_of GSL::Permutation, indices
    assert_equal [3, 4], indices.to_a
  end

  def test_where_no_matches
    v = GSL::Vector.alloc(0.0, 0.0, 0.0)
    indices = v.where
    assert_nil indices
  end

  def test_where2_all_true_condition
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    true_indices, false_indices = v.where2
    assert_equal [0, 1, 2], true_indices.to_a
    assert_nil false_indices
  end

  def test_where2_all_false_condition
    v = GSL::Vector.alloc(0.0, 0.0, 0.0)
    true_indices, false_indices = v.where2
    assert_nil true_indices
    assert_equal [0, 1, 2], false_indices.to_a
  end

  def test_where2_with_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0)
    true_indices, false_indices = v.where2 { |x| x > 3 }
    assert_equal [3, 4], true_indices.to_a
    assert_equal [0, 1, 2], false_indices.to_a
  end

  # Test any with block (extends existing test_any)
  def test_any_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    result = v.any { |x| x > 2 }
    assert_equal 1, result
  end

  def test_any_predicate_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert v.any? { |x| x > 2 }
    refute v.any? { |x| x > 5 }
  end

  # Test all? with block (extends existing test_all)
  def test_all_predicate_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert v.all? { |x| x > 0 }
    refute v.all? { |x| x > 1 }
  end

  # Test none? with block (extends existing test_none)
  def test_none_predicate_block
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert v.none? { |x| x > 5 }
    refute v.none? { |x| x > 2 }
  end

  # Test logical operations with scalars
  def test_and_with_scalar
    v = GSL::Vector.alloc(1.0, 0.0, 2.0)
    result = v.and(1.0)
    assert_equal [1, 0, 1], block_to_array(result)
  end

  def test_or_with_scalar
    v = GSL::Vector.alloc(1.0, 0.0, 0.0)
    result = v.or(0.0)
    assert_equal [1, 0, 0], block_to_array(result)
  end

  def test_xor_with_scalar
    v = GSL::Vector.alloc(1.0, 0.0, 2.0)
    result = v.xor(1.0)
    assert_equal [0, 1, 0], block_to_array(result)
  end

  # Test zip singleton method
  def test_zip_as_singleton
    v1 = GSL::Vector.alloc(1.0, 2.0)
    v2 = GSL::Vector.alloc(3.0, 4.0)
    result = GSL::Vector.zip(v1, v2)
    assert_kind_of Array, result
    assert_equal 2, result.size
  end

  # Test to_gplot
  def test_to_gplot_basic
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    s = v.to_gplot
    assert_kind_of String, s
  end

  def test_to_gplot_with_multiple_vectors
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(4.0, 5.0, 6.0)
    s = GSL::Vector.to_gplot(v1, v2)
    assert_kind_of String, s
  end

  # Test subvector_with_stride edge cases
  def test_subvector_with_stride_one_arg
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
    sv = v.subvector_with_stride(2)
    assert_equal [1.0, 3.0, 5.0], sv.to_a
  end

  def test_subvector_with_stride_two_args
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
    sv = v.subvector_with_stride(1, 2)
    assert_equal [2.0, 4.0, 6.0], sv.to_a
  end

  def test_subvector_with_stride_three_args
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
    sv = v.subvector_with_stride(0, 2, 3)
    assert_equal [1.0, 3.0, 5.0], sv.to_a
  end

  def test_subvector_with_stride_negative_offset
    v = GSL::Vector.alloc(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
    sv = v.subvector_with_stride(-3, 1)
    assert_equal [4.0, 5.0, 6.0], sv.to_a
  end

  def test_subvector_with_stride_zero_stride_error
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert_raises(ArgumentError) { v.subvector_with_stride(0) }
  end

  def test_subvector_with_stride_offset_too_large
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert_raises(RangeError) { v.subvector_with_stride(10, 1) }
  end

  def test_subvector_with_stride_negative_length
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    assert_raises(ArgumentError) { v.subvector_with_stride(0, 1, -1) }
  end

  # Test matrix_view_with_tda
  def test_matrix_view_with_tda_basic
    v = GSL::Vector.indgen(12)
    m = v.matrix_view_with_tda(2, 3, 4)
    assert_kind_of GSL::Matrix::View, m
    assert_equal 2, m.size1
    assert_equal 3, m.size2
    assert_in_delta 0.0, m[0, 0], 1e-10
    assert_in_delta 1.0, m[0, 1], 1e-10
    assert_in_delta 4.0, m[1, 0], 1e-10
  end

  # Test concat with various types (extends existing test_concat)
  def test_concat_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0)
    result = v.concat(3.0)
    assert_equal [1.0, 2.0, 3.0], result.to_a
  end

  def test_concat_with_array
    v = GSL::Vector.alloc(1.0, 2.0)
    result = v.concat([3.0, 4.0])
    assert_equal [1.0, 2.0, 3.0, 4.0], result.to_a
  end

  def test_concat_with_range
    v = GSL::Vector.alloc(1.0, 2.0)
    result = v.concat(3..5)
    assert_equal [1.0, 2.0, 3.0, 4.0, 5.0], result.to_a
  end

  # Test inplace arithmetic with scalars
  def test_add_inplace_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v.add!(5.0)
    assert_equal [6.0, 7.0, 8.0], v.to_a
  end

  def test_sub_inplace_with_scalar
    v = GSL::Vector.alloc(10.0, 20.0, 30.0)
    v.sub!(5.0)
    assert_equal [5.0, 15.0, 25.0], v.to_a
  end

  def test_mul_inplace_with_scalar
    v = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v.mul!(2.0)
    assert_equal [2.0, 4.0, 6.0], v.to_a
  end

  def test_div_inplace_with_scalar
    v = GSL::Vector.alloc(10.0, 20.0, 30.0)
    v.div!(2.0)
    assert_equal [5.0, 10.0, 15.0], v.to_a
  end

  # Test Vector::Int specific methods
  def test_int_where_basic
    v = GSL::Vector::Int.alloc(0, 1, 0, 3, 0)
    indices = v.where
    assert_kind_of GSL::Permutation, indices
    assert_equal [1, 3], indices.to_a
  end

  def test_int_any_predicate
    v = GSL::Vector::Int.alloc(0, 0, 1)
    assert v.any?
  end

  def test_int_all_predicate
    v = GSL::Vector::Int.alloc(1, 2, 3)
    assert v.all?
  end

  def test_int_none_predicate
    v = GSL::Vector::Int.alloc(0, 0, 0)
    assert v.none?
  end

  def test_int_histogram_basic
    v = GSL::Vector::Int.alloc(0, 1, 2, 3, 4)
    h = v.histogram(5)
    assert_kind_of GSL::Histogram, h
  end

  def test_int_join_with_sep
    v = GSL::Vector::Int.alloc(1, 2, 3)
    result = v.join(", ")
    assert_kind_of String, result
    assert result.include?('1')
  end

  def test_int_zip_basic
    v1 = GSL::Vector::Int.alloc(1, 2, 3)
    v2 = GSL::Vector::Int.alloc(4, 5, 6)
    result = v1.zip(v2)
    assert_kind_of Array, result
    assert_equal 3, result.size
  end

  def test_int_indgen_bang_basic
    v = GSL::Vector::Int.alloc(5)
    v.indgen!
    assert_equal [0, 1, 2, 3, 4], v.to_a
  end

  def test_int_to_m_basic
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5, 6)
    m = v.to_m(2, 3)
    assert_kind_of GSL::Matrix::Int, m
    assert_equal 2, m.size1
    assert_equal 3, m.size2
  end

  def test_int_inplace_add
    v1 = GSL::Vector::Int.alloc(1, 2, 3)
    v2 = GSL::Vector::Int.alloc(10, 20, 30)
    v1.add!(v2)
    assert_equal [11, 22, 33], v1.to_a
  end

  def test_int_concat_with_scalar
    v = GSL::Vector::Int.alloc(1, 2)
    result = v.concat(3)
    assert_equal [1, 2, 3], result.to_a
  end

  def test_int_to_s_for_col
    v = GSL::Vector::Int.alloc(1, 2, 3).col
    s = v.to_s
    assert_kind_of String, s
  end

  def test_int_subvector_with_stride_basic
    v = GSL::Vector::Int.alloc(1, 2, 3, 4, 5, 6)
    sv = v.subvector_with_stride(2)
    assert_equal [1, 3, 5], sv.to_a
  end

  def test_int_block_accessor
    v = GSL::Vector::Int.alloc(1, 2, 3)
    b = v.block
    assert_kind_of GSL::Block::Int, b
  end

  # Test singleton methods
  def test_inner_product_as_singleton
    v1 = GSL::Vector.alloc(1.0, 2.0, 3.0)
    v2 = GSL::Vector.alloc(4.0, 5.0, 6.0)
    result = GSL::Vector.inner_product(v1, v2)
    assert_in_delta 32.0, result, 1e-10
  end

  def test_inner_product_int_as_singleton
    v1 = GSL::Vector::Int.alloc(1, 2, 3)
    v2 = GSL::Vector::Int.alloc(4, 5, 6)
    result = GSL::Vector::Int.inner_product(v1, v2)
    assert_equal 32, result
  end

  def test_connect_as_singleton
    v1 = GSL::Vector.alloc(1.0, 2.0)
    v2 = GSL::Vector.alloc(3.0, 4.0)
    result = GSL::Vector.connect(v1, v2)
    assert_equal [1.0, 2.0, 3.0, 4.0], result.to_a
  end

end
