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
env = Wasmer::Wasi::StateBuilder.builder("wasi_test_program") {
  with_arg("--test")
  with_env("COLOR", "true")
  with_env("APP_SHOULD_LOG", "false")
  with_map_dir("the_host_current_dir", ".")
  with_capture_stdout
}

# From the WASI environment, we generate a custom import object. Why?
# Because WASI is, from the user perspective, a bunch of
# imports. Consequently `generate_import_object`… generates a
# pre-configured import object.
#
# Do you remember when we said WASI has multiple versions? Well, we
# need the WASI version here!

imp_obj = env.generate_import_object(store, module_)

# Now can instantiate the module
instance = Wasmer.new_instance(module_, imp_obj)

# The entry point for a WASI WebAssembly module is a function named
# `_start`. Let's call it and see what happens!
instance.wasi_start_func.call

# Since we have captured the stdout `with_capture_stdout`, it won't print any
# output to console.

# So let's read the captured stdout via `read_stdout'. It returns the Slice
# so let's convert that to String
output = String.new(env.read_stdout)

expected_output = <<-OUTPUT
Found program name: `wasi_test_program`
Found 1 arguments: --test
Found 2 environment variables: COLOR=true, APP_SHOULD_LOG=false
Found 1 preopened directories: DirEntry("/the_host_current_dir")

OUTPUT
puts output
assert { output === expected_output }
