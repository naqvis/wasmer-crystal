require "./prelude"
# Running a WASI compiled WebAssembly module with Wasmer.
#
# This example illustrates how to run WASI modules with
# Wasmer. To run WASI we have to have to do mainly 3 steps:
#
#   1. Create a `Wasi::Environment` instance,
#   2. Attach the imports from the `Wasi::Environment` to a new
#      instance,
#   3. Run the WASI module.
#
# You can run the example directly by executing in Wasmer root:
#
# ```shell
# $ crystal examples/wasi.cr
# ```
#
# Ready?

# Let's get the `wasi.wasm` bytes
file = File.read("#{__DIR__}/appendices/wasi.wasm")

# Create a store
store = Wasmer.default_engine.new_store

# Let's compile the Wasm module, as usual
module_ = Wasmer.module(store, file)

# Here we go.
#
# First, let's extract the WASI version from the module. Why? Because
# WASI already exists in multiple versions, and it doesn't work the
# same way. So, to ensure compatibility, we need to know the version.
wasi_version = Wasmer::Wasi.version(module_)

# Second, create a `Wasmer::Wasi::Environment`. It contains everything related
# to WASI. To build such an environment, we must use the
# `Wasmer::Wasi::StateBuilder`.
#
# In this case, we specify the program name is `wasi_test_program`. We
# also specify the program is invoked with the `--test` argument, in
# addition to two environment variable: `COLOR` and
# `APP_SHOULD_LOG`. Finally, we map the `the_host_current_dir` to the
# current directory. There it is:
# In Wasmer 7, StateBuilder.builder requires the store as a second argument.
# Note: wasi_config_capture_stdout has known issues in the Wasmer 7 C API
# (the async pipe used internally doesn't work well from the C/FFI layer).
# Use with_inherit_stdout for output, or check the trap's wasi_exit? method
# to detect normal WASI program termination.
env = Wasmer::Wasi::StateBuilder.builder("wasi_test_program", store) {
  with_arg("--test")
  with_env("COLOR", "true")
  with_env("APP_SHOULD_LOG", "false")
  with_map_dir("the_host_current_dir", ".")
  with_inherit_stdout
}

# In Wasmer 7, use env.instantiate(store, module_) which handles the full WASI
# setup: wasi_get_imports -> wasm_instance_new -> wasi_env_initialize_instance.
instance = env.instantiate(store, module_)

# The entry point for a WASI WebAssembly module is a function named
# `_start`. Let's call it and see what happens!
begin
  instance.wasi_start_func.call
rescue ex : Wasmer::TrapException
  # WASI programs terminate via proc_exit, which Wasmer 7 delivers as a trap.
  # Check if this is a normal exit vs an actual runtime error.
  if ex.trap.wasi_exit?
    code = ex.trap.wasi_exit_code
    puts "WASI program exited with code: #{code}"
  else
    raise ex
  end
end
