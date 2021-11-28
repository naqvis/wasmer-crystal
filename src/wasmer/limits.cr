require "./lib"

module Wasmer
  # Returns the value used to represent an unbound limit.
  # i.e. when a limit only has a min but not a max.
  # See `Limits`
  def self.max_unbound
    LibWasmer::WASM_LIMITS_MAX_DEFAULT
  end

  # Limits classify the size range of resizable storage associated with `Memory` types and `Table` types.
  # See also
  # Specification: https://webassembly.github.io/spec/core/syntax/types.html#limits
  class Limits
    # Instantiates a new limit which describes the Memory used. The `min` and `max` parameters
    # are number of memory pages.
    # Note: Each page is 64 KiB in size
    #
    # Note: You cannot `Memory#grow` the `Memory` beyond the maximum bound defined here
    def initialize(min : Int, max : Int)
      raise WasmerError.new("The minimum limit is greater than the maximum limit") if min > max
      @ptr = LibWasmer::WasmLimitsT.new
      @ptr.min = min.to_u32
      @ptr.max = max.to_u32
    end

    def initialize(@ptr : LibWasmer::WasmLimitsT)
    end

    # Returns the mimimum size of the Memory allocated in "number of pages"
    # Note: Each page is 64 KiB in size.
    def minimum
      @ptr.min
    end

    # Returns the maximum size of the Memory allocated in "number of pages"
    # Note: Each page is 64 KiB in size.
    # Note: YOu cannot grow memory beyond this defined size
    def maximum
      @ptr.max
    end

    # :nodoc:
    def to_unsafe
      pointerof(@ptr)
    end
  end
end
