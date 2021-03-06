require "./lib"
require "./value"
require "./store"
require "./limits"
require "./extern"

module Wasmer
  # TableType classifies tables over elements of element types within a size range.
  #
  # See also
  #
  # Specification: https://webassembly.github.io/spec/core/syntax/types.html#table-types
  class TableType
    include WithExternType

    def initialize(vtype : ValueType, limits : Limits)
      @ptr = LibWasmer.wasm_tabletype_new(vtype, limits)
    end

    # :nodoc:
    protected def initialize(@ptr : LibWasmer::WasmTabletypeT)
    end

    # Returns `ValueType` for this `TableType`
    def value_type : ValueType
      p = LibWasmer.wasm_tabletype_element(self)
      ValueType.new(p)
    end

    # Returns the `Limits` of this `TableType`
    def limits : Limits
      p = LibWasmer.wasm_tabletype_limits(self)
      Limits.new(p.value)
    end

    def to_externtype : ExternType
      p = LibWasmer.wasm_tabletype_as_externtype(self)
      ExternType.new(p)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end

  # A Table instance is the runtime representation of a table. It holds
  # a vector of function elements and an optional maximum size, if one
  # was specified in the table type at the table’s definition site.
  #
  # A table created by the host or in WebAssembly code will be
  # accessible and mutable from both host and WebAssembly.
  #
  # See also
  #
  # Specification: https://webassembly.github.io/spec/core/exec/runtime.html#table-instances
  class Table
    include WithExtern

    protected def initialize(@ptr : LibWasmer::WasmTableT)
    end

    # Returns the Table's size
    #
    # ```
    # table = instance.table("exported_table").not_nil!
    # size = table.size
    # ```
    def size : UInt32
      LibWasmer.wasm_table_size(self)
    end

    def to_extern : Extern
      p = LibWasmer.wasm_table_as_extern(self)
      Extern.new(p)
    end

    def to_unsafe
      @ptr
    end
  end
end
