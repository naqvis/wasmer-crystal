require "../prelude"

# Let's define the engine, that holds the compiler.
engine = Wasmer::Engine.new

# Let's define the store, that holds the engine, that holds the compiler.
store = Wasmer::Store.new(engine)

# Above two lines are same as invoking below helper method
# store = Wasmer.default_engine.new_store

# Let's compile the module to be able to execute it!
module_ = Wasmer::Module.new(store, File.read("#{__DIR__}/simple.wasm"))

# Now the module is compiled, we can instantiate it.
instance = Wasmer::Instance.new(module_)

# get the exported `sum` function
# function methods returns nil if it can't find the requested function. we know its there, so let's add `not_nil!`
sum = instance.function("sum").not_nil!

# Call the exported `sum` function with Crystal standard values. The WebAssembly
# types are inferred and values are casted automatically.
result = sum.call(5, 37)

puts result # => 42
