require "./lib"
require "./limits"
require "./extern"
require "./pages"
require "./store"

module Wasmer
  # MemoryType classifies linear memories and their size range.
  # See Also
  # Specification: https://webassembly.github.io/spec/core/syntax/types.html#memory-types
  class MemoryType
    include WithExternType

    def initialize(limit : Limits)
      @ptr = LibWasmer.wasm_memorytype_new(limit)
    end

    # :nodoc:
    protected def initialize(@ptr : LibWasmer::WasmMemorytypeT)
    end

    # Returns MemoryType's limits
    def limits : Limits
      Limits.new(LibWasmer.wasm_memorytype_limits(self).value)
    end

    def to_externtype : ExternType
      p = LibWasmer.wasm_memorytype_as_externtype_const(self)
      ExternType.new(p)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end

  # Memory is a vector of raw uninterpreted bytes.
  # See Also
  # Specification: https://webassembly.github.io/spec/core/syntax/modules.html#memories
  class Memory
    include WithExtern

    def initialize(store : Store, type : MemoryType)
      @ptr = LibWasmer.wasm_memory_new(store, type)
    end

    # :nodoc:
    protected def initialize(@ptr : LibWasmer::WasmMemoryT)
    end

    # Returns memory's MemoryType
    def type : MemoryType
      MemoryType.new(LibWasmer.wasm_memory_type(self))
    end

    # Returns memory size as Pages
    def size : Pages
      Pages.new(LibWasmer.wasm_memory_size(self))
    end

    # Returns memory size as a number of bytes
    def bytesize : UInt32
      LibWasmer.wasm_memory_data_size(self).to_u32
    end

    # Returns memory contents as Bytes
    def data : Bytes
      len = bytesize
      data = LibWasmer.wasm_memory_data(self)
      Bytes.new(data, len)
    end

    # Grows the Memory's size by a given number of `Pages` (the delta)
    def grow(delta : Pages) : Bool
      LibWasmer.wasm_memory_grow(self, delta)
    end

    # Returns the view of memory starting from provided offset
    # raises if offset is greater than memory byte size
    def view(offset : Int)
      raise WasmerError.new("offset exceeded the memory size.") unless offset < bytesize
      data[offset..]
    end

    def to_extern : Extern
      p = LibWasmer.wasm_memory_as_extern(self)
      Extern.new(p)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end

    # :nodoc:
    def finalize
      return if @ptr.null?
      LibWasmer.wasm_memory_delete(self)
    end
  end
end
