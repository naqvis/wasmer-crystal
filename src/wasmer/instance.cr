require "./lib"
require "./import"
require "./trap"
require "./exports"

module Wasmer
  # A WebAssembly `Instance` is a stateful, executable instance of a
  # WebAssembly [`Module`].
  #
  # Instance objects contain all the exported WebAssembly
  # functions, memories, tables and globals that allow interacting
  # with WebAssembly.
  #
  # Specification:
  # <https://webassembly.github.io/spec/core/exec/runtime.html#module-instances>
  class Instance
    getter exports : Exports

    # Instantiates a new `Instance`
    # It takes two arguments, the `Module` and an `ImportObject`
    # Note: Instantiating a module may raise `TrapException` if the module's start function traps.
    def initialize(mod : Module, imports : ImportObject)
      externs = imports.into_inner(mod)

      @instance = LibWasmer.wasm_instance_new(mod.store, mod, pointerof(externs), out trap)

      raise TrapException.new(Trap.new(trap)) if trap.null? && @instance.null?
      @exports = Exports.new(@instance, mod)
    end

    def self.new(mod : Module)
      new(mod, ImportObject.new)
    end

    # :nodoc:
    def to_unsafe
      @instance
    end

    # :nodoc:
    def finalize
      return if @instance.null?
      LibWasmer.wasm_instance_delete(self)
    end

    forward_missing_to @exports
  end

  def self.new_instance(mod : Module, imports : ImportObject = ImportObject.new)
    Instance.new(mod, imports)
  end
end
