require "./lib"
require "./target"

module Wasmer
  # wat2wasm parses a string as either WAT or a binary Wasm module
  # See https://webassembly.github.io/spec/core/text/index.html
  # Note: This is not part of the standard Wasm C API. It is Wasmer specific
  def self.wat2wasm(wat : String) : Bytes
    LibWasmer.wasm_byte_vec_new(out wat_bytes, wat.bytesize, wat)
    LibWasmer.wat2wasm(pointerof(wat_bytes), out wasm)
    check_error if wasm.data.null?
    v = Bytes.new(wasm.data, wasm.size)
    LibWasmer.wasm_byte_vec_delete(pointerof(wat_bytes))
    v
  end
end
