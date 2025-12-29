#!/usr/bin/env ruby
# frozen_string_literal: true

# Standalone coverage runner for matrix_complex.c
# Exercises all the major functions to improve coverage

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('../../ext/gsl_native', __dir__)

require 'gsl'

puts "Running matrix_complex.c coverage tests..."

# Constructor tests
m = GSL::Matrix::Complex.alloc(3, 4)
m = GSL::Matrix::Complex[3, 4]
m = GSL::Matrix::Complex.calloc(3, 4)
me = GSL::Matrix::Complex.eye(3)
me = GSL::Matrix::Complex.eye(3, GSL::Complex.alloc(2, 3))
me = GSL::Matrix::Complex.eye(3, [1.0, 2.0])
mi = GSL::Matrix::Complex.identity(3)
mi = GSL::Matrix::Complex.unit(3)
mi = GSL::Matrix::Complex.I(3)
puts "Constructors: OK"

# Accessor tests
m = GSL::Matrix::Complex.alloc(3, 3)
m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
m[1, 1] = [3.0, 4.0]
m.set(2, 2, GSL::Complex.alloc(5.0, 6.0))
_ = m[0, 0]
_ = m.get(1, 1)
# Note: m.ptr(i, j) returns a pointer to internal data which is unsafe - skip testing
puts "Accessors: OK"

# set_row and set_col
c1 = GSL::Complex.alloc(1.0, 2.0)
c2 = GSL::Complex.alloc(3.0, 4.0)
c3 = GSL::Complex.alloc(5.0, 6.0)
m.set_row(0, c1, c2, c3)
m.set_row(1, [7.0, 8.0], [9.0, 10.0], [11.0, 12.0])
m.set_col(0, c1, c2, c3)
puts "set_row/set_col: OK"

# Properties
_ = m.size1
_ = m.size2
_ = m.shape
_ = m.size
_ = m.isnull
puts "Properties: OK"

# Arithmetic with scalars
m = GSL::Matrix::Complex.alloc(2, 2)
m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
_ = m + 3.0  # add_constant
_ = m - 3.0  # sub
_ = m.scale(2.0)  # mul scalar
_ = m / 2.0  # div scalar
m2 = m.clone
m2.scale!(2.0)  # scale! with float
m3 = m.clone
m3.scale!(GSL::Complex.alloc(0, 1))  # scale! with complex
puts "Scalar arithmetic: OK"

# Arithmetic with complex
c = GSL::Complex.alloc(1.0, 1.0)
_ = m + c
_ = m - c
_ = m * c
_ = m / c
puts "Complex arithmetic: OK"

# Arithmetic with matrices
m1 = GSL::Matrix::Complex.alloc(2, 2)
m1[0, 0] = GSL::Complex.alloc(1.0, 0.0)
m1[0, 1] = GSL::Complex.alloc(2.0, 0.0)
m1[1, 0] = GSL::Complex.alloc(3.0, 0.0)
m1[1, 1] = GSL::Complex.alloc(4.0, 0.0)
m2 = m1.clone
_ = m1 + m2
_ = m1 - m2
_ = m1.mul_elements(m2)
_ = m1.div_elements(m2)
_ = m1.mul(m2)  # Matrix multiplication
_ = m1 * m2
m3 = m1.clone
m3.mul!(m2)  # mul! in-place
puts "Matrix arithmetic: OK"

# Arithmetic with real matrices
mr = GSL::Matrix.alloc(2, 2)
mr[0, 0] = 1.0
mr[0, 1] = 2.0
mr[1, 0] = 3.0
mr[1, 1] = 4.0
_ = m1 + mr
_ = m1 - mr
_ = m1.mul_elements(mr)
_ = m1.div_elements(mr)
_ = m1 * mr  # Matrix multiplication with real
puts "Real matrix arithmetic: OK"

