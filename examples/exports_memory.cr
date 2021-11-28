require "./prelude"
# A Wasm module can export entities, like functions, memories,
# globals and tables.
#
# This example illustrates how to use exported memories.
#
# You can run the example directly by executing in Wasmer root:
#
# ```shell
# $ crystal examples/exports_memory.cr
# ```
#
# Ready?

# Let's declare the Wasm module with the text representation.
# If this module was written in Rust, it would have been:
#
# ```rs
# #[no_mangle]
# pub extern fn hello() -> *const u8 {
#     b"Hello, World!\0".as_ptr()
# }
# ```
wat = <<-WAT
  (module
    (type $hello_t (func (result i32)))
    (func $hello (type $hello_t) (result i32)
        i32.const 42)
    (memory $memory 1)
    (export "hello" (func $hello))
    (export "mem" (memory $memory))
    (data (i32.const 42) "Hello, World!"))
WAT

# Create a store
store = Wasmer.default_engine.new_store

# Let's compile the Wasm module
module_ = Wasmer.module(store, wat)

# Let's instantiate the module
instance = Wasmer.new_instance(module_)

# OK, here go. First, let's call `hello`. It returns a pointer to the
# string in memory.
pointer = instance.function("hello").not_nil!.call

# Since the pointer is a constant here, it's easy to assert its value.
assert { pointer == 42 }

# Now let's read the string. It lives in memory. Usually the main
# memory is named `memory`, but the sake of not being simple, the
# memory is named `mem` in our case.
memory = instance.memory("mem").not_nil!

# See, it's a `Memory`!
assert { memory.is_a?(Wasmer::Memory) }

# Next, read it. Memory provides `view` helper method, which provides a
# view (Slice) starting from the offset provided as its argument
reader = memory.view(pointer.as(Int32))

# Go read. We know `Hello, World!` is 13 bytes long.
#
# Don't forget that we read bytes. We need to decode them!
returned_string = String.new(reader[...13])
p! returned_string

assert { returned_string == "Hello, World!" }

# Yeah B-)!
