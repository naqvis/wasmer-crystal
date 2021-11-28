require "./lib"

module Wasmer
  # Units of WebAssembly pages (as specified to be 65,536 bytes)
  struct Pages
    # Represents a memory page size
    PageSize = 0x10000_u32

    # Represents the maximum number of pages
    MaxPages = 0x10000_u32

    # Represents the minimum number of pages
    MinPages = 0x100_u32

    @value : UInt32

    def initialize(val : Number)
      @value = val.to_u32
    end

    # Converts Pages to a native Crystal UInt32 which is the Pages' size
    def to_u32
      @value
    end

    # Converts Pages to a native Crystal UInt32 which is the Pages' size in bytes
    def to_bytes : UInt32
      @value * PageSize
    end

    def to_s(io : IO) : Nil
      io << to_u32
    end
  end
end