# Vector operations
v = GSL::Vector.alloc([1.0, 1.0])
_ = m1 * v  # Multiply complex matrix by real vector

vc = GSL::Vector::Complex.alloc(2)
vc[0] = GSL::Complex.alloc(1.0, 0.0)
vc[1] = GSL::Complex.alloc(1.0, 0.0)
# Matrix-vector multiply is through BLAS, not tested here
puts "Vector operations: OK"

# Copy operations
m = GSL::Matrix::Complex.alloc(2, 2)
m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
m2 = m.clone
m2 = m.dup
m2 = m.duplicate
m3 = GSL::Matrix::Complex.alloc(2, 2)
GSL::Matrix::Complex.memcpy(m3, m)
puts "Copy operations: OK"

# Row/column operations
m = GSL::Matrix::Complex.alloc(3, 3)
(0...3).each { |i| (0...3).each { |j| m[i, j] = GSL::Complex.alloc(i * 3 + j, 0) } }
m.swap_rows(0, 1)
m.swap_columns(0, 1)
m.swap_rowcol(0, 1)
_ = m.row(0)
_ = m.column(0)
_ = m.col(0)
_ = m.diagonal
_ = m.diag
_ = m.subdiagonal(1)
_ = m.superdiagonal(1)
_ = m.submatrix(0, 0, 2, 2)
_ = m.view(0, 0, 2, 2)
puts "Row/column operations: OK"

# Set diagonal
v = GSL::Vector::Complex.alloc(3)
v[0] = GSL::Complex.alloc(1.0, 0.0)
v[1] = GSL::Complex.alloc(2.0, 0.0)
v[2] = GSL::Complex.alloc(3.0, 0.0)
m.set_diagonal(v)
puts "Set diagonal: OK"

# Matrix properties
m = GSL::Matrix::Complex.alloc(3, 3)
m[0, 1] = GSL::Complex.alloc(1.0, 2.0)
m.transpose
_ = m.real
_ = m.re
_ = m.to_real
_ = m.imag
_ = m.im

m2 = m.clone
_ = m2.conjugate
m3 = m.clone
m3.conjugate!

m4 = m.clone
_ = m4.dagger
m5 = m.clone
m5.dagger!
puts "Matrix properties: OK"

# Trace
m = GSL::Matrix::Complex.alloc(3, 3)
m[0, 0] = GSL::Complex.alloc(1.0, 1.0)
m[1, 1] = GSL::Complex.alloc(2.0, 2.0)
m[2, 2] = GSL::Complex.alloc(3.0, 3.0)
_ = m.trace
puts "Trace: OK"

# add_diagonal
m = GSL::Matrix::Complex.alloc(3, 3)
m.add_diagonal(2.0)  # float
m.add_diagonal(GSL::Complex.alloc(1.0, 2.0))  # complex
m.add_diagonal([3.0, 4.0])  # array
puts "Add diagonal: OK"

# Iteration
m = GSL::Matrix::Complex.alloc(2, 3)
m.each_row { |r| _ = r }
m.each_col { |c| _ = c }
m.each_column { |c| _ = c }
_ = m.collect { |z| GSL::Complex.alloc(z.real * 2, z.imag * 2) }
_ = m.map { |z| GSL::Complex.alloc(z.real * 2, z.imag * 2) }
m2 = m.clone
m2.collect! { |z| GSL::Complex.alloc(z.real * 2, z.imag * 2) }
puts "Iteration: OK"

# Unary operators
m = GSL::Matrix::Complex.alloc(2, 2)
m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
_ = +m
_ = -m
puts "Unary operators: OK"

# Conversion
m = GSL::Matrix::Complex.alloc(2, 2)
m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
_ = m.to_a
_ = m.to_s
_ = m.to_s(1)
_ = m.to_s(1, 1)
_ = m.inspect
_ = m.inspect(1, 1)

# Empty matrix
m_empty = GSL::Matrix::Complex.alloc(0, 0)
_ = m_empty.to_s
puts "Conversion: OK"

