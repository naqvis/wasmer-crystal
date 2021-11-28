require "./lib"
require "./extern"
require "./target"
require "./value"
require "./function"

module Wasmer
  # ImportObject contains all of the import data used when
  # instantiating a WebAssembly module.
  class ImportObject
    getter externs : Hash(String, Hash(String, WithExtern))

    def initialize
      @externs = Hash(String, Hash(String, WithExtern)).new
    end

    # :nodoc:
    protected def into_inner(mod : Module) : LibWasmer::WasmExternVecT
      ret = LibWasmer::WasmExternVecT.new
      vals = Array(LibWasmer::WasmExternT).new
      mod.imports.each do |imp|
        namespace = imp.mod_name
        name = imp.name

        raise WasmerError.new("Missing import: '#{namespace}'.'#{name}'") unless v = @externs[namespace][name]?
        vals << v.to_extern.to_unsafe
      end
      LibWasmer.wasm_extern_vec_new(pointerof(ret), vals.size, vals.to_unsafe) unless vals.empty?
      ret
    end

    # Returns true if the `ImportObject` contains the given namespace (or module name)
    # ```
    # imports = ImportObject.new
    # imports.contains_namespace?("env")
    # ```
    def contains_namespace?(name : String) : Bool
      @externs.has_key?(name)
    end

    # Registers a namespace (or module name) in the `ImportObject`.
    # It takes two arguments: the namespace name and a hash with imports names as key and externs as value
    # Note: An extern is anything implementing `WithExtern` : `Function`, `Global`, `Memory`, `Table`
    #
    # ```
    # imports = ImportObject.new
    # imports.register("env", {"host_function" => host_function, "host_global" => host_global})
    # ```
    # Note: The namespace (or module name) may be empty:
    # ```
    # imports = ImportObject.new
    # imports.register("", {"host_function" => host_function, "host_global" => host_global})
    # ```
    def register(ns_name : String, ns : Hash(String, WithExtern)) : Nil
      if val = @externs[ns_name]?
        ns.each { |k, v| val[k] = v }
      else
        @externs[ns_name] = ns
      end
    end
  end

  # ImportType is a descriptor for an imported value into a WebAssembly module
  class ImportType
    # Instantiates a new `ImportType` with a module name (or namespace),
    # a name and en extern type.
    #
    # Note: An extern is anything implementing `WithExtern` : `Function`, `Global`, `Memory`, `Table`
    #
    # ```
    # val_type = ValueType.new(Wasmer::I32)
    # global_type = GlobalType.new(val_type, Wasmer::IMMUTABLE)
    # import_type = ImportType.new("ns", "host_global", global_type)
    # ```
    def initialize(namespace : String, name : String, type : WithExternType)
      mod_name = Name.new(namespace)
      name_name = Name.new(name)
      extern_type = type.to_externtype.to_unsafe
      extern_type_copy = LibWasmer.wasm_externtype_copy(extern_type)

      @ptr = LibWasmer.wasm_importtype_new(mod_name, name_name, extern_type_copy)
    end

    # :nodoc:
    protected def initialize(@ptr : LibWasmer::WasmImporttypeT)
    end

    # Returns the `ImportType`'s module name (or namespace)
    # ```
    # val_type = ValueType.new(Wasmer::I32)
    # global_type = GlobalType.new(val_type, Wasmer::IMMUTABLE)
    # import_type = ImportType.new("ns", "host_global", global_type)
    # import_type.mod_name
    # ```
    def mod_name : String
      byte_vec = LibWasmer.wasm_importtype_module(self).value
      String.new(byte_vec.data)[...byte_vec.size]
    end

    # Returns the `ImportType`'s name
    # ```
    # val_type = ValueType.new(Wasmer::I32)
    # global_type = GlobalType.new(val_type, Wasmer::IMMUTABLE)
    # import_type = ImportType.new("ns", "host_global", global_type)
    # import_type.name
    # ```
    def name : String
      byte_vec = LibWasmer.wasm_importtype_name(self).value
      String.new(byte_vec.data)[...byte_vec.size]
    end

    # Returns the `ImportType`'s type as an `ExternType`
    # ```
    # val_type = ValueType.new(Wasmer::I32)
    # global_type = GlobalType.new(val_type, Wasmer::IMMUTABLE)
    # import_type = ImportType.new("ns", "host_global", global_type)
    # import_type.type
    # ```
    def type : ExternType
      ty = LibWasmer.wasm_importtype_type(self)
      ExternType.new(ty)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end

    # :nodoc:
    def finalize
      return if @ptr.null?
      LibWasmer.wasm_importtype_delete(@ptr)
    end
  end

  # :nodoc:
  class ImportTypes
    getter import_types : Array(ImportType)

    def initialize(mod : Module)
      LibWasmer.wasm_module_imports(mod, out @ptr)
      @import_types = Array(ImportType).new(@ptr.size.to_i)
      first_ptr = @ptr.data
      0.upto(@ptr.size.to_i - 1) do |i|
        @import_types << ImportType.new(first_ptr[i])
      end
    end

    # :nodoc:
    def to_unsafe
      pointerof(@ptr)
    end
  end
end
