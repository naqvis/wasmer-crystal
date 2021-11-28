require "../spec_helper"

describe Wasmer do
  it "test wasi version" do
    store = Wasmer.default_engine.new_store
    mod = Wasmer.module(store, get_data("wasi.wasm"))
    Wasmer::Wasi.version(mod).should eq(Wasmer::Wasi::Version::Snapshot1)
  end

  it "test wasi with captured stdout" do
    store = Wasmer.default_engine.new_store
    mod = Wasmer::Module.new(store, get_data("wasi.wasm"))

    env = Wasmer::Wasi::StateBuilder.builder("test-program") {
      with_arg("--foo")
      with_env("ABC", "DEF")
      with_env("X", "ZY")
      with_map_dir("the_host_current_directory", ".")
      with_capture_stdout
    }

    imp = env.generate_import_object(store, mod)
    inst = Wasmer::Instance.new(mod, imp)
    start = inst.exports.wasi_start_func
    start.call
    stdout = String.new(env.read_stdout)
    stdout.should eq(
      <<-OUT
Found program name: `test-program`
Found 1 arguments: --foo
Found 2 environment variables: ABC=DEF, X=ZY
Found 1 preopened directories: DirEntry("/the_host_current_directory")

OUT
    )
  end
end
