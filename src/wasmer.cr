# A complete and mature WebAssembly runtime for Crystal based on [Wasmer](https://wasmer.io/).
module Wasmer
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify.downcase }}

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
