require "./lib"

module Wasmer
  # handy constants to `ValueKind` so one can use `Wasmer::I32` instead of `Wasmer::ValueKind::I32`
  I32 = ValueKind::I32
  I64 = ValueKind::I64
  F32 = ValueKind::F32
  F64 = ValueKind::F64

  # Represents the kind of a value
  enum ValueKind : UInt8
    # A 32-bit integer. In WebAssembly, integers are
    # sign-agnostic, i.E. this can either be signed or unsigned
    I32

    # A 64-bit integer. In WebAssembly, integers are
    # sign-agnostic, i.E. this can either be signed or unsigned
    I64

    # A 32-bit float
    F32

    # A 64-bit float
    F64

    # An externref value which can hold opaque data to the WebAssembly instance itself.
    AnyRef = 128

    # A first-class reference to a WebAssembly function
    FuncRef

    # Returns true if the ValueKind is a number type
    def number?
      self.value < FuncRef.value
    end

    # Returns true if the ValueKind is a reference
    def reference?
      self.value >= FuncRef.value
    end

    def to_s(io : IO)
      io << self.to_s.downcase
    end

    # :nodoc:
    def to_unsafe
      self.value
    end
  end

  # ValueType classifies the individual values that WebAssembly code
  # can compute with and the values that a variable accepts.
  class ValueType
    def initialize(kind : ValueKind)
      @ptr = LibWasmer.wasm_valtype_new(kind)
    end

    def initialize(@ptr : LibWasmer::WasmValtypeT)
    end

    def kind : ValueKind
      ValueKind.from_value(LibWasmer.wasm_valtype_kind(self))
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end

  # WebAssembly computations manipulate values of basic value types:
  # * Integer (32 or 64 bit width)
  # * Floating-point (32 or 64 bit width)
  # * Vectors (128 bits, with 32 or 64 bit lanes)
  #
  # See Also
  # Specification: https://webassembly.github.io/spec/core/exec/runtime.html#values
  class Value
    def initialize(val : Number, kind : ValueKind)
      @value = LibWasmer::WasmValT.new
      @value.kind = kind.value
      case val
      when Int8, Int16, Int32, UInt8, UInt16, UInt32 then @value.of.i32 = val
      when Int64, UInt64                             then @value.of.i64 = val
      when Float32                                   then @value.of.f32 = val
      when Float64                                   then @value.of.f64 = val
      else
        raise WasmerError.new("Not supported Value type '#{typeof(val)}' with kind : #{kind}")
      end
    end

    # :nodoc:
    protected def initialize(@value : LibWasmer::WasmValT)
    end

    def self.new(value : Int)
      case value
      when Int64
        new(value.to_i64, ValueKind::I64)
      else
        new(value.to_i, ValueKind::I32)
      end
    end

    def self.new(value : Float)
      case value
      when Float64
        new(value.to_f64, ValueKind::F64)
      else
        new(value.to_f32, ValueKind::F32)
      end
    end

    def kind
      ValueKind.from_value(@value.kind)
    end

    # Returns the Value's value as a native Crystal value
    def unwrap : Number
      case kind
      when .i32? then @value.of.i32
      when .i64? then @value.of.i64
      when .f32? then @value.of.f32
      when .f64? then @value.of.f64
      else
        raise WasmerError.new("Unsupported value")
      end
    end

    # Returns the Value's value as a native Crystal Int32
    # raises otherwise
    def as_i : Int32
      raise WasmerError.new("Cannot convert value to 'Int32'") unless kind == ValueKind::I32
      @value.of.i32
    end

    # Returns the Value's value as a native Crystal Int64
    # raises otherwise
    def as_i64 : Int64
      raise WasmerError.new("Cannot convert value to 'Int64'") unless kind == ValueKind::I64
      @value.of.i64
    end

    # Returns the Value's value as a native Crystal Float64
    # raises otherwise
    def as_f : Float64
      raise WasmerError.new("Cannot convert value to 'Float64'") unless kind == ValueKind::F64
      @value.of.f64
    end

    # Returns the Value's value as a native Crystal Float32
    # raises otherwise
    def as_f32 : Float32
      raise WasmerError.new("Cannot convert value to 'Float32'") unless kind == ValueKind::F32
      @value.of.f32
    end

    # :nodoc:
    def to_unsafe
      @value
    end
  end

  # Instantiates a new ValueType array from a list of ValueKind.
  # Helper function specifically designed to help you declare function types
  def self.value_types(*kinds : ValueKind) : Array(ValueType)
    value_types(kinds.to_a)
  end

  def self.value_types(kinds : Array(ValueKind)) : Array(ValueType)
    ret = Array(ValueType).new(kinds.size)
    kinds.each { |k| ret << ValueType.new(k) }
    ret
  end

  def self.value_types : Array(ValueType)
    value_types([] of ValueKind)
  end

  # :nodoc:
  protected def self.valuetypes_to_c(value_types : Array(ValueType))
    LibWasmer.wasm_valtype_vec_new_uninitialized(out vec, value_types.size)
    first_ptr = vec.data
    value_types.each_with_index do |v, i|
      ptr = LibWasmer.wasm_valtype_new(LibWasmer.wasm_valtype_kind(v))
      first_ptr[i] = ptr
    end
    vec
  end

  # :nodoc:
  protected def self.c_to_valuetypes(value_types : LibWasmer::WasmValtypeVecT)
    count = value_types.size.to_i
    list = Array(ValueType).new(count)
    first_ptr = value_types.data
    0.upto(count - 1) do |n|
      ptr = first_ptr[n]
      list << ValueType.new(ptr)
    end
    list
  end

  # :nodoc:
  protected def self.values_to_c(list : Array(Value)) : LibWasmer::WasmValVecT
    raise WasmerError.new("Values list is empty") if list.empty?
    values = Array(LibWasmer::WasmValT).new
    list.each { |v| values << v.to_unsafe }
    LibWasmer.wasm_val_vec_new(out vec, values.size, values.to_unsafe)
    vec
  end

  def self.c_to_valuelist(values : LibWasmer::WasmValVecT) : Array(Value)
    res = Array(Value).new(values.size)
    ptr = values.data
    0.upto(values.size.to_i - 1) do |i|
      res << Value.new(ptr[i])
    end
    res
  end
end