# File I/O
m = GSL::Matrix::Complex.alloc(2, 2)
m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
m[1, 1] = GSL::Complex.alloc(3.0, 4.0)
path_bin = "/tmp/matrix_complex_test.bin"
m.fwrite(path_bin)
m2 = GSL::Matrix::Complex.alloc(2, 2)
m2.fread(path_bin)
File.delete(path_bin) if File.exist?(path_bin)

path_txt = "/tmp/matrix_complex_test.txt"
m.fprintf(path_txt)
m.fprintf(path_txt, "%.6f")
m3 = GSL::Matrix::Complex.alloc(2, 2)
m3.fscanf(path_txt)
File.delete(path_txt) if File.exist?(path_txt)
puts "File I/O: OK"

# Math functions (element-wise)
m = GSL::Matrix::Complex.alloc(2, 2)
m[0, 0] = GSL::Complex.alloc(1.0, 1.0)
m[1, 1] = GSL::Complex.alloc(0.5, 0.5)
_ = m.arg
_ = m.angle
_ = m.phase
_ = m.abs
_ = m.amp
_ = m.abs2
_ = m.logabs
puts "Math (arg/abs): OK"

_ = m.sqrt
_ = m.exp
_ = m.log
_ = m.log10
puts "Math (sqrt/exp/log): OK"

_ = m.sin
_ = m.cos
_ = m.tan
_ = m.sec
_ = m.csc
_ = m.cot
puts "Trig functions: OK"

_ = m.arcsin
_ = m.arccos
_ = m.arctan
_ = m.arcsec
_ = m.arccsc
_ = m.arccot
puts "Inverse trig: OK"

_ = m.sinh
_ = m.cosh
_ = m.tanh
_ = m.sech
_ = m.csch
_ = m.coth
puts "Hyperbolic functions: OK"

_ = m.arcsinh
_ = m.arccosh
_ = m.arctanh
_ = m.arcsech
_ = m.arccsch
_ = m.arccoth
puts "Inverse hyperbolic: OK"

# Index generation
m = GSL::Matrix::Complex.alloc(2, 3)
_ = m.indgen
_ = m.indgen(10.0)
_ = m.indgen(10.0, 2.0)
m.indgen!
m.indgen!(5.0)
m.indgen!(5.0, 0.5)
_ = GSL::Matrix::Complex.indgen(2, 3)
_ = GSL::Matrix::Complex.indgen(2, 3, 10.0)
_ = GSL::Matrix::Complex.indgen(2, 3, 10.0, 2.0)
puts "Index generation: OK"

# Equality
m1 = GSL::Matrix::Complex.alloc(2, 2)
m1[0, 0] = GSL::Complex.alloc(1.0, 2.0)
m2 = m1.clone
m3 = GSL::Matrix::Complex.alloc(2, 2)
m3[0, 0] = GSL::Complex.alloc(1.0, 3.0)
_ = m1.equal?(m2)
_ = m1.equal?(m2, 1e-10)
_ = m1 == m2
_ = m1.not_equal?(m3)
_ = m1 != m3
puts "Equality: OK"

# Coercion
m = GSL::Matrix::Complex.alloc(2, 2)
m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
_ = 2.0 + m  # coerce float
mr = GSL::Matrix.alloc(2, 2)
mr[0, 0] = 1.0
_ = mr + m  # coerce real matrix
puts "Coercion: OK"

# Set operations
m = GSL::Matrix::Complex.alloc(3, 3)
m[0, 0] = GSL::Complex.alloc(1.0, 2.0)
m.set_zero
m.set_identity
m.set_all([3.0, 4.0])
m.set_all(GSL::Complex.alloc(5.0, 6.0))
puts "Set operations: OK"

puts ""
puts "=" * 60
puts "All matrix_complex.c coverage tests passed!"
puts "=" * 60
