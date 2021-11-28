require "./prelude"
# Defining an engine in Wasmer is one of the fundamental steps.
#
# Wasmer comes with few engines, to check if one particular engine is available
# use `Wasmer::EngineKind#available?`.
#
# An engine applies roughly 2 steps:
#
#   1. It compiles the Wasm module bytes to executable code, through
#      the intervention of a compiler,
#   2. It stores the executable code somewhere.
#
# In the particular context of the JIT engine, the executable code
# is stored in memory.
#
# You can run the example directly by executing in folder root:
#
# ```shell
# $ crystal examples/engine_jit.cr
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

# Let's iterate through Engines and check their availability
Wasmer::EngineKind.each do |engine|
  puts "Engine: #{engine} , Available: #{engine.available?}"
end

# Let's just use universal engine
engine = Wasmer.universal_engine
# Create a store
store = Wasmer::Store.new(engine)

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
