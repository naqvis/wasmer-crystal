require "./lib"

module Wasmer
  # Represents possible compiler/backend types.
  # In Wasmer 7, compilers and engines were unified into a single `backend` concept.
  enum CompilerKind
    Cranelift
    LLVM
    Singlepass

    # Checks that the given compiler backend is available in this current version of wasmer-crystal
    def available?
      LibWasmer.wasmer_is_backend_available(to_c)
    end

    def to_s(io : IO)
      io << self.to_s.downcase
    end

    # :nodoc:
    protected def to_c
      LibWasmer::WasmerBackendT.from_value(self.value)
    end
  end

  # Represents the possible engine/backend types.
  # In Wasmer 7, the engine concept was replaced by backends. `Universal` and `Dylib`
  # map to the Cranelift backend for backward compatibility.
  enum EngineKind
    Universal
    Dylib
    Staticlib

    # Checks that the Cranelift backend is available (replaces per-engine availability in Wasmer 7)
    def available?
      LibWasmer.wasmer_is_backend_available(LibWasmer::WasmerBackendT::Cranelift)
    end

    def to_s(io : IO)
      io << self.to_s.downcase
    end

    # :nodoc:
    # In Wasmer 7, Universal/Dylib/Staticlib engines map to Cranelift backend
    protected def to_c
      LibWasmer::WasmerBackendT::Cranelift
    end
  end

  class Config
    def initialize
      @ptr = LibWasmer.wasm_config_new
    end

    # Sets the backend to Cranelift (replaces Universal engine in Wasmer 7).
    # Will raise if Cranelift backend is not supported.
    def use_universal_engine
      set_backend(LibWasmer::WasmerBackendT::Cranelift)
    end

    # Sets the backend to Cranelift (replaces Dylib engine in Wasmer 7).
    # Will raise if Cranelift backend is not supported.
    def use_dylib_engine
      set_backend(LibWasmer::WasmerBackendT::Cranelift)
    end

    # Sets the backend to Cranelift (replaces Staticlib engine in Wasmer 7).
    # Will raise if Cranelift backend is not supported.
    def use_staticlib_engine
      set_backend(LibWasmer::WasmerBackendT::Cranelift)
    end

    # Sets the backend to Cranelift. Will raise if not supported.
    # Check `CompilerKind::Cranelift.available?` to check the availability
    def use_cranelift_compiler
      set_backend(LibWasmer::WasmerBackendT::Cranelift)
    end

    # Sets the backend to LLVM. Will raise if not supported.
    # Check `CompilerKind::LLVM.available?` to check the availability
    def use_llvm_compiler
      set_backend(LibWasmer::WasmerBackendT::Llvm)
    end

    # Sets the backend to Singlepass. Will raise if not supported.
    # Check `CompilerKind::Singlepass.available?` to check the availability
    def use_singlepass_compiler
      set_backend(LibWasmer::WasmerBackendT::Singlepass)
    end

    # Use a specific target for doing cross-compilation
    def use_target(target : Target)
      LibWasmer.wasm_config_set_target(self, target)
      self
    end

    private def set_backend(backend : LibWasmer::WasmerBackendT)
      raise "This backend (#{backend}) is not available in this build" unless LibWasmer.wasmer_is_backend_available(backend)
      LibWasmer.wasm_config_set_backend(self, backend)
      self
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end
end
