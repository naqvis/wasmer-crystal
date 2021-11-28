require "./lib"
require "./engine"

module Wasmer
  # Store represents all global state that can be manipulated by
  # WebAssembly programs. It consists of the runtime representation of
  # all instances of functions, tables, memories, and globals that have
  # been allocated during the life time of the abstract machine.
  # The Store holds the Engine (that is — amongst many things — used to
  # compile the Wasm bytes into a valid module artifact).
  # See also
  # Specification: https://webassembly.github.io/spec/core/exec/runtime.html#store
  class Store
    def initialize(@engine : Engine)
      @ptr = LibWasmer.wasm_store_new(@engine)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end

    # :nodoc:
    def finalize
      return if @ptr.null?
      LibWasmer.wasm_store_delete(self)
    end
  end
end
