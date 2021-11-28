# A complete and mature WebAssembly runtime for Crystal based on [Wasmer](https://wasmer.io/).
module Wasmer
  VERSION = "0.1.0"

  class WasmerError < Exception
  end

  class TrapException < WasmerError
    getter trap : Trap

    def initialize(@trap)
      super(@trap.message)
    end
  end

  def self.version
    String.new(Wasmer::LibWasmer.wasmer_version)
  end
end

require "./wasmer/*"
