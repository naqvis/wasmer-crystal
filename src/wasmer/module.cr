require "./lib"
require "./import"
require "./trap"
require "./exports"
require "./wat"

module Wasmer
  # Module contains stateless WebAssembly code that has already been
  # compiled and can be instantiated multiple times.
  #
  # WebAssembly programs are organized into modules, which are the unit
  # of deployment, loading, and compilation. A module collects
  # definitions for types, functions, tables, memories, and globals. In
  # addition, it can declare imports and exports and provide
  # initialization logic in the form of data and element segments or a
  # start function.
  #
  # See also
  #
  # Specification: https://webassembly.github.io/spec/core/syntax/modules.html#modules
  class Module
    # Stored if computed to avoid further reallocations.
    private getter import_types : ImportTypes { ImportTypes.new(self) }

    # Stored if computed to avoid further reallocations.
    private getter export_types : ExportTypes { ExportTypes.new(self) }
    protected getter store : Store

    def self.new(store : Store, bytes : Bytes)
      new(store, String.new(bytes))
    end

    def initialize(@store : Store, wat : String)
      wasm = Wasmer.wat2wasm(wat)
      wasm_vec = LibWasmer::WasmByteVecT.new
      wasm_vec.size = wasm.bytesize
      wasm_vec.data = wasm.to_unsafe
      @ptr = LibWasmer.wasm_module_new(@store, pointerof(wasm_vec))
      Wasmer.check_error if @ptr.null?
    end

    # Validates a new `Module` against the given store.
    def validate(@store : Store, bytes : Bytes) : Nil
      wasm = Wasmer.wat2wasm(String.new(bytes))
      wasm_vec = LibWasmer::WasmByteVecT.new
      wasm_vec.size = wasm.bytesize
      wasm_vec.data = wasm.to_unsafe
      ret = LibWasmer.wasm_module_validate(@store, pointerof(wasm_vec))
      Wasmer.check_error unless ret
    end

    # Returns the Module's name
    # Note: This is not part of the standard Wasm C API. It is Wasmer specific
    def name : String
      LibWasmer.wasmer_module_name(self, out name)
      ret = String.new(name.data)[...name.size]
      LibWasmer.wasm_byte_vec_delete(pointerof(name))
      ret
    end

    # Returns the Module's imports as an `ImportType` array
    def imports : Array(ImportType)
      import_types.import_types
    end

    # Returns the Module's exports as an `ExportType` array
    def exports : Array(ExportType)
      export_types.export_types
    end

    # Serializes the module and returns the Wasm code as bytes
    def serialize : Bytes
      LibWasmer.wasm_module_serialize(self, out bytes)
      Wasmer.check_error if bytes.data.null?
      Bytes.new(bytes.data, bytes.size)
    end

    # Deserializes bytes to a Module
    def self.deserialize(store : Store, bytes : Bytes) : Module
      vec = LibWasmer::WasmByteVecT.new
      vec.size = bytes.bytesize
      vec.data = bytes.to_unsafe
      ptr = LibWasmer.wasm_module_deserialize(self, pointerof(vec))
      Wasmer.check_error if ptr.null?
      new(ptr)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end

    # :nodoc:
    def finalize
      return if @ptr.null?
      LibWasmer.wasm_module_delete(self)
    end
  end

  # Helper method to return an instance of `Module`
  def self.module(store : Store, wat : String | Bytes)
    Module.new(store, wat)
  end
end
