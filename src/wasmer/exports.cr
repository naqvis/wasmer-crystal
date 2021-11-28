require "./lib"
require "./module"
require "./extern"
require "./function"

module Wasmer
  # Represents all the exports of an instance.
  #
  # Exports can be of kind `Function`, `Global`, `Table`, or `Memory`.
  # Exports is a special kind of map that allows easily unwrapping the
  # types of instances.
  class Exports
    # :nodoc:
    protected def initialize(@instance : LibWasmer::WasmInstanceT, _module : Module)
      LibWasmer.wasm_instance_exports(@instance, out @ptr)
      @exports = Hash(String, Extern).new
      first = @ptr.data

      mod_exports = _module.exports

      0.upto(@ptr.size - 1) do |n|
        exp = Extern.new(first[n])
        @exports[mod_exports[n].name] = exp
      end
    end

    # Retries and returns an `Extern` by its name.
    # If the name does not refer to an existing export, it will raise an exception
    def [](name : String) : Extern
      exp = @exports[name]?
      raise WasmerError.new("Export '#{name}' does not exist") unless exp
      exp
    end

    # Retrieves and return an exported function by its name.
    # If the name doesn't not refer to an existing export, it will raise an exception.
    # if the export is not a function, it will return nil as its result
    def raw_function(name : String) : Function?
      exp = self.[name]
      exp.to_function
    end

    # Retrieves an exported function by its name and return it as a native Crystal Proc
    # The difference with `raw_function` is that `Function#native` has been called on the
    # exported function.
    #
    # Note: If the name does not refer to an existing export, `function` raises exception.
    # Note: If the export is not a function, `function` will return nil as its result
    def function(name : String) # : NativeFunc?
      func = raw_function(name)
      func.try &.native
    end

    # Retrieves and return an exported Global by its name.
    # If the name doesn't not refer to an existing export, it will raise an exception.
    # if the export is not a global, it will return nil as its result
    def global(name : String) : Global?
      exp = self.[name]
      exp.to_global
    end

    # Retrieves and return an exported Table by its name.
    # If the name doesn't not refer to an existing export, it will raise an exception.
    # if the export is not a table, it will return nil as its result
    def table(name : String) : Table?
      exp = self.[name]
      exp.to_table
    end

    # Retrieves and return an exported Memory by its name.
    # If the name doesn't not refer to an existing export, it will raise an exception.
    # if the export is not a memory, it will return nil as its result
    def memory(name : String) : Memory?
      exp = self.[name]
      exp.to_memory
    end

    # Similar to function("_start"). It saves you the cost of knowing
    # the name of the WASI start function.
    def wasi_start_func
      if start = LibWasmer.wasi_get_start_function(@instance)
        return Function.new(start, nil).native
      end
      raise WasmerError.new("WASI start function was not found")
    end

    # :nodoc:
    def to_unsafe
      pointerof(@ptr)
    end

    # :nodoc:
    def finalize
      @exports.clear
      return unless @ptr
      LibWasmer.wasm_extern_vec_delete(self)
    end
  end

  # ExportType is a descriptor for an exported WebAssembly value
  class ExportType
    @closed = false

    def initialize(name : String, type : WithExternType)
      new_name = Name.new(name)
      ext_type = type.to_externtype.to_unsafe
      ext_type_copy = LibWasmer.wasm_externtype_copy(ext_type)

      @ptr = LibWasmer.wasm_exporttype_new(new_name, ext_type_copy)
    end

    # :nodoc:
    protected def initialize(@ptr : LibWasmer::WasmExporttypeT)
    end

    def name
      val = LibWasmer.wasm_exporttype_name(self).value
      String.new(val.data)[...val.size]
    end

    def type
      ExternType.new(LibWasmer.wasm_exporttype_type(self))
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end

    # :nodoc:
    def finalize
      return if @ptr.null?
      LibWasmer.wasm_exporttype_delete(@ptr)
    end
  end

  private class ExportTypes
    getter export_types : Array(ExportType)
    @closed = false

    def initialize(_module : Module)
      LibWasmer.wasm_module_exports(_module, out @ptr)

      @export_types = Array(ExportType).new(@ptr.size)

      exp = @ptr.data
      0.upto(@ptr.size.to_i - 1) do |n|
        @export_types << ExportType.new(exp[n])
      end
    end

    # :nodoc:
    def to_unsafe
      pointerof(@ptr)
    end
  end
end
