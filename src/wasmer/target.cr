require "./lib"

module Wasmer
  class Name
    @ptr : LibWasmer::WasmByteVecT

    def initialize(name : String)
      LibWasmer.wasm_byte_vec_new(out @ptr, name.bytesize, name)
    end

    def to_s(io : IO)
      if @ptr.size > 0 && @ptr.data
        io << String.new(@ptr.data)[...@ptr.size]
      end
    end

    # :nodoc:
    def to_unsafe
      pointerof(@ptr)
    end
  end

  # Target represents a triple + CPU features pairs
  class Target
    def initialize(triple : Triple, cpu : CpuFeatures)
      @ptr = LibWasmer.wasmer_target_new(triple, cpu)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end

  class Triple
    @triple : LibWasmer::WasmerTripleT

    # Creates a new triple, otherwise it returns an error
    # specifying why the provided triple isn't valid.
    # ```
    # triple = Wasmer::Triple.new("aarch64-unknown-linux-gnu")
    # ```
    def initialize(name : String)
      name_ptr = Name.new(name)
      begin
        @triple = LibWasmer.wasmer_triple_new(name_ptr)
        Wasmer.check_error if @triple.value.nil?
      ensure
        LibWasmer.wasm_byte_vec_delete(name_ptr)
      end
    end

    # Creates a new triple from the current host
    def self.from_host
      new(LibWasmer.wasmer_triple_new_from_host)
    end

    private def initialize(@triple)
    end

    # :nodoc:
    def to_unsafe
      @triple
    end
  end

  # CpuFeatures holds a set of CPU features. They are identified by
  # their stringified names. The reference is the GCC options:
  # * https:gcc.gnu.org/onlinedocs/gcc/x86-Options.html,
  # * https:gcc.gnu.org/onlinedocs/gcc/ARM-Options.html,
  # * https:gcc.gnu.org/onlinedocs/gcc/AArch64-Options.html.
  # At the time of writing this documentation (it might be outdated in
  # the future), the supported featurse are the following:
  # * sse2,
  # * sse3,
  # * ssse3,
  # * sse4.1,
  # * sse4.2,
  # * popcnt,
  # * avx,
  # * bmi,
  # * bmi2,
  # * avx2,
  # * avx512dq,
  # * avx512vl,
  # * lzcnt.
  class CpuFeatures
    # Create a new CputFeatures, which is a set of CPU features.
    def initialize
      @ptr = LibWasmer.wasmer_cpu_features_new
    end

    # Add a new CPU feature to the existing set
    def add(feature : String)
      name_ptr = Name.new(feature)
      begin
        ret = LibWasmer.wasmer_cpu_features_add(self, name_ptr)
        Wasmer.check_error unless ret
      ensure
        LibWasmer.wasm_byte_vec_delete(name_ptr)
      end
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end

  # :nodoc:
  protected def self.check_error
    err_len = LibWasmer.wasmer_last_error_length
    return unless err_len > 0
    msg = Bytes.new(err_len + 1)
    ret = LibWasmer.wasmer_last_error_message(msg.to_unsafe, err_len)
    raise "failed to read last error from Wasmer" if ret == -1
    raise WasmerError.new(String.new(msg))
  end
end
