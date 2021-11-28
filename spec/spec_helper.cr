require "spec"
require "../src/wasmer"

def get_data(fname)
  path = Path["spec/test_data"].join(fname)
  File.read(path).to_slice
end

def get_inst
  store = Wasmer.default_engine.new_store
  mod = Wasmer::Module.new(store, get_data("tests.wasm"))
  Wasmer.new_instance(mod)
end

class MyEnvironment
  getter instance : Wasmer::Instance?
  getter answer : Int32

  def initialize(@instance, @answer)
  end
end
