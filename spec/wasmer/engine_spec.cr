require "../spec_helper"

describe Wasmer do
  it "test native engine" do
    engine = Wasmer.dylib_engine
    store = engine.new_store
    mod = Wasmer::Module.new(store, get_data("tests.wasm"))
    instance = Wasmer::Instance.new(mod, Wasmer::ImportObject.new)
    sum = instance.exports.function("sum").not_nil!
    result = sum.call(37, 5)
    result.should eq(42)
  end

  it "Test enginge with target" do
    triple = Wasmer::Triple.new("aarch64-unknown-linux-gnu")
    cpu = Wasmer::CpuFeatures.new
    target = Wasmer::Target.new(triple, cpu)
    config = Wasmer::Config.new
    config.use_target(target)
    engine = Wasmer::Engine.new(config)
    store = engine.new_store
    Wasmer::Module.new(store, get_data("tests.wasm"))
  end
end
