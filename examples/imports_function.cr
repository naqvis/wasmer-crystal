require "./prelude"
# A Wasm module can import entities, like functions, memories,
# globals and tables.
#
# This example illustrates how to use imported functions, aka host
# functions.
#
# You can run the example directly by executing in Wasmer root:
#
# ```shell
# $ crystal examples/imports_function.cr
# ```
#
# Ready?

# Let's declare the Wasm module with the text representation.
# If this module was written in Rust, it would have been:
#
# ```rs
# extern "C" {
#     fn sum(x: i32, y: i32) -> i32;
# }
#
# #[no_mangle]
# pub extern "C" fn add_one(x: i32) -> i32 {
#     unsafe { sum(x, 1) }
# }
# ```
wat = <<-WAT
(module
    (import "env" "sum" (func $sum (param i32 i32) (result i32)))
    (func (export "add_one") (param $x i32) (result i32)
    local.get $x
    i32.const 1
    call $sum))
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

# Let's write the Crystal function that is going to be imported,
# i.e. called by the WebAssembly module.
# The function definition must be a native Crystal function with a `Value` array
# as its single argument. The function must return a `Value` array or
# raise an exception for abnormal conditions.
#
# Note: Even if the function does not take any argument (or use any argument)
# it must receive a `Value` array as its single argument. At runtime, this array will be empty.
# The same applies to the result.
def sum(args : Array(Wasmer::Value)) : Array(Wasmer::Value)
  x = args[0].as_i
  y = args[1].as_i
  [Wasmer::Value.new(x + y)]
end

sum_host_func = Wasmer::Function.new(
  store,
  Wasmer::FunctionType.new(
    Wasmer.value_types(Wasmer::I32, Wasmer::I32),
    Wasmer.value_types(Wasmer::I32)),
  &->sum(Array(Wasmer::Value))
)

# Now let's register the `sum` import inside the `env` namespace.
import_object.register("env", {"sum" => sum_host_func.as(Wasmer::WithExtern)})

# Let's instantiate the module!
instance = Wasmer.new_instance(module_, import_object)

# And finally, call the `add_one` exported function!
assert { instance.function("add_one").not_nil!.call(41) == 42 }
