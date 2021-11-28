require "./lib"

module Wasmer
  # Represents possible compiler types
  enum CompilerKind
    Cranelift
    LLVM
    Singlepass

    # Checks that the given compiler is available in this current version of wasmer-crystal
    def available?
      LibWasmer.wasmer_is_compiler_available(to_c)
    end

    def to_s(io : IO)
      io << self.to_s.downcase
    end

    # :nodoc:
    protected def to_c
      LibWasmer::WasmerCompilerT.from_value(self.value)
    end
  end

  # Represents the possible engine types
  enum EngineKind
    Universal
    Dylib
    Staticlib

    # Checks that the given engine is available in this current version of wasmer-crystal
    def available?
      LibWasmer.wasmer_is_engine_available(to_c)
    end

    def to_s(io : IO)
      io << self.to_s.downcase
    end

    # :nodoc:
    protected def to_c
      LibWasmer::WasmerEngineT.from_value(self.value)
    end
  end

  class Config
    def initialize
      @ptr = LibWasmer.wasm_config_new
    end

    # Sets the engine to Universal. Will raise if `Universal` engine is not
    # supported by current binding.
    # Check `EngineKind.available?` to check the availability
    def use_universal_engine
      set_engine(EngineKind::Universal)
    end

    # Sets the engine to Dylib. Will raise if `Dylib` engine is not
    # supported by current binding.
    # Check `EngineKind.available?` to check the availability
    def use_dylib_engine
      set_engine(EngineKind::Dylib)
    end

    # Sets the engine to Staticlib. Will raise if `Staticlib` engine is not
    # supported by current binding.
    # Check `EngineKind.available?` to check the availability
    def use_staticlib_engine
      set_engine(EngineKind::Staticlib)
    end

    # Sets the compiler to Cranelift. Will raise if `Cranelift` compiler is not
    # supported by current binding.
    # Check `CompilerKind.available?` to check the availability
    def use_cranelift_compiler
      set_compiler(CompilerKind::Cranelift)
    end

    # Sets the compiler to LLVM. Will raise if `llvm` compiler is not
    # supported by current binding.
    # Check `CompilerKind.available?` to check the availability
    def use_llvm_compiler
      set_compiler(CompilerKind::LLVM)
    end

    # Sets the compiler to Singlepass. Will raise if `Singlepass` compiler is not
    # supported by current binding.
    # Check `CompilerKind.available?` to check the availability
    def use_singlepass_compiler
      set_compiler(CompilerKind::Singlepass)
    end

    # Use a specific target for doing cross-compilation
    def use_target(target : Target)
      LibWasmer.wasm_config_set_target(self, target)
      self
    end

    private def set_engine(kind : EngineKind)
      raise "This version doesn't include #{kind.to_s.capitalize} engine" unless kind.available?
      LibWasmer.wasm_config_set_engine(self, kind.to_c)
      self
    end

    private def set_compiler(kind : CompilerKind)
      raise "This version doesn't include #{kind.to_s.capitalize} compiler" unless kind.available?
      LibWasmer.wasm_config_set_compiler(self, kind.to_c)
      self
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end
end
