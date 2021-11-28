require "./lib"

module Wasmer
  # Represents the kind of an Extern
  enum ExternKind : UInt8
    Func
    Global
    Table
    Memory

    def to_s(io : IO)
      io << self.to_s.downcase
    end
  end

  module WithExternType
    abstract def to_externtype : ExternType
  end

  # ExternType classifies imports and external values with their respective types.
  # See also
  # Specification: https://webassembly.github.io/spec/core/syntax/types.html#external-types
  class ExternType
    # :nodoc:
    protected def initialize(@ptr : LibWasmer::IntPtr)
    end

    def kind : ExternKind
      ExternKind.from_value(LibWasmer.wasm_externtype_kind(self))
    end

    # Converts the ExterType into a `FunctionType`
    # If the ExternType is not a `FunctionType`, this method returns nil
    def to_functiontype : FunctionType?
      ret = LibWasmer.wasm_externtype_as_functype_const(self)
      return nil unless ret
      FunctionType.new(ret)
    end

    # Converts the ExterType into a `GlobalType`
    # If the ExternType is not a `GlobalType`, this method returns nil
    def to_globaltype : GlobalType?
      ret = LibWasmer.wasm_externtype_as_globaltype_const(self)
      return nil unless ret
      GlobalType.new(ret)
    end

    # Converts the ExterType into a `TableType`
    # If the ExternType is not a `TableType`, this method returns nil
    def to_tabletype : TableType?
      ret = LibWasmer.wasm_externtype_as_tabletype_const(self)
      return nil unless ret
      TableType.new(ret)
    end

    # Converts the ExterType into a `MemoryType`
    # If the ExternType is not a `MemoryType`, this method returns nil
    def to_memorytype : MemoryType?
      ret = LibWasmer.wasm_externtype_as_memorytype_const(self)
      return nil unless ret
      MemoryType.new(ret)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end

  module WithExtern
    abstract def to_extern : Extern
  end

  # Extern is the runtime representation of an entity that can be
  # imported or exported
  class Extern
    include WithExtern

    # :nodoc:
    protected def initialize(@ptr : LibWasmer::IntPtr)
    end

    def to_extern : Extern
      self
    end

    def kind : ExternKind
      ExternKind.from_value(LibWasmer.wasm_extern_kind(self))
    end

    def type : ExternType
      ExternType.new(LibWasmer.wasm_extern_type(self))
    end

    # Converts the Extern into a `Function`
    # If the Extern is not a `Function`, this method returns nil
    def to_function : Function?
      ret = LibWasmer.wasm_extern_as_func(self)
      return nil unless ret
      Function.new(ret, nil)
    end

    # Converts the Extern into a `Global`
    # If the Extern is not a `Global`, this method returns nil
    def to_global : Global?
      ret = LibWasmer.wasm_extern_as_global(self)
      return nil unless ret
      Global.new(ret)
    end

    # Converts the Extern into a `Table`
    # If the Extern is not a `Table`, this method returns nil
    def to_table : Table?
      ret = LibWasmer.wasm_extern_as_table(self)
      return nil unless ret
      Table.new(ret)
    end

    # Converts the Extern into a `Memory`
    # If the Extern is not a `Memory`, this method returns nil
    def to_memory : Memory?
      ret = LibWasmer.wasm_extern_as_memory(self)
      return nil unless ret
      Memory.new(ret)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end
end
