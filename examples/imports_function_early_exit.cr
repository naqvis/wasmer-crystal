require "./prelude"
# A Wasm module can import entities, like functions, memories,
# globals and tables.
#
# This example illustrates how to use an imported function that fails!
#
# You can run the example directly by executing in Wasmer root:
#
# ```shell
# $ crystal examples/imports_function_early_exit.cr
# ```
#
# Ready?

# Let's declare the Wasm module with the text representation.
wat = <<-WAT
(module
    (type $run_t (func (param i32 i32) (result i32)))
    (type $early_exit_t (func (param) (result)))
    (import "env" "early_exit" (func $early_exit (type $early_exit_t)))
    (func $run (type $run_t) (param $x i32) (param $y i32) (result i32)
        (call $early_exit)
        (i32.add
            local.get $x
            local.get $y))
    (export "run" (func $run)))
WAT

# Create a store
store = Wasmer.default_engine.new_store

# Let's compile the Wasm module
module_ = Wasmer.module(store, wat)

# Here we go.
#
# When creating an `Instance`, we can pass an `ImportObject`. All
# entities that must be imported are registered inside the
# `ImportObject`.
import_object = Wasmer::ImportObject.new

# Let's create a Host Function, which doesn't take any parameter and
# has no return type
func = Wasmer::Function.new(store, Wasmer::FunctionType.new) { |_|
  raise "oops"
}

# Now let's register the early_exit function inside the `env` namespace
import_object.register("env", {"early_exit" => func.as(Wasmer::WithExtern)})

# Let's instantiate the module!
instance = Wasmer.new_instance(module_, import_object)

# And finally, call the `run` exported function
begin
  instance.function("run").not_nil!.call(1, 2)
rescue e : Wasmer::TrapException
  assert { e.message == "oops" }
else
  assert { false }
end
