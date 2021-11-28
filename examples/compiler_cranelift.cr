require "./prelude"
# A Wasm module can be compiled with multiple compilers.
#
# Cranelift is set byu default.
# You can check available compilers by invoking `Wasmer::CompilerKind#available?`
#
# You can run the example directly by executing in Wasmer root:
#
# ```shell
# $ crystal examples/compiler_cranelift.cr
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

# Creates a config and set engine and compiler options
config = Wasmer::Config.new

# Let's iterate through Compilers and check their availability
Wasmer::CompilerKind.each do |compiler|
  puts "Compiler: #{compiler} , Available: #{compiler.available?}"
end

# Let's jsut settle down to Cranelift compiler for this example. Below method
# will raise if Cranelift compiler is not available in this bindings.
config.use_cranelift_compiler

# Let's create an engine with our selected compiler
engine = Wasmer.engine(config)

# Create a store, that holds the engine, that holds the compiler.
store = engine.new_store

# Here we go.
#
# Let's compile the Wasm module. It is at this step that the Wasm text
# is transformed into Wasm bytes (if necessary), and then compiled to
# executable code by the compiler, which is then stored in memory by
# the engine.
module_ = Wasmer.module(store, wat)

# Congrats, the Wasm module is compiled! Now let's execute it for the
# sake of having a complete example.
#
# Let's instantiate the Wasm module.
instance = Wasmer.new_instance(module_)

# The Wasm module exports a function called `sum`.
sum = instance.function("sum").not_nil!

results = sum.call(1, 2)
puts "1 + 2 = #{results}"

assert { results == 3 }
