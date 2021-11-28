require "./lib"
require "./extern"
require "./value"

module Wasmer
  Mutable   = GlobalMutability::Mutable
  Immutable = GlobalMutability::Immutable

  enum GlobalMutability : UInt8
    # Represents a global that is constant
    Immutable

    # Represents a global that is mutable
    Mutable

    def to_s(io : IO)
      io << case self
      when .immutable? then "const"
      when .mutable?   then "var"
      end
    end

    # :nodoc:
    def to_unsafe
      self.value
    end
  end

  # GlobalType classifies global variables, which hold a value and can either be mutable or immutable.
  # See Also:
  # Specification: https://webassembly.github.io/spec/core/syntax/types.html#global-types
  class GlobalType
    include WithExternType

    # Instantiates a new `GlobalType` from a `ValueType` and `GlobalMutability`
    #
    # ```
    # val_type = ValueType.new(Wasmer::I32)
    # global_type = GlobalType.new(val_type, Wasmer::Immutable)
    # ```
    def initialize(val_type : ValueType, mutability : GlobalMutability)
      @owner = true
      @ptr = LibWasmer.wasm_globaltype_new(val_type, mutability)
    end

    # :nodoc:
    protected def initialize(@ptr : LibWasmer::WasmGlobaltypeT)
      @owner = false
    end

    # Returns the `GlobalType`'s `ValueType`
    #
    # ```
    # val_type = ValueType.new(Wasmer::I32)
    # global_type = GlobalType.new(val_type, Wasmer::Immutable)
    # puts global_type.value_type.kind # => i32
    # ```
    def value_type : ValueType
      v = LibWasmer.wasm_globaltype_content(self)
      ValueType.new(v)
    end

    # Returns the `GlobalType`'s `GlobalMutability`
    #
    # ```
    # val_type = ValueType.new(Wasmer::I32)
    # global_type = GlobalType.new(val_type, Wasmer::Immutable)
    # puts global_type.mutability # => const
    # ```
    def mutability : GlobalMutability
      v = LibWasmer.wasm_globaltype_mutability(self)
      GlobalMutability.from_value(v)
    end

    def mutable?
      mutability == Wasmer::Mutable
    end

    # Converts this `GlobalType` into an `Externype`
    #
    # ```
    # val_type = ValueType.new(Wasmer::I32)
    # global_type = GlobalType.new(val_type, Wasmer::Immutable)
    # extern_type = global_type.to_externtype
    # ```
    def to_externtype : ExternType
      v = LibWasmer.wasm_globaltype_as_externtype_const(self)
      ExternType.new(v)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end

    # :nodoc:
    def finalize
      return if @ptr.null? || !@owner
      LibWasmer.wasm_globaltype_delete(@ptr)
    end
  end

  # `Global` stores a single value of the given `GlobalType`
  # See Also
  # https://webassembly.github.io/spec/core/syntax/modules.html#globals
  class Global
    include WithExtern

    # Instantiates a new `Global` in the given `Store`
    # It takes three arguments, the `Store`, the `GlobalType` and the `Value`
    #
    # ```
    # val_type = ValueType.new(Wasmer::I32)
    # global_type = GlobalType.new(val_type, Wasmer::Immutable)
    # global = Global.new(store, global_type, Value.new(42))
    # ```
    def initialize(store : Store, type : GlobalType, value : Value)
      v_ptr = value.to_unsafe
      @ptr = LibWasmer.wasm_global_new(store, type, pointerof(v_ptr))
    end

    # :nodoc:
    protected def initialize(@ptr : LibWasmer::WasmGlobalT)
    end

    # Converts the `Global` into an `Extern`
    def to_extern : Extern
      p = LibWasmer.wasm_global_as_extern(self)
      Extern.new(p)
    end

    # Returns the `Global`'s `GlobalType`
    def type : GlobalType
      p = LibWasmer.wasm_global_type(self)
      GlobalType.new(p)
    end

    # Sets the `Global`'s value
    # It takes two arguments, value as a native Crystal value
    def set(value) : Nil
      raise WasmerError.new("The global variable is not mutable, cannot set a new value") if type.mutability == Immutable
      v = Value.new(value).to_unsafe
      LibWasmer.wasm_global_set(self, pointerof(v))
    end

    # Returns the `Global`'s value as native Crystal value
    def get
      LibWasmer.wasm_global_get(self, out value)
      Value.new(value).unwrap
    end

    # Sets the `Global`'s value. it calls `set` method
    def value=(value)
      set(value)
    end

    # Returns the `Global`'s value as native Crystal value. it just calls `get`
    def value
      get
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end
end
