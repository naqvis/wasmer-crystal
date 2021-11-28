require "./lib"
require "./value"
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
end
