require "./lib"
require "./config"

module Wasmer
  # Engine is used by the `Store` to drive the compilation and the
  # execution of a WebAssembly module
  class Engine
    # Instantiates and returns a new Engine with default configuration
    def initialize
      @ptr = LibWasmer.wasm_engine_new
    end

    # Instantiates and returns a new Engine with given configuration
    def initialize(config : Config)
      @ptr = LibWasmer.wasm_engine_new_with_config(config)
    end

    # Instantiates and returns a new Universal engine
    def self.universal
      config = Config.new
      config.use_universal_engine
      new(config)
    end

    # Instantiates and returns a new Dylib engine
    def self.dylib
      config = Config.new
      config.use_dylib_engine
      new(config)
    end

    # helper method to returns a new `Store` object
    def new_store
      Store.new(self)
    end

    # :nodoc:
    def finalize
      return if @ptr.null?
      LibWasmer.wasm_engine_delete(@ptr)
    end

    # :nodoc:
    def to_unsafe
      @ptr
    end
  end

  # Instantiates and returns a new default engine
  def self.default_engine
    Engine.new
  end

  # Instantiates and returns a new Universal engine
  def self.universal_engine
    Engine.universal
  end

  # Instantiates and returns a new Dylib engine
  def self.dylib_engine
    Engine.dylib
  end

  # Instantiates and returns a new Engine with default configuration
  def self.engine(config : Config)
    Engine.new(config)
  end
end

require "./store"
