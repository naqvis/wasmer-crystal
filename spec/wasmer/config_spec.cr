require "../spec_helper"

describe Wasmer do
  it "test config" do
    config = Wasmer::Config.new
    engine = Wasmer::Engine.new(config)
    store = engine.new_store
    mod = Wasmer::Module.new(store, get_data("tests.wasm"))
    instance = Wasmer::Instance.new(mod, Wasmer::ImportObject.new)
    sum = instance.exports.function("sum").not_nil!
    result = sum.call(37, 5)
    result.should eq(42)
  end
end
