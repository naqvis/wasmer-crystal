require "../spec_helper"

describe Wasmer do
  it "test wasi version" do
    store = Wasmer.default_engine.new_store
    mod = Wasmer.module(store, get_data("wasi.wasm"))
    Wasmer::Wasi.version(mod).should eq(Wasmer::Wasi::Version::Snapshot1)
  end

  it "test wasi execution succeeds" do
    store = Wasmer.default_engine.new_store
    mod = Wasmer::Module.new(store, get_data("wasi.wasm"))

    env = Wasmer::Wasi::StateBuilder.builder("test-program", store) {
      with_arg("--foo")
      with_env("ABC", "DEF")
      with_env("X", "ZY")
      with_map_dir("the_host_current_directory", ".")
      with_inherit_stdout
    }

    inst = env.instantiate(store, mod)
    start = inst.exports.wasi_start_func
    begin
      start.call
    rescue ex : Wasmer::TrapException
      # WASI _start functions terminate via proc_exit, which Wasmer 7 delivers
      # as a trap. Check if it's a normal exit vs an actual error.
      trap = ex.trap
      unless trap.wasi_exit?
        raise ex
      end
    end
    true.should be_true
  end
end
