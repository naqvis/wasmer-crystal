require "./lib"
require "./module"
require "./target"
require "./import"

module Wasmer::Wasi
  # Represents the possible WASI versions.
  enum Version
    # Latest version. It's a “floating” version, i.e. it's an
    # alias to the latest version. Using this version is a way to
    # ensure that modules will run only if they come with the
    # latest WASI version (in case of security issues for
    # instance), by just updating the runtime.
    Latest

    # Represents the wasi unstable version
    Snapshot0
    # Represents the wasi snapshot preview1 version
    Snapshot1
    # Represents an invalid version
    Invalid = -1

    def to_s(io : IO) : Nil
      io << case self
      when .latest?    then "__latest__"
      when .snapshot0? then "wasi_unstable"
      when .snapshot1? then "wasi_snapshot_preview1"
      when .invalid?   then "__uknown__"
      end
    end
  end

  # Convenient API for configuring WASI
  class StateBuilder
    private def initialize(name : String)
      @ptr = LibWasmer.wasi_config_new(name)
    end

    # store is required to build the WASI environment
    def self.builder(program_name : String, store : Store) : Environment
      wasi = new(program_name)
      with wasi yield wasi
      wasi.build(store)
    end

    # Configures a new argument to the WASI module
    def with_arg(argument : String)
      LibWasmer.wasi_config_arg(self, argument)
      self
    end

    # Configures a new environment variable for the WASI module
    def with_env(key : String, value : String)
      LibWasmer.wasi_config_env(self, key, value)
      self
    end

    # Configures a new directory to pre-open.
    #
    # This opens the given directory at the virtual root /, and allows
    # the WASI module to read and write to the given directory.
    def with_preopen_dir(dir : String)
      LibWasmer.wasi_config_preopen_dir(self, dir)
      self
    end

    # Configures a new directory to pre-open with a different name exposed to the WASI module.
    def with_map_dir(_alias : String, dir : String)
      LibWasmer.wasi_config_mapdir(self, _alias, dir)
      self
    end

    # Configures the WASI module to inherit the STDIN from the host
    def with_inherit_stdin
      LibWasmer.wasi_config_inherit_stdin(self)
      self
    end

    # Configures the WASI module to capture its STDOUT
    def with_capture_stdout
      LibWasmer.wasi_config_capture_stdout(self)
    end

    # Configures the WASI module to inherit the STDOUT from the host
    def with_inherit_stdout
      LibWasmer.wasi_config_inherit_stdout(self)
      self
    end

    # Configures the WASI module to capture its STDERR
    def with_capture_stderr
      LibWasmer.wasi_config_capture_stderr(self)
    end

    # Configures the WASI module to inherit the STDERR from the host
    def with_inherit_stderr
      LibWasmer.wasi_config_inherit_stderr(self)
      self
    end

    # Builds the state builder to produce a `WasiEnvironment`.
    # store is required to create the WASI environment
    def build(store : Store)
      Environment.new(self, store)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end

  # `Environment` represents the environment provided to the WASI
  class Environment
    private BUF_SIZE = 1024_u64

    # :nodoc:
    # wasi_env_new requires the store as first argument
    protected def initialize(builder : StateBuilder, store : Store)
      @ptr = LibWasmer.wasi_env_new(store, builder)
      Wasmer.check_error if @ptr.null?
    end

    # Reads the WASI module STDOUT if captured with `WasiStateBuilder#with_capture_stdout`
    def read_stdout : Bytes
      read(->LibWasmer.wasi_env_read_stdout)
    end

    # Reads the WASI module STDERR if captured with `WasiStateBuilder#with_capture_stderr`
    def read_stderr : Bytes
      read(->LibWasmer.wasi_env_read_stderr)
    end

    # Generates an import object, that can be extended and passed to `Instance`.
    # Uses wasi_get_imports (ordered) as the primary path.
    #
    # Note: For additional imports on top of WASI, use `register` on the returned
    # `ImportObject` before passing it to `Instance`.
    def generate_import_object(store : Store, mod : Module) : ImportObject
      LibWasmer.wasm_extern_vec_new_empty(out imports_vec)
      ret = LibWasmer.wasi_get_imports(store, self, mod, pointerof(imports_vec))
      Wasmer.check_error unless ret

      # Build ImportObject from the ordered extern vec, matching module import names.
      # Do NOT delete imports_vec here — the externs are owned by the vec and must
      # stay alive until after wasm_instance_new. We copy each extern so that
      # into_inner can safely pass them to wasm_extern_vec_new.
      res = ImportObject.new
      mod_imports = mod.imports
      first_ptr = imports_vec.data
      size = imports_vec.size.to_i
      0.upto(size - 1) do |i|
        # Copy the extern so the ImportObject owns its own reference
        ext = LibWasmer.wasm_extern_copy(first_ptr[i])
        if i < mod_imports.size
          mod_name = mod_imports[i].mod_name
          name = mod_imports[i].name
          extern = Extern.new(ext)
          res.externs[mod_name] = Hash(String, WithExtern).new unless res.externs.has_key?(mod_name)
          res.externs[mod_name][name] = extern
        end
      end
      # Delete the original vec after copying all externs
      LibWasmer.wasm_extern_vec_delete(pointerof(imports_vec))
      res
    end

    # Creates and initializes a WASI `Instance` directly from this environment.
    # This is the recommended way to instantiate a WASI module.
    # It uses `wasi_get_imports` to get the ordered externs and passes them
    # directly to `wasm_instance_new` without copying, then calls
    # `wasi_env_initialize_instance` to complete the setup.
    def instantiate(store : Store, mod : Module) : Instance
      LibWasmer.wasm_extern_vec_new_empty(out imports_vec)
      ok = LibWasmer.wasi_get_imports(store, self, mod, pointerof(imports_vec))
      Wasmer.check_error unless ok

      raw_instance = LibWasmer.wasm_instance_new(store, mod, pointerof(imports_vec), out _trap)
      LibWasmer.wasm_extern_vec_delete(pointerof(imports_vec))

      raise WasmerError.new("Failed to create WASI instance") if raw_instance.null?

      # Initialize the WASI env with the created instance (required)
      initialized = LibWasmer.wasi_env_initialize_instance(self, store, raw_instance)
      Wasmer.check_error unless initialized

      Instance.new(raw_instance, mod)
    end

    # Initializes the WASI environment with the given instance.
    # This must be called after creating the `Instance` and before calling any WASI functions.
    # This is required by newer Wasmer versions.
    def initialize_instance(store : Store, instance : Instance) : Bool
      LibWasmer.wasi_env_initialize_instance(self, store, instance)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end

    # :nodoc:
    def finalize
      return if @ptr.null?
      LibWasmer.wasi_env_delete(self)
    end

    private def name_to_s(ptr)
      val = ptr.value
      String.new(val.data)[...val.size]
    end

    private def read(reader : (LibWasmer::WasiEnvT, LibC::Char*, LibC::ULong) -> LibC::Long) : Bytes
      buff = Bytes.new(BUF_SIZE.to_i)
      result = IO::Memory.new
      while true
        len = reader.call(self.to_unsafe, buff.to_unsafe, BUF_SIZE)
        result.write(buff[...len])
        buff.to_unsafe.clear(BUF_SIZE)
        break if len < BUF_SIZE
      end
      result.rewind
      result.to_slice
    end
  end

  # Returns the WASI version of the given Module if any
  def self.version(mod : Module)
    Version.from_value(LibWasmer.wasi_get_wasi_version(mod).value)
  end
end
