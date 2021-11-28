require "./prelude"
# A Wasm module can export entities, like functions, memories, globals
# and tables.
#
# This example illustrates how to use exported globals. They come in 2
# flavors:
#
#   1. Immutable globals (const),
#   2. Mutable globals.
#
# You can run the example directly by executing in Wasmer root:#
#
# ```shell
# $ crystal examples/exports_global.cr
# ```
#
# Ready?

# Let's declare the Wasm module with the text representation.
wat = <<-WAT
(module
    (global $one (export "one") f32 (f32.const 1))
    (global $some (export "some") (mut f32) (f32.const 0))
    (func (export "get_one") (result f32) (global.get $one))
    (func (export "get_some") (result f32) (global.get $some))
    (func (export "set_some") (param f32) (global.set $some (local.get 0))))
WAT

# Create a store
store = Wasmer.default_engine.new_store

# Let's compile the Wasm module
module_ = Wasmer.module(store, wat)

# Let's instantiate the module
instance = Wasmer.new_instance(module_)

# Here we go.
#
# The Wasm module exports some globals. Let's get them.
one = instance.global("one").not_nil!
some = instance.global("some").not_nil!

assert { one.is_a?(Wasmer::Global) }
assert { some.is_a?(Wasmer::Global) }

one_type = one.type
assert { one_type.value_type.kind == Wasmer::F32 }
assert { one_type.mutable? == false }

some_type = some.type
assert { some_type.value_type.kind == Wasmer::F32 }
assert { some_type.mutable? == true }

# Getting the values of globals can be done in two ways:
#
# 1. Through an exported function,
# 2. Using the Global API directly.
#
# We will use an exported function for the `one` global and the Global
# API for `some`.
get_one = instance.function("get_one").not_nil!

one_value = get_one.call
some_value = some.value

assert { one_value == 1.0 }
assert { one.value == 1.0 }
assert { some_value == 0.0 }

# Trying to set the value of a immutable global (`const`) will result
# in an exception.
begin
  one.value = 42.0
rescue e : Wasmer::WasmerError
  assert { e.message == "The global variable is not mutable, cannot set a new value" }
else
  assert { false }
end

# Setting the values of globals can be done in two ways:
#
# 1. Through an exported function,
# 2. Using the Global API directly.
#
# We will use both for the `some` global.
instance.function("set_some").not_nil!.call(21.0_f32)
assert { some.value == 21.0_f32 }

some.value = 42.0_f32
assert { some.value == 42.0_f32 }
