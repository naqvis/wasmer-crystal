require "./prelude"
# A Wasm module can export entities, like functions, memories,
# globals and tables.
#
# This example illustrates how to use exported functions.
#
# You can run the example directly by executing in folder root:
#
# ```shell
# $ crystal examples/exports_function.cr
# ```
#
# Ready?

# Let's declare the Wasm module with the text representation.
wat = <<-WAT
(module
(type $sum_t (func (param i32 i32) (result i32)))
(func $sum_f (type $sum_t) (param $x i32) (param $y i32) (result i32)
  local.get $x
  local.get $y
  i32.add)
(export "sum" (func $sum_f)))
WAT

# Create a store
store = Wasmer.default_engine.new_store

# Let's compile the Wasm module
module_ = Wasmer.module(store, wat)

# Let's instantiate the module
instance = Wasmer.new_instance(module_)

# Here we go.
#
# An `Instance` has an `exports` getter, which returns the same
# `Exports` object (per `Instance`). It will return either a `Function`, a
# `Memory`, a `Global` or a `Table`.
#
# Let's call the `sum` function with 1 and 2.

# calling below method is same as `result = instance.exports.function("sum").not_nil!.call(1,2)`
result = instance.function("sum").not_nil!.call(1, 2)
assert { result == 3 }

# But this is not always ideal. Keep in mind that a `Function` object
# is created everytime you call `Exports#function`. Hence the
# following solution to store the function inside a variable.
sum = instance.function("sum").not_nil!

# We use the `.call(args)` notation to call the function.
results = sum.call(1, 2)

# Did you notice something? We didn't cast the Crystal values
# (arguments of `sum`) to WebAssembly values. It's done automatically!
#
# Same for the results. It's casted to Crystal values automatically.

assert { results == 3 }

# How cool is that :-)?
